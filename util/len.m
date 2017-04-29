function o = len(y)
  %
  %  for plotting y (a multi-column input), this returns the # of points. this
  %  is just a convenience function in case y contains only one line to plot and
  %  is given as a row vector instead of a column vector.
  %
  %  inputs ....................................................................
  %  y                input. <(vector), [points plots]> 
  %
  %  outputs ...................................................................
  %  o                # points in plot. (int)
  %

  if isvector(y)
    o = length(y);
  else
    o = size(y,1);
  end

end

