function root = bisection(func,xl,xu,es,maxit)
% bisection(xl,xu,es,maxit):
% uses bisection method to find the root of a function
% input:
% func = name of function
% xl, xu = lower and upper guesses
% es = (optional) stopping criterion (%)
% maxit = (optional) maximum allowable iterations
% output:
% root = real root
if func(xl)*func(xu)>0 %if guesses do not bracket a sign
 error('no bracket') %change, display an error message
 return %and terminate
end
% if necessary, assign default values
if nargin<5, maxit = 50; end %if maxit blank set to 50
if nargin<4, es = 0.001; end %if es blank set to 0.001
% bisection
iter = 0;
xr = xl;
while (1)
 xrold = xr;
 xr = (xl + xu)/2;
 iter = iter + 1;
 if xr ~= 0, ea = abs((xr - xrold)/xr) * 100; end
 test = func(xl)*func(xr);
 if test < 0
 xu = xr;
 elseif test > 0
 xl = xr;
 else
 ea = 0;
 end
 if ea <= es | iter >= maxit, break, end
end
root = xr;