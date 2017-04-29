function o = tsdf(n, tr)
  %
  %  calculates the effective degrees of freedom in a time-series.
  %
  %  function o = tsdf(n, tr)
  %  
  %  inputs ....................................................................
  %  n                # time frames. (int)
  %  tr               repetition time. (s) (float)
  %  
  %  outputs ...................................................................
  %  o                effective # degrees of freedom. (float)
  %

  rho = max(0, 1-tr*.5); % nice approximation for autocorrlation
  o = round((n-2)^2/(n*(1+2*rho*rho)));

end

