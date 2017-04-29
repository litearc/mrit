function o = linmap(i, ri, ro)
  %
  %  maps values from one range of values to another.
  %
  %  function o = linmap(i, ri, ro)
  %
  %  inputs ....................................................................
  %  i                input values. (vector)
  %  ri               input range. (vector)
  %  ro               output range. (vector)
  %
  %  outputs ...................................................................
  %  o                remapped values. (vector)
  %

  m = (ro(2)-ro(1))/(ri(2)-ri(1));
  b = ro(1)-m*ri(1);
  o = m*i+b;

end

