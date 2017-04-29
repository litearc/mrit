function o = ldicoms(d)
  %
  %  loads dicoms from a directory, where the files are named:
  %  'I#...#.dcm' (variable number of digits).
  %   
  %  function o = ldicoms(d)
  %
  %  inputs ....................................................................
  %  d                directory name. (string)
  %
  %  outputs ...................................................................
  %  o                dicom data. [x y z]
  %

  f = dir(d);
  
  % the . and .. dirs don't count.
	nf = length(f)-2;
  
  % # chars the dicom # should take up.
  nc = length(f(end).name)-5;

  % filename with variable # digits.
  fn = sprintf(['I%0' int2str(nc) 'd.dcm'], 1);
	o = dicomread([d '/' fn]);
	
  % load dicoms.
  j = 1;
  for i = 1:nf
		while 1
			fn = sprintf(['I%0' int2str(nc) 'd.dcm'],j);
			j = j+1;
			if exist([d '/' fn]) break, end
		end
		o(:,:,i) = dicomread([d '/' fn]);
	end
  o = double(o);

end

