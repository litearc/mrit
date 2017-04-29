% this demo shows the design and inversion and spin-echo responses of an
% adiabatic hyperbolic-secant pulse
clear

% parameters
dt = .004;   % ms
gam = 4.258; % gamma
mu = 2*pi;   % `mu' and `b' control the shape of the pulse
b = 1;       % the pulse bandwidth is given by: mu*b/pi
A0 = 5;      % pulse amplitude scale factor
T = 10;      % pulse length (ms)

% design rf pulse
rf = rfhs(mu, b, A0, T, 'show', 1);
n = length(rf);

bw = mu*b/pi; % kHz
p = [ -bw bw 64 ]; % frequencies to simulate over

% inversion ....................................................................

% the bloch function takes an input gradient in G/cm, so we need to set the
% gradient amplitude to generate the appropriate frequencies over the range.
% i.e. gam*G*bw = bw; -> G = 1/gam
G = 1/gam;
M = bloch(rf, [G*ones(n,1)], p);
mz = Mz(M);

% spin echo ....................................................................

% excitation pulse parameters
T1 = 8;            % ms
n1 = round(T1/dt); % # points
tb1 = 16;          % time-bandwidth
bw1 = tb1/T1;      % kHz

% excitation pulse
rf1 = vec(wsinc(n1, tb1));
rf1 = rf1/sum(rf1)/(4*gam*dt); % scale to pi/2 flip angle
gr = -n1/2*ones(250,1)/250;
mxy1 = bloch([rf1; 0*gr], 1/gam*[ones(n1,1); gr], p, 'out', 'mxy');
mxy1 = imag(mxy1);
Mxy1 = mxy2M(mxy1);
gc = 4*G*ones(round(n/10),1); % crusher
mxy2 = bloch([0*gc;rf;0*gc], [gc;G*ones(n,1);gc], p, 'M0', Mxy1, 'out', 'mxy');

% ..............................................................................

% display responses
figure; fig(8, 2, 'units', 'inches');
subplot(1,3,1);
f = a2ls(p);
mplot({}, f, mz, 'f (kHz)', 'M_z', 'inversion profile');
subplot(1,3,2);
mplot({}, f, mxy1, 'f (kHz)', 'M_z', 'excitation profile');
subplot(1,3,3);
mplot({}, f, mxy2, 'f (kHz)', 'M_z', 'spin-echo profile');

% show bloch simulation
blochvis = 2; % 1: inversion, 2: spin-echo
switch blochvis
  case 1
    Mt = bloch(rf, 1/gam*ones(n1,1), [0 0 1], 'time', 1);
    Mt = permute(Mt, [4 5 1 2 3]);
    viewbloch(Mt, 'rf', rf, 'B1mod', 'fm');
  case 2 
    gse = [1/gam*[ones(n1,1); gr];gc;G*ones(n,1);gc];
    % this shows the bloch evolution of 5 spins at frequencies from -bw/4 to +bw/4
    Mt = bloch([rf1;0*gr;0*gc;rf;0*gc], gse, [-bw/4 bw/4 5], 'time', 1);
    Mt = permute(Mt, [4 5 1 2 3]);
    viewbloch(Mt, 'rf', [rf1;0*gr;0*gc;rf;0*gc], 'g', gse, 'B1mod', 'fm');
end 

