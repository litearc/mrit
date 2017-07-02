function c = grap2coef(r, s, varargin)
  %
  %  computes GRAPPA coefficients using a fully sampled region of k-space and
  %  a kernel mask indicating which surrounding points to use.
  %
  %  function c = grap2coef(r, s, varargin)
  %
  %  inputs ....................................................................
  %  r                 fully sampled k-space data. [points views coils]
  %  s                 a kernel mask. here, 1s indicate surrounding points to
  %                    use for estimating the coefficients, 0s indicate points
  %                    not to use, and a 2 indicates the center point.
  %
  %  options ...................................................................
  %  solv              method for solving linear system. the options are:
  %                    'cg'  : bi-conjugate gradient (default)
  %                    'mld' : matlab's left-divide
  %
  %  outputs ...................................................................
  %  c                 matrix containing grappa coefficients.
  %                    [points_in_kernel coils]
  %
  %  I consulted the 'myGRAPPA' function written by Santiago Aja-Fernandez, in
  %  particular with regards to using 'bicg' to solve the linear system.
  %

  % set default arguments
  v = ap2s(varargin);
  lam   = def(v, 'lam', 0);
  solv  = def(v, 'solv', 'mld');

  % calculate various # points
  [np, nv, nc] = size(r);
  [is, js] = ind2sub(size(s), find(s==2));
  n1 = nnz(s==1);

  % # points around center point in each direction
  nu = is-1;
  nl = js-1;
  nd = size(s,1)-is;
  nr = size(s,2)-js;
  nt = (np-nu-nd)*(nv-nl-nr); % # center points per coil

  % contains calibration points for all coils for each position
  A = zeros(nt, n1*nc);
  i = (s==1); i = repmat(i,[1,1,nc]);
  j = 1;
  for iy = js:nv-nr % loop needs to be in this order, (iy, then ix) to match 'B'
    for ix = is:np-nd
      t = r(ix+[-nu:nd], iy+[-nl:nr], :);
      A(j,:) = t(i).';
      j = j+1;
    end
  end

  % get coefficients
  switch solv
    case 'cg' % seems to work better than '\'
      A2 = A'*A;
      c = zeros(n1*nc, nc);
      for ic = 1:nc
        b = vec(r(is:np-nd, js:nv-nr, ic));
        [c(:,ic), ~] = bicg(A2, A'*b); % 2nd output arg suppresses warning/error
      end
    case 'mld'
      B = reshape(r(is:np-nd, js:nv-nr, :), nt, nc);
      c = pinv(A)*B;
      % c = A\B;
      % T = lam*eye(size(A,2));
      % c = pinv(A'*A+T'*T)*A'*B;
  end

end

