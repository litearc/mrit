function M = mz2M(mz)
  %
  %  converts the longitudinal magnetization (in complex form) to magnetization
  %  in the form of the 'bloch' function.
  %
  %  function M = mz2M(mz)
  %
  %  input .....................................................................
  %  mz               longitudinal magnetization. [x y z t]
  % 
  %  output ....................................................................
  %  M                magnetization. [x y z (Mx,My,Mz) t]
  %

  [nx,ny,nz,nt] = size(mz);
  M = zeros(nx,ny,nz,3,nt);
  M(:,:,:,3,:) = mz;

end

