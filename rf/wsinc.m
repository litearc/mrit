function rf = wsinc(n, tb)
	%
  %  creates a Hamming-weighted sinc rf pulse.
	%
	%  rf = wsinc(n, tb)
	%
	%  inputs ....................................................................
	%  n                # points. (int)
	%  tb               time-bandwidth product. (float)
	%
	%  outputs ...................................................................
	%  rf               rf pulse (scaled to sum to 1). (vector)
	%

	a = 0.46; % for hamming window
	nz = tb/2; 
	x = linspace(-nz, nz, n);
  rf = (1-a+a*cos(pi*x/nz)).*sinc(x);
	rf = rf/sum(rf);

end
