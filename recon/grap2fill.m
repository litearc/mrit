function k = grap2fill(r, x, s, c, varargin)
  %
  %  fills in missing entries in k-space data using GRAPPA.
  %
  %  function o = grap2fill(r, x, s, c)
  %
  %  inputs ....................................................................
  %  r                raw zero-filled k-space data. [points views coils]
  %  x                binary array specifying sampled entries in 'r'.
  %                   [points views]
  %  s                kernel mask
  %  c                GRAPPA coefficients
  %
  %  options ...................................................................
  %  o                binary array specifying entries in 'r' to fill in.
  %                   [points views] (default = invert 'x')
  %  ochk             checks if entries to fill in can be filled in, i.e. has
  %                   the necessary samples around it. (default = 1)
  %
  %  outputs ...................................................................
  %  k                k-space with missing entries filled in
  %

  [o, ochk] = setopts(varargin, {'o', ~x, 'ochk', 1});

  % calculate various # points
  [np, nv, nc] = size(r);
  [is, js] = ind2sub(size(s), find(s==2));
  n1 = nnz(s==1);
  
  % # points around center point in each direction
  nu = is-1;
  nl = js-1;
  nd = size(s,1)-is;
  nr = size(s,2)-js;

  % apply coefficients
  k = r;
  i = (s==1); i = repmat(i,[1,1,nc]);
  for ix = is:np-nd
    for iy = js:nv-nr
      if o(ix,iy) == 1
        for ic = 1:nc
          t = r(ix+[-nu:nd],iy+[-nl:nr],:);
          k(ix,iy,ic) = t(i).'*c(:,ic);
        end
      end
    end
  end

end

