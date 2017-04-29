function o = blur2(m, n, s, varargin)
  %
  %  convolves N-D array with a 2D gaussian kernel along first 2 dimensions.
  %
  %  function o = blur2(m, n, s)
  %
  %  inputs ....................................................................
  %  m                input data. [x y ...]
  %  n                # points in gaussian kernel. (int)
  %  s                standard deviation in pixels. (float)
  %
  %  outputs ...................................................................
  %  o                blurred data. [x y ...]
  %
  
  rm = size(m, 1)/2;
  f = fspecial('gaussian', [n n], s);
  
  [~,~,nz] = size(m);
  o = zeros(size(m));
  for iz = 1:nz
    o(:,:,iz) = conv2(m(:,:,iz), f, 'same');
  end

end

