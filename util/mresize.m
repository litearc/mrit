function o = mresize(m, sz, varargin)
  %
  %  resizes each 2D slice of an array.
  %
  %  function o = mresize(m, sz, varargin)
  %
  %  inputs ....................................................................
  %  m                input array. [x y ...]
  %  sz               size of slice. [(nx,ny)] (int).
  %                   if scalar int is provided,then nx = sz(1), ny = sz(2).
  %
  %  outputs ...................................................................
  %  o                output array. [nx ny ...]
  %
  


  s = size(m);
  if length(s) == 2, s = [s 1]; end
  if length(sz) == 1, sz = [sz sz]; end
  o = zeros([sz(1) sz(2) s(3:end)]);
  nz = prod(s(3:end));
  for i = 1:nz
    o(:,:,i) = imresize(m(:,:,i), sz);
  end
end

