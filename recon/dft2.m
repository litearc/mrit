function m = dft2(r, varargin)
  %
  %  performs a simple 2DFT recon on a multi-channel k-space dataset.
  %
  %  function m = dft2(r)
  %
  %  inputs ....................................................................
  %  r                k-space data. [points views coils ...]
  %
  %  options ...................................................................
  %  comb             how to combine coils. the options are:
  %                   'ss'   : sum of squares (default)
  %                   'sum'  : sum
  %                   'no'   : don't combine
  %                   'sens' : use sensitivity maps to retain phase
  %  dir              direction of FFT. the options are:
  %                   'rev' : reverse (default)
  %                   'fwd' : forward
  %  cmaps            coil maps. if provided, are not calculated when needed.
  %                   [x y ... coils]
  %
  %  outputs ...................................................................
  %  m                reconstructed image. [x y ...] (complex)
  %

  % set default arguments
  v = ap2s(varargin);
  cmaps = def(v, 'cmaps', []);
  comb  = def(v, 'comb', 'ss');
  dir   = def(v, 'dir', 'rev');

  s = size(r);
  [~,~,nc,no] = size(r);
  mc = zeros(s);

  switch dir
    case 'rev', ffftc = @ifftc;
    case 'fwd', ffftc = @fftc;
  end

  for i = 1:nc
    for j = 1:no
      mc(:,:,i,j) = ffftc(r(:,:,i,j));
    end
  end

  switch comb
    case 'sum'
      m = squeeze(sum(mc, 3));
    case 'ss'
      m = squeeze(sqrt(sum(abs(mc).^2,3)));
    case 'no'
      m = mc;
    case 'sens'
      mc = permute(mc, [1 2 4 3]);
      [nx,ny,nz,~] = size(mc);
      if ~isempty(cmaps)
        c = cmaps;
      else
        c = mri_sensemap_denoise(mc);
      end
      m = zeros(nx, ny, nz);
      for ix = 1:nx, for iy = 1:ny, for iz = 1:nz
        m(ix,iy,iz) = vec(c(ix,iy,iz,:))\vec(mc(ix,iy,iz,:));
      end, end, end
  end

end

