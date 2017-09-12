function s = mask2(m, varargin)
  %
  %  masks an image - simply uses graythresh (Otsu's method) on each slice.
  %
  %  function s = mask2(m, varargin)
  %
  %  inputs ....................................................................
  %  m                input data. [x y ...]
  %
  %  outputs ...................................................................
  %  s                thresholded data. [x y ...]
  %
  
  [~,~,nz] = size(m);
  s = zeros(size(m));
  m = linmap(m, lims(m), [0 1]);
  for i = 1:nz
    th = graythresh(m(:,:,i));
    s(:,:,i) = m(:,:,i)>th;
  end

end

