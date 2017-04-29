function m = repi(e, r, k, varargin)
  %
  %  reconstructs ramp-sampled EPI data. performs phase-correction using a
  %  reference scan, with options for off-resonance correction and GRAPPA
  %  acceleration.
  %
  %  sources:
  %  - 1D phase correction method: Bruder H, Fisher H, Reinfelder HE Schmitt F.
  %    Image reconstruction for EPI with non- equidistant k-space sampling.
  %    Magn Reson Med 1992; 23:311–323.
  %  - 2D phase correction method: Chen NK, Wyrwicz AM. Removal of EPI Nyquist
  %    ghost artifacts with two-dimensional phase correction. Magn Reson Med
  %    2004;51:1247-1253.
  %
  %  function m = repi(e, r, k, varargin)
  %
  %  inputs ....................................................................
  %  e                EPI raw data. [reads views coils slices frames] (complex)
  %  r                EPI reference data, i.e. with phase-encodes turned off.
  %                   [reads views coils slices frames] (complex)
  %  k                k-space locations for odd phase-encodes. for the even
  %                   phase-encodes, the locations are flipped, and shifted to
  %                   start at k(end). (vector) (a.u.)
  %
  %  options ...................................................................
  %  nx               # of grid points along readout direction. (number)
  %                   (default = estimate from k-space points)
  %  out              type of data to output. ('k': k-space, 'm': image)
  %                   (default = 'm')
  %  l                binary vector specifying sampled lines. the length must
  %                   equal the # of views in the raw data. this is only needed
  %                   for GRAPPA acceleration. (vector)
  %  f                fully-sampled k-space region for calculating GRAPPA
  %                   coefficients. the region must be large enough to estimate
  %                   the necessary coefficients for the subsampled EPI data.
  %                   this must contain the same # of points, views, coils, and
  %                   slices as the raw data, but may contain either one frame,
  %                   in which case one set of coefficients is applied for all
  %                   frames in the raw data, or the same # frames as the raw
  %                   data, in which case a separate set of coefficients are
  %                   applied for each frame. this is only needed for GRAPPA
  %                   acceleration. [reads views coils slices frames] (complex)
  %  acs              indices for fully sampled k-space lines in the raw data,
  %                   used to calculate the GRAPPA coefficients. this is an
  %                   alternative to providing a fully sampled k-space region
  %                   'f', i.e. both options should not be used together.
  %                   (vector)
  %  fdc              do frequency-drift correction? (0 or 1) (default = 1)
  %  tell             display messages? (0 or 1) (default = 0)
  %  B0map            B0 field map. if supplied, will perform B0 correction
  %                   (if possible). the echo-spacing must also be provided.
  %                   (Hz) [x y z]
  %  es               echo-spacing. (ms)
  %
  %  outputs ...................................................................
  %  m                reconstructed image. [x y z time]
  %

  [nx, out, l, f, acs, fdc, tell, B0map, es] = setopts(varargin, {'nx', [], ...
    'out', 'm', 'l', [],  'f', [], 'acs', [], 'fdc', 0, 'tell', 1, ...
    'B0map', [], 'es', []});

  if tell, fprintf('repi: initializing ...\n'); end

  [np,nv,nc,ns,nt] = size(e);
 
  % k-space positions for odd/even lines
  k = k(1:np); % just in case
  ko = k;
  ke = -k+k(1)+k(end);

  % density compensation
  w = zeros(np,1);
  for i = 2:np-1
    w(i) = abs((ko(i+1)-ko(i-1))/2);
  end
  w(1) = w(2); w(end) = w(end-1);

  % if GRAPPA calibration data provided, make grid size equal along x
  if ~isempty(f), nx = size(f,1); end
  if ~isempty(B0map), nx = size(B0map,1); end
  
  % if 'nx' not specified, calculated based on fov and res
  if isempty(nx)
    fov = 1/max(abs(diff(k)));
    res = .5/max(abs(k));
    nx = round(fov/res);
  end
  hx = round(nx/2); % mid-point
  x = [1:nx]';
   
  % output arrays
  m = zeros(nx,nv,ns,nt);
  o = zeros(nx,nv,nc,ns,nt);

  % identify coil with most signal - used for frequency-drift correction
  [~,icmax] = max(sum(reshape(permute(abs(r(:,:,:,:,1)),[1,2,4,3]),[],nc),1));
  ipmax = round(nx/2);
  % [~,ipmax] = max(abs(r(:,1,icmax,1)));

  nchar = [];

  % first, we correct for phase-errors between the odd and even lines, using one
  % of two methods:
  %   - a 1D method, in which the phase-encodes are turned off in a reference
  %     scan, and each even line is phase-matched to the previous odd line
  %   - a 2D method, in which a separate scan where the readout direction is
  %     reversed in each line, and a phase map is calculated to correct for the
  %     phase difference in the even-echo images between the normal and reversed
  %     readout images. (see Chen 2004, Magn Reson Med 51:1247–1253)

  % figure out phase-correction method from # frames in reference scan
  switch size(r,5)
    case 1, pcm = 1;
    case 2, pcm = 2;
  end

  % 1D phase correction ........................................................
  if pcm == 1

    % each slice has a separate set of phase coefficients
    for is = 1:ns
      % calculate 1st-order polynomial coefficients
      p = zeros(nv/2, 2); % corrects odd/even errors
      a = zeros(nv/2, 1); % corrects for freq drift, e.g. from off-resonance
      mm = zeros(nx, nc);
      ee = zeros(nx, nc);
      for iv = 1:nv/2
        for ic = 1:nc
          od = nufft1(r(:,2*iv-1,ic,is).*w, ko, nx);
          ed = nufft1(r(:,2*iv,ic,is).*w, ke, nx);
          mm(:,ic) = od;
          ee(:,ic) = unwrap(angle(od)-angle(ed));
          ee(:,ic) = ee(:,ic)-round(ee(hx,ic)/(2*pi))*2*pi;
        end
        ss = sqrt(sum(abs(mm).^2,2));
        s = mask(ss);
        y = median(ee, 2);
        p(iv,:) = pfit(x(s), y(s), 1, 'w', ss(s))';
        a(iv) = angle(mm(ipmax,icmax));
      end
      b = pfit(1:nv/2, unwrap(a), 1);

      % apply linear phase to even readouts
      for it = 1:nt
        if tell
          str = sprintf('phase-correction : is = %d, it = %d', is, it);
          if ~isempty(nchar)
            fprintf(repmat('\b', [1, nchar]));
            if nchar > length(str), str = strpad(str, nchar-length(str)); end
          end
          nchar = fprintf(str);
          fprintf('\r');
        end
        for ic = 1:nc
          for iv = 1:nv/2
            od = nufft1(e(:,2*iv-1,ic,is,it).*w, ko, nx);
            ed = nufft1(e(:,2*iv,ic,is,it).*w, ke, nx);
            % apply linear correction
            ed = ed.*exp(1i*(p(iv,1)*x+p(iv,2)));
            % apply frequency drift correction
            if fdc
              od = od.*exp(-1i*(b(1)*iv+b(2)));
              ed = ed.*exp(-1i*(b(1)*iv+b(2)));
            end
            % fill into data array
            o(:,2*iv-1,ic,is,it) = vec(ifftc(od));
            o(:,2*iv,ic,is,it) = vec(ifftc(ed));
          end
        end
      end
    end
  
  end % ........................................................................

  % 2D phase correction ........................................................
  if pcm == 2

    for is = 1:ns

      % readout in -> direction
      r1 = zeros(np, nv, nc);
      r1(:,1:2:end,:) = r(:,1:2:end,:,is,1);
      r1(:,2:2:end,:) = r(:,2:2:end,:,is,2);
      r1 = gridepi(r1, ko, 'flyback', 1, 'nx', nx);

      % readout in <- direction
      r2 = zeros(np, nv, nc);
      r2(:,1:2:end,:) = r(:,1:2:end,:,is,2);
      r2(:,2:2:end,:) = r(:,2:2:end,:,is,1);
      r2 = gridepi(r2, ke, 'flyback', 1, 'nx', nx);
      
      % even-echo images
      m1e = zeros(nx,nv,nc);
      m1e(:,2:2:end,:) = r1(:,2:2:end,:);
      m1e = dft2(m1e, 'comb', 'no');
      m2e = zeros(nx,nv,nc);
      m2e(:,2:2:end,:) = r2(:,2:2:end,:);
      m2e = dft2(m2e, 'comb', 'no');

      % get phase correction map
      dphi = angle(m1e./m2e);

      for it = 1:nt
        if tell
          str = sprintf('phase-correction : is = %d, it = %d', is, it);
          if ~isempty(nchar)
            fprintf(repmat('\b', [1, nchar]));
            if nchar > length(str), str = strpad(str, nchar-length(str)); end
          end
          nchar = fprintf(str);
          fprintf('\r');
        end

        % get odd and even echo images from EPI data
        eg = gridepi(e(:,:,:,is,it), ko, 'nx', nx);
        mo = zeros(nx,nv,nc);
        mo(:,1:2:end,:) = eg(:,1:2:end,:);
        mo = dft2(mo, 'comb', 'no');
        me = zeros(nx,nv,nc);
        me(:,2:2:end,:) = eg(:,2:2:end,:);
        me = dft2(me, 'comb', 'no');

        % apply phase correction to even echo image
        me = me.*exp(1i*dphi);
        ms = mo+me;
        m(:,:,is,it) = sqrt(sum(abs(ms).^2,3));
        o(:,:,:,is,it) = dft2(ms, 'comb', 'no', 'dir', 'fwd');
      end
    end

  end % ........................................................................

  % exit out of carriage-return
  if tell, fprintf('\n'); end

  % GRAPPA
  if ~isempty(l)
    if ~isempty(f), o = grap2dft(o, l, f, 'out', 'k', 'tell', tell); end
    if ~isempty(acs), o = grap2dft(o, l, o(:,acs,:,:,:), 'out', 'k', 'tell', tell); end
  end

  % B0 map correction
  if ~isempty(B0map)
    if isempty(l) % epi
      m = epifmc(o, B0map, 'dt', es);
    else % GRAPPA
      i0 = find(~l); i1 = find(l);
      pc = polyfit(i1, 0:length(i1)-1, 1);
      vt = zeros(1,size(o,2)); % view timing
      vt(i0) = pc(1)*i0+pc(2);
      vt(i1) = pc(1)*i1+pc(2);
      vt = vt-vt(1);
      vt = vt*es;
      m = epifmc(o, B0map, 'vt', vt);
    end
    if strcmp(out, 'k')
      m = dft2(m, 'comb', 'no', 'dir', 'fwd');
    else
      m = squeeze(sqrt(sum(abs(m).^2,3)));
    end
    return;
  end
  
  % return requested output
  if strcmp(out, 'k') m = o; end 
  if strcmp(out, 'm') m = dft2(o); end

end

