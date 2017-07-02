function o = nufft1(r, k, n, varargin)
  %
  %  performs a non-uniform 1D fft.
  %
  %  function o = nufft1(r, k, n, varargin)
  %
  %  inputs ....................................................................
  %  r                raw data. (complex vector)
  %  k                k-space positions. (1/cm) (vector)
  %  n                # points in the grid. (int)
  %
  %  options ...................................................................
  %  kern             gridding kernel. <'tri'> (default = 'tri')
  %  kw               kernel width. (float) (default = 2.5)
  %  osf              grid oversampling factor. (int) (default = 3)
  %
  %  outputs ...................................................................
  %  o                non-uniform fft. (complex vector)
  %
  %  originally written by John Pauly.
  %

  % set default arguments
  v = ap2s(varargin);
  kern = def(v, 'kern', 'tri');
  kw   = def(v, 'kw', 2.5);
  osf  = def(v, 'osf', 3);

  % format data
  r = r(:);
  k = .5*k(:)/max(abs(k));

  % initialize variables
  npad = 0;                     % # points to extend grid
  N = osf*n+2*npad;             % total # points in grid
  xp = (k+.5)*(osf*n-1)+1+npad; % k-space positions on grid
  o = zeros(N, 1);

  % kernel-weighting function
  switch kern
    case 'tri'
      kwf = @(d,w) max(w-d,0);
  end

  % grid all data for each point in kernel
  for dx = -kw:kw
    x = round(xp+dx);
    x = min(max(x,1),N);
    wx = kwf(abs(xp-x), kw);
    o = o+accumarray(x, r.*wx, [N,1]);
  end

  o([1 end]) = 0; % zero out data at edge
  o = fftc(o);
 
  % deapodization weighting for kernel
  r = vec(kw*linspace(-.5,.5,n*osf));
  switch kern
    case 'tri'
      af = (sinc(r)).^2;
  end
  o = o./af;

  % only return the center
  o = o(cen(n,N));

end
