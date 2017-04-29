function o = a2ls(a)
  %
  %  returns linspace with a(3) elements between a(1) and a(2).
  %
  %  function o = a2ls(a)
  %
  %  inputs ....................................................................
  %  a                specifies linspace. (3-vector)
  %
  %  outputs ...................................................................
  %  o                output. (vector)
  %
  
  o = vec(linspace(a(1), a(2), a(3)));

end

