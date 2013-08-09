function dy = problem_seven_y( t, y )
% Problem 22.7b, y(1) = y, y(2) = z
% t is step
dydt = -2.*y(1) + 5.*exp(-1.*t);
dzdt = -1 * (y(1)*y(2).^2./2);
dy = [dydt; dzdt];
end

