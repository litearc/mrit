function varargout = show4d(varargin)
  %
  %  displays a 4D (3D+time) dataset with an interactive GUI
  %
  %  show4d(m)
  %
  %  inputs ....................................................................
  %  m                4D dataset of size [x y z t]
  %
  %  options ...................................................................
  %  tl               time axis values. (vector) (default = 1:nt)
  %  tt               time axis label. (string) (default = '')
  %  clim             specifies how images should be scaled for display.
  %                     'slice'  : scale each slice independently.
  %                     'volume' : scale by whole volume. (default)
  %

  % Begin initialization code - DO NOT EDIT
  gui_Singleton = 1;
  gui_State = struct('gui_Name',       mfilename, ...
                     'gui_Singleton',  gui_Singleton, ...
                     'gui_OpeningFcn', @show4d_OpeningFcn, ...
                     'gui_OutputFcn',  @show4d_OutputFcn, ...
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
  % End initialization code - DO NOT EDIT
end

% returns the range [l u] but extended by a factor p ...............................................
function o = yrange(l, u, p)
  if (l == u)
    o = l+[-1 1];
  else
    o = (u+l)/2+(u-l)*p/2*[-1 1];
  end
end

% vectorize ........................................................................................
function o = vec(i)
  o = i(:);
end

% setting optional arguments .......................................................................
function varargout = setopts(v, e)
	for i = 1:numel(e)/2
		varargout{i} = getdef(v, e{2*i-1}, e{2*i});
	end
end
function o = getdef(v, e, d)
  for i = 1:numel(v)/2
		if strcmp(v{2*i-1}, e)
			o = v{2*i};
			return
		end
	end
  o = d;
end

% gets called when the data cursor position changes ................................................
function o = datacurfcn(~, evt, hf)
  haxp = get(get(evt,'Target'), 'Parent');
  h = guidata(hf);

  % check which axes was clicked on
  if haxp == h.axes1
    
    p = get(evt, 'Position');
    h.ix = p(1);
    h.iy = p(2);
    h.val = h.im(h.iy, h.ix, h.iz, h.it);
    o = sprintf('x: %d, y: %d, value: %g', h.ix, h.iy, h.val);
    
    % update time-series plot
    ydata = squeeze(h.im(h.iy,h.ix,h.iz,:));
    set(h.plot1, 'XData', h.tl', 'YData', ydata);
    
    % update cursor position in image and coordinate display
    set(h.imcur, 'XData', h.ix, 'YData', h.iy);
    set(h.text2, 'String', sprintf('(x,y,z) = (%d,%d,%d)',h.ix,h.iy,h.iz));

  elseif haxp == h.axes2
    
    p = get(evt, 'Position');
    h.it = find(h.tl==p(1));
    o = sprintf('x: %g, y: %g', p(1), p(2));
    ydata = squeeze(h.im(h.iy,h.ix,h.iz,:));

    % update slice image
    set(h.image1, 'CData', h.im(:,:,h.iz,h.it));   

  end
  
  % update time-point indicator on time-series plot
  yl = yrange(min(ydata), max(ydata), h.ypad);
  set(h.plcur, 'XData', h.tl(h.it)*[1,1], 'YData', [yl(1)-1,yl(2)+1]);
  set(h.axes2, 'ylim', yl);

  guidata(hf, h);
end

% --- Executes just before show4d is made visible. .................................................
function show4d_OpeningFcn(hf, eventdata, h, varargin)
  % must supply at least one argument
  if length(varargin) < 1, error('usage: show4d(<4D-image>)'); end;

  % set and initialize various data
  h.im = abs(varargin{1});
  [h.ny, h.nx, h.nz, h.nt] = size(h.im);
  h.iy = round(h.ny/2);
  h.ix = round(h.nx/2);
  h.iz = 1;
  h.it = 1;
  
  [h.tl, h.tt, h.clim, h.ypad] = setopts(varargin(2:end), {'tl', 1:h.nt, 'tt', '', ...
    'clim', 'slice', 'ypad', 1.1});

  % display initial slice image + cursor
  axes(h.axes1);
  h.image1 = imshow(h.im(:,:,h.iz,h.it), [], 'Parent', h.axes1);
  hold(h.axes1, 'on');
  h.imcur = plot(h.ix, h.iy, 'r+');
  l = min(vec(h.im(:,:,h.iz,:))); u = max(vec(h.im(:,:,h.iz,:)));
  l = 0; u = +1e4;
  caxis(h.axes1, [l u]);

  % display initial time series plot + time-point indicator
  ydata = squeeze(h.im(h.iy,h.ix,h.iz,:));
  h.plot1 = plot(h.axes2, h.tl, ydata);
  set(h.axes2, 'xlim', [h.tl(1) h.tl(end)]);
  hold(h.axes2, 'on');
  yl = yrange(min(ydata), max(ydata), h.ypad);
  h.plcur = plot(h.axes2, [h.it h.it], [yl(1)-1;yl(2)+2], 'r');
  set(h.axes2, 'ylim', yl);
  xlabel(h.axes2, h.tt);

  % coordinate display
  set(h.text2, 'String', sprintf('(x,y,z) = (%d,%d,%d)',h.ix,h.iy,h.iz));

  % enable data cursor and set function
  dcm = datacursormode(hf);
  set(dcm, 'Enable', 'on', 'DisplayStyle', 'window', 'UpdateFcn', {@datacurfcn, hf});

  % set slider parameters
  if h.nz == 1
    set(h.slider1, 'Enable', 'off');
  else
    dz = 1/(h.nz-1);
    set(h.slider1, 'Min', 1, 'Max', h.nz, 'Value', 1, 'SliderStep', [dz dz]);
  end

  % other stuff ...
  h.current_data = h.im;
  h.output = hf;
  guidata(hf, h);
end

% --- Outputs from this function are returned to the command line. .................................
function varargout = show4d_OutputFcn(hf, eventdata, h) 
  % varargout  cell array for returning output args (see VARARGOUT);
  % hf    handle to figure
  % eventdata  reserved - to be defined in a future version of MATLAB
  % h    structure with h and user data (see GUIDATA)

  % Get default command line output from h structure
  varargout{1} = h.output;
end

% --- Executes on slider movement. .................................................................
function slider1_Callback(hf, eventdata, h)
  % hf    handle to slider1 (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % h    structure with h and user data (see GUIDATA)

  % Hints: get(hf,'Value') returns position of slider
  %        get(hf,'Min') and get(hf,'Max') to determine range of slider

  h.iz = round(get(h.slider1, 'Value'));
  set(h.slider1, 'Value', h.iz);                     % so slider pos corresponds to slice #
  set(h.text1, 'String', ['Slice ' int2str(h.iz)]);  % set slice # display
  
  % update coordinate display
  set(h.text2, 'String', sprintf('(x,y,z) = (%d,%d,%d)',h.ix,h.iy,h.iz));

  % update slice image and clim (if needed)
  set(h.image1, 'CData', h.im(:,:,h.iz,h.it));
  if strcmp(h.clim, 'slice')
    l = min(vec(h.im(:,:,h.iz,:))); u = max(vec(h.im(:,:,h.iz,:)));
    caxis(h.axes1, [l u]);
  end
  
  % update time-series plot
  ydata = squeeze(h.im(h.iy,h.ix,h.iz,:));
  set(h.plot1, 'XData', h.tl', 'YData', ydata);
  
  % update time-point indicator on time-series plot
  yl = yrange(min(ydata), max(ydata), h.ypad);
  set(h.plcur, 'XData', h.tl(h.it)*[1,1], 'YData', [yl(1)-1,yl(2)+1]);
  set(h.axes2, 'ylim', yl);
  
  guidata(hf, h);
end


% --- Executes during object creation, after setting all properties. ...............................
function slider1_CreateFcn(hf, eventdata, h)
  % hf    handle to slider1 (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % h    empty - h not created until after all CreateFcns called

  % Hint: slider controls usually have a light gray background.
  if isequal(get(hf,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hf,'BackgroundColor',[.9 .9 .9]);
  end
end
