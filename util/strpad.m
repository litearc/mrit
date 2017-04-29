function o = strpad(s, n, varargin)
  %
  %  pads a string with empty space.
  %
  %  function o = strpad(s, n, varargin)
  %
  %  inputs ....................................................................
  %  s                string to pad. (string)
  %  n                # spaces to add. (int)
  %
  %  outputs ...................................................................
  %  o                padded string. (string)
  %

  o = [s repmat(' ',[1,n])];

end

