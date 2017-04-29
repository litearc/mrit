function g = gtrap(a, s, varargin)
  %
  %  creates a trapezoidal gradient. depending on the inputs, this does
  %  different things. if the length 'len' is specified, it maximizes the area
  %  for the given length. if the area 'area' is specified, it creates the
  %  minimum-length trapezoid with that area. if the both length and area are
  %  specified, it creates a trapezoid with the given length and area, if
  %  possible. at least one of the inputs (length or area) must be specified.
  %
  %  the length is specified in time units, so the # points depends on the
  %  sample time. the area is specified in k-space units, so depends on the
  %  gyromagnetic ratio 'gam', set for proton by default.
  %
  %  inputs ....................................................................
  %  a                maximum gradient amplitude. (G/cm)
  %  s                maximum slew rate. (G/cm/ms)
  %
  %  options ...................................................................
  %  len              duration of trapezoid. (ms)
  %  area             area of trapezoid. (1/cm)
  %  dt               sample time. (ms) (default = .004)
  %  gam              gyromagnetic ratio. (kHz/G) (default = 4.258)
  %
  %  outputs ...................................................................
  %  g                trapezoidal gradient. (G/cm)
  %

  [len, area, dt, gam] = setopts(varargin, {'len', 0, 'area', 0, 'dt', .004, ...
    'gam', 4.258});

  g = trap(a, s*dt, 'len', round(len/dt), 'area', area/(gam*dt));

end

