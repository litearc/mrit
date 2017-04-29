function o = grad2(m)
  %
  %  gets the magnitude of the gradient along the first 2 dimensions.
  %
  %  inputs ....................................................................
  %  m                input. [x y ...]
  %
  %  outputs ...................................................................
  %  o                output. [x y ...]
  %

  [ny,nx,nz] = size(m);
  o = zeros(size(m));
  for i = 1:nz
    [gx,gy] = gradient(m(:,:,i));
    o(:,:,i) = sqrt(gx.^2+gy.^2);
  end

end

