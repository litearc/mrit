function m = epifmc(r, fm, varargin)
  %
  %  performs B0 field-map correction on EPI data that has already been
  %  gridded and phase-corrected.
  %
  %  note: either the echo-spacing 'dt', or view-timing information 'vt' must be
  %  provided.
  %
  %  function m = epifmc(r, fm, varargin)
  %
  %  inputs ....................................................................
  %  r                EPI data. [reads views frames ...]
  %  fm               B0 field map. (Hz) [x y ...]
  %
  %  options ...................................................................
  %  dt               line-to-line timing difference. (number) (ms)
  %  vt               view-timing information. (vector) (ms)
  %
  %  outputs ...................................................................
  %  m                B0-corrected image. [x y ...]                
  %

  [dt, vt, tell, npad] = setopts(varargin, {'dt', [], 'vt', [], 'tell', 0, ...
    'npad', 0});

  if tell, fprintf('epifmc: initializing ...\n'); end
  nchar = [];

  fm = fm*1e-3; % Hz -> kHz 
  [npi,nvi,~] = size(r);
  if npad ~= 0
    r = padarray(r, [0 npad]);
    fm = real(mifftc(padarray(mfftc(fm),[0 npad])));
  end
  [np,nv,nc,nz] = size(r);
  m = zeros(size(r));
  rv = zeros(np,nv);
  mv = zeros(np,nv);
  
  if ~isempty(dt), vt = dt*[0:nv-1]; end

  for iz = 1:nz
    for ic = 1:nc
      if tell
        str = sprintf('B0 correction : is = %d, it = %d', iz, ic);
        if ~isempty(nchar)
          fprintf(repmat('\b', [1, nchar]));
          if nchar > length(str), str = strpad(str, nchar-length(str)); end
        end
        nchar = fprintf(str);
        fprintf('\r');
      end
      for iv = npad+[1:nvi]
        rv(:) = 0; rv(:,iv) = r(:,iv,ic,iz);
        mv = ifftc(rv).*exp(-1i*2*pi*fm(:,:,iz)*vt(iv-npad));
        m(:,:,ic,iz) = m(:,:,ic,iz)+mv;
      end
    end
  end
  m = mresize(m, [npi nvi]);

  % exit out of carriage-return
  if tell, fprintf('\n'); end

end

