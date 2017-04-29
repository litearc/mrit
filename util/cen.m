function o = cen(n, N)
  %
  %  returns the indices for the center 'n' of 'N' elements.
  %
  %  function o = cen(n, N)
  %
  %  inputs ....................................................................
  %  n                # center elements. (int)
  %  N                # total elements. (int)
  %
  %  outputs ...................................................................
  %  o                center indices. (vector)
  %

  o = N/2 + [-n/2+1:n/2];

end

