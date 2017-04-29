function o = cbo(m1, m2, dte, varargin)
  %
  %  calculates the B0 field from two complex images and the delta TE.
  %
  %  function o = cbo(m1, m2, dte)
  %
  %  inputs ....................................................................
  %  m1               first echo.
  %  m2               second echo, acquired at the later echo time.
  %  dte              the difference in echo times. (ms)
  %
  %  output ....................................................................
  %  o                B0 map. (Hz)
  %

  % angle
  n1 = m1./abs(m1);
  n2 = m2./abs(m2);
  e = real(log(n2./n1)/1i);
  o = e/(2*pi*dte*1e-3);

end

