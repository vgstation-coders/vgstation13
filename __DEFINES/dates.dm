//Useful for making time-limited things.

#define IS_TODAY time2text(world.realtime, "MM/DD") == "03/23"
#define IS_VALENTINES  time2text(world.realtime, "MM/DD") == "02/14"
#define IS_APRILS_FOOL time2text(world.realtime, "MM/DD") == "04/01"
