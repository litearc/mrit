function o = mfftc(m)
  %
  %  performs an fftc for each 2D slice of the array
  %
  %  function o = mfftc(m)
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
    o(:,:,i) = fftc(m(:,:,i));
  end
end

