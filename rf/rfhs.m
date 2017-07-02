function [rfg, w] = rfhs(mu, b, A0, T, varargin)
  %
  %  designs an adiabatic hyperbolic-secant rf pulse, defined by:
  %    rf(t) = B(t)*exp(1i*w(t))
  %  where
  %    B(t) = A0*sech(b*t)    % amplitude-modulation
  %    w(t) = -mu*b*tanh(b*t) % frequency-modulation
  %
  %  function [rf, w] = rfhs(mu, b, T, varargin)
  %
  %  inputs ....................................................................
  %  mu               mu value. (unitless) (float)
  %  b                beta value. (rad/ms) (float)
  %  A0               B1 scale factor. (rad/ms) (float)
  %  T                adse pulse length. (ms) (float)
  %
  %  options ...................................................................
  %  dt               sample time (ms). (number) (default = .004)
  %
  %  outputs ...................................................................
  %  rfg              rf pulse (G). (vector)
  %

  % set default arguments
  v = ap2s(varargin);
  dt    = def(v, 'dt', .004);
  gam   = def(v, 'gam', 4.258);
  fshow = def(v, 'show', 0);

  t = [-T/2:dt:T/2]';
  n = length(t);
  B = A0*sech(b*t);    % rad/ms
  w = -mu*b*tanh(b*t); % rad/ms
  e = cumsum(w)*dt;
  rf = B.*exp(1i*e);
  rfg = rf/(2*pi*gam); % scale to G

  % display stuff
  if fshow
    % rf pulse trajectory
    figure; fig(30, 5);
    subplot(1,5,1);
    mplot({}, B, w, '\omega_{1}', '\omega_{RF}', 'B1 trajectory');

    % rf pulse
    subplot(1,5,2);
    mplot({}, t, [abs(rfg) real(rfg) imag(rfg)], 't (ms)', 'B_1 (G)', 'rf pulse');

    % effective B1
    subplot(1,5,3);
    Beff = sqrt(B.^2+w.^2);
    mplot({}, t, Beff, 't (ms)', 'B_{eff} (rad/ms)', 'effective B1');

    % angle
    subplot(1,5,4);
    ang = unwrap(atan(w./B));
    mplot({}, t, ang, 't (ms)', '\theta (rad)', 'B1 angle');

    % eta
    subplot(1,5,5);
    eta = Beff./abs(gradient(ang)/dt);
    mplot({}, t, eta, 't (ms)', 'eta');
    title(['min \eta : ' sprintf('%.1f', min(eta(:)))]);
  end

end

