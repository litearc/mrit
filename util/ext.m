function o = ext(r, a)
  %
  %  extends a range of values by some factor.
  %
  %  function o = ext(r, a)
  %
  %  inputs ....................................................................
  %  r                input range. (2-vector)
  %  a                scale factor. (float)
  %
  %  outputs ...................................................................
  %  o                scaled range. (2-vector)
  %
  
  o = (r(2)+r(1))/2+(r(2)-r(1))*a/2*[-1 1];

end

