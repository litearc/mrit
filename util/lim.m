function m = lim(m, th, varargin)
  %
  %  caps the values of the array above and/or below some percentile.
  %
  %  function o = cap(m, th, varargin)
  %
  %  inputs ....................................................................
  %  m                input array. (N-D array)
  %  th               fractions at which to cap values. [low high]
  %                   values < `low' are set to `low'
  %                   values > `high' are set to `high'
  %                   set element to nan if you don't want to cap at that end.
  %
  %  outputs ...................................................................
  %  m                capped array. (N-D array)
  %

  a = abs(m);
  [h,x] = hist(a(:), 1000);
  cs = cumsum(h);
  ss = sum(h);

  % lower limit
  if ~isnan(l(1)
    for i = 1:length(cs)
      if cs(i)/ss >= l(1), break; end
    end
    m(a<x(i)) = x(i);
  end

  % upper limit
  if ~isnan(l(2))
    for i = 1:length(cs)
      if cs(i)/ss > th, break; end
    end
    m(a>x(i)) = x(i);
  end

end

