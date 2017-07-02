function M = fftc(m, varargin) 
  % 
  %  a centered fft - just does fft with fftshifts along all dimensions.
  %
  %  function M = fftc(m, varargin)
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
    M = fftshift(fftn(fftshift(m)));
  else
    for i = 1:length(dims)
      m = fftshift(fft(fftshift(m,dims(i)),[],dims(i)),dims(i));
    end
    M = m;
  end
  if ss ~= 0, M = M/sum(abs(M(:)).^2)*ss; end

end

