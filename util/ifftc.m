function M = ifftc(m, varargin) 
  % 
  %  a centered ifft - just does ifft with fftshifts along all dimensions.
  %
  %  function M = ifftc(m)
  %
  %  inputs ....................................................................
	%  m                input. (complex N-D array)
	%  
  %  outputs ...................................................................
	%  M                output.(complex N-D array)
  %

  % set default arguments
  v = ap2s(varargin);
  dims = def(v, 'dims', []); % don't use 'dims' for now (buggy)

  ss = sum(abs(m(:)).^2);
  if isempty(dims),
    M = ifftshift(ifftn(ifftshift(m)));
  else
    for i = 1:length(dims)
      m = ifftshift(ifft(ifftshift(m,dims(i)),[],dims(i)),dims(i));
    end
    M = m;
  end
  if ss ~= 0, M = M/sum(abs(M(:)).^2)*ss; end

end

