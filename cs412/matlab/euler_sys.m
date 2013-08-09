function [ tp,yp ] = euler_sys(dydt,tspan,y0,h,varargin)
if nargin<4,error('at least 4 input arguments required'),end
if any(diff(tspan)<=0),error('tspan not ascending order'),end
n = length(tspan);
ti = tspan(1);tf = tspan(n);
if n == 2
    t = (ti:h:tf)'; n = length(t);
    if t(n)<tf
        t(n+1) = tf;
        n = n + 1;
    end
else
    t = tspan;
end
tt = ti;
yp(1,:) = y0

np = 1; tp(np) = tt;
while(1)
    yp(np+1,:) = yp(np,:) + dydt(yp(np,:), tt) .* h;
    np = np+1; 
    tp(np) = tt; 
    tt = tt + h;
    if tt>=tf,break,end
end