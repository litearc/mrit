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

  % don't use 'dims' for now, something buggy with it...
  [dims] = setopts(varargin, {'dims', []});

  ss = sum(abs(m(:)).^2);
  if isempty(dims),
    M = fftshift(ifftn(fftshift(m)));
  else
    for i = 1:length(dims)
      m = fftshift(ifft(fftshift(m,dims(i)),[],dims(i)),dims(i));
    end
    M = m;
  end
  if ss ~= 0, M = M/sum(abs(M(:)).^2)*ss; end

end

