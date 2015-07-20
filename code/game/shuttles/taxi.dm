#define TAXI_SHUTTLE_MOVE_TIME 0
#define TAXI_SHUTTLE_COOLDOWN 100

#define TAXI_A_NAME "taxi A"
#define TAXI_B_NAME "taxi B"

var/global/datum/shuttle/taxi/a/taxi_a = new

var/global/datum/shuttle/taxi/b/taxi_b = new

/datum/shuttle/taxi
	var/move_time_access = 20
	var/move_time_no_access = 60

	var/area/area_medical_silicon
	var/area/area_engineering_cargo
	var/area/area_security_science
	var/area/area_abandoned

	collision_type = COLLISION_DISPLACE

/datum/shuttle/taxi/a/New()
	.=..()
	setup_everything(starting_area = /area/shuttle/taxi_a/engineering_cargo_station, \
		all_areas=list(/area/shuttle/taxi_a/medcal_silicon_station,
			/area/shuttle/taxi_a/engineering_cargo_station,
			/area/shuttle/taxi_a/security_science_station,
			/area/shuttle/taxi_a/abandoned_station), \
		name = TAXI_A_NAME, transit_area = /area/shuttle/taxi_a/transit, cooldown = TAXI_SHUTTLE_COOLDOWN, delay = TAXI_SHUTTLE_MOVE_TIME)

/datum/shuttle/taxi/b/New()
	.=..()
	setup_everything(starting_area = /area/shuttle/taxi_b/engineering_cargo_station, \
		all_areas=list(/area/shuttle/taxi_b/medcal_silicon_station,
			/area/shuttle/taxi_b/engineering_cargo_station,
			/area/shuttle/taxi_b/security_science_station,
			/area/shuttle/taxi_b/abandoned_station), \
		name = TAXI_B_NAME, transit_area = /area/shuttle/taxi_b/transit, cooldown = TAXI_SHUTTLE_COOLDOWN, delay = TAXI_SHUTTLE_MOVE_TIME)

/datum/shuttle/taxi/initialize()
	if(!areas || !areas.len) return

	//Assign areas to variables
	//This is AWFUL I'm sorry
	switch(name)
		if(TAXI_A_NAME)
			area_medical_silicon = locate(/area/shuttle/taxi_a/medcal_silicon_station) in areas
			area_engineering_cargo = locate(/area/shuttle/taxi_a/engineering_cargo_station) in areas
			area_security_science = locate(/area/shuttle/taxi_a/security_science_station) in areas
			area_abandoned = locate(/area/shuttle/taxi_a/abandoned_station) in areas
		if(TAXI_B_NAME)
			area_medical_silicon = locate(/area/shuttle/taxi_b/medcal_silicon_station) in areas
			area_engineering_cargo = locate(/area/shuttle/taxi_b/engineering_cargo_station) in areas
			area_security_science = locate(/area/shuttle/taxi_b/security_science_station) in areas
			area_abandoned = locate(/area/shuttle/taxi_b/abandoned_station) in areas

//Taxi computers are located in code\game\machinery\computer\taxi_shuttle.dm

#undef TAXI_A_NAME
#undef TAXI_B_NAME

#undef TAXI_SHUTTLE_MOVE_TIME
#undef TAXI_SHUTTLE_COOLDOWN