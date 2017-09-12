function o = cstat(a, b, u, n, varargin)
  %
  %  converts between different stats in an fmri time-series.
  %
  %  function o = cstat(a, b, n, varargin)
  %  
  %  inputs ....................................................................
  %  a                input stat, can be one of the following:
  %                   'p' : p value
  %                   'r' : correlation coefficient
  %                   't' : t score
  %  b                output stat.
  %  u                input stat value. (float)
  %  n                # of time-points. (int)
  %
  %  options ...................................................................
  %  tr               repetition time (s). used to account for auto-correlation
  %                   of the hemodynamic response function.
  %

  % set default arguments
  v = ap2s(varargin);
  tr = def(v, 'tr', inf);

  df = tsdf(n, tr);

  % https://afni.nimh.nih.gov/sscc/gangc/tr.html
  function r = t2r(t)
    r = t.*sqrt(1./(t.^2+df));
  end

  function t = r2t(r)
    t = r.*sqrt(df./(1-r.^2));
  end

  function p = t2p(t)
    p = .5-abs(tcdf(t,df)-.5); % two-tailed
  end

  switch [a b]
    case 'pr'
      o = t2r(tinv(u,df));
    case 'pt'
      o = abs(tinv(u,df));
    case 'rp'
      o = t2p(r2t(u));
    case 'rt'
      o = r2t(u);
    case 'tp'
      o = t2p(u);
    case 'tr'
      o = t2r(u);
  end

end

