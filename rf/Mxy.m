function mxy = Mxy(M)
  %
  %  returns the transverse magnetization (in complex form) from the output of
  %  the 'bloch' function.
  %
  %  function mxy = Mxy(M)
  %
  %  input .....................................................................
  %  M                magnetization (output of bloch.m). [x y z (Mx,My,Mz) t]
  %
  %  output ....................................................................
  %  mxy              transverse magnetization component. [x y z t]
  %

  mxy = squeeze(M(:,:,:,1,:)+1i*M(:,:,:,2,:));

end
