/* Force-included by build-ext-windows.sh: POSIX bits MSVC lacks. */
#include <time.h>
#ifndef CLOCK_REALTIME
#define CLOCK_REALTIME 0
static int
clock_gettime(int clk, struct timespec *ts)
{
	(void) clk;
	return timespec_get(ts, TIME_UTC) ? 0 : -1;
}
#endif
