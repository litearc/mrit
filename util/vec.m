function x = vec(x)
  %
  %  takes all the elements in the input and creates a vector. this might seem
  %  like an unnecessary function, but in matlab, you cannot do:
  %  marray(1,2,:)(:); but with this, you can do: vec(marray(1,2,:));
  %
  %  function x = vec(x)
  %
  %  inputs ....................................................................
  %  x                input. (N-D arracy).
  %
  %  outputs ...................................................................
  %  x                output. (vector)
  %

  x = x(:);

end

