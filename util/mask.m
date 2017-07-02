function m = mask(im, varargin) 
  %
  %  creates a mask of 'im' based on image intensity. specifically, this finds
  %  the largest drop in the histogram, with the idea that the background makes
  %  up a substantial part of the image, and background and foreground usually
  %  fall into non-adjacent bins.
  %
  %  function m = mask(im, varargin)
  %
  %  inputs ....................................................................
  %  im               input image. (N-D array)
  %
  %  options ...................................................................
  %  nbins            # bins to use for the histogram. (int) (default = 10)
  %
  %  outputs ...................................................................
  %  m                output mask. (logical N-D array)
  %

  % set default arguments
  v = ap2s(varargin);
  nbins = def(v, 'nbins', 10);

  % in case image is complex (assume not negative)
  im = abs(im);

  % get histogram.
  a = im(:);
  h = hist(a, nbins);

  % find sharpest dropoff in intensity.
  d = abs(diff(h));
  [~,i] = max(d); 

  % size of intensity range for each bin.
  di = (max(a)-min(a))/nbins;

  % cutoff intensity.
  co = di*i; 
  
  % only get pixels higher than cutoff.
  m = (im>co);

end
