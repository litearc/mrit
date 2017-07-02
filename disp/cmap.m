function o = cmap(m, cm, varargin)
  %
  %  takes an image and maps its values to a colormap.
  %
  %  function o = cmap(m, cm, varargin)
  %
  %  inputs ....................................................................
  %  m                image (can be multi-dimensional). [x y ...]
  %  cm               colormap. [colors (red, green, blue)]
  %
  %  options ...................................................................
  %  clim             color limits. (2-vector) (default = [min(m(:)) max(m(:))])
  %
  %  outputs ...................................................................
  %  o                mapped image. [x y (red, green, blue) ...].
  %

  % set default arguments
  v = ap2s(varargin);
  clim = def(v, 'clim', []);

  if isempty(clim)
    [cmin, cmax] = lims(m);
  else
    cmin = clim(1);
    cmax = clim(2);
  end

  % scales from 0 to 1
  scl = @(x) (x-cmin)/(cmax-cmin);

  % returns RGB value in colormap from an index
  % function [Ri,Gi,Bi] = mapcol(mci)
  %   Ri = cm(mci, 1);
  %   Gi = cm(mci, 2);
  %   Bi = cm(mci, 3);
  % end

  % creates space for 3rd dimension, which will contain RGB values
  ndim = length(size(m));
  m = permute(m, [1 2 ndim+1 3:ndim]);

  % map intensity values to color indices
  nc = size(cm, 1);
  mc = max(min(round((nc-1)*scl(m))+1,nc),1);

  % get RGB values
  % [R,G,B] = arrayfun(@mapcol, mc); % too slow
  s = size(mc);
  R = zeros(s); G = zeros(s); B = zeros(s);
  for i = 1:numel(R)
    R(i) = cm(mc(i), 1);
    G(i) = cm(mc(i), 2);
    B(i) = cm(mc(i), 3);
  end

  % put RGB values together
  o = cat(3, R, G, B);

end

