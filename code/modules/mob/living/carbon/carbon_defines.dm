/mob/living/carbon/
	gender = MALE
	var/list/stomach_contents = list()

	var/last_eating = 0 	//Not sure what this does... I found it hidden in food.dm

	var/life_tick = 0      // The amount of life ticks that have processed on this mob.
	// total amount of wounds on mob, used to spread out healing and the like over all wounds
	var/number_wounds = 0

	var/mob/living/carbon/mutual_handcuffed_to = null
	var/mutual_handcuffed_to_event_key = null
	var/obj/item/handcuffed = null //Whether or not the mob is handcuffed.
	var/obj/item/weapon/handcuffs/mutual_handcuffs = null // whether or not cuffed to somebody else
	var/mutual_handcuff_forcemove_time = 0 //last teleport time when user moves ontop of another
	var/obj/item/legcuffed = null  //Same as handcuffs but for legs. Bear traps use this.
	//Surgery info
	var/datum/surgery_status/op_stage = new/datum/surgery_status

	var/pulse = PULSE_NORM	//current pulse level

	var/hasmouth = 1 // Used for food, etc.
	var/give_check = FALSE
	var/event/on_emote = new ()
	var/base_insulation = 0
	var/unslippable = 0 //Whether the mob can be slipped
	var/list/body_alphas = list()	//Alpha values applied to just the body sprite of humans/monkeys, rather than their whole icon
	var/coughedtime = null
	status_flags = CANSTUN|CANKNOCKDOWN|CANPARALYSE|CANPUSH
	var/obj/item/device/station_map/displayed_holomap = null

/mob/living/carbon/Destroy()
	if (mutual_handcuffs && mutual_handcuffed_to)
		mutual_handcuffs.remove_mutual_cuff_events(mutual_handcuffed_to)
	. = ..()
