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

  [gam, dt] = setopts(varargin, {'gam', 4.258, 'dt', .004});

  rf = rf(:);
  m = bloch(rf, 0*rf, [0 0 1], 'gam', gam, 'dt', dt);
  o = atan2(abs(Mxy(m)), Mz(m));

end

