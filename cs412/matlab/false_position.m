function ANS = false_position(func, lower, upper, max_iter, tolerance)
for i = 1:max_iter
    fp(i) = upper - (func(upper) * (lower - upper)) / (func(lower) - func(upper));
    guess = fp(i);
    if func(guess) == 0
        break;
    end
    if (func(guess) > 0 && func(lower) > 0)
        lower = guess;
    elseif (func(guess) < 0 && func(lower) < 0)
        lower = guess;
    else
        upper = guess;
    end
    if ((i > 1) && abs(fp(i) - fp(i - 1) / fp(i) * 100) < tolerance)
        break
    end
end
display(i)
ANS = guess;