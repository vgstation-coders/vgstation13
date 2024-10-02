// Subsystem defines.
// All in one file so it's easier to see what everything is relative to.

#define SS_INIT_TICKER_SPAWN       999
#define SS_INIT_DBCORE			   900
#define SS_INIT_SSdbcore	       800
#define SS_INIT_RUST               26
#define SS_INIT_PLANT              25.5
#define SS_INIT_SUPPLY_SHUTTLE     25
#define SS_INIT_SUN                24
#define SS_INIT_GARBAGE            23
#define SS_INIT_JOB                22
#define SS_INIT_HUMANS             21
#define SS_INIT_MAP                20
#define SS_INIT_COMPONENT          19.5
#define SS_INIT_POWER              19
#define SS_INIT_OBJECT             18
#define SS_INIT_PIPENET            17.5
#define SS_INIT_XENOARCH           17
#define SS_INIT_MORE_INIT          16
#define SS_INIT_AIR                15
#define SS_INIT_LIGHTING           14
#define SS_INIT_UNSPECIFIED        0
#define SS_INIT_EMERGENCY_SHUTTLE -19
#define SS_INIT_ASSETS            -20
#define SS_INIT_TICKER            -21
#define SS_INIT_FINISH            -22
#define SS_INIT_MINIMAP           -23
#define SS_INIT_PERSISTENCE_MAP	  -98
#define SS_INIT_PERSISTENCE_MISC  -99
#define SS_INIT_PATHFINDER        -100
#define SS_INIT_DAYNIGHT		  -200

#define SS_PRIORITY_TIMER          1000
#define FIRE_PRIORITY_RUNECHAT	   410
#define SS_PRIORITY_WEATHER        210
#define SS_PRIORITY_TICKER         200
#define SS_PRIORITY_MOB            150
#define SS_PRIORITY_PATHING        149
#define SS_PRIORITY_BOTS           145
#define SS_PRIORITY_COMPONENT      125
#define SS_PRIORITY_NANOUI         120
#define SS_PRIORITY_TGUI           115
#define SS_PRIORITY_VOTE           110
#define SS_PRIORITY_FAST_OBJECTS   105
#define SS_PRIORITY_OBJECTS        100
#define SS_PRIORITY_POWER          95
#define SS_PRIORITY_MACHINERY      90
#define SS_PRIORITY_ENGINES		   89
#define SS_PRIORITY_PIPENET        85
#define SS_PRIORITY_AIR            70
#define SS_PRIORITY_EVENT          65
#define SS_PRIORITY_DISEASE        60
#define SS_PRIORITY_FAST_MACHINERY 55
#define SS_PRIORITY_PLANT          40
#define SS_PRIORITY_UNSPECIFIED    30
#define SS_PRIORITY_THERM_ENTROPY_RECHECK  22
#define SS_PRIORITY_THERM_ENTROPY  21
#define SS_PRIORITY_LIGHTING       20
#define SS_PRIORITY_THERM_DISS     19
#define SS_PRIORITY_AMBIENCE	   18
#define SS_PRIORITY_DBCORE		   17
#define SS_PRIORITY_SUN            3
#define SS_PRIORITY_GARBAGE        2
#define SS_PRIORITY_INACTIVITY     1
#define SS_PRIORITY_BURNABLE	  -50
#define SS_PRIORITY_DAYNIGHT	  -200
#define SS_PRIORITY_NEWS          -1000

#define SS_WAIT_WEATHER         	2 SECONDS
#define SS_WAIT_MACHINERY           2 SECONDS //TODO move the rest of these to defines
#define SS_WAIT_BOTS           		1 SECONDS
#define SS_WAIT_FAST_MACHINERY      0.7 SECONDS
#define SS_WAIT_FAST_OBJECTS        0.5 SECONDS
#define SS_WAIT_THERM_ENTROPY     	2 SECONDS
#define SS_WAIT_THERM_ENTROPY_RECHECK	60 SECONDS
#define SS_WAIT_THERM_DISS			1 SECONDS
#define SS_WAIT_TICKER              2 SECONDS
#define SS_WAIT_ENGINES				30 SECONDS
#define SS_WAIT_BURNABLE			3 SECONDS

#define SS_DISPLAY_TIMER          -110
#define SS_DISPLAY_GARBAGE        -100
#define SS_DISPLAY_AIR            -90
#define SS_DISPLAY_LIGHTING       -80
#define SS_DISPLAY_MOB            -70
#define SS_DISPLAY_COMPONENT      -69
#define SS_DISPLAY_FAST_OBJECTS   -65
#define SS_DISPLAY_OBJECTS        -60
#define SS_DISPLAY_MACHINERY      -50
#define SS_DISPLAY_BOTS           -45
#define SS_DISPLAY_PIPENET        -40
#define SS_DISPLAY_FAST_MACHINERY -30
#define SS_DISPLAY_PLANT          -25
#define SS_DISPLAY_POWER          -20
#define SS_DISPLAY_TICKER         -10
#define SS_DISPLAY_UNSPECIFIED     0
#define SS_DISPLAY_WEATHER         5
#define SS_DISPLAY_ENGINES		   6
#define SS_DISPLAY_SUN             10
#define SS_DISPLAY_THERM_ENTROPY_RECHECK   12
#define SS_DISPLAY_THERM_ENTROPY   13
#define SS_DISPLAY_THERM_DISS      14
#define SS_DISPLAY_DBCORE		   15
#define SS_DISPLAY_DAYNIGHT		   20
#define SS_DISPLAY_BURNABLE		   21

#define SS_TRASH                  "trash"
#define SS_CLEANABLE              "cleanable_decals"
#define SS_BLOOD                  "blood"
#define SS_GIBS                   "gibs"
#define SS_TRACKS                 "tracks"
