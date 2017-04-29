function h = imdisp(u, varargin)
  %
  %  displays slices of an multidimensional array, where the first two
  %  dimensions contain individual slices. the higher dimensions, i.e. >= 3, are
  %  collapsed, i.e. the slices are simply displayed as an array. if the input
  %  is complex, the magnitude is displayed.
  %
  %  the following keys can be pressed to do different things:
  %  - : decrease magnification.
  %  + : increase magnification.
  %  0 : resize to nearest integer magnification.
  %  c : cycle through colormaps.
  %  b : toggle colorbar. (note: if the colorbar is outside the figure area, it
  %      will not be visible, i.e. the program does not resize the window)
  %  s : toggle between scaling each image independently or not
  %  q : closes figure.
  %  [ : if overlay is specified, lower threshold.
  %  ] : if overlay is specified, raise threshold.
  %
  %  function h = imdisp(m, varargin)
  %
  %  inputs ....................................................................
  %  u                underlay image (input array of slices). [x y ...]
  %
  %  options ...................................................................
  %  nrows            # of rows. (int) (default = make figure roughly square)
  %  cbon             display colorbar? <0, 1> (default = 0)
  %  cblab            colorbar label. (string) (default = '')
  %  defmag           default magnification. (float) (default = 1)
  %  title            figure title. (string) (default = '')
  %  o                overlay image (e.g. activation map). must be same size as
  %                   underlay `u'. [x y ...] (default = none)
  %  onth             # overlay threshold levels. (int) (default = 20)
  %  oith             initial threshold value. (float) (default = 19th
  %                   threshold value)
  %  olim             overlay limits. (2-vector) (default = calculate from
  %                   `olim')
  %  ulim             underlay limits. (2-vector) (default = calculate
  %                   from `ulim')
  %  t                significance image. (e.g. t-value map). must be same size
  %                   as underlay `u'. (default = overlay image). if supplied,
  %                   this will be used for thresholding the overlay image.
  %  ucmap            colormap to use for underlay. (string) (default = 'gray')
  %
  %  outputs ...................................................................
  %  h                figure handle. (float)
  %

  [nrows, cbon, cblab, ftitle, defmag, o, onth, oith, olim, ulim, t, ucmap] = ...
    setopts(varargin, {'nrows', [], 'cbon', 0, 'cblab', '', 'title', '', ...
    'defmag', 1, 'o', [], 'onth', 20, 'oith', [], 'olim', [], 'ulim', [], ...
    't', [], 'ucmap', []});

  % not really important (somewhat arbitrary) values
  cbes = 80;   % colorbar figure extra space
  cbw = 16;    % colorbar width
  cbles = 20;  % colorbar label extra space
  cblpad = 16; % space to the left of colorbar
  tes = 40 ;   % title extra space
  xpad = 100;  % figure does not take up entire screen, this accounts for it
  ypad = 100;

  % padding around main part of figure (images) for things like title, ...
  upad = 0; dpad = 0; lpad = 0; rpad = 0;

  % set UDLR padding ...........................................................
  function setpads()
    upad = 0; dpad = 0; lpad = 0; rpad = 0;
    if tlon
      upad = upad+tes;
      dpad = dpad+tes;
    end
    if cbon
      lpad = lpad+cblpad+cbes;
      rpad = rpad+cblpad+cbes;
      if ~strcmp(cblab, '')
        lpad = lpad+cbles;
        rpad = rpad+cbles;
      end
    end
  end
  
  mags = [1./[10:-1:2] 1:10]; % magnifications
  scli = false;               % scale images individually
  if strcmp(ftitle, ''), tlon = false; else tlon = true; end % show title?
  if ~strcmp(cblab, ''), cbon = 1; end
  
  % make underlay double
  if ~isreal(u), u = abs(u); end
  if islogical(u), u = double(u); end
  u = double(u);

  if isempty(ulim)
    ulim = lims(u);
  end

  % set various overlay parameters .............................................
  os = ~isempty(o);
  if os
    % min and max values for overlay colorbar
    if isempty(olim), olim = lims(o); end
    omin = olim(1);
    omax = olim(2);
    % initial overlay threshold value
    if isempty(t)
      oths = linspace(omin, omax, onth);
      if isempty(oith)
        oth = oths(onth-1);
      else
        oth = oith;
      end
      t = o;
    else
      plim = lims(t);
      oths = linspace(plim(1), plim(2), onth);
      if isempty(oith)
        oth = oths(onth-1);
      else
        oth = oith;
      end
    end
  end

  % reshape data to array of slice images ......................................
  nx = size(u, 1);
  ny = size(u, 2);
  ni = numel(u)/(nx*ny);

  % calculate # rows and columns
  if isempty(nrows)
    nr = floor(sqrt(ni));
    nc = ceil(ni/nr);
  else
    nr = nrows;
    nc = ceil(ni/nr);
  end

  % increase magnification if figure too small
  szn = [128 128]; % minimum size
  szn = [0 0];
  while defmag*nc*ny < szn(1) ||  defmag*nr*nx < szn(2)
    defmag = defmag+1;
  end

  % create figure ..............................................................
  setpads();
  hf = figure;
  fig(defmag*nc*ny+lpad+rpad, defmag*nr*nx+upad+dpad, 'units', 'pixels');
  warning('off', 'Images:initSize:adjustingMag');

  % define colormaps. note: we pre-calculate RGB images for each colormap so
  % switching between them is fast, but this also uses more memory, so don't add
  % a ton of colormaps here. if overlay is specified, underlay is drawn in gray
  % and only overlay colormap can be switched. also, we need to get the matlab
  % colormaps after creating the figure, or else matlab creates a new figure.
  iuc = 1; ioc = 1;
  ucols = {'gray', 'jet'};
  if os, ocols = {'jet', 'hot'}; end
  if ~isempty(ucmap)
    i = strmatch(ucmap, ucols);
    if isempty(i)
      ucols{end+1} = ucmap;
      iuc = length(ucols);
    else
      iuc = i;
    end
  end

  % format the data for 'montage' and make RGB .................................
  % underlay
  ua = arr2mon(u, [nr nc]);
  uc = {};
  for i = 1:length(ucols)
    uc{i} = cmap(ua, colormap(ucols{i}), 'clim', ulim);
  end
  % overlay
  if os
    oa = arr2mon(o, [nr nc]);
    oc = {};
    for i = 1:length(ocols)
      oc{i} = cmap(oa, colormap(ocols{i}), 'clim', olim);
    end
  end

  % underlay image array with each image scaled individually
  ua = reshape(u, nx, ny, []);
  uas = zeros(nx, ny, ni);
  for i = 1:ni
    uas(:,:,i) = linmap(ua(:,:,i), lims(ua(:,:,i)), ulim);
  end
  uas = arr2mon(uas, [nr nc]);
  ucs = {};
  for i = 1:length(ucols)
    ucs{i} = cmap(uas, colormap(ucols{i}), 'clim', ulim);
  end

  % montage initially wants [nx ny ...] data ...................................
  ua = reshape(u, nx, ny, []);
  um = cmap(ua, colormap(ucols{iuc}), 'clim', ulim);
  if os
    oa = reshape(o, nx, ny, []);
    om = cmap(oa, colormap(ocols{ioc}), 'clim', olim);
  end

  % compute thresholds for overlay
  if os
    ia = 1;
    a = {};
    for i = 1:onth
      a{i} = arr2mon(t>oths(i), [nr nc]);
    end
  end

  % underlay image .............................................................
  hs = subplot(1,1,1);
  set(hs, 'position', [0 0 1 1]);
  hu = montage(um, 'DisplayRange', ulim, 'Size', [nr nc]);
  hold on;

  % overlay image
  if os
    ho = montage(om, 'DisplayRange', olim, 'Size', [nr nc]);
    atemp = arr2mon(t>oth, [nr nc]); % don't use a{oith} in case oith specified
    set(ho, 'AlphaData', atemp);
  end

  % colorbar
  hc = colorbar;
  ht = title(hs, ftitle);
  ylabel(hc, cblab);
  if os, getcbl(olim, 'hf', hf, 'hc', hc); end
  if cbon, set(hc,'Visible','on'); else set(hc,'Visible','off'); end
  if tlon, set(ht,'Visible','on'); else set(ht,'Visible','off'); end

  % resize callback to set subplot positions when figure is resized ............
  % this gets called even when figure is resized with set(hf, 'position', ...)
  function onresize(h, e)
    setpads();
    p = get(h, 'position');
    fw = p(3); fh = p(4);
    iw = fw-lpad-rpad;
    ih = fh-upad-dpad;
    % set start position and dimensions of subplots
    if fw/fh > (ny*nc)/(nx*nr) % figure is 'wide'
      sh = ih/nr;
      sw = sh*ny/nx;
      wi = (iw-sw*nc)/2+lpad;
      hi = upad;
    else % figure is 'tall'
      sw = iw/nc;
      sh = sw*nx/ny;
      wi = lpad;
      hi = (ih-sh*nr)/2+upad;
    end
    set(hs, 'position', [wi/fw hi/fh sw*nc/fw sh*nr/fh]);
    set(hc, 'position', [(wi+sw*nc+cblpad)/fw hi/fh cbw/fw sh*nr/fh]);
    % update colorbar labels if needed
    if os, getcbl(olim, 'hf', hf, 'hc', hc); end
  end

  % resize callback to change image magnifications on keypresses ...............
  function onkeyrelease(h, e) % had a problem with on key press (matlab bug?)
    % various toggles
    switch e.Key
      case 'u' % change underlay colormap
        if ~os
          iuc = mod(iuc, length(ucols))+1;
          if scli, set(hu, 'CData', ucs{iuc});
          else set(hu, 'CData', uc{iuc}); end
          colormap(ucols{iuc});
        end
        return
      case 'o' % change overlay colormap
        if os
          ioc = mod(ioc, length(ocols))+1;
          set(ho, 'CData', oc{ioc});
          colormap(ocols{ioc});
        end
        return
      case 'b' % toggle colorbar
        cbon = double(~cbon);
        if cbon, hc.Visible = 'on'; else hc.Visible = 'off'; end
        return
      case 't' % toggle title
        tlon = double(~tlon);
        if tlon, ht.Visible = 'on'; else ht.Visible = 'off'; end
        return
      case 's' % toggle individual image scaling
        scli = ~scli;
        if scli, set(hu, 'CData', ucs{iuc});
        else set(hu, 'CData', uc{iuc}); end
        return
      case 'q' % quit
        close(hf);
        return
    end

    % increments or decrements to nearest value in array
    function [v,i] = modr(x, xs, d)
      [~,i] = min(abs(x-xs));
      if d == 1 && i ~= length(xs), i = i+1; end
      if d == -1 && i ~= 1, i = i-1; end
      v = xs(i);
    end

    % get and update magnification
    p = get(h, 'position');
    fw = p(3); fh = p(4);
    ih = fh-upad-dpad;
    rr = ih/(nx*nr);
    setpads();
    % get screen width and height
    set(0, 'units', 'pixels');
    ss = get(0, 'screensize');
    sw = ss(3); sh = ss(4);
    % change magnification
    switch e.Key
      case 'equal'
        rr = modr(rr, mags, 1);
      case 'hyphen'
        rr = modr(rr, mags, -1);
      case '0'
        rr = modr(rr, mags, 0);
    end
    cw = rr*ny*nc+lpad+rpad;
    ch = rr*nx*nr+upad+dpad;
    if cw+xpad<=sw && ch+ypad<=sh
      set(h, 'position', [p(1:2) cw ch]);
    end

    % change overlay threshold
    if ~isempty(olim)
      oupd = 0;
      switch e.Key
        case 'rightbracket'
          [~,i] = modr(oth, oths, 1); oupd = 1;
        case 'leftbracket'
          [~,i] = modr(oth, oths, -1); oupd = 1;
      end
      if oupd
        oth = oths(i);
        set(ho, 'AlphaData', a{i});
        % update colorbar labels if needed
        getcbl(olim, 'hf', hf, 'hc', hc);
      end
    end

  end

  % the default data cursor displays the (x, y) position of the cursor within
  % the entire montage. this makes it display the (x, y) position within the
  % current slice, as well as the slice # (much more useful).
  function s = datacurfcn(~, evt, hf)
    p = get(evt, 'Position');
    ox = p(2);
    oy = p(1);
    ix = mod(ox-1,nx)+1;
    iy = mod(oy-1,ny)+1;
    rr = floor((ox-1)/nx);
    cc = floor((oy-1)/ny);
    iz = rr*nc+cc+1;
    if iz <= ni
      if os
        s = sprintf('[x,y,z] = [%d,%d,%d]\nunderlay = %g\noverlay = %g', ...
          ix, iy, iz, ua(ix, iy, iz), oa(ix, iy, iz));
      else
        s = sprintf('[x,y,z] = [%d,%d,%d]\nval = %g', ix, iy, iz, ua(ix, iy, iz));
      end
    else
      s = '';
    end
  end

  % change cursor data display
  dcm = datacursormode(hf);
  set(dcm, 'UpdateFcn', {@datacurfcn, hf});
  % set callbacks
  set(hf, 'ResizeFcn', @onresize);
  set(hf, 'WindowKeyReleaseFcn', @onkeyrelease);
  % call to set correct subplot positions, ...
  onresize(hf, []);

end

