function varargout = setopts(v, e)
  % 
  %  sets default options. 'v' contains the optional arguments (vargin), and
  %  'e' contains the default value for each variable.  if the variable is
  %  found in the 'v', that value is returned, otherwise the default value is
  %  returned.
  %
  %  e.g. to create two variables 'msize' and 'mcolor', with default values of
  %  32 and 'blue', respectively, we add:
  %  [msize, mcolor] = setopts(varargin, {'msize', 32, 'mcolor', 'blue'});
	%  
  %  function o = setopts(v, e)
  %
  %  inputs ....................................................................
	%  v                cell array with optional arguments (varargin).
	%  e                cell array with variable names and default values.
  %
  %  outputs ...................................................................
  %  o                cell array of values for each optional variable.
  %

	for i = 1:numel(e)/2
		varargout{i} = getdef(v, e{2*i-1}, e{2*i});
	end

end

% ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-

function o = getdef(v, e, d)
	%
  %  if the variable name 'e' is found in 'v', returns the value of that
  %  variable. otherwise, returns the default value.
  %
  %  function o = getdef(v, e, d)
  %
  %  inputs ....................................................................
  %  v                cell array with variable names and values alternating.
  %  e                name of variable to check.
  %  d                default value of variable.
  %  
  %  outputs ...................................................................
  %  o                output variable value
  %

  for i = 1:numel(v)/2
		if strcmp(v{2*i-1}, e)
			o = v{2*i};
			return
		end
	end
	
  o = d;

end

