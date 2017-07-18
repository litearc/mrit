% this demo shows the design and response of an EPI RF pulse
clear

% parameters
dx = 4;    % width of excited region along x
dy = 8;    % " along y
tbx = 4;   % time-bandwidth along x
tby = 6;   % " along y
repy = 32; % position of first alias/replicate along y

p = [            ...
  -dx dx 16;     ... % x positions to simulate over
  -repy repy 64; ... % y positions to simulate over
];

% generate rf pulse and gradient
[rf,g] = rfepi(dx, dy, tbx, tby, repy);

% run bloch simulator
M = bloch(rf, g, p);

% display response
mxy = M(:,:,1,1)+1i*M(:,:,1,2);
lr = @(r) vec(linspace(p(r,1), p(r,2), p(r,3)));

% display rf pulse and response
figure; fig(6, 2, 'units', 'inches');
subplot(1,3,1);
t = .004*[0:length(rf)-1];
mplot({}, t, [real(rf) imag(rf)], 't (ms)', 'B_1 (G)', 'rf pulse');
axis square;
subplot(1,3,2);
mplot({}, t, g, 't (ms)', 'G_x, G_y (G/cm)', 'gradients');
axis square;
subplot(1,3,3);
imagesc(lr(2), lr(1), abs(mxy));
colormap gray; axis image;
xlabel('y (cm)'); ylabel('x (cm)');
title('response');

