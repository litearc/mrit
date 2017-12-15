function m = repips(e, r, k, varargin)
  %
  %  this function is a wrapper around repi, calling it for each slice in the
  %  input data. this is cpu-inefficient, but substantially reduces the memory
  %  load, so may be useful for large datasets.
  %
  %  function m = repips(e, r, k, varargin)
  %
  %  inputs ....................................................................
  %  e                a cell array, used to load slice data. the 1st element
  %                   is a handle to a function with 1st argument the slice #
  %                   to load. any remaining elements in the cell array are
  %                   also passed to the function. the function should return
  %                   the slice data [reads views coils 1 frames].
  %  r                EPI reference data, i.e. with phase-encodes turned off.
  %                   [reads views coils slices frames] (complex)
  %  k                k-space locations for odd phase-encodes. for the even
  %                   phase-encodes, the locations are flipped, and shifted to
  %                   start at k(end). (vector) (a.u.)
  %
  %  options ...................................................................
  %  the options for `repips.m` are identical to those for `repi.m`, and are
  %  simply passed along to `repi.m`.
  %
  %  outputs ...................................................................
  %  m                reconstructed image. [x y z time]
  %

  % set default arguments
  v = ap2s(varargin);
  acs      = def(v, 'acs', []);
  B0map    = def(v, 'B0map', []);
  coilmaps = def(v, 'coilmaps', []);
  es       = def(v, 'es', []);
  f        = def(v, 'f', []);
  fdc      = def(v, 'fdc', 0);
  l        = def(v, 'l', []);
  nx       = def(v, 'nx', []);
  osf      = def(v, 'osf', 3);
  out      = def(v, 'out', 'm');
  tell     = def(v, 'tell', 1);
  use_mex  = def(v, 'mex', 1);
  
  if tell, fprintf('repips: initializing ...\n'); end

  % to get # time-frames, load one slice of `e` (ugh, not very efficient)
  nt = size(e{1}(1,e{2:end}), 5);
  [np,nv,nc,ns,~] = size(r);

  % if GRAPPA calibration data provided, make grid size equal along x
  if ~isempty(f), nx = size(f,1); end
  if ~isempty(B0map), nx = size(B0map,1); end
  
  % if 'nx' not specified, calculated based on fov and res
  if isempty(nx)
    fov = 1/max(abs(diff(k)));
    res = .5/max(abs(k));
    nx = round(fov/res);
  end

  % calculate 'ny'
  ny = nv;
  if ~isempty(f), ny = size(f,2); end
  if ~isempty(B0map), ny = size(B0map,2); end
  if ~isempty(coilmaps), ny = size(coilmaps,2); end

  % allocate output array
  if strcmp(out,'m')
    m = zeros(nx,ny,ns,nt);
    pps = nx*ny*nt;
  else % out == 'k'
    m = zeros(nx,ny,nc,ns,nt);
    pps = nx*ny*nc*nt;
  end
 
  nchar = [];

  % reconstruct slice by slice
  for is = 1:ns
    % show progress (slice number)
    if tell
      str = sprintf('progress : is = %d', is);
      if ~isempty(nchar)
        fprintf(repmat('\b', [1, nchar]));
        if nchar > length(str), str = strpad(str, nchar-length(str)); end
        end
        nchar = fprintf(str);
        fprintf('\r');
    end

    e_ = e{1}(is,e{2:end});
    r_ = r(:,:,:,is,:);
    if isempty(f), f_ = []; else f_ = f(:,:,:,is,:); end
    if isempty(B0map), B0map_ = []; else B0map_ = B0map(:,:,:,is,:); end
    if isempty(coilmaps), coilmaps_ = []; else coilmaps_ = coilmaps(:,:,is,:); end
    ii = pps*(is-1)+[1:pps];
    % reconstruct slice (turn tell off and handle text display here)
    m(ii) = repi(e_, r_, k, 'acs', acs, 'B0map', B0map_, 'coilmaps', coilmaps_, ...
      'es', es, 'f', f_, 'fdc', fdc, 'l', l, 'nx', nx, 'osf', osf, 'out', out, ...
      'tell', 0, 'use_mex', use_mex);
  end

  % exit out of carriage-return
  if tell, fprintf('\n'); end

end

