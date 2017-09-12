function o = cfa(s1, s2)
  %
  %  computes the flip-angle map.
  %
  %  inputs ....................................................................
  %  s1               image acquired with flip angle theta. [x y ...]
  %  s2               image acquired with flip angle 2*theta. [x y ...]
  %
  %  outputs ...................................................................
  %  o                flip angle map. [x y ...]
  %

  m = mask(s1).*mask(s2);
  s1 = blur2(s1,5,2);
  s2 = blur2(s2,5,2);
  o = m.*acos(.5*abs(s2)./abs(s1))*180/pi;

end

