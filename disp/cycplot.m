function cycplot(o, x, y, xl, yl, t)
  %
  %  this function creates a figure in which you can cycle through the plots
  %  using the left and right arrow keys.
  %
  %  function cycplot(o, x, y, xl, yl)
  %
  %  inputs ....................................................................
  %  o                a struct which contains various options.
  %  x                x-axis values. (vector)
  %  y                y-axis values. (cell array of y-values, which can be
  %                   multi-column vectors)
  %  xl               x-label. (string)
  %  yl               y-label. (string)
  %  t                titles. (cell array of strings)
  %

  hf = figure;
  fig(8,6);
  h = guidata(hf);

  % set default arguments
  v = ap2s(o);
  h.onescl = def(v, 'onescl', 0);
  h.ylim   = def(v, 'ylim', []);

  h.x = x;
  h.y = y;
  h.nl = size(y{1},2); % # lines to plot
  h.ip = 1; % current plot #
  h.np = length(y);
  h.yr = lims(vec(cell2mat(y)));

  % titles
  if nargin < 6
    h.t = {};
    for i = 1:h.np, h.t{i} = ''; end
  else
    if strcmp(class(t), 'char'), t = {t}; end
    if length(t) == 1
      h.t = cell(h.np,1);
      [h.t{:}] = deal(t);
    else
      h.t = t;
    end
  end

  h.ax = mplot({}, x, y{h.ip}, xl, yl);
  title(h.t{h.ip});

  if h.onescl, ylim(h.yr); end
  if ~isempty(h.ylim), ylim(h.ylim); end
  
  set(hf, 'KeyPressFcn', @kpfunc);
  guidata(hf, h);
end

function kpfunc(hf, e)
  h = guidata(hf);
  switch e.Key
    case 'leftarrow'
      h.ip = max(h.ip-1,1);
    case 'rightarrow'
      h.ip = min(h.ip+1,h.np);
    case 'q'
      close(hf);
      return;
  end
  for i = 1:h.nl
    set(h.ax(i), 'YData', h.y{h.ip}(:,i));
  end
  title(h.t{h.ip});
  guidata(hf, h);
end

