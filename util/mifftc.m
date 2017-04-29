function o = mifftc(m)
  %
  %  performs an ifftc for each 2D slice of the array
  %
  %  function o = mifftc(m)
  %
  %  inputs ....................................................................
  %  m                input array. [x y ...] (complex)
  %
  %  outputs ...................................................................
  %  o                output array. [x y ...] (complex)
  %

  [~,~,nz] = size(m);
  o = zeros(size(m));
  for i = 1:nz
    o(:,:,i) = ifftc(m(:,:,i));
  end
end

