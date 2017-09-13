function o = grad2(m, varargin)
  %
  %  gets the magnitude of the gradient.
  %
  %  function o = grad2(m)
  %
  %  inputs ....................................................................
  %  m                input data. [x y ...]
  %  s                mask. if specified, gradient is only computed using pixels
  %                   within the mask (this is slow!). [x y ...]
  %
  %  outputs ...................................................................
  %  o                gradient map. [x y ...]
  %

  % set default arguments
  v = ap2s(varargin);
  s = def(v, 's', []);

  [ny,nx,nz] = size(m);
  o = zeros(size(m));

  if isempty(s) % if no mask is provided, go simple 2d gradient
    for i = 1:nz
      [gx,gy] = gradient(m(:,:,i));
      o(:,:,i) = sqrt(gx.^2+gy.^2);
    end
  else % compute gradient using only pixels w/in the mask
    for iz = 1:nz
      for ix = 1:nx
        for iy = 1:ny
          if s(ix,iy,iz)
            dx = 0; dy = 0;
            if ix>1  && s(ix-1,iy,iz), dx = dx+m(ix,iy,iz)-m(ix-1,iy,iz); end
            if ix<nx && s(ix+1,iy,iz), dx = dx+m(ix+1,iy,iz)-m(ix,iy,iz); dx = dx/2; end
            if iy<1  && s(ix,iy-1,iz), dy = dy+m(ix,iy,iz)-m(ix,iy-1,iz); end
            if iy<ny && s(ix,iy+1,iz), dy = dy+m(ix,iy+1,iz)-m(ix,iy,iz); dy = dy/2; end
            o(ix,iy,iz) = sqrt(dx*dx+dy*dy);
          end
        end
      end
    end
  end

end

