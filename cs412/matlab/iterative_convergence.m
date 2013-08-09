function [ a,b,c ] = iterative_convergence( )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    x1 = 0;
    x2 = 0;
    x3 = 0;
    tolerance = 5;
    count = 0;
    while(1)
       x1old = x1;
       x2old = x2;
       x3old = x3;
       
       x1 = (-20 - 1*x2 - -2*x3) ./ -8;
       e1 = abs((x1 - x1old) ./ x1 * 100);
       fprintf('x1: -20 - 1(%d) - -2(%d) / -8 = %d. Error: %d - %d / %d = %d\n', x2, x3, x1, x1, x1old, x1, e1);
       x2 = (-38 - 2*x1 - -1*x3) ./ -6;
       e2 = abs((x2 - x2old) ./ x2 * 100);
       fprintf('x2: -38 - 2(%d) - -1(%d) / -6 = %d. Error: %d - %d / %d = %d\n', x1, x3, x2, x2, x2old, x2, e2);
       x3 = (-34 - -3*x1 - -1*x2) ./ 7;
       e3 = abs((x3 - x3old) ./ x3 * 100);
       fprintf('x3: -34 - -3(%d) - -1(%d) / 7 = %d. Error: %d - %d / %d = %d\n', x1, x2, x3, x3, x3old, x3, e3);
       
       if (e1 < tolerance && e2 < tolerance && e3 < tolerance)
          break; 
       end
       count = count + 1
    end
    a = x1;
    b = x2;
    c = x3;
    count = count
end

