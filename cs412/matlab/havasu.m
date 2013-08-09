function [ concentration ] = havasu(upper_guess, lower_guess)
% Answer for 11.12
    target = 75;
    tolerance = 0.001;
    A = [13.422 0 0 0; -13.422 12.252 0 0; 0 -12.252 12.377 0; 0 0 -12.377 11.797];
    
    count = 0;
    while (1)
        guess = (upper_guess + lower_guess) / 2;
        b = [guess;300;102;30];
        x = A\b;
        h = x(4);
        if (h < target + tolerance && h > target - tolerance)
            break;
        end
        if (h > target)
            lower_guess = guess;
        elseif (h < target)
            upper_guess = guess;
        else
            break;
        end
        count = count + 1;
        if (count > 10)
            break;
        end
    end
    concentration = guess;
end

