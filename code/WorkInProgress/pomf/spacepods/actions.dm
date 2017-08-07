/datum/action/spacepod

/datum/action/spacepod/Trigger()
	..()
	var/obj/spacepod/S = target
	if(!istype(S))
		qdel(src)
		return

/datum/action/spacepod/fire_weapons
	name = "Fire weapons"

/datum/action/spacepod/fire_weapons/Trigger()
	..()
	var/obj/spacepod/S = target
	if(S.equipment_system && S.equipment_system.weapon_system)
		var/obj/item/device/spacepod_equipment/weaponry/W = S.equipment_system.weapon_system
		if(S.passengers.Find(owner) && !S.passenger_fire)
			to_chat(owner, "<span class = 'warning'>Passenger gunner system disabled.</span>")
			return
		W.fire_weapons()

/datum/action/spacepod/pilot //Subtype for space pod pilots only

/datum/action/spacepod/pilot/toggle_passengers
	name = "Toggle Passenger Allowance"

/datum/action/spacepod/pilot/toggle_passengers/Trigger()
	..()
	var/obj/spacepod/S = target
	S.toggle_passengers()

/datum/action/spacepod/pilot/toggle_passenger_weaponry
	name = "Toggle Passenger Weaponry"

/datum/action/spacepod/pilot/toggle_passenger_weaponry/Trigger()
	..()
	var/obj/spacepod/S = target
	S.toggle_passenger_guns()

/datum/action/spacepod/passenger //Subtype for passengers only

/datum/action/spacepod/passenger/Trigger()
	..()
	var/obj/spacepod/S = target
	if(!S || !S.passengers.len || !S.passengers.Find(owner))
		to_chat(owner, "<span class = 'warning'>How did you get control of this button?</span>")
		qdel(src)
		return

/datum/action/spacepod/passenger/assume_control
	name = "Assume pod controls"

/datum/action/spacepod/passenger/assume_control/Trigger()
	..()
	var/obj/spacepod/S = target

	if(!S.occupant)
		to_chat(owner, "<span class = 'warning'>You assume control of \the [S].</span>")
		S.move_passenger_outside(owner, get_turf(S))
		S.move_pilot_inside(owner)
		qdel(src)
	else
		to_chat(owner, "<span class = 'warning'>[S.occupant] is the pilot of \the [S] currently.</span>")