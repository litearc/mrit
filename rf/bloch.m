function [M, t] = bloch(rf, g, p, varargin)
  %
  %  simulates the response to an rf pulse using the hard-pulse approximation.
  %
  %  function M = bloch(rf, g, p, varargin)
  %
  %  input .....................................................................
  %  rf               complex rf-pulse. (vector) (G)
  %  g                gradient waveform(s). this is a matrix with 1, 2, or 3
  %                   columns that contain the gx, gy, and gz gradient
  %                   waveforms. [gx gy gz] (G/cm)
  %  p                specifies spatial positions at which to simulate the
  %                   response (cm). this is a matrix with 1, 2, or 3 rows,
  %                   and 2 or 3 columns:
  %                   | xl xu nx |  xl and xu are the lower and upper limits 
  %                   | yl yu ny |  along x, and nx is the # of points along x
  %                   | zl zu nz |  (same with y and z). if 2 columns are given,
  %                                 the # points are set to 'np'.
  %
  %  options ...................................................................
  %  dt               sample time. (ms) (default = .004)
  %  gam              gyromagnetic ratio. (kHz/G) (default = 4.258)
  %  M0               initial magnetization. [nx ny nz 3]
  %                   (default = [0 0 1] array)
  %  T1               T1. (ms) [nx ny nz] (default = ignore T1 relaxation)
  %  T2               T2. (ms) [nx ny nz] (default = ignore T2 relaxation)
  %  B0               B0 field map. (Hz) [nx ny nz] (default = 0s array)
  %  B1               B1 field map (scale factor). (float) [nx ny nz]
  %                   (default = 1s array)
  %  np               # points at which to simulate response. (int)
  %                   (default = 64)
  %  mex              use mex version of simulation. <0, 1> (default = use if
  %                   available)
  %  out              output type:
  %                   'mxy' : output mxy = mx + 1i*my
  %                   'mz'  : output mz
  %                   'all' : output [x y z (Mx,My,Mz)] array (default)
  %  time             if time = 1, outputs M as a [x y z (Mx,My,Mz) time] array.
  %                   <0, 1> (default = 0)
  %
  %  outputs ...................................................................
  %  M                magnetization response. [nx ny nz 3]
  %
  
  [dt, gam, M0, T1, T2, B0, B1, np, use_mex, out, time] = setopts(varargin, ...
    {'dt', .004, 'gam', 4.258, 'M0', [], 'T1', [], 'T2', [], 'B0', [], ...
    'B1', [], 'np', 64, 'mex', [], 'out', 'all', 'time', 0});
  
  [nrows, ncols] = size(p);
  rf = rf(:);

  % set nx, ny, nz depending on # columns in x
  if ncols == 3
    nx = p(1,3);
    if nrows >= 2, ny = p(2,3); end
    if nrows >= 3, nz = p(3,3); end
  else
    nx = np;
    ny = np; % this may get overwritten below
    nz = np; % "
  end

  % set default y and z positions, if not specified
  if nrows < 3, p(3,1) = 0; p(3,2) = 0; nz = 1; end
  if nrows < 2, p(2,1) = 0; p(2,2) = 0; ny = 1; end
  p(2,3) = ny;
  p(3,3) = nz;

  [xm,ym,zm] = ndgrid(linspace(p(1,1),p(1,2),nx), ...
    linspace(p(2,1),p(2,2),ny), linspace(p(3,1),p(3,2),nz));
  x = cat(4, xm, ym, zm);

  % initialize various optional parameters
  if isempty(M0), M0 = repmat(reshape([0 0 1],1,1,1,3), [nx, ny, nz, 1]); end
  if ndims(M0) == 2, M0 = repmat(reshape(M0,1,1,1,3), [nx, ny, nz, 1]); end
  if isempty(B0), B0 = zeros(nx, ny, nz); end
  if isempty(B1), B1 = ones(nx, ny, nz); end
  if isempty(T1), T1 = -1*ones(nx, ny, nz); end
  if isempty(T2), T2 = -1*ones(nx, ny, nz); end
  if isempty(use_mex), use_mex = exist('blochm'); end
  
  if time == 0, nt = 1; else nt = length(rf); end
  M = zeros(nx, ny, nz, 3, nt);
  lg = size(g, 1);

  % make gradient 3 columns
  if size(g,2) < 3
    g(lg,3) = 0;
  end

  % run bloch simulation
  if use_mex
    M = blochm(complex(rf), g, p, dt, gam, M0, T1, T2, B0, complex(B1), time);
  else
    % compute response at each position
    for ix = 1:nx, for iy = 1:ny, for iz = 1:nz
      m = vec(M0(ix,iy,iz,:));
      for ig = 1:lg
        % rf pulse
        e = angle(rf(ig))+angle(B1(ix,iy,iz)); % rf pulse phase
        u = -[cos(e) sin(e) 0]; % unit vector axis of rotation
        a = 2*pi*gam*dt*abs(rf(ig))*abs(B1(ix,iy,iz)); % rotation angle
        m = rot(a,u)*m;
        % free precession
        a = 2*pi*gam*dt*g(ig,:)*vec(x(ix,iy,iz,:)) + 2*pi*dt*B0(ix,iy,iz)*1e-3;
        m = rotz(a)*m;
        % T2 decay, T1 relaxation
        if T2(ix,iy,iz) ~= -1, m(1:2) = m(1:2)*exp(-dt/T2(ix,iy,iz)); end
        if T1(ix,iy,iz) ~= -1, m(3) = m(3)+(1-m(3))*(1-exp(-dt/T1(ix,iy,iz))); end
        % store magnetization if outputting time dimension
        if time == 1, M(ix,iy,iz,:,ig) = reshape(m, [1,1,1,3]); end
      end
      if time == 0, M(ix,iy,iz,:) = reshape(m, [1,1,1,3]); end
    end, end, end
  end

  switch out
    case 'mxy'
      M = M(:,:,:,1,:)+1i*M(:,:,:,2,:);
    case 'mz'
      M = M(:,:,:,3,:);
  end

end

% ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-

% rotation matrix for rotation of angle 'e' about axis defined by u
% from wikipedia page: https://en.wikipedia.org/wiki/Rotation_matrix
function R = rot(e, u)
  ux = u(1); uy = u(2); uz = u(3);
  c = cos(e); s = sin(e);
  R = [
    c+ux^2*(1-c)      ux*uy*(1-c)-uz*s  ux*uz*(1-c)+uy*s;
    uy*ux*(1-c)+uz*s  c+uy^2*(1-c)      uy*uz*(1-c)-ux*s;
    uz*ux*(1-c)-uy*s  uz*uy*(1-c)+ux*s  c+uz^2*(1-c)
  ];
end

% ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-

% rotation about z axis
function R = rotz(e)
  R = [
    cos(e)  sin(e) 0;
    -sin(e) cos(e) 0;
    0       0      1;
  ];
end

