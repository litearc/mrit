% reconstruct epi data for phantom with large linear gradient off-resonance ....
clear, load epixy

mdft = dft2(r1);
[nx,ny] = size(mdft);
mepi = zeros(nx,ny,16);
tell = 0;

disp('There are various reconstruction options for the EPI data.');
disp('Look inside the script for more details and usage.');

% set these parameters to do different recons
R = 2;           % acceleration factor. 1 or 2
ref = '2D';      % nyquist correction method. ('1D' or '2D')
fmc = 1;         % do field map correction? 0:no, 1:yes
pit = 'grappa';  % parallel imaging recon type (only used if R = 2). ('grappa' or 'sense')
uds = 'acs';     % undersampled dataset.
                 %   'unif' : uniformly undersampled (used if pit = 'sense')
                 %   'acs'  : sampled with calibration lines (can only be used with pit = 'grappa')
gc = '2dft';     % where to get grappa coefficients from (only used if pit = 'grappa')
                 %   '2dft': compute from the 2dft scan
                 %   'acs' : compute from acs lines

switch [int2str(R) ref]
  case '11D', d = r2; nr = 1; es = es2;
  case '12D', d = r3; nr = 2; es = es2;
  case '21D'
    if strcmp(pit,'grappa')
      nr = 1; es = es5;
      if strcmp(uds,'unif'), d = r5; l = samplines5; end
      if strcmp(uds,'acs'),  d = r6; l = samplines6; end
    end
    if strcmp(pit,'sense'),  d = r5; nr = 1; es = es5; end
  case '22D'
    if strcmp(pit,'grappa')
      nr = 2; es = es5;
      if strcmp(uds,'unif'), d = r7; l = samplines5; end
      if strcmp(uds,'acs'),  d = r8; l = samplines6; end
    end
    if strcmp(pit,'sense'),  d = r7; nr = 2; es = es5; end
end

if fmc, B0map = o4; else B0map = []; end

e = d(:,:,:,:,nr+1); % epi data
r = d(:,:,:,:,1:nr); % nyquist correction reference data

switch R
  case 1
    mepi = repi(e, r, k, 'es', es, 'nx', nx, 'tell', tell, 'B0map', B0map);
  case 2
    if strcmp(pit, 'grappa')
      if strcmp(gc, '2dft'), mepi = repi(e, r, k, 'es', es, 'nx', nx, 'tell', tell, 'B0map', B0map, 'l', l, 'f', r1); end
      if strcmp(gc, 'acs'),  mepi = repi(e, r, k, 'es', es, 'nx', nx, 'tell', tell, 'B0map', B0map, 'l', l, 'acs', acslines6); end
    end
    if strcmp(pit, 'sense')
      mepi = repi(e, r, k, 'es', es, 'nx', nx, 'tell', tell, 'out', 'k'); % get k-space
      mepi = dft2(mepi, 'comb', 'no'); % get coil images
      mepi = sense(mepi, c, 'tell', 0);
      if ~isempty(B0map)
        mepi = mfftc(mepi);
        mepi = epifmc(mepi, B0map, 'dt', es/R, 'tell', 0);
      end
    end
end

imdisp(o4, 'ucmap', 'jet', 'cblab', 'Hz', 'title', 'B_0 map', 'defmag', 2);
figure; fig(5,2,'units','inches');
subplot(1,2,1); imshow(abs(mdft), []); title('2DFT');
subplot(1,2,2); imshow(abs(mepi), []); title('EPI');

