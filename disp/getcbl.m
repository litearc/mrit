function [t, l] = getcbl(lims, varargin)
  %
  %  given a range of values for a colorbar, this computes a reasonable set of
  %  tick position and corresponding labels.
  %
  %  note: either the height 'h' or colorbar handle 'hcb' must be provided.
  %
  %  function [t, l] = getcbl(h, lims, varargin)
  %
  %  inputs ....................................................................
  %  lims             min and max values of colorbar. [(min, max)]
  %
  %  options ...................................................................
  %  h                colorbar height in pixels. (int)
  %  hc               handle to colorbar. (float)
  %  hf               handle to figure. (float)
  %  lset             set labels? this requires handles to the colorbar and
  %                   figure be provided. <0, 1> (default = 1)
  %  lspc             approximate label spacing in pixels. (float)
  %                   (default = 32)
  %
  %  outputs ...................................................................
  %  t                tick positions, given as values in the colorbar. (vector)
  %  l                tick labels. (cell array of strings)
  %

  % set default arguments
  v = ap2s(varargin);
  h    = def(v, 'h', []);
  hc   = def(v, 'hc', []);
  hf   = def(v, 'hf', []);
  lset = def(v, 'lset', 1);
  lspc = def(v, 'lspc', 32);

  if ~isempty(hf) && ~isempty(hc)
    a = get(hf, 'Position'); a = a(4);
    b = get(hc, 'Position'); b = b(4);
    h = a*b;
  end

  vn = lims(1);
  vm = lims(2);
  r = vm-vn;
  dv = r/h*lspc; % value spacing
  s = sprintf('%e', dv);
  i = find(s=='e');
  d = str2num(s(1:i-1));   % decimal
  e = str2num(s(i+1:end)); % exponent
  dr = round(d);
  dvr = dr*10.^(e);
  rr = floor(vn/dvr)*dvr-dvr:dvr:ceil(vm/dvr)*dvr+dvr;
  rr(rr<vn | rr>vm) = [];
  t = rr;
  for i = 1:length(t)
    l{i} = sprintf('%g', t(i)); % let matlab decide how to format number
  end

  if lset && ~isempty(hc)
    cl = get(hc, 'Limits');
    tm = linmap(t, lims, cl);
    set(hc, 'YTick', tm, 'YTickLabel', l);
  end

end

