function yp = newhump(t, x )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
x = x(length(x))
yp = [t;1./((x-0.3).^2 + 0.01) + 1./((x-0.9).^2 + 0.04) - 6]

end

