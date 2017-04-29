function o = relax(m, T, T1, T2)
  %
  %  simulates T1 and T2 relaxation on magnetization output from 'bloch'
  %  function.
  %
  %  function o = relax(m, T, T1, T2)
  %
  %  input .....................................................................
  %  m                magnetization (output of bloch.m). [x y z (Mx,My,Mz) t]
  %  
  %  output ....................................................................
  %  o                magnetization after relaxation. [x y z 3 t]
  %

  o = m;
  o(:,:,:,1:2) = o(:,:,:,1:2).*exp(-T/T2);
  o(:,:,:,3) = o(:,:,:,3) + (1-o(:,:,:,3)).*(1-exp(-T/T1));

end

