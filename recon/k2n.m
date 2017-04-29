function n = k2n(k)
  %
  %  based on the k-space sample point locations, this first computes the fov
  %  and resolution, and from that, the # points in the grid (i.e.
  %  fov/resolution).
  %
  %  function n = k2n(k)
  %
  %  inputs ....................................................................
  %  k                k-space sample point locations
  %
  %  outputs ...................................................................
  %  n                # points in the grid
  %

  fov = 1/max(abs(diff(k)));
  res = .5/max(abs(k));
  n = round(fov/res);

end

