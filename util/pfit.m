function p = pfit(x, y, o, varargin)
  %
  %  does a polynomial fit (has more options than matlab's 'polyfit').
  %
  %  function p = pfit(x, y, varargin)
  %
  %  inputs ....................................................................
  %  x                x-values. (vector)
  %  y                y-values. (vector)
  %  o                polynomial order. (int)
  %
  %  options ...................................................................
  %  w                weights for the different points. (default = 1s array)
  %  objf             objective function. <'L2'> (default = 'L2')
  %
  %  outputs ...................................................................
  %  p                polynomial coefficients, starting with highest order.
  %                   (vector)
  %

  [w, objf] = setopts(varargin, {'w', [], 'objf', 'L2'});

  % weighting matrix
  n = length(x);
  if isempty(w)
    w = ones(1,n);
  end
  W = diag(sqrt(w));
  
  % matrix with x raised to different orders
  x = x(:); y = y(:);
  A = zeros(n, 0);
  for i = 0:o
    A = [x.^i A];
  end

  % get polynomial coefficients
  switch objf
    case 'L2'
      p = (W*A)\(W*y);
  end

end

