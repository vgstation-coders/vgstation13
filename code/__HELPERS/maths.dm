/**
 * Credits to Nickr5 for the useful procs I've taken from his library resource.
 */

var/const/E		= 2.71828183
var/const/Sqrt2	= 1.41421356

/* //All point fingers and laugh at this joke of a list, I even heard using sqrt() is faster than this list lookup, honk.
// List of square roots for the numbers 1-100.
var/list/sqrtTable = list(1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5,
                          5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7,
                          7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
                          8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 10)
*/


// Returns y so that y/x = a/b.
#define RULE_OF_THREE(a, b, x) ((a*x)/b)
#define tan(x) (sin(x)/cos(x))

/proc/Atan2(x, y)
	if (!x && !y)
		return 0

	var/invcos = arccos(x / sqrt(x * x + y * y))
	return y >= 0 ? invcos : -invcos

proc/arctan(x)
	var/y=arcsin(x/sqrt(1+x*x))
	return y

/proc/Ceiling(x, y = 1)
	. = -round(-x / y) * y

/proc/sgn(const/i)
	if(i > 0)
		return 1
	else if(i < 0)
		return -1
	else
		return 0

// -- Returns a Lorentz-distributed number.
// -- The probability density function has centre x0 and width s.

/proc/lorentz_distribution(var/x0, var/s)
	var/x = rand()
	var/y = s*tan_rad(PI*(x-0.5)) + x0
	return y

// -- Returns the Lorentz cummulative distribution of the real x.

/proc/lorentz_cummulative_distribution(var/x, var/x0, var/s)
	var/y = (1/PI)*ToRadians(arctan((x-x0)/s)) + 1/2
	return y

// -- Returns an exponentially-distributed number.
// -- The probability density function has mean lambda

/proc/exp_distribution(var/desired_mean)
	if (desired_mean <= 0)
		desired_mean = 1 // Let's not allow that to happen
	var/lambda = 1/desired_mean
	var/x = rand()
	while (x == 1)
		x = rand()
	var/y = -(1/lambda)*log(1-x)
	return y
	
// -- Returns the Lorentz cummulative distribution of the real x, with mean lambda

/proc/exp_cummulative_distribution(var/x, var/lambda)
	var/y = 1 - E**(lambda*x)
	return y


//Moved to macros.dm to reduce pure calling overhead, this was being called shitloads, like, most calls of all procs.
/*
/proc/Clamp(const/val, const/min, const/max)
	if (val <= min)
		return min

	if (val >= max)
		return max

	return val
*/

// cotangent
/proc/Cot(x)
	return 1 / Tan(x)

// cosecant
/proc/Csc(x)
	return 1 / sin(x)

/proc/Default(a, b)
	return a ? a : b

/proc/Floor(x = 0, y = 0)
	if(x == 0)
		return 0
	if(y == 0)
		return round(x)

	if(x < y)
		return 0

	var/diff = round(x, y) //finds x to the nearest value of y
	if(diff > x)
		return x - (y - (diff - x)) //diff minus x is the inverse of what we want to remove, so we subtract from y - the base unit - and subtract the result
	else
		return diff //this is good enough

// Greatest Common Divisor - Euclid's algorithm
/proc/Gcd(a, b)
	return b ? Gcd(b, a % b) : a

/proc/Inverse(x)
	return 1 / x

/proc/IsAboutEqual(a, b, deviation = 0.1)
	return abs(a - b) <= deviation

/proc/IsEven(x)
	return x % 2 == 0

// Returns true if val is from min to max, inclusive.
/proc/IsInRange(val, min, max)
	return min <= val && val <= max

/proc/IsInteger(x)
	return Floor(x) == x

/proc/IsOdd(x)
	return !IsEven(x)

/proc/IsMultiple(x, y)
	return x % y == 0

// Least Common Multiple
/proc/Lcm(a, b)
	return abs(a) / Gcd(a, b) * abs(b)

/**
 * Generic lerp function.
 */
/proc/lerp(x, x0, x1, y0 = 0, y1 = 1)
    return y0 + (y1 - y0)*(x - x0)/(x1 - x0)

/**
 * Lerps x to a value between [a, b]. x must be in the range [0, 1].
 * My undying gratitude goes out to wwjnc.
 *
 * Basically this returns the number corresponding to a certain
 * percentage in a range. 0% would be a, 100% would be b, 50% would
 * be halfways between a and b, and so on.
 *
 * Other methods of lerping might not yield the exact value of a or b
 * when x = 0 or 1. This one guarantees that.
 *
 * Examples:
 *   - mix(0.0,  30, 60) = 30
 *   - mix(1.0,  30, 60) = 60
 *   - mix(0.5,  30, 60) = 45
 *   - mix(0.75, 30, 60) = 52.5
 */
/proc/mix(a, b, x)
	return a*(1 - x) + b*x

/**
 * Lerps x to a value between [0, 1]. x must be in the range [a, b].
 *
 * This is the counterpart to the mix() function. It returns the actual
 * percentage x is at inside the [a, b] range.
 *
 * Note that this is theoretically equivalent to calling lerp(x, a, b)
 * (y0 and y1 default to 0 and 1) but this one is slightly faster
 * because Byond is too dumb to optimize procs with default values. It
 * shouldn't matter which one you use (since there are no FP issues)
 * but this one is more explicit as to what you're doing.
 *
 * @todo Find a better name for this. I can't into english.
 * http://i.imgur.com/8Pu0x7M.png
 */
/proc/unmix(x, a, b, min = 0, max = 1)
	if(a==b)
		return 1
	return Clamp( (b - x)/(b - a), min, max )

/proc/Mean(...)
	var/values 	= 0
	var/sum		= 0
	for(var/val in args)
		values++
		sum += val
	return sum / values


/*
 * Returns the nth root of x.
 */
/proc/Root(const/n, const/x)
	return x ** (1 / n)

/*
 * Secant.
 */
/proc/Sec(const/x)
	return 1 / cos(x)

// The quadratic formula. Returns a list with the solutions, or an empty list
// if they are imaginary.
/proc/SolveQuadratic(a, b, c)
	ASSERT(a)
	. = list()
	var/d		= b*b - 4 * a * c
	var/bottom  = 2 * a
	if(d < 0)
		return
	var/root = sqrt(d)
	. += (-b + root) / bottom
	if(!d)
		return
	. += (-b - root) / bottom

/*
 * Tangent.
 */
/proc/Tan(const/x) 
	return sin(x) / cos(x)

/proc/tan_rad(const/x) // This one assumes that x is in radians.
	return Tan(ToDegrees(x))


/proc/ToDegrees(const/radians)
	// 180 / Pi
	return radians * 57.2957795

/proc/ToRadians(const/degrees)
	// Pi / 180
	return degrees * 0.0174532925

// min is inclusive, max is exclusive
/proc/Wrap(val, min, max)
	var/d = max - min
	var/t = Floor((val - min) / d)
	return val - (t * d)

/*
 * A very crude linear approximatiaon of pythagoras theorem.
 */
/proc/cheap_pythag(const/Ax, const/Ay)
	var/dx = abs(Ax)
	var/dy = abs(Ay)

	if (dx >= dy)
		return dx + (0.5 * dy) // The longest side add half the shortest side approximates the hypotenuse.
	else
		return dy + (0.5 * dx)

/*
 * Magic constants obtained by using linear regression on right-angled triangles of sides 0<x<1, 0<y<1
 * They should approximate pythagoras theorem well enough for our needs.
 */
#define k1 0.934
#define k2 0.427
/proc/cheap_hypotenuse(const/Ax, const/Ay, const/Bx, const/By)
	var/dx = abs(Ax - Bx) // Sides of right-angled triangle.
	var/dy = abs(Ay - By)

	if (dx >= dy)
		return (k1*dx) + (k2*dy) // No sqrt or powers :).
	else
		return (k2*dx) + (k1*dy)
#undef k1
#undef k2

/**
 * Get Distance, Squared
 *
 * Because sqrt is slow, this returns the distance squared, which skips the sqrt step.
 *
 * Use to compare distances. Used in component mobs.
 */
/proc/get_dist_squared(var/atom/a, var/atom/b)
	return ((b.x-a.x)**2) + ((b.y-a.y)**2)

//Checks if something's a power of 2, to check bitflags.
//Thanks to wwjnc for this.
/proc/test_bitflag(var/bitflag)
	return bitflag != 0 && !(bitflag & (bitflag - 1))

/*
 * Diminishing returns formula using a triangular number sequence.
 * Taken from http://lostsouls.org/grimoire_diminishing_returns
 */
/proc/triangular_seq(input, scale)
	if(input < 0)
		return -triangular_seq(-input, scale)
	var/mult = input/scale
	var/trinum = (sqrt(8 * mult + 1) - 1 ) / 2
	return trinum * scale

// Input: a number
// Returns: the number of bits set
/proc/count_set_bitflags(var/input)
	. = 0
	while(input)
		input &= (input - 1)
		.++

#if UNIT_TESTS_ENABLED
/datum/unit_test/count_set_bitflags/start()
	assert_eq(count_set_bitflags(0), 0)
	assert_eq(count_set_bitflags(1|2|4|8|16|32|64|128|256|512|1024|2048|4096|8192|16384|32768|65535|131072|262144|524288|1048576|2097152|4194304|8388608), 23)
	assert_eq(count_set_bitflags(1), 1)
	assert_eq(count_set_bitflags(2), 1)
	assert_eq(count_set_bitflags(3), 2)
	assert_eq(count_set_bitflags(1|2), 2)
	assert_eq(count_set_bitflags(1|4), 2)
	assert_eq(count_set_bitflags(1|65536), 2)
	assert_eq(count_set_bitflags(65536|32768), 2)
	assert_eq(count_set_bitflags(1|4|16), 3)
#endif
