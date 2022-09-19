//Percentage of tick to leave for master controller to run
#define MAPTICK_MC_MIN_RESERVE 70
//internal_tick_usage is updated every tick
#if DM_VERSION > 513
#define MAPTICK_LAST_INTERNAL_TICK_USAGE world.map_cpu
#else
#define MAPTICK_LAST_INTERNAL_TICK_USAGE 50
#endif

#define TimeOfTick (world.tick_usage*0.01*world.tick_lag)

#define DS2TICKS(DS) ((DS)/world.tick_lag)
#define TICKS2DS(T) ((T) TICKS)
#define MS2DS(T) ((T) MILLISECONDS)
#define DS2MS(T) ((T) * 100)

// Tick limit while running normally
#define TICK_BYOND_RESERVE 2
#define TICK_LIMIT_RUNNING (max(100 - TICK_BYOND_RESERVE - MAPTICK_LAST_INTERNAL_TICK_USAGE, MAPTICK_MC_MIN_RESERVE))
// Tick limit used to resume things in stoplag
#define TICK_LIMIT_TO_RUN 70
// Tick limit for MC while running
#define TICK_LIMIT_MC 70
// Tick limit while initializing
#define TICK_LIMIT_MC_INIT_DEFAULT (100 - TICK_BYOND_RESERVE)

//for general usage
#define TICK_USAGE world.tick_usage
//to be used where the result isn't checked
#define TICK_USAGE_REAL world.tick_usage

// Returns true if tick_usage is above the limit
#define TICK_CHECK ( TICK_USAGE > CURRENT_TICKLIMIT )
// runs stoplag if tick_usage is above the limit
#define CHECK_TICK ( TICK_CHECK ? stoplag() : 0 )

// Returns true if tick usage is above 95, for high priority usage
#define TICK_CHECK_HIGH_PRIORITY ( TICK_USAGE > 95 )
// runs stoplag if tick_usage is above 95, for high priority usage
#define CHECK_TICK_HIGH_PRIORITY ( TICK_CHECK_HIGH_PRIORITY? stoplag() : 0 )

// Do X until it's done, while looking for lag.
#define UNTIL(X) while(!(X)) stoplag()

//Increases delay as the server gets more overloaded,
//as sleeps aren't cheap and sleeping only to wake up and sleep again is wasteful
#define DELTA_CALC max(((max(world.tick_usage, world.cpu) / 100) * max(Master.sleep_delta,1)), 1)

/proc/stoplag(initial_delay)
	. = 0
	var/i = 1
	if(!initial_delay)
		initial_delay = world.tick_lag
	do
		. += Ceiling(i*DELTA_CALC)
		sleep(i*world.tick_lag*DELTA_CALC)
		i *= 2
	while (world.tick_usage > min(TICK_LIMIT_TO_RUN, CURRENT_TICKLIMIT))

#undef DELTA_CALC