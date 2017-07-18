% this demo shows the design and response of a SPSP RF pulse
clear

% parameters
dt = .004;   % ms
gam = 4.258; % gamma
dx = .5;     % width of excited region along x
df = .2;     % " along f
tbx = 4;     % time-bandwidth along x
tbf = 3;     % " along f
repf = .6;   % position of first alias/replicate along f

p = [            ...
  -dx dx 64;     ... % x positions to simulate over
  -repf repf 64; ... % y positions to simulate over
];

% flyback ......................................................................

% generate rf pulse and gradient
[rf g] = spsp(dx, df, tbx, tbf, repf);
n = length(rf);

% the bloch simulator expects the gradient units to be G/cm which yield k-space
% coordinates that are in units 1/cm. since we want a frequency response in
% units of kHz, we want the 'k-space' units to be 1/kHz, or ms. thus, we need
% gam*dt*sum(G) = length(g)*dt, where length(g)*dt is the total gradient duration
% in ms traversed in 'k-space'. since sum(G) = G*length(g), this gives G = 1/gam
% so, to get the frequency response, we simply set another gradient axis with
% a constant waveform of amplitude G.
G = 1/gam;
M = bloch(rf, [g G*ones(n,1)], p);
mxy = Mxy(M);
lr = @(r) vec(linspace(p(r,1), p(r,2), p(r,3)));

% display rf pulse and response
figure('name', 'flyback SPSP pulse'); fig(6, 2, 'units', 'inches');
subplot(1,3,1);
t = dt*[0:length(rf)-1];
mplot({}, t, rf, 't (ms)', 'B_1 (G)', 'rf pulse');
axis square;
subplot(1,3,2);
mplot({}, t, g, 't (ms)', 'G_x (G/cm)', 'gradients');
axis square;
subplot(1,3,3);
imagesc(lr(2), lr(1), abs(mxy));
colormap gray; axis image;
xlabel('f (kHz)'); ylabel('x (cm)');
title('response');

% no flyback ...................................................................

% generate rf pulse and gradient
[rf g] = spsp(dx, df, tbx, tbf, repf, 'flyback', 0);
n = length(rf);

% get response
G = 1/gam;
M = bloch(rf, [g G*ones(n,1)], p);
mxy = Mxy(M);
lr = @(r) vec(linspace(p(r,1), p(r,2), p(r,3)));

% display rf pulse and response
figure('name', 'no flyback SPSP pulse'); fig(6, 2, 'units', 'inches');
subplot(1,3,1);
t = dt*[0:length(rf)-1];
mplot({}, t, rf, 't (ms)', 'B_1 (G)', 'rf pulse');
axis square;
subplot(1,3,2);
mplot({}, t, g, 't (ms)', 'G_x (G/cm)', 'gradients');
axis square;
subplot(1,3,3);
imagesc(lr(2), lr(1), abs(mxy));
colormap gray; axis image;
xlabel('f (kHz)'); ylabel('x (cm)');
title('response');

