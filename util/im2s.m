function s = im2s(f, ny, nx, varargin)
  % 
  %  creates mask from image
  %
  %  function s = im2s(f, ny, nx)
  %
  %  inputs ....................................................................
  %  f                image file-name. (string)
  %  ny               height in pixels of a slice. (int)
  %  nx               width in pixels of a slice. (integer)
  %
  %  options ...................................................................
  %  ns               # slices. (integer)
  %
  %  outputs ...................................................................
  %  s                image mask. (array)
  %

  % set default arguments
  v = ap2s(varargin);
  ns = def(v, 'ns', -1);

  if nargin == 2, nx = ny; end
  im = rgb2gray(imread(f));
  im = im~=0;
  [h,w] = size(im);
  h = floor(h/ny); w = floor(w/nx);
  if ns == -1, ns = w*h; end
  s = zeros(ny,nx,ns);
  for i = 1:ns
    ix = mod(i-1,w);
    iy = floor((i-1)/w);
    s(:,:,i) = im(iy*ny+[1:ny], ix*nx+[1:nx]);
  end

end

