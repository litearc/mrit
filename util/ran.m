function o = ran(l, u)
  %
  %  generates a range of indices between the start and end indices. only one
  %  argument may be provided, in which case it is a 2-element vector containing
  %  both the start and end indices.
  %
  %  function o = ran(l, u)
  %
  %  inputs ....................................................................
  %  l                start index (int) or 2-element vector with start and end
  %                   indices. (2-vector)
  %  u                end index. (int)
  %
  %  outputs ...................................................................
  %  o                range of indices. (vector)
  %

  if nargin == 1
    o = l(1):l(end);
  else
    o = l:u;
  end

end

