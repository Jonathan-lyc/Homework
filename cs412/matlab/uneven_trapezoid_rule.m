function [ i ] = uneven_trapezoid_rule( x,y )
% Takes a set of x and y's, applies unequal trapezoid rule to determine
% integral.
i = 0;
for n = 1:length(x) - 1
    a = x(n);
    b = x(n+1);
    fa = y(n);
    fb = y(n+1);
    h = (b - a) ./ 4;
    i = i + h .* (fa + fb) / 2;
end
    

end

