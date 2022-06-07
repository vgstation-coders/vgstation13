#define POWER_PRIORITY_BYPASS		1 // Meant for power sinks, zaps, and similar malicious power drains
#define POWER_PRIORITY_CRITICAL		2
#define POWER_PRIORITY_HIGHEST		3
#define POWER_PRIORITY_VERY_HIGH	4
#define POWER_PRIORITY_HIGH			5
#define POWER_PRIORITY_NORMAL		6
#define POWER_PRIORITY_LOW			7
#define POWER_PRIORITY_VERY_LOW		8
#define POWER_PRIORITY_LOWEST		9
#define POWER_PRIORITY_MINIMAL		10
#define POWER_PRIORITY_EXCESS		11 // Meant for the antique matter synth and other beneficial power sinks that could wreak havoc if misused

#define TOTAL_PRIORITY_SLOTS 		POWER_PRIORITY_EXCESS // Make sure to update this as needed if you add extra priority levels

#define POWER_PRIORITY_POWER_EQUIPMENT	POWER_PRIORITY_HIGH		// Emitters and other important machinery
#define POWER_PRIORITY_APC				POWER_PRIORITY_NORMAL
#define POWER_PRIORITY_MISC_EQUIPMENT	POWER_PRIORITY_NORMAL
#define POWER_PRIORITY_APC_RECHARGE		POWER_PRIORITY_LOW
#define POWER_PRIORITY_SMES_RECHARGE	POWER_PRIORITY_VERY_LOW

#define MONITOR_STATUS_BATTERY_CHARGING 	1 // This machine is recharging it's battery/power storage
#define MONITOR_STATUS_BATTERY_STEADY 		0 // This machine's charge remains unchanged
#define MONITOR_STATUS_BATTERY_DISCHARGING -1 // This machine is running on battery power
