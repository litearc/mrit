function o = ap2s(a)
  %
  %  converts a cell array containing argument-value pairs to a struct.
  %  
  %  example:
  %  s = ap2s({'mcolor', 'blue', 'mlength', 4}) ->
  %  s.mcolor = 'blue'
  %  s.mlength = 4
  %
  %  function o = ap2s(a)
  %
  %  inputs ....................................................................
  %  a                argument-value pairs. (cell array)
  % 
  %  outputs ...................................................................
  %  o                output struct. 
  %

  o = struct;
  na = length(a)/2;
  for i = 1:na
    o.(a{2*i-1}) = a{2*i}; % didn't work with setfield (?)
  end

end

