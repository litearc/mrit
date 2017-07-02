function o = def(s, name, v)
  %
  %  if the field 'name' is in struct 's', returns getfield(s, name),
  %  else the default value 'v'.
  %
  %  function o = def(s, name, v)
  %
  %  inputs ....................................................................
  %  s                values. (struct)
  %  name             field name. (string)
  %  v                default value.
  %
  %  outputs ...................................................................
  %  o                output value.
  %

  if isfield(s, name)
    o = getfield(s, name);
  else
    o = v;
  end

end

