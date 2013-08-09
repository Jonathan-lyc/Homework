from __future__ import division
import sys

def sixtwo(x, error, count=0):
    """
    Problem 6.2 (3rd edition)
    :param x: Initial guess
    :param error: Error threshold as a percent
    :param count: Start counter (used for printing)
    :return: Nothing. Prints to console.
    """
    x = float(x)
    error = float(error)
    x1 = x - ((-0.9 * x**2) + (1.7 * x) + 2.5)/((-1.8 * x) + 1.7)
    e = abs((x1 - x)/x1) * 100
    print "x{count}: {0:.6f}, x{count2}: {1:.6f}, error: {2:.3f}%".format(x, x1, e, count=count, count2=count+1)

    if e < error:
        return
    else:
        sixtwo(x1, error, count + 1)

def sixthree(x, error, count=0):
    """
    Problem 6.3b (3rd edition)
    :param x: Initial guess
    :param error: Error threshold as a percent
    :param count: Start counter (used for printing)
    :return: Nothing. Prints to console.
    """
    x = float(x)
    error = float(error)
    # x1 = x - ((-0.9 * x**2) + (1.7 * x) + 2.5)/((-1.8 * x) + 1.7)
    x1 = x - ((x**3 - (6 * (x**2)) + (11 * x) - 6.1) / ((3 * (x**2)) - (12 * x) + 11))
    e = abs((x1 - x)/x1) * 100
    print "x{count}: {0:.6f}, x{count2}: {1:.6f}, error: {2:.3f}%".format(x, x1, e, count=count, count2=count+1)

    if e < error:
        return
    else:
        sixthree(x1, error, count + 1)

def sixthreesecant(x, x1, fx, error, count=0):
    """
    Problem 6.3c (3rd edition)
    :param x: Initial guess
    :param error: Error threshold as a percent
    :param fx: function
    :param count: Start counter (used for printing)
    :return: Nothing. Prints to console.
    """
    x = float(x)
    x1 = float(x1)
    fx0 = fx(x)
    fx1 = fx(x1)
    # print "fx", x, fx0
    # print "fx1", x1, fx1
    error = float(error)

    # xi = x - ((x**3 - (6 * (x**2)) + (11 * x) - 6.1) / ((3 * (x**2)) - (12 * x) + 11))
    xi = x - ((fx0 * (x1 - x)) / (fx1 - fx0))
    # print x, "- (", fx1, " * ", x1, "-", x, ") / (", fx1, " - ", fx0, ")"
    # print "xi", xi
    e = abs((xi - x)/xi) * 100
    print "x{prev_count}: {0:.6f}, x{count}: {1:.6f}, f(xi-1): {2:.6f}, f(xi): {3:.6f}, x{next_count}: {5:.6f}, error: {4:.3f}%".format(x1, x, fx1, fx0, e, xi, count=count, prev_count=count-1, next_count=count+1)
    if e < error or count > 3:
        return
    else:
        sixthreesecant(xi, x, fx, error, count=count+1)

def sixthreemodsecant(x, perturb, fx, error, count=0):
    """
    Problem 6.3c (3rd edition)
    :param x: Initial guess
    :param error: Error threshold as a percent
    :param fx: function
    :param count: Start counter (used for printing)
    :return: Nothing. Prints to console.
    """
    x = float(x)
    perturb = float(perturb)

    # print "x0", x
    # print "pertub", perturb, perturb*x
    # print "x0 per", x + (perturb * x)
    # print "fx0", fx(x)
    # print "fxper", fx(x + (perturb * x))
    error = float(error)

    # xi = x - ((x**3 - (6 * (x**2)) + (11 * x) - 6.1) / ((3 * (x**2)) - (12 * x) + 11))
    xi = x - (perturb * x * fx(x)) / (fx(x + (x * perturb)) - fx(x))
    # print x, "- (", fx1, " * ", x1, "-", x, ") / (", fx1, " - ", fx0, ")"
    # print "xi", xi
    e = abs((xi - x)/xi) * 100
    print "x{count}: {0:.6f}, f(xi): {1:.6f}, f(xi + perturb): {2:.6f}, x{next_count}: {3:.6f}, error: {4:.3f}%".format(x, fx(x), fx(x + perturb), xi, e, count=count, next_count=count+1)
    if e < error or count > 3:
        return
    else:
        sixthreemodsecant(xi, perturb, fx, error, count=count+1)

def sixthreesecantfunc(x):
    """
    The secant function in 6.3
    :param x: The x variable
    :return:
    """
    return (x**3) - (6 * (x**2)) + (11 * x) - 6.1

if __name__ == "__main__":
    # sixtwo(sys.argv[1], sys.argv[2])
    # sixthree(sys.argv[1], sys.argv[2])
    # sixthreesecant(3.5, 2.5, sixthreesecantfunc, 0.001)
    sixthreemodsecant(3.5, 0.02, sixthreesecantfunc, 0.001)