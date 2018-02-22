//Quality

#define AWFUL 1
#define SHODDY 2
#define POOR 3
#define NORMAL 4
#define GOOD 5
#define SUPERIOR 6
#define EXCELLENT 7
#define MASTERWORK 8
#define LEGENDARY 9

/proc/getQualityString(var/quality)
	switch(quality)
		if(AWFUL)
			return "awful"
		if(SHODDY)
			return "shoddy"
		if(POOR)
			return "poor"
		if(NORMAL)
			return "normal"
		if(GOOD)
			return "good"
		if(SUPERIOR)
			return "superior"
		if(EXCELLENT)
			return "excellent"
		if(MASTERWORK)
			return "masterwork"
		if(LEGENDARY)
			return "legendary"