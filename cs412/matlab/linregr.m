function [ a, err ] = linregr(x,y)
n = length(x);
if length(y)~=n, error('x and y must be same length'); end
x = x(:); y = y(:); % convert to column vectors
sx = sum(x) ;
sy = sum(y);
sx2 = sum(x.*x); 
sxy = sum(x.*y); 
sy2 = sum(y.*y);
a(2) = (n*sxy-sx*sy)/(n*sx2-sx^2);
a(1) = sy/n-a(2)*sx/n;
sr = 0;
residuals = [];
for i = 1:length(x)
    %fprintf('y: %d, a0: %d, a1: %d, x: %d, a1*x: %d, a0a1x: %d, eq: %d, ^2: %d\n', y(i), a(1), a(2), x(i), a(1) + a(2)*x(i),(y(i) - a(1) - a(2)*x(i)), (y(i) - a(1) - a(2)*x(i)).^2)
    residual = y(i) - a(1) - a(2)*x(i);
    residuals(i) = residual;
    sr = sr + (residual).^2;
end
%sr = sum((y - a(1) - (a(2)*x)).^2)
sr
% Standard error calc
err = sqrt(sr ./ (n - 2))
r2 = ((n*sxy-sx*sy)/sqrt(n*sx2-sx^2)/sqrt(n*sy2-sy^2))^2;
% create plot of data and best fit line
xp = linspace(min(x),max(x),2);
yp = a(2)*xp+a(1);
subplot(2,1,1);
plot(x,y,'o',xp,yp);
subplot(2,1,2);
plot(x,residuals);
grid on


end