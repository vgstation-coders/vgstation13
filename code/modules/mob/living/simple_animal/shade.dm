/mob/living/simple_animal/shade
	name = "Shade"
	real_name = "Shade"
	desc = "A bound spirit."
	gender = PLURAL
	icon = 'icons/mob/mob.dmi'
	icon_state = "shade"
	icon_living = "shade"
	maxHealth = 40
	health = 40
	spacewalk = TRUE
	healable = 0
	speak_emote = list("hisses")
	emote_hear = list("wails.","screeches.")
	response_help  = "puts their hand through"
	response_disarm = "flails at"
	response_harm   = "punches"
	speak_chance = 1
	melee_damage_lower = 5
	melee_damage_upper = 12
	attacktext = "metaphysically strikes"
	minbodytemp = 0
	maxbodytemp = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	stop_automated_movement = 1
	status_flags = 0
	faction = list("cult")
	status_flags = CANPUSH
	movement_type = FLYING
	loot = list(/obj/item/ectoplasm)
	del_on_death = TRUE
	initial_language_holder = /datum/language_holder/construct

/mob/living/simple_animal/shade/death()
	deathmessage = "lets out a contented sigh as [p_their()] form unwinds."
	..()

/mob/living/simple_animal/shade/canSuicide()
	if(istype(loc, /obj/item/device/soulstone)) //do not suicide inside the soulstone
		return 0
	return ..()

/mob/living/simple_animal/shade/attack_animal(mob/living/simple_animal/M)
	if(isconstruct(M))
		var/mob/living/simple_animal/hostile/construct/C = M
		if(!C.can_repair_constructs)
			return
		if(health < maxHealth)
			adjustHealth(-25)
			Beam(M,icon_state="sendbeam",time=4)
			M.visible_message("<span class='danger'>[M] heals \the <b>[src]</b>.</span>", \
					   "<span class='cult'>You heal <b>[src]</b>, leaving <b>[src]</b> at <b>[health]/[maxHealth]</b> health.</span>")
		else
			to_chat(M, "<span class='cult'>You cannot heal <b>[src]</b>, as [p_they()] [p_are()] unharmed!</span>")
	else if(src != M)
		return ..()

/mob/living/simple_animal/shade/attackby(obj/item/O, mob/user, params)  //Marker -Agouri
	if(istype(O, /obj/item/device/soulstone))
		var/obj/item/device/soulstone/SS = O
		SS.transfer_soul("SHADE", src, user)
	else
		. = ..()
