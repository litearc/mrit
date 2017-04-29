function [rf, g, i] = rfepi(dx, dy, tbx, tby, repy, varargin)
  %
  %  creates an epi rf pulse to excite a rectangular region.
  %
  %  function [rf, g] = rfepi(dx, dy, tbx, tby, repy, varargin)
  %
  %  inputs ....................................................................
  %  dx               width of response along x. (cm)
  %  dy               width of response along y. (cm)
  %  tbx              time-bandwidth along x. (float)
  %  tby              time-bandwidth along y. (float)
  %  repy             position of replicate along y. (cm)
  %
  %  options ...................................................................
  %  gm               max gradient amplitude. (G/cm) (default = 4)
  %  sm               max slew-rate. (G/cm/ms) (default = 15)
  %  dt               sample time. (ms) (default = .004)
  %  gam              gyromagnetic ratio. (kHz/G) (default = 4.258)
  %  fa               flip angle. (rad) (default = pi/2)
  %    
  %  output ....................................................................
  %  rf               rf pulse. (G) (complex)
  %  g                gradient waveform matrix. [points (x,y)] (G/cm)
  %  i                info struct.
  %

  [gm, sm, dt, gam, fa] = setopts(varargin, {'gm', 4, 'sm', 15, 'dt', .004, ...
    'gam', 4.258, 'fa', pi/2});

  % epi gradient
  nl = round(tby/dy*repy)+1; % total # lines.
  [g i] = gepi(.5*tbx/dx, .5*tby/dy, nl, 'gm', gm, 'sm', sm, 'dt', dt, 'gam', gam);
  
  % rf pulse
  gtrap = g(ran(i.itrap),1);
  rfs = vec([verse(gtrap, wsinc(i.ltrap,tbx)); zeros(i.lblip,1)]);
  rfe = wsinc(nl, tby);
  rf = rfs*rfe;
  rf = vec([zeros(1,i.ldep) rf(1:end-i.lblip) zeros(1,i.ldep)]);
  rf = rf/sum(rf)*fa/(2*pi*gam*dt);

end

