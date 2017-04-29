function o = fig(w, h, varargin)
  %
  %  sets various properties for the current figure, including setting its
  %  width and height, and making the printed image match what is displayed.
  %
  %  function h = fig(w, h, varargin)
  %
  %  inputs ....................................................................
  %  w                width in units 'units'. (float)
  %  h                height in units 'units'. (float)
  %
  %  options ...................................................................
  %  units            units for dimensions. any matlab-supported units can be
  %                   specified. (string) (default = 'centimeters')
  %
  %  outputs ...................................................................
  %  o                figure handle. (float)
  %

  [units] = setopts(varargin, {'units', 'centimeters'});

  o = gcf;
  set(o, 'units', units);
  pos = get(o, 'position');
  set(o, 'units', units, 'position', [pos(1:2) w h], ...
    'paperpositionmode', 'auto');

end

