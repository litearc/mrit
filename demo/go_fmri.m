% processes fmri data acquired using a simple block-design task
load fmri;
load hrf;

% create task regressor. the task was a 5 min 30 s visual + sensory-motor block
% design task with 30 s ON and OFF blocks. since the hrf is sampled at a
% different scale than the fmri data, we first create the task regressor at the
% hrf scale and then % downsample to the fmri scale.
dt = .1; % sample time for hrf (s)
tr = 2;  % (s)
r = tr/dt;
nt = size(m, 4);
bd = repmat([zeros(1,15*r) ones(1,15*r)], [1,10])';
ts = conv(bd, hrf);
ts = ts(floor(r/2)+[1:r:nt*r]);

% compute the gradient of the task regressor to account for hrf delays in
% different regions of the brain
gts = gradient(ts);

% mask the fmri image
s = mask(m(:,:,:,1));
se = strel('square', 3);
s = imopen(s, se);
m = m.*repmat(s, [1 1 1 nt]);

% compute activation maps. the glm does 4th-order polynomial detrending by
% default (see glm.m for what the various arguments do).
[t,c,p] = glm(m, ts, gts, tr, 'dob', 1, 'sdb', .25);
th = cstat('p', 't', 1e-6, nt, 'tr', tr); % t-score for p < 1e-6

% display image (see imdisp.m for what the various arguments do).
% the slices were acquired at an oblique orientation, so they look a little
% "squished" in the A/P direction. the brain is oriented so that anterior
% faces "up" on the screen.
imdisp(m(:,:,:,1), 'o', t, 'oith', th, 'cblab', 't-score', ...
  'olim', max(abs(t(:)))*[-1 1]);
set(gcf, 'name', 'fMRI activation map');

% display raw image data
show4d(m);

