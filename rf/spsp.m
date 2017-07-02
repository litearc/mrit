function [rf g i] = spsp(dx, df, tbx, tbf, repf, varargin)
  %
  %  creates a spatial-spectral (spsp) rf pulse.
  %
  %  function [rf i] = spsp(dx, bw, tbx, tbf, rep, varargin)
  %
  %  inputs ....................................................................
  %  dx               width of response along x. (cm)
  %  df               bandwidth of frequency response. (kHz)
  %  tbx              time-bandwidth along x. (float)
  %  tby              time-bandwidth along frequency. (float)
  %  repf             position of replicate along frequency. (kHz)
  %
  %  options ...................................................................
  %  gm               max gradient amplitude. (G/cm) (default = 4)
  %  sm               max slew-rate. (G/cm/ms) (default = 15)
  %  dt               sample time. (ms) (default = .004)
  %  gam              gyromagnetic ratio. (kHz/G) (default = 4.258)
  %  fa               flip angle. (rad) (default = pi/2)
  %  flyback          use flyback trajectory? this increases the pulse length
  %                   but avoids the opposed null patterns. <0, 1>
  %                   (default = 1)
  %    
  %  output ....................................................................
  %  rf               rf pulse. (G) (complex)
  %  g                gradient waveform matrix. (vector) (G/cm)
  %  i                info struct.
  %

  % set default arguments
  v = ap2s(varargin);
  dt      = def(v, 'dt', .004);
  fa      = def(v, 'fa', pi/2);
  flyback = def(v, 'flyback', 1);
  gam     = def(v, 'gam', 4.258);
  gm      = def(v, 'gm', 4);
  sm      = def(v, 'sm', 15);

  if flyback

    % flyback and readout gradients
    gfb = -gtrap(gm, sm, 'area', tbx/dx, 'gam', gam, 'dt', dt);

    g1 = gtrap(gm, sm, 'area', tbx/dx, 'len', 1/repf-dt*length(gfb), ...
      'gam', gam', 'dt', dt);

    nfb = length(gfb);
    n1 = length(g1);
    
    % repeat gradient
    g = [];
    nl = round(tbf/df*repf)+1; % total # lines.
    for i = 1:nl-1, g = [g g1 gfb]; end
    g = [g g1];

    % rephaser
    g = vec([g -g1/2]);

    % rf pulse
    rfs = vec(verse(g1, wsinc(n1,tbx)));
    rfs = [rfs; zeros(nfb,1)];
    rfe = wsinc(nl, tbf);
    rf = vec(rfs*rfe);
    rf(length(g)) = 0; % make rf and g same length
    rf = rf/sum(rf)*fa/(2*pi*gam*dt);

  else

    % readout gradient
    g1 = gtrap(gm, sm, 'area', tbx/dx, 'len', 1/repf, 'gam', gam', 'dt', dt);
    n1 = length(g1);

    % repeat gradient
    g = [];
    nl = round(tbf/df*repf)+1; % total # lines.
    for i = 1:nl, g = [g (-1)^(i-1)*g1]; end

    % rephaser
    g = vec([g (-1)^(mod(nl,2))*g1/2]);

    % rf pulse
    rfs = vec(verse(g1, wsinc(n1,tbx)));
    rfe = wsinc(nl, tbf);
    rf = vec(rfs*rfe);
    rf(length(g)) = 0; % make rf and g same length
    rf = rf/sum(rf)*fa/(2*pi*gam*dt);
  
  end

end
