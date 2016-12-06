// btime.cpp : Defines the exported functions for the DLL application.
//

#include <stdlib.h>
#include "btime.h"
#include <time.h>
#include <stdio.h>

using namespace std;

#ifdef WIN32
#include <Windows.h>
#include <stdint.h>
#define snprintf _snprintf

double timeofhour()
{
	// Note: some broken versions only have 8 trailing zero's, the correct epoch has 9 trailing zero's
	static const uint64_t EPOCH = ((uint64_t)116444736000000000ULL);
	static double timeofhour;
	SYSTEMTIME  system_time;
	GetSystemTime(&system_time);
	timeofhour = ((int)system_time.wHour * 60 * 60 + (int)system_time.wMinute * 60 + (int)system_time.wSecond) % 3600 + (double)system_time.wMilliseconds / (double)1000;
	return timeofhour;
}
#else
#include <sys/time.h>
#include <string.h>

double timeofhour()
{
	static struct timespec ts;
	timespec* tsp = &ts;
	static double timeofhour;
	static struct tm t;
	tm* tp = &t;
	static const double nsec = 1000000000;
	clock_gettime(CLOCK_MONOTONIC, tsp);
	localtime_r(&(tsp->tv_sec), tp);
	timeofhour = ((int)tp->tm_hour * 3600 + (int)tp->tm_min * 60 + (int)tp->tm_sec) % 3600 + (double)tsp->tv_nsec / nsec;
	return timeofhour;
}
#endif

EXPORT char * byond_gettime(void)
{
	static char buf[11];
	static double amount;
	amount = 10 * timeofhour();
	snprintf(buf, 11, "%f", amount);
	return buf;
}

// C export
extern "C" EXPORT char * gettime(int argc, char *argv[])
{
	return byond_gettime();
}
