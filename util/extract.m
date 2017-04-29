function o = extract(x, y, r)
  %
  %  this function extracts the part of y(x) within the range r.
  %
  %  function o = extract(x, y, r)
  %
  %  inputs ....................................................................
  %  x                x-values. (vector)
  %  y                y-values. (vector)
  %  r                range to extract. (2-vector)
  %
  %  outputs ...................................................................
  %  o                extracted part of y. (vector)
  %
  
  di = abs(x-r(1));
  dr = abs(x-r(end));
  [~,ii] = min(di);
  [~,ir] = min(dr);
  o = y(ii:ir);

end

