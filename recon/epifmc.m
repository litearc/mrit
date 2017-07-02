function m = epifmc(r, fm, varargin)
  %
  %  performs B0 field-map correction on EPI data that has already been
  %  gridded and phase-corrected.
  %
  %  note: either the echo-spacing 'dt', or view-timing information 'vt' must be
  %  provided.
  %
  %  function m = epifmc(r, fm, varargin)
  %
  %  inputs ....................................................................
  %  r                EPI data. [reads views z frames ...]
  %  fm               B0 field map. (Hz) [x y z ...]
  %
  %  options ...................................................................
  %  dt               line-to-line timing difference. (number) (ms)
  %  vt               view-timing information. (vector) (ms)
  %
  %  outputs ...................................................................
  %  m                B0-corrected image. [x y ...]                
  %

  % set default arguments
  v = ap2s(varargin);
  dt   = def(v, 'dt', []);
  vt   = def(v, 'vt', []);
  tell = def(v, 'tell', 0);

  if tell, fprintf('epifmc: initializing ...\n'); end
  nchar = [];

  fm = fm*1e-3; % Hz -> kHz 
  [np,nv,nz,ni] = size(r);
  m = zeros(size(r));

  % the timing array (ta) is an [nx ny nv] array, with ta(:,:,iv) = vt(iv);
  nx = np; ny = nv;
  if ~isempty(dt), vt = dt*[0:nv-1]; end
  ta = repmat(permute(vt(:),[3 2 1]), [nx ny 1]);

  % we 'vectorize' the time-segmented correction by (for each slice and image)
  % creating a 'stack' of data (rstack) with size [np nv nv], where for the ith
  % 'slice', i.e. rstack(:,:,i), only the ith phase encode is in the slice, with
  % all other entries zero. istack stores the location of the non-zero indices
  % in rstack.
  rstack = zeros(np,nv,nv);
  istack = padarray(ones(np,nv),nv*np,0,'post');
  istack = find(istack(1:np*nv*nv));

  for iz = 1:nz
    o = repmat(fm(:,:,iz), [1 1 nv]);
    for ii = 1:ni
      if tell
        str = sprintf('B0 correction : is = %d, ii = %d', iz, ii);
        if ~isempty(nchar)
          fprintf(repmat('\b', [1, nchar]));
          if nchar > length(str), str = strpad(str, nchar-length(str)); end
        end
        nchar = fprintf(str);
        fprintf('\r');
      end
      rstack(istack) = r(:,:,iz,ii);
      ms = ifftshift(ifft(ifftshift(rstack,1),[],1),1);
      ms = ifftshift(ifft(ifftshift(ms,2),[],2),2);
      m(:,:,iz,ii) = sum(ms.*exp(-2i*pi*o.*ta),3);
    end
  end
  % exit out of carriage-return
  if tell, fprintf('\n'); end

end


