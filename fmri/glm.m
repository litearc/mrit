function [t c p] = glm(m, s, r, tr, varargin)
  %
  %  performs voxel-wise General Linear Model. includes polynomial regressors.
  %
  %  function [t, c, p] = glm(m, s, r, tr, varargin)
  %
  %  inputs ....................................................................
  %  m                magnitude fmri data. [x y z time]
  %  s                stimulus to correlate with. [time]
  %  r                regressors to remove (in addition to polynomials).
  %                   [time regressors]
  %  tr               repetition time. (s) (float)
  %
  %  options ..................................................................
  %  dop              do polynomial regression. <0, 1> (default = 1)
  %  ord              polynomial order for regression. (int) (default = 2)
  %  dob              blur data? if 1, uses gaussian kernel with standard
  %                   deviation sdb. <0, 1> (default = 0)
  %  sdb              standard deviation in pixels of gaussian used for
  %                   blurring. (float) (default = 1)
  %  npb              # points in gaussian kernel used for blurring. (int)
  %                   (default = 5)
  %
  %  outputs ..................................................................
  %  t                t-score map. [x y z]
  %  c                correlation map. [x y z]
  %  p                p-value map. [x y z]
  %
  
  [dop, ord, dob, sdb, npb] = setopts(varargin, {'dop', 1, 'ord', 4, ...
    'dob', 0, 'sdb', 1, 'npb', 3});

  m = abs(m); % in case complex.
  [nx,ny,nz,nt] = size(m);

  % blur data
  if dob, m = blur2(m, npb, sdb); end

  ns = size(s,2); % # stimuli
  nr = size(r,2); % # regressors
  if ~dop
    ord = -1; % e.g. ord 2 means 0th, 1st, 2nd order polynomials
  end 

  % design matrix X, where y = X*b
  X = zeros(nt,ns+nr+ord+1);
  o = linspace(0,1,nt)';
  X(:,1:ns) = s;
  if ~isempty(r), X(:,ns+1:ns+nr) = r; end
  for i = 0:ord
    X(:,ns+1+nr+i) = o.^i;
  end
  df = nt-(ns+nr+ord+1);

  % do GLM
  t = zeros(nx,ny,nz,ns); % t-score map
  c = zeros(nx,ny,nz,ns); % correlation map
  for ix = 1:nx, for iy = 1:ny, for iz = 1:nz
    y = vec(m(ix,iy,iz,:));
    b = X\y; % beta coefficients
    rm = X(:,ns+1:end)*b(ns+1:end); % noise component
    m(ix,iy,iz,:) = reshape(y-rm,[1,1,1,nt]);
    % e = std(y-X*b); % residual component
    for is = 1:ns
      c(ix,iy,iz,is) = corr(vec(m(ix,iy,iz,:)), s(:,is));
    end
  end, end, end

  % possible to get nans if, e.g. all values are 0
  c(isnan(c)) = 0;

  t = cstat('r', 't', c, nt, 'tr', tr);
  p = cstat('r', 'p', c, nt, 'tr', tr);

end

