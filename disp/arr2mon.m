function o = arr2mon(a, s)
  %
  %  places data from a multi-dimensional array into a 2D array, as done in
  %  matlab's 'montage' function.
  %
  %  function o = arr2mon(a, s)
  %
  %  inputs ....................................................................
  %  a                input array. [x y ...]
  %  s                number of rows and columns in 'montage'. [(rows, columns)]
  %
  %  outputs ...................................................................
  %  o                reformatted array. [x y]
  %

  [nx,ny,nz] = size(a);
  nr = s(1); nc = s(2);
  o = zeros(nx*nr, ny*nc);
  for i = 1:nz
    ix = floor((i-1)/nc);
    iy = mod(i-1,nc);
    o([1:nx]+ix*nx, [1:ny]+iy*ny) = a(:,:,i);
  end

end

