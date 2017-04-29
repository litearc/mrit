function o = pfilt(m, varargin)
  %
  %  low-pass filters an activation map to increase SNR, but attempts to
  %  preserve edges by looking at the local standard deviation.
  %
  %  function o = pfilt(m, varargin)
  %
  %  inputs ....................................................................
  %  m                input map. [x y ...]
  %
  %  options ...................................................................
  %  r                radius. (pixels) (float) (default = 1)
  %
  %  outputs ...................................................................
  %  o                filtered map. [x y ...]
  %
  %  originally written by Gary Glover.
  %

  [r] = setopts(varargin, {'r', 1});

  [nx,ny,nz] = size(m);
  siggain = .5;
  ntot = (2*r+1)*(2*r+1);
  
  o = m;
  % loop over pixels in image
  for iz = 1:nz
    for ix = 1+r:nx-r
      for iy = 1+r:ny-r
        % local standard deviation
        sd = std(vec(m(ix-r:ix+r, iy-r:iy+r,iz)));
        sum0 = 0; sum1= 0;
        % average of 'non-noisy' local pixels
        for jx = -r:r
          for jy = -r:r
            if abs(m(ix+jx,iy+jy)-m(ix,iy)) <= sd*siggain
              sum1 = sum1+m(ix+jx,iy+jy,iz);
              sum0 = sum0+1; 
            end
          end
        end
        % set output value
        o(ix,iy,iz) = sum1/sum0;
      end
    end
  end

end

