function o = sense(m, c, varargin)
  %
  %  performs a SENSE recon of data uniformly undersampled along 'y' dimension.
  %
  %  function m = sense(m, c)
  %
  %  inputs ....................................................................
  %  m                aliased image. [x y coils z ...].
  %  c                coil sensitivity maps. [x y coils z].
  %
  %  outputs ...................................................................
  %  o                reconstructed image. [x y z ...].
  %

  [tell] = setopts(varargin, {'tell', 0});
  
  if tell, fprintf('sense: initializing ...\n'); end
  nchar = [];

  [nx,nyu,nc,nz,nt] = size(m);
  ny = size(c,2);
  u = ny/nyu;
  s = zeros(nc,1);
  C = zeros(nc,u);
  iys = zeros(u,1);
  ms = size(m);
  o = zeros([ms(1) ny ms(4:end)]); % remove coil dimension

  % loop over pixels in undersampled image
  for iz = 1:nz
    for it = 1:nt
      if tell
        str = sprintf('sense : is = %d, it = %d', iz, it);
        if ~isempty(nchar)
          fprintf(repmat('\b', [1, nchar]));
          if nchar > length(str), str = strpad(str, nchar-length(str)); end
        end
        nchar = fprintf(str);
        fprintf('\r');
      end
      for ix = 1:nx
        for iy = 1:nyu
          % indices in coil sensitivity images
          iys = round(mod(iy+ny/2*(1-1/u)+[0:u-1]*ny/u-1,ny)+1);
          iys = max(min(iys,ny),1);
          % loop over coils
          for ic = 1:nc
            s(ic) = m(ix,iy,ic,iz,it);
            C(ic,:) = c(ix,iys,ic,iz);
          end
          % do inversion to unalias pixels
          p = C\s;
          o(ix,iys,iz,it) = p;
        end
      end
    end
  end

  % exit out of carriage-return
  if tell, fprintf('\n'); end

end

