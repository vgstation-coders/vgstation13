/datum/map_element/shuttle
	name = SHUTTLE_ABSTRACT //If this name isn't changed, it will be considered abstract and ignored in initialization.
	desc = "An escape shuttle."
	type_abbreviation = "SH"
	var/home //which map this fits on; should match map_dir
	var/cost = 0 //to be paid from the station account

/proc/eligible_ship_by_name(var/text)
	for(var/datum/map_element/shuttle/S in map.escape_shuttles)
		if(S.name == text)
			return S
	return null

/datum/map_element/shuttle/packed
	home = "packedstation"

/datum/map_element/shuttle/packed/classic
	name = "Classic Shuttle"
	desc = "The NTS Classic is the award-winning design known and trusted by stations everywhere."
	cost = 200

/*datum/map_element/shuttle/packed/deluxe
	name = "Deluxe Shuttle"
	desc = "The NTC Regent is certainly the preferred choice for those who are planning to evacuate in style."
	file_path = "maps/shuttles/packed/deluxe.dmm"
	cost = 2500

/datum/map_element/shuttle/packed/old
	name = "Ancient Shuttle"
	desc = "Dating to 2243, the NTS Vainglory is the oldest operating emergency shuttle in the fleet."
	file_path = "maps/shuttles/packed/old.dmm"
	cost = 0*/

/datum/map_element/shuttle/packed/plasma
	name = "Atmospherics Response Shuttle"
	desc = "The NTRV Uriel is a research support vessel aimed at relieving stations compromised by plasma contamination."
	file_path = "maps/shuttles/packed/plasma.dmm"
	cost = 400

/datum/map_element/shuttle/packed/armored
	name = "Armored Shuttle"
	desc = "The NTS Waspnest is a light security cruiser. Its forward battery has been removed, but it features few structural weakpoints and a highly secure choke entrance."
	file_path = "maps/shuttles/packed/armored.dmm"
	cost = 400

/*datum/map_element/shuttle/packed/cargo
	name = "Cargo Tanker"
	desc = "The AOG Hercules is an industrial-use cargo-shipping vessel specializing in the transportation of plasma stores. Kind of cramped for passenger use."
	file_path = "maps/shuttles/packed/cargo.dmm"
	cost = -200*/

/datum/map_element/shuttle/packed/diy
	name = "Do-It-Yourself Skiff"
	desc = "This isn't a ship, it's a bunch of materials loaded onto a support skiff! No atmosphere included."
	file_path = "maps/shuttles/packed/diy.dmm"
	cost = -200