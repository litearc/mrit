% reconstructs epi data for uniform agar phantom ...............................
clear, load epi1ch

% reconstruct 2dft data
mdft = dft2(rd);

% # points along readout direction. this is used in the epi recon to make the
% image the same size as the 2dft image, but isn't necessary.
nx = size(mdft,1);

% reconstruct epi data
mepi = repi(e, r, k, 'nx', nx, 'tell', 0);

% display data
imdisp(mdft, 'title', '2DFT');
imdisp(mepi, 'title', 'EPI');

