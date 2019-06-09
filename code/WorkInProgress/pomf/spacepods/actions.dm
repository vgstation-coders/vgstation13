/datum/action/spacepod
	icon_icon = 'icons/pods/button_icons.dmi'
	background_icon_state = "bg_pod"

/datum/action/spacepod/Trigger()
	..()
	var/obj/spacepod/S = target
	if(!istype(S))
		qdel(src)
		return

/datum/action/spacepod/fire_weapons
	name = "Fire weapons"
	button_icon_state = "weapon"

/datum/action/spacepod/fire_weapons/Trigger()
	..()
	var/obj/spacepod/S = target
	if(S.ES && S.ES.weapon_system)
		var/obj/item/device/spacepod_equipment/weaponry/W = S.ES.weapon_system
		var/list/passengers = S.get_passengers()
		if(passengers.Find(owner) && !S.passenger_fire)
			to_chat(owner, "<span class = 'warning'>Passenger gunner system disabled.</span>")
			return
		W.fire_weapons()

/datum/action/spacepod/pilot //Subtype for space pod pilots only

/datum/action/spacepod/pilot/toggle_passengers
	name = "Toggle Passenger Allowance"
	button_icon_state = "lock_open"

/datum/action/spacepod/pilot/toggle_passengers/Trigger()
	..()
	var/obj/spacepod/S = target
	S.toggle_passengers()
	if(S.passengers_allowed)
		button_icon_state = "lock_open"
	else
		button_icon_state = "lock_closed"
	UpdateButtonIcon()

/datum/action/spacepod/pilot/toggle_passenger_weaponry
	name = "Toggle Passenger Weaponry"
	button_icon_state = "weapons_on"

/datum/action/spacepod/pilot/toggle_passenger_weaponry/Trigger()
	..()
	var/obj/spacepod/S = target
	S.toggle_passenger_guns()
	if(S.passenger_fire)
		button_icon_state = "weapons_on"
	else
		button_icon_state = "weapons_off"
	UpdateButtonIcon()

/datum/action/spacepod/passenger //Subtype for passengers only

/datum/action/spacepod/passenger/Trigger()
	..()
	var/obj/spacepod/S = target
	if(!S || !S.occupants.Find(owner))
		to_chat(owner, "<span class = 'warning'>How did you get control of this button?</span>")
		qdel(src)
		return

/datum/action/spacepod/pilot/change_speed
	name = "Change speed"
	button_icon_state = "change_speed"

/datum/action/spacepod/pilot/change_speed/Trigger()
	..()
	var/obj/spacepod/S = target
	S.change_speed()

/datum/action/spacepod/pilot/toggle_lights
	name = "Toggle lights"
	button_icon_state = "toggle_lights"

/datum/action/spacepod/pilot/toggle_lights/Trigger()
	..()
	var/obj/spacepod/S = target
	S.toggle_lights()