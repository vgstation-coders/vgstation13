/datum/malfhack_ability
	var/name = "HACK"						//ability name (must be unique)
	var/desc = "This does something."	//ability description
	var/icon = "radial_off"				//icon to display in the radial
	var/icon_toggled = "radial_on"
	
	var/toggled = FALSE		
	var/cost = 0

	var/obj/machinery/machine 

/datum/malfhack_ability/New(var/obj/machinery/M)
	machine = M

/datum/malfhack_ability/proc/activate(var/mob/living/silicon/ai/A)
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(!istype(A) || !istype(M))
		return FALSE
	if(M.processing_power >= cost)
		M.add_power(-cost)
		return TRUE
	return FALSE

/datum/malfhack_ability/proc/check_cost(var/mob/living/silicon/ai/A)
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(!istype(A) || !istype(M))
		return FALSE
	if(M.processing_power >= cost)
		return TRUE
	return FALSE

/datum/malfhack_ability/proc/check_available(var/mob/living/silicon/ai/A)
	//include some check for an ability
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(!istype(A) || !istype(M))
		return FALSE
	return TRUE


/datum/malfhack_ability/oneuse/activate(var/mob/living/silicon/ai/A)
	if(!..())
		return FALSE
	machine.hack_abilities -= src
	return TRUE


/datum/malfhack_ability/toggle/activate(var/mob/living/silicon/ai/A)
	if(!..())
		return FALSE
	toggled = !toggled
	return TRUE
	

//---------------------------------------

/datum/malfhack_ability/toggle/disable
	name = "Toggle On/Off"
	desc = "Disable/Enable this machine."
	icon = "radial_off"
	icon_toggled = "radial_on"

/datum/malfhack_ability/toggle/disable/activate(var/mob/living/silicon/ai/A)
	if(!..())
		return
	toggled ? (machine.stat |= FORCEDISABLE) : (machine.stat &= ~FORCEDISABLE)
	machine.power_change()  //update any lighting effects
	machine.update_icon()

//---------------------------------------


/datum/malfhack_ability/toggle/apclock
	name = "Toggle Exclusive Control"
	desc = "Enable/Disable Exclusive Control"
	icon = "radial_lock"
	icon_toggled = "radial_unlock_alt"

/datum/malfhack_ability/toggle/apclock/activate(var/mob/living/silicon/ai/A)
	if(!..())
		return
	var/obj/machinery/power/apc/P = machine
	if(!istype(P))
		return
	toggled ? (P.malflocked = TRUE) : (P.malflocked = FALSE)

//---------------------------------------

/datum/malfhack_ability/shunt
	name = "Shunt Core Processes"
	desc = "Upload your software to this APC and leave your core. You can return to your core as long as it is still intact."
	icon = "radial_shunt"

/datum/malfhack_ability/shunt/activate(var/mob/living/silicon/ai/A)
	if(!..())
		return
	var/obj/machinery/power/apc/P = machine
	if(!istype(P))
		return
	
	var/obj/machinery/hologram/holopad/H  = A.current
	if(istype(H))
		H.clear_holo()

	var/mob/living/silicon/shuntedAI/S = new(get_turf(A),A.laws,A)
	A.mind.transfer_to(S)
	new /obj/effect/malf_jaunt(S.loc, S, P)
	S.update_perception()
	

//---------------------------------------

/datum/malfhack_ability/oneuse/turret_pulse
	name = "Upgrade Turret Laser"
	desc = "Upgrade this turret's laser to a pulse laser."
	icon = "radial_pulse"
	cost = 10

/datum/malfhack_ability/oneuse/turret_pulse/activate(var/mob/living/silicon/ai/A)
	if(!..())
		return
	var/obj/machinery/turret/T = machine
	if(!istype(T))
		return
	T.installed = new /obj/item/weapon/gun/energy/pulse_rifle/destroyer(src)
	T.icon_state = "blue_target_prism"

/datum/malfhack_ability/oneuse/turret_upgrade
	name = "Upgrade Turret Power"
	desc = "Upgrade this turret's firerate and health."
	icon = "radial_upgrade"
	cost = 10

/datum/malfhack_ability/oneuse/turret_upgrade/activate(var/mob/living/silicon/ai/A)
	if(!..())
		return
	var/obj/machinery/turret/T = machine
	if(!istype(T))
		return
	T.health += 120	//200 Total HP
	T.shot_delay = 15
	T.fire_twice = TRUE


//--------------------------------------------------------

/datum/malfhack_ability/dump_dispenser_energy
	name = "Drain Energy"
	desc = "Drain the energy stored in this dispenser."
	icon = "radial_drain"
	cost = 5

/datum/malfhack_ability/dump_dispenser_energy/activate(var/mob/living/silicon/ai/A)
	if(!..())
		return
	var/obj/machinery/chem_dispenser/C = machine
	if(!istype(C))
		return
	C.energy = 0


//--------------------------------------------------------

/datum/malfhack_ability/create_lifelike_hologram
	name = "Create Lifelike Hologram"
	desc = "Project a realistic looking hologram from this holopad."
	icon = "radial_holo"
	cost = 5

/datum/malfhack_ability/create_lifelike_hologram/activate(var/mob/living/silicon/ai/A)
	var/obj/machinery/hologram/holopad/C = machine
	if(!istype(C))
		return
	if(C.create_advanced_holo(A))
		..()

/datum/malfhack_ability/create_lifelike_hologram/check_available(mob/living/silicon/ai/A)
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(!istype(A) || !istype(M))
		return FALSE
	if(!(locate(/datum/malf_module/holopadfaker) in M.purchased_modules))
		return FALSE
	return TRUE

//--------------------------------------------------------

/datum/malfhack_ability/overload
	name = "Overload Machine"
	desc = "Overload the circuits in this machine, causing an explosion."
	icon = "radial_overload"
	cost = 5

/datum/malfhack_ability/overload/activate(var/mob/living/silicon/ai/A)
	machine.visible_message("<span class='warning'>You hear a [pick("loud", "violent", "unsettling")], [pick("electrical","mechanical")] [pick("buzzing","rumbling","shaking")] sound!</span>") //highlight this, motherfucker
	spark(machine)
	machine.shake_animation(4, 4, 0.2 SECONDS, 4, 5)
	spawn(4 SECONDS)
		explosion(get_turf(machine), -1, 1, 2, 3) //C4 Radius + 1 Dest for the machine
		qdel(machine)

/datum/malfhack_ability/overload/check_available(mob/living/silicon/ai/A)
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(!istype(A) || !istype(M))
		return FALSE
	if(!(locate(/datum/malf_module/overload) in M.purchased_modules))
		return FALSE
	return TRUE