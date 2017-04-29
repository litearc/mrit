function M = mxy2M(mxy)
  %
  %  converts the transverse magnetization (in complex form) to magnetization
  %  in the form of the 'bloch' function.
  %
  %  function M = mxy2M(mxy)
  %
  %  input .....................................................................
  %  mxy              tranverse magnetization. [x y z t] (complex)
  % 
  %  output ....................................................................
  %  M                magnetization. [x y z (Mx,My,Mz) t]
  %

  [nx,ny,nz,nt] = size(mxy);
  M = zeros(nx,ny,nz,3,nt);
  M(:,:,:,1,:) = real(mxy);
  M(:,:,:,2,:) = imag(mxy);

end

