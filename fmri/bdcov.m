function y = bdcov(n, p, tr, varargin)
  %
  %  creates a stimulus covariate by convolving a block-design with a standard
  %  hemodynamic response function.
  %
  %  function o = bdcov(n, p, tr)
  %
  %  inputs ....................................................................
  %  n                # points. (int)
  %  p                block size. (int)
  %  tr               repetition time. (s) (float)
  %
  %  options ...................................................................
  %  beg              beginning block. <0:off, 1:on> (default = 0)
  %
  %  outputs ...................................................................
  %  y                covariate time-series. (vector)
  %
  %  originally written by Gary Glover.
  %

  [beg] = setopts(varargin, {'beg', 0});

  n1 = 5.0; t1 = 1.1; n2 = 12.0; t2 = 0.9; a2 = 0.4; nh = 30;
  tt = 1:nh;
  h1 = tt.^n1.*exp(-tt/t1);
  h2 = tt.^n2.*exp(-tt/t2);
  hin = h1/max(h1) - a2*h2/max(h2);
  hin = hin/max(hin);

  tdur = tr*p;
  T = 2*tdur;
  ncycles = n/p/2;

  t = (1:ncycles*T);
  h = [hin zeros(1, ncycles*T-nh)];

  sq = zeros(1,T);
  if beg == 1
    sq(1:tdur) = ones(1,tdur); 
  else
    sq(tdur+1:end) = ones(1,tdur); 
  end
  excit = sq;
  for j = 2:ncycles
    excit = [excit sq];
  end	

  y = conv(excit, h);
  y = y(1:ncycles*T); 
  xi = linspace(1, length(y), n);
  y = interp1(1:length(y), y, xi);
  y = y(:);

end

