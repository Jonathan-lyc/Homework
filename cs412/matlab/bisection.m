function ANS = bisection(func, lower, upper, max_iter, tolerance)
for i = 1:max_iter
    bi = (upper + lower) / 2;
    if func(bi) == 0 || (upper - lower)/2 < tolerance
        break;
    end
    if (func(bi) > 0 && func(lower) > 0)
        lower = bi;
    elseif (func(bi) < 0 && func(lower) < 0)
        lower = bi;
    else
        upper = bi;
    end
end
ANS = bi
    