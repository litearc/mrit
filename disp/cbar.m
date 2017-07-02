function hc = cbar(varargin)
  %
  %  creates a colorbar without resizing the image.
  %
  %  function hc = cbar(varargin)
  %
  %  options ...................................................................
  %  label            colorbar label. (string)
  %  lims             colorbar limits. [(low, high)]
  %
  %  outputs ...................................................................
  %  hc               colorbar handle. (float)
  %

  % set default arguments
  v = ap2s(varargin);
  label = def(v, 'label', []);
  lims  = def(v, 'lims', []);

  h1 = get(gca, 'Position');
  hc = colorbar;
  if ~isempty(label)
    xlabel(hc, label);
  end
  if ~isempty(lims)
    clim = caxis;
    if isnan(lims(1)), lims(1) = caxis(1); end
    if isnan(lims(2)), lims(2) = caxis(2); end
    caxis(lims);
  end
  h2 = get(gca, 'Position');
  set(gca, 'Position', h1);

end

