function o = ccfilt2(m, p, varargin)
  %
  %  filters 2D connected components (cc) from a binary image.
  %
  %  inputs ....................................................................
  %  m                binary image. [x y ...]
  %  p                a struct that specifies criteria to keep cc's. the struct
  %                   contains (cc property name) and (criteria to keep) pairs.
  %                   e.g. {'Area', [10 20], 'Eccentricity', [.2 .4]} keeps only
  %                   cc's with area between 10 and 20, and eccentricity between
  %                   .2 and .4.
  %                   so far, this function only supports scalar cc properties
  %                   with criteria given as a range.
  %
  %  options ...................................................................
  %  conn             connectivity type. <4, 8>
  %
  %  outputs ...................................................................
  %  o                filtered image. [x y ...]
  %

  [conn] = setopts(varargin, {'conn', 4});

  [nx,ny,nz] = size(m);
  o = zeros(size(m));
  t = zeros(nx,ny);
  np = length(p);

  for iz = 1:nz
    cc = bwconncomp(m(:,:,iz), conn);
    rp = regionprops(cc, p{1:2:end});
    for ic = 1:cc.NumObjects
      keep = 1;
      for ip = 1:np/2
        pv = getfield(rp(ic), p{2*ip-1});
        switch p{2*ip-1}
          otherwise
            if pv<p{2*ip}(1) || pv>p{2*ip}(2)
              keep = 0;
              break;
            end
        end
      end
      if keep
        t(:) = 0;
        t(cc.PixelIdxList{ic}) = 1;
        o(:,:,iz) = o(:,:,iz)+t;
      end
    end
  end

end

