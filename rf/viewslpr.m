function viewslpr(tb, dz, sz, varargin)
  %
  %  displays adjacent slice profiles for a given time-bandwidth rf pulse and
  %  slice thickness and slice-to-slice distance. useful for visualizing slice
  %  overlap.
  %
  %  function viewslpr(tb, dz, sz)
  %
  %  inputs ....................................................................
  %  tb               time-bandwidth. (float)
  %  dz               slice-thickness. (cm)
  %  sz               slice-to-slice distance. (cm)
  %

  l = 1024; gam = 4.258; dt = .004;

  % calculate response
  rf = wsinc(l, tb);
  rf = pi/2*rf/sum(rf);
  ga = (tb/(l*dt))/(gam*dz);
  g = ga*ones(1,l);
  g = 2*pi*gam*dt*g;
  x = linspace(-2*dz,2*dz,1024);
  m = abs(ab2ex(abr(rf, g, x))); m = m(:).';

  % shift response for adjacent slices
  ps = round(sz/(4*dz)*l);
  ml = [m(1+ps:end) zeros(1,ps)];
  mr = [zeros(1,ps) m(1:end-ps)];
 
  % display plots
  figure; fig(8,6);
  mplot({}, x, [ml(:) m(:) mr(:)], 'z (cm)', 'M_{xy}');

end

