function wbin(f, m, t, varargin)
  %
  %  writes contents of array to a binary data file.
  %
  %  function wbin(f, m, varargin)
  %
  %  inputs ....................................................................
  %  f                file-name. (string)
  %  m                array to write. (N-D array)
  %  t                data-type. (string) (default = 'float')
  %

  fp = fopen(f, 'wb');
  fwrite(fp, m, t);
  fclose(fp);

end

