function o = verse(g, rf)
  %
  %  reshapes an rf pulse based on the concurrent gradient so that the deposited
  %  B1 weighting is the same as the original rf pulse.
  %
  %  function o = verse(rf, g)
  %
  %  inputs ....................................................................
  %  g                gradient waveform. (vector)
  %  rf               rf pulse. (vector)
  %
  %  outputs ...................................................................
  %  o                reshaped rf pulse. (vector)
  %

  k = cumsum(g);
  k = k/max(k);
  n = length(rf);
  x = linspace(0,1,n);
  o = interp1(x, rf, k);
  o = o(:);

end

