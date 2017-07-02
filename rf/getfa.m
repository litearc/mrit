function o = getfa(rf, varargin)
  %
  %  calculates the flip angle of a complex rf pulse.
  %
  %  function o = getfa(rf)
  %
  %  inputs ....................................................................
  %  rf               rf pulse. (G)
  %
  %  options ...................................................................
  %  dt               sample time. (ms) (default = .004)
  %  gam              gyromagnetic ratio. (kHz/G) (default = 4.258)
  %
  %  outputs ...................................................................
  %  o                flip angle. (rad)
  %

  % set default arguments
  v = ap2s(varargin);
  dt  = def(v, 'dt', .004);
  gam = def(v, 'gam', 4.258);

  rf = rf(:);
  m = bloch(rf, 0*rf, [0 0 1], 'gam', gam, 'dt', dt);
  o = atan2(abs(Mxy(m)), Mz(m));

end

