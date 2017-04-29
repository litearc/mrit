function o = gridepi(r, k, varargin)
  %
  %  grids ramp-sampled EPI data.
  %
  %  function o = gridepi(r, k, varargin)
  %
  %  inputs ....................................................................
  %  r                EPI raw data. [reads views coils slices] (complex)
  %  k                k-space locations for odd phase-encodes. for the even
  %                   phase-encodes, the locations are flipped, and shifted to
  %                   start at k(end). (vector) (a.u.)
  %
  %  options ...................................................................
  %  nx               # of grid points along readout direction. (number)
  %                   (default = estimate from k-space points)
  %  flyback          flyback EPI? (0 or 1) (default = 0)
  %  
  %  outputs ...................................................................
  %  o                EPI gridded data. [x y z]
  %

  [nx, flyback] = setopts(varargin, {'nx', [], 'flyback', 0});

  [np,nv,nc,ns] = size(r);
  
  % k-space positions for odd/even lines
  ko = k;
  if flyback, ke = ko; else ke = -k+k(1)+k(end); end
  
  % density compensation
  w = zeros(np,1);
  for i = 2:np-1
    w(i) = abs((ko(i+1)-ko(i-1))/2);
  end
  w(1) = w(2); w(end) = w(end-1);

  % if 'nx' not specified, calculated based on fov and res
  if isempty(nx)
    fov = 1/max(abs(diff(k)));
    res = .5/max(abs(k));
    nx = round(fov/res);
  end

  o = zeros(nx, nv, nc, ns); % output array

  % grid data each slice, view, coil
  for is = 1:ns
    for iv = 1:nv/2
      for ic = 1:nc
        o(:,2*iv-1,ic,is) = ifftc(nufft1(r(:,2*iv-1,ic,is).*w, ko, nx));
        o(:,2*iv,ic,is) = ifftc(nufft1(r(:,2*iv,ic,is).*w, ke, nx));
      end
    end
  end

end

