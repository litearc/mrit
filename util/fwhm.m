function [w, o] = fwhm(x, y, varargin)
  %
  %  calculates the full-width at half-max of a function y(x). specifically,
  %  this finds the peak and then looks for where the function drops to half
  %  this value on both the left and right side. the width is defined as the
  %  distance between these intersection points.
  %
  %  function [w, o] = fwhm(x, y, varargin)
  %
  %  inputs ....................................................................
  %  x                x-axis values. (vector)
  %  y                function values. (vector)
  %
  %  options ...................................................................
  %  fmax             fraction of max to find width at. (float) (default = 0.5)
  %  zbl              subtract minimum value to set baseline to zero? <0, 1>
  %                   (default = 0)
  %
  %  outputs ...................................................................
  %  w                width at half-max (or fraction of max specified). (float)
  %  o                x-position halfway between left and right intersections.
  %                   (float)
  %

  % set default arguments
  v = ap2s(varargin);
  fmax = def(v, 'fmax', .5);
  zbl  = def(v, 'zbl', 0);
  
  if isvector(y) && length(y) == size(y,2), y = y(:); end
  if isvector(x) && length(x) == size(x,2), x = x(:); end
  if isempty(x), x = [1:size(y,1)]'; end

  if zbl, y = abs(y-min(y)); end
  [ys, ii] = max(y);
  h = fmax*ys; % threshold

  % left intersection
  for i = 1:length(y)
    if ii-i < 1, error('curve is too close to edge!'); end
    if y(ii-i) < h
      s = (y(ii-i+1)-y(ii-i))/(x(ii-i+1)-x(ii-i));
      xa = x(ii-i+1)-(y(ii-i+1)-h)/s;
      break;
    end
  end

  % right intersection
  for i = 1:length(y)
    if ii+i > length(y), error('curve is too close to edge!'); end
    if y(ii+i) < h
      s = (y(ii+i-1)-y(ii+i))/(x(ii+i-1)-x(ii+i));
      xb = x(ii+i-1)+(y(ii+i-1)-h)/s;
      break;
    end
  end

  w = xb-xa;
  o = (xa+xb)/2;

end

