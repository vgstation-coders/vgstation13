#define MAPTICK_MC_MIN_RESERVE 40 //Percentage of tick to leave for master controller to run
#define TICK_LIMIT_RUNNING (max(90 - world.map_cpu, MAPTICK_MC_MIN_RESERVE))
#define TICK_LIMIT_TO_RUN 78
#define TICK_LIMIT_MC 70
#define TICK_LIMIT_MC_INIT 98
#define TICK_CHECK ( world.tick_usage > CURRENT_TICKLIMIT ? stoplag() : 0 )
#define CHECK_TICK if (world.tick_usage > CURRENT_TICKLIMIT)  stoplag()

// Do X until it's done, while looking for lag.
#define UNTIL(X) while(!(X)) stoplag()
