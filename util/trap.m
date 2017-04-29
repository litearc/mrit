function w = trap(a, s, varargin)
  %
  %  creates a trapezoid. depending on the inputs, this does different things.
  %  if the length 'len' is specified, it maximizes the area for the given
  %  length. if the area 'area' is specified, it creates the minimum-length
  %  trapezoid with that area. if the both length and area are specified, it
  %  creates a trapezoid with the given length and area, if possible. at least
  %  one of the inputs (length or area) must be specified.
  %
  %  function g = trap(a, s, varargin)
  %
  %  inputs ....................................................................
  %  a                maximum amplitude of trapezoid. (float)
  %  s                slope of ramps, i.e. maximum increase per sample point.
  %                   (float)
  %
  %  options ...................................................................
  %  len              # points in trapezoid. (int)
  %  area             area of trapezoid (sum of values in output vector).
  %                   (float)
  %
  %  outputs ...................................................................
  %  w                trapezoid waveform. (vector)
  %

  [len, area] = setopts(varargin, {'len', 0, 'area', 0});
  
  % if area is negative, create positive waveform and invert at the end
  area_neg = (area<0);
  if area_neg
    area = -area;
  end

  if len == 0 && area == 0
    error('the length ''len'' or area ''area'' must be specified!');
  end

  % if only the length is specified, get max area
  if len ~= 0 && area == 0
    w = max_area_trap(a, s, len);
  end

  % if both length and area are specified, try to get both
  if len ~= 0 && area ~= 0
    % first check if it's possible
    if area > sum(max_area_trap(a, s, len))
      error('gradient area not possible in given time!');
    end
    % tough to find analytic solution, so use loop.
    n = len;
    for i = 1:n/2
      gu = [0:s:(i-1)*s];
      d = area-sum(gu)*2;
      a = d/(n-2*i);
      if a <= gu(end)+s % found solution!
        w = [gu a*ones(1,n-2*i) gu(end)-gu];
        break;
      end
    end
  end

  % if only the area is specified, get minimum-time trapezoid
  if len == 0 && area ~= 0
    % # points to get to max g.
    n = a/s+1;
    if area > s*(n-1)^2
      % trapezoid
      n = ceil(n);
      aa = (n-2)*s;
      da = area-aa*(n-1);
      np = ceil(da/a);
      af = area/(n+np-2);
      gu = linspace(0, af, n);
      w = [gu af*ones(1,np-2) fliplr(gu)];
    else
      % triangle
      np = ceil(sqrt(area/s)+1);
      ss = area/(np-1)^2;
      gu = 0:ss:(np-1)*ss;
      w = [gu fliplr(gu(1:end-1))];
    end
  end

  % invert if negative area specified
  if area_neg
    w = -w;
  end

end

function g = max_area_trap(a, s, len)
  
  % calculate # total points and # points to get to 'a'
  n = len;
  ns = ceil(a/s+1);
  
  if n <= 2*ns
    % triangle, need to account for even/odd # points
    nr = ceil(n/2);
    gr = [0:s:(nr-2)*s];
    gs = min((nr-1)*s, a);
    g = [gr gs*ones(1,1+(~mod(n,2))) gr(end)-gr];
 else
   % trapezoid
   gu = 0:s:(ns-2)*s;
   g = [gu a*ones(1,n-2*(ns-1)) gu(end)-gu];
 end

end

