function o = lbin(f, t, varargin)
  %
  %  loads a binary data file.
  %
  %  function o = lbin(f, t, varargin)
  %
  %  inputs ....................................................................
  %  f                file-name. (string)
  %  t                data-type. (string)
  %
  %  outputs ...................................................................
  %  o                output data. (vector)
  %  

  fp = fopen(f, 'rb');
  o = fread(fp, inf, t);
  fclose(fp);

end

