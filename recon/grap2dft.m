function o = grap2dft(r, s, f, varargin)
  %
  %  performs GRAPPA on 2DFT (or gridded and phase-corrected EPI) data. for each
  %  unsampled line, this calculates the GRAPPA coefficients using a kernel from
  %  the two nearest adjacent sampled lines, and applies them to all unsampled
  %  lines that would use the same kernel.
  %
  %  function m = grap2dft(r, s, varargin)
  %
  %  inputs ....................................................................
  %  r                raw (not zero-filled) data.
  %                   [points views coils slices frames]
  %  s                mask specifying positions of sampled lines in k-space. the
  %                   # of non-zeros must equal the # of views in 'r'. (vector)
  %  f                fully-sampled k-space data. note: this must be large
  %                   enough to  estimate the necessary GRAPPA coefficients for
  %                   the given EPI data. this must contain the same # of points,
  %                   views, coils, and slices as 'r', but may contain either
  %                   one frame, in which case the same coefficients will be
  %                   used for all frames in 'r', or the same # frames as in 'r',
  %                   in which case coefficients are calculated for each frame.
  %                   [points views coils slices frames]
  %
  %  options ...................................................................
  %  out              type of data to output. the options are:
  %                   'm' : reconstructed image (default)
  %                   'k' : k-space
  %  nkx              # points along kx in GRAPPA kernel (better if an odd #).
  %                   (default = 3)
  %  tell             display messages? (0 or 1) (default = 0)
  %
  %  outputs ...................................................................
  %  o                reconstructed image
  %

  % set default arguments
  v = ap2s(varargin);
  out     = def(v, 'out', 'm');
  nkx     = def(v, 'nkx', 3);
  tell    = def(v, 'tell', 1);
  use_mex = def(v, 'mex', 1);
  
  if tell, fprintf('grap2dft: initializing ...\n'); end

  ckx = cen(1,nkx); % center point
  x = s;            % mask specifying lines already filled in (or sampled)
  
  % create zero-filled dataset
  nl = length(s);
  [np,nv,nc,ns,nt] = size(r);
  ntf = size(f,5);
  o = complex(zeros(np,nl,nc,ns,nt));
  o(:,find(s),:,:,:) = r;

  % creates GRAPPA kernel for a given line based on nearest sampled lines
  function k = ykern(i)
    il = i; while (il>=1  && ~s(il)), il=il-1; end 
    iu = i; while (iu<=nl && ~s(iu)), iu=iu+1; end
    k = repmat([1 zeros(1, iu-il-1) 1], [nkx, 1]);
    k(ckx, i-il+1) = 2;
    if (il==0),    k(:,1) = [];   end
    if (iu==nl+1), k(:,end) = []; end
  end

  a = repmat(s(:)', [np, 1]); % sampled lines
  b = zeros(np, nl);          % what to fill in
  nchar = [];

  % fill in each non-sampled line
  for i = 1:nl
    if x(i), continue; end % already filled in
    % get GRAPPA kernel and coefficients
    yk = ykern(i);
    b(:) = 0; b(:,i) = 1;
    x(i) = 1;
    % find other lines that use the same kernel
    for j = i+1:nl
      if x(j), continue; end
      if isequal(ykern(j), yk)
        b(:,j) = 1;
        x(j) = 1;
      end
    end
    % fill in lines
    for is = 1:ns
      if ntf == 1, gc = grap2coef(f(:,:,:,is), yk); end
      for it = 1:nt
        if tell
          str = sprintf('grappa : is = %d, it = %d', is, it);
          if ~isempty(nchar)
            fprintf(repmat('\b', [1, nchar]));
            if nchar > length(str), str = strpad(str, nchar-length(str)); end
          end
          nchar = fprintf(str);
          fprintf('\r');
        end
        if ntf ~= 1, gc = grap2coef(f(:,:,:,is,it), yk); end
        if use_mex && exist('grap2fillm')
          o(:,:,:,is,it) = grap2fillm(o(:,:,:,is,it), b, yk, gc);
        else
          o(:,:,:,is,it) = grap2fill(o(:,:,:,is,it), a, yk, gc, 'o', b);
        end
      end
    end
  end

  % exit out of carriage-return
  if tell, fprintf('\n'); end

  % reconstruct image
  if strcmp(out, 'm')
    o = dft2(o);
  end

end


