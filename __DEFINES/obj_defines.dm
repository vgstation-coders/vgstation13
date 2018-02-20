//Quality

#define AWFUL 0
#define SHODDY 1
#define POOR 2
#define NORMAL 3
#define GOOD 4
#define SUPERIOR 5
#define EXCELLENT 6
#define MASTERWORK 7
#define LEGENDARY 8

/proc/getQualityString(var/quality)
	switch(quality)
		if(0)
			return "awful"
		if(1)
			return "shoddy"
		if(2)
			return "poor"
		if(3)
			return "normal"
		if(4)
			return "good"
		if(5)
			return "superior"
		if(6)
			return "excellent"
		if(7)
			return "masterwork"
		if(8)
			return "legendary"