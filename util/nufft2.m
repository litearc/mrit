function o = nufft2(r, k, n, varargin)
  %
  %  performs a non-uniform 2D fft.
  %
  %  function o = nufft2(r, k, n, varargin)
  %
  %  inputs ....................................................................
  %  r                raw data. (complex 2-D array)
  %  k                k-space positions. [kx ky] (1/cm)
  %  n                # points in the grid. [nx ny] (int)
  %
  %  options ...................................................................
  %  kern             gridding kernel. <'tri'> (default = 'tri')
  %  kw               kernel width. (float) (default = 2.5)
  %  osf              grid oversampling factor. (int) (default = 3)
  %
  %  outputs ...................................................................
  %  o                non-uniform fft. (complex) (2-D array)
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
  if iscomplex(k)
    k = [real(k(:)) imag(k(:))];
  end
  kmax = max(abs(k(:)));
  kx = .5*k(:,1)/kmax;
  ky = .5*k(:,2)/kmax;

  % initialize variables
  npad = 0;                       % # points to extend grid
  Nx = osf*nx+2*npad;             % total # points in grid along x
  Ny = osf*ny+2*npad;             % " along y
  xp = (kx+.5)*(osf*nx-1)+1+npad; % k-space positions on grid
  yp = (ky+.5)*(osf*ny-1)+1+npad;
  o = zeros(Nx, Ny);

  % kernel-weighting function
  switch kern
    case 'tri'
      kwf = @(d,w) max(w-d,0);
  end

  % grid all data for each point in kernel
  for dx = -kw:kw
    x = round(xp+dx);
    x = min(max(x,1),Nx);
    wx = kwf(abs(xp-x), kw);
    for dy = -kw:kw
      y = round(yp+dy)
      y = min(max(y,1),Ny);
      wy = kwf(abs(yp-y), kw);
      o = o+accumarray({x,y}, r.*wx.*wy, [Nx,Ny]);
    end
  end

  o(:,[1 end]) = 0; % zero out data at edge
  o([1 end],:) = 0;
  o = fftc(o);
 
  % deapodization weighting for kernel
  [ry,rx] = meshgrid(kw*linspace(-.5,.5,Ny), kw*linspace(-.5,.5,Nx));
  switch kern
    case 'tri'
      af = (sinc(rx)).^2.*(sinc(ry)).^2;
  end
  o = o./af;

  % only return the center
  o = o(cen(nx,Nx), cen(ny,Ny));

end
