function varargout = viewbloch(varargin)
  %
  %  displays the magnetization and allows you to scroll through time to see
  %  how it evolves. useful for visualizing the effect of an rf pulse.
  %
  %  function viewbloch(M, varargin)
  %
  %  inputs ....................................................................
  %  M                magnetization over time. [(Mx,My,Mz) time spins]
  %

  % initialization
  gui_Singleton = 1;
  gui_State = struct('gui_Name',       mfilename, ...
                     'gui_Singleton',  gui_Singleton, ...
                     'gui_OpeningFcn', @viewbloch_OpeningFcn, ...
                     'gui_OutputFcn',  @viewbloch_OutputFcn, ...
                     'gui_LayoutFcn',  [] , ...
                     'gui_Callback',   []);
  if nargin && ischar(varargin{1})
      gui_State.gui_Callback = str2func(varargin{1});
  end

  if nargout
      [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
  else
      gui_mainfcn(gui_State, varargin{:});
  end
end

% update stuff based on current time point .....................................
function updateui(h)
  set(h.slider1, 'Value', h.it);
  set(h.text1, 'String', sprintf('time point = %d, t = %.3f ms', ...
    h.it, h.t(h.it)));
  if strcmp(h.B1mod, 'fm') && ~isempty(h.rf)
    set(h.q3, 'UData', h.Mfm(1,h.it,:), 'VData', h.Mfm(2,h.it,:), 'WData', h.Mfm(3,h.it,:));
  else
    set(h.q3, 'UData', h.M(1,h.it,:), 'VData', h.M(2,h.it,:), 'WData', h.M(3,h.it,:));
  end
  if ~isempty(h.rf)
    switch h.B1mod
      case 'std'
        set(h.B1, 'UData', h.rs*real(h.rf(h.it)), ...
          'VData', h.rs*imag(h.rf(h.it)), ...
          'WData', 0*h.rs);
      case 'fm'
        set(h.B1, 'UData', h.rs*abs(h.rf(h.it)), ...
          'VData', 0*h.rs, ...
          'WData', h.rs*h.fm(h.it));
    end
    set(h.magcur, 'XData', h.t(h.it)*[1,1]);
    set(h.phscur, 'XData', h.t(h.it)*[1,1]);
  end
  if ~isempty(h.g)
    set(h.gcur, 'XData', h.t(h.it)*[1,1]);
  end
end

% gets called when the data cursor position changes ............................
function o = datacurfcn(~, evt, hf)
  haxp = get(get(evt,'Target'), 'Parent');
  h = guidata(hf);

  % update indicator on graphs
  if haxp == h.axes2 || haxp == h.axes3
    p = get(evt, 'Position');
    h.it = find(h.t==p(1));
    guidata(hf, h);
    updateui(h);
  end

end

% --- Executes just before viewbloch is made visible ...........................
function viewbloch_OpeningFcn(hf, eventdata, h, varargin)
  % must supply at least one argument
  if length(varargin) < 1
    error('must supply at least 1 argument (see: help viewbloch)'); 
  end;

  [h.gam, h.dt, h.rf, h.g, h.tstep, h.B1mod] = setopts(varargin(2:end), ...
    {'gam', 4.258, 'dt', .004, 'rf', [], 'g', [], 'tstep', [], 'B1mod', 'std'});

  h.M = varargin{1};
  h.nt = size(h.M,2);
  h.np = size(h.M,3);
  znp = zeros(1,1,h.np);
  h.it = 1;
  h.t = 0:h.dt:(h.nt-1)*h.dt;
  h.nspins = size(h.M,3);

  % nice default tstep
  if isempty(h.tstep)
    h.tstep = round(h.nt/100);
  end

  % if frequency modulation, modulate frequency of spins by rf pulse's frequency
  % TODO: i *think* this part is correct, but check after thesis
  if strcmp(h.B1mod, 'fm') && ~isempty(h.rf)
    mtemp = h.M(1,:,:)+1i*h.M(2,:,:);
    mtemp = mtemp.*exp(-1i*repmat(reshape(angle(h.rf(:)),1,h.nt),[1 1 h.nspins]));
    h.Mfm = h.M;
    h.Mfm(1,:,:) = real(mtemp);
    h.Mfm(2,:,:) = imag(mtemp);
  end

  % main plot
  axes(h.axes1);
  hold on;
  if strcmp(h.B1mod, 'fm') && ~isempty(h.rf)
    h.q3 = quiver3(znp, znp, znp, h.Mfm(1,1,:), h.Mfm(2,1,:), h.Mfm(3,1,:), ...
      'linewidth', 3, 'maxheadsize', .6);
  else
    h.q3 = quiver3(znp, znp, znp, h.M(1,1,:), h.M(2,1,:), h.M(3,1,:), ...
      'linewidth', 3, 'maxheadsize', .6);
  end
  xlim([-1.5 1.5]); xlabel('M_x');
  ylim([-1.5 1.5]); ylabel('M_y');
  zlim([-1.5 1.5]); zlabel('M_z');

  % make the different arrows different colors to help visualization
  % http://stackoverflow.com/questions/29632430/quiver3-arrow-color-corresponding-to-magnitude
  col1 = [1 .2 .2 1]; col2 = [.2 .2 1 1];
  cmap = linspace(1,0,h.np)'*col1+linspace(0,1,h.np)'*col2;
  cmap = permute(uint8(cmap*255), [3 1 2]);
  cmap = repmat(cmap, [3 1 1]);
  set(h.q3.Head, 'ColorBinding', 'interpolated', ...
  'ColorData', reshape(cmap(1:3,:,:), [], 4).');
  set(h.q3.Tail, 'ColorBinding', 'interpolated', ...
  'ColorData', reshape(cmap(1:2,:,:), [], 4).');

  % plot x = y = z = 0 lines
  plot3([-2 2], [0 0], [0 0], 'k--');
  plot3([0 0], [-2 2], [0 0], 'k--');
  plot3([0 0], [0 0], [-2 2], 'k--');
  view(135, 30);

  if ~isempty(h.rf)
    h.rf = h.rf(:);

    % draw B1
    h.fm = gradient(unwrap(angle(h.rf)))/(2*pi*h.gam*h.dt); % G
    switch h.B1mod
      case 'std'
        h.rs = 1.5/max(abs(h.rf));
        h.B1 = quiver3(0, 0, 0, h.rs*real(h.rf(h.it)), h.rs*imag(h.rf(h.it)), 0, ...
          'g', 'linewidth', 2, 'maxheadsize', .4);
        set(h.radiobutton1, 'Value', 1);
        set(h.radiobutton2, 'Value', 0);
      case 'fm'
        % h.rs = 1.5/max(abs([h.rf; h.fm]));
        h.rs = 1.5/max(abs(h.rf));
        h.B1 = quiver3(0, 0, 0, h.rs*abs(h.rf(h.it)), 0, h.rs*h.fm(h.it), ...
          'g', 'linewidth', 2, 'maxheadsize', .4);
        set(h.radiobutton1, 'Value', 0);
        set(h.radiobutton2, 'Value', 1);
    end

    % plot rf pulse (magnitude, real, imag)
    axes(h.axes2); hold on;
    % plot(lims(h.t), [0 0], 'color', .5*[1 1 1]);
    yy = [abs(h.rf) real(h.rf) imag(h.rf)];
    h.rfmplot = mplot({}, h.t, yy, '', 'B_1 (G)');
    % set(h.axes2, 'xtick', []);
    ylim(ext(lims(yy),1.2));
    legend(h.rfmplot, {'mag', 'real', 'imag'});
    h.magcur = plot(h.t(h.it)*[1 1], ext(lims(yy),1.2), 'r', 'linewidth', 2);

    % plot rf phase
    axes(h.axes3); hold on;
    % plot(lims(h.t), [0 0], 'color', .5*[1 1 1]);
    mplot({}, h.t, angle(h.rf), 't (ms)', '\phi (rad)');
    if ~isempty(h.g)
      xlabel('');
      % set(h.axes3, 'xtick', []);
    end
    ylim(ext([-pi pi],1.2));
    h.phscur = plot(h.t(h.it)*[1 1], [-4 4], 'r', 'linewidth', 2);
  else
    set(h.axes2, 'Visible', 'off');
    set(h.axes3, 'Visible', 'off');
  end

  if ~isempty(h.g)
    % plot gradients
    axes(h.axes4); hold on;
    % plot(lims(h.t), [0 0], 'color', .5*[1 1 1]);
    h.gplot = mplot({}, h.t, h.g, 't (ms)', 'G/cm');
    ylim(ext(lims(h.g),1.2));
    h.gcur = plot(h.t(h.it)*[1 1], [-4 4], 'r', 'linewidth', 2);
    labs = {'G_x', 'G_y', 'G_z'};
    legend(h.gplot, labs{1:size(h.g,2)});
  else
    set(h.axes4, 'Visible', 'off');
  end

  % set slider parameters
  if h.nt == 1
    set(h.slider1, 'Enable', 'off');
    set(h.edit1, 'Enable', 'off');
  else
    dz = h.tstep*1/(h.nt-1);
    set(h.slider1, 'Min', 1, 'Max', h.nt, 'Value', 1, 'SliderStep', [dz dz]);
  end

  % if no rf pulse or gradients are given, resize window
  if isempty(h.rf) && isempty(h.g)
    hf.Units = 'centimeters';
    pos = get(hf, 'Position');
    set(hf, 'Position', [pos(1) pos(2) 11.5 pos(4)])
  end

  % enable data cursor and set function
  % dcm = datacursormode(hf);
  % set(dcm, 'Enable', 'on', 'DisplayStyle', 'window', 'UpdateFcn', {@datacurfcn, hf});

  h.edit1s = int2str(h.tstep);
  set(h.edit1, 'String', h.edit1s);

  h.it = 1;
  h.output = hf;
  guidata(hf, h);
end

% --- Outputs from this function are returned to the command line.
function varargout = viewbloch_OutputFcn(hf, eventdata, h) 
  varargout{1} = h.output;
end

% --- Executes on slider movement.
function slider1_Callback(hf, eventdata, h)
  h.it = round(get(h.slider1, 'Value'));
  h.it = max(min(h.it, h.nt), 1);
  guidata(hf, h);
  updateui(h);
end

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hf, eventdata, h)
  if isequal(get(hf,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hf,'BackgroundColor',[.9 .9 .9]);
  end
end

function edit1_Callback(hf, eventdata, h)
  s = get(hf, 'String');
  i = str2num(s);
  if isempty(i)
    fprintf('need to enter positive integer!\n');
    set(hf, 'String', h.edit1s);
    return
  end
  i = round(i);
  if i < 1
    fprintf('need to enter positive integer!\n');
    set(hf, 'String', h.edit1s);
    return
  end
  h.tstep = i;
  dz = h.tstep*1/(h.nt-1);
  set(h.slider1, 'Min', 1, 'Max', h.nt, 'SliderStep', [dz dz]);
  h.edit1s = int2str(h.tstep);
  guidata(hf, h);
end

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hf, eventdata, h)
  if ispc && isequal(get(hf,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hf,'BackgroundColor','white');
  end
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hf, eventdata, h)
  if get(hf,'Value')
    h.B1mod = 'std';
  else
    h.B1mod = 'fm';
  end
  guidata(hf, h);
  updateui(h);
end


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hf, eventdata, h)
  if get(hf,'Value')
    h.B1mod = 'fm';
  else
    h.B1mod = 'std';
  end
  guidata(hf, h);
  updateui(h);
end
