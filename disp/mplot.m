function h = mplot(o, x, y, xl, yl, t, l)
  %
  %  this is a convenience function for plotting and setting various options at
  %  once. the first 3 arguments are required, but after that are optional.
  %
  %  the first argument is a struct that can contain optional arguments. this
  %  was done in this way so that the later arguments can be specified without
  %  setopts, which needs a string for each optional argument.
  %
  %  inputs ....................................................................
  %  o                struct that contains optional arguments. (struct)
  %                   cdisp : how to display complex data
  %                     'mp' : mag/phase (default)
  %                     'ri' : real/imag
  %                     'mo' : mag only
  %                   these options only apply if data is complex
  %  x                x data. (vector)
  %  y                y data. (vector or 2D array where each column produces a
  %                   separate x-y plot in the figure)
  %  xl               x label. (string)
  %  yl               y label. (string)
  %  t                title. (string)
  %  l                legend struct. (struct of strings)
  %

  % for convenience, if only one or two arguments are passed, make assumptions
  switch nargin
    case 1
      y = o;
      x = 1:len(y);
      o = {};
    case 2
      y = x;
      x = o;
      o = {};
  end

  % set default arguments
  v = ap2s(o);
  cdisp   = def(v, 'cdisp', 'mp');
  isangle = def(v, 'angle', 0);
  ylimits = def(v, 'ylimits', []);
 
  % set default parameter values
  if nargin < 4, xl = ''; end
  if nargin < 5, yl = ''; end
  if nargin < 6, t = '';  end
  if nargin < 7, l = {};  end

  % format inputs if needed
  if isvector(y) && length(y) == size(y,2), y = y(:); end
  if isvector(x) && length(x) == size(x,2), x = x(:); end
  if isempty(x), x = [1:size(y,1)]'; end

  % if no figure exists, create one
  if isempty(findall(0,'type','figure'))
    figure;
    fig(8,6);
  end

  % if you only care about magnitude, then remove phase information
  [nx,ny] = size(y);
  if strcmp(cdisp, 'mo')
    for i = 1:ny
      if ~isreal(y(:,i))
        y(:,i) = abs(y(:,i));
      end
    end
  end

  col1 = [0 .4 .8];
  col2 = [.8 .2 .2];
  posfig = [.2 .2 .6 .7];

  % if there are complex values in 'y', then create two axes (left and right)
  % and display mag/phase or real/imag
  if isreal(y) % only real values
    % plot data and set various options
    h = plot(x, y, 'linewidth', 2); %, 'color', col1);
    if isangle
      set(gca, 'ylim', [-4 4], 'ytick', [-pi 0 pi], 'yticklabel', {'-\pi', '0', '+\pi'});
    end
    if ~isempty(ylimits), ylim(ylimits); end
    xlim(lims(x));
    ylim(ext(lims(y),1.2));
    xlabel(xl);
    ylabel(yl);
    title(t);
    if ~isempty(l), legend(l); end
    % set(gca, 'position', posfig);
  else
    % if you want to display real and imaginary, then this loops over the
    % columns and for each complex column, separates it into the real and
    % imaginary components
    if strcmp(cdisp, 'ri')
      y_ = zeros(nx,0); l_ = {};
      for i = 1:ny
        if isreal(y(:,i))
          y_ = [y_ y(:,i)];
          if ~isempty(l), l_{end+1} = l{i}; end
        else
          y_ = [y_ real(y(:,i)) imag(y(:,i))];
          if ~isempty(l)
            l_{end+1} = [l{i} ' real'];
            l_{end+1} = [l{i} ' imag'];
          end
        end
      end
      y = y_; l = l_;
      h = plot(x, y, 'linewidth', 2);
      if ~isempty(ylimits), ylim(ylimits); end
      xlim(lims(x));
      xlabel(xl);
      ylabel(yl);
      title(t);
      if ~isempty(l), legend(l); end
    end

    % if you want to display mag and phase, then we create two axes, on the
    % left and right, since they have different units. for now, cannot use
    % legend with this since the colors are used to indicate which axis.
    if strcmp(cdisp, 'mp')
      yL = zeros(nx,0); yR = zeros(nx,0);
      for i = 1:ny
        if isreal(y(:,i))
          yL = [yL y(:,i)];
        else
          yL = [yL abs(y(:,i))];
          yR = [yR angle(y(:,i))];
        end
      end
      [ax,h1,h2] = plotyy(x, yL, x, yR);
      colL = col1; colR = col2;
      for i = 1:length(h1)
        set(h1(i), 'color', colL, 'linewidth', 2);
      end
      for i = 1:length(h2)
        set(h2(i), 'color', colR, 'linewidth', 2);
      end
      set(ax, {'ycolor'}, {colL; colR});
      xlim(ax(1), lims(x));
      xlim(ax(2), lims(x));
      ylim(ax(1), ext(lims(abs(y)),1.2));
      ylim(ax(2), [-4 4]);
      if ~isempty(ylimits), ylim(ax(1), ylimits); end
      xlabel(xl);
      ylabel(ax(1), yl);
      ylabel(ax(2), 'angle');
      set(ax(2), 'ytick', [-pi 0 pi], 'yticklabel', {'-\pi', '0', '+\pi'});
      title(t);
    end

    % set(ax, 'position', posfig);

  end

end

