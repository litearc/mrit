function o = depoly(m, ord)
  %
  %  performs a polynomial detrend
  %
  %  function o = depoly(m, ord)
  %
  %  inputs ....................................................................
  %  m                4D volume dataset. [x y z time]
  %  ord              polynomial order. (int)
  %
  %  outputs ...................................................................
  %  o                dataset detrended. [x y z time]
  %

  m = abs(m); % in case complex.
  [nx,ny,nz,nt] = size(m);

  X = zeros(nt,ord+1);
  o = linspace(0,1,nt)';
  for i = 0:ord
    X(:,i+1) = o.^i;
  end

  for ix = 1:nx, for iy = 1:ny, for iz = 1:nz
    y = vec(m(ix,iy,iz,:));
    b = X\y; % beta coefficients
    rm = X*b; % noise component
    m(ix,iy,iz,:) = reshape(y-rm,[1,1,1,nt]);
  end, end, end
  o = m;

end

