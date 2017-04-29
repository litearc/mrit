function [l, u] = lims(m)
  %
  %  returns the minimum and maximum values in some array. depending on the
  %  number of output arguments, it either returns a 2-element array with each
  %  value or the two values separately.
  %
  %  function [l, u] = lims(m)
  %
  %  inputs ....................................................................
  %  m                input. (N-D array)
  %
  %  outputs ...................................................................
  %  l                if two output arguments, contains the minimum value
  %                   (float). otherwise, is a 2-element array with the minimum
  %                   and maximum values. (2-vector)
  %  u                maximum value. (float)
  %

  m = m(:); % vectorize

  if nargout == 2
    l = min(m);
    u = max(m);
  else
    l = [min(m) max(m)];
  end

end

