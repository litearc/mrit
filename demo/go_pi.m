% this script shows simple grappa and sense reconstructions from 2DFT data.
% the original data is fully sampled, so is undersampled in simulation.
% for epi reconstructions from (actually) undersampled data, look at the
% 'go_reconepilg' demo.

% load data
clear, load dft8ch

[nx,ny,nc] = size(r);

% full dataset recon
m = dft2(r);

% undersampled dataset
ru = r;
ru(:,2:2:end,:) = 0;
mu = dft2(ru); % image from undersampled data

% grappa recon .................................................................

% get grappa coefficients
gk = [1 0 1; 1 2 1; 1 0 1]; % kernel
gc = grap2coef(r(:,cen(8,64),:), gk);

% filled in entries
x = zeros(nx,ny);
x(:,1:2:end) = 1;

% fill in missing entries with grappa
rg = grap2fill(ru, x, gk, gc);
mg = dft2(rg); % image from grappa recon

% the grappa recon could also have been done using the 'grap2dft' function,
% which calls the 'grap2coef' and 'grap2fill' functions as needed.
% s = zeros(1,64); s(1:2:end) = 1;
% ru = r(:,find(s),:);
% ma = grap2dft(ru, s, r(:,cen(8,64),:));

% sense recon ..................................................................

ruc = ru(:,1:2:end,:);
muc = dft2(ruc, 'comb', 'no');
ms = sense(muc, c); % image from sense recon

% display image ................................................................
figure; fig(8, 2, 'units', 'inches');
subplot(1,4,1); imshow(abs(m), []); title('fully sampled');
subplot(1,4,2); imshow(abs(mu), []); title('undersampled R = 2');
subplot(1,4,3); imshow(abs(mg), []); title('GRAPPA R = 2');
subplot(1,4,4); imshow(abs(ms), []); title('SENSE R = 2');

