function mz = Mz(M)
  %
  %  returns the longitudinal magnetization from the output of the 'bloch'
  %  function.
  %
  %  function mz = Mz(M)
  %
  %  input .....................................................................
  %  M                magnetization (output of bloch.m). [x y z (Mx,My,Mz) t]
  %
  %  output ....................................................................
  %  mxy              longitudinal magnetization component. [x y z t]
  %

  mz = squeeze(M(:,:,:,3,:));

end

