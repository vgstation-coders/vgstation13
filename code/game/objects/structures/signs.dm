/*//////////////////////////////////////////
//			WARNING! ACHTUNG!			  //
//		WHEN YOU'RE MAKING A SIGN:		  //
//		REMEMBER TO USE \improper		  //
//	ONLY IF NAME IS CAPITALIZED AND 	  //
//ACTUALLY NOT PROPER; FAILURE TO DO THIS //
// WILL RESULT IN MESSAGES LIKE "The The  //
//	Periodic Table has been hit..."		  //
//	PLEASE REMEMBER THAT AND THANKS.	  //
//			HAVE A NICE DAY!			  //
*///////////////////////////////////////////

/obj/structure/sign
	icon = 'icons/obj/decals.dmi'
	anchored = 1
	opacity = 0
	density = 0
	layer = ABOVE_WINDOW_LAYER


/obj/structure/sign/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			qdel(src)
			return
		if(3.0)
			qdel(src)
			return
		else
	return

/obj/structure/sign/blob_act()
	qdel(src)
	return

/obj/structure/sign/attackby(obj/item/tool as obj, mob/user as mob)	//deconstruction
	if(tool.is_screwdriver(user) && !istype(src, /obj/structure/sign/double))
		to_chat(user, "You unfasten the sign with your [tool].")
		var/obj/item/sign/S = new(src.loc)
		S.name = name
		S.desc = desc
		S.icon_state = icon_state
		//var/icon/I = icon('icons/obj/decals.dmi', icon_state)
		//S.icon = I.Scale(24, 24)
		S.sign_state = icon_state
		qdel(src)
		return
	else
		..()

/obj/item/sign
	name = "sign"
	desc = ""
	icon = 'icons/obj/decals.dmi'
	w_class = W_CLASS_MEDIUM		//big
	var/sign_state = ""

/obj/item/sign/attackby(obj/item/tool as obj, mob/user as mob)	//construction
	if(tool.is_screwdriver(user) && isturf(user.loc))
		var/direction = input("In which direction?", "Select direction.") in list("North", "East", "South", "West", "Cancel")
		if(direction == "Cancel" || src.loc == null)
			return // We can get qdel'd if someone spams screwdrivers on signs before responding to the prompt.
		var/obj/structure/sign/S = new(user.loc)
		switch(direction)
			if("North")
				S.pixel_y = WORLD_ICON_SIZE
			if("East")
				S.pixel_x = WORLD_ICON_SIZE
			if("South")
				S.pixel_y = -WORLD_ICON_SIZE
			if("West")
				S.pixel_x = -WORLD_ICON_SIZE
			else
				return
		S.name = name
		S.desc = desc
		S.icon_state = sign_state
		to_chat(user, "You fasten \the [S] with your [tool].")
		qdel(src)
		return
	else
		..()

/obj/structure/sign/kick_act(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] kicks \the [src]!</span>", "<span class='danger'>You kick \the [src]!</span>")

	if(prob(70))
		to_chat(H, "<span class='userdanger'>Ouch! That hurts!</span>")

		H.apply_damage(rand(5,7), BRUTE, pick(LIMB_RIGHT_LEG, LIMB_LEFT_LEG, LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT))

/obj/structure/sign/double/map
	name = "station map"
	desc = "A framed picture of the station."

/obj/structure/sign/double/map/left
	icon_state = "map-left"

/obj/structure/sign/double/map/right
	icon_state = "map-right"

//For efficiency station
/obj/structure/sign/map/efficiency
	name = "station map"
	desc = "A framed picture of the station."
	icon_state = "map_efficiency"

/obj/structure/sign/map/meta/left
	name = "station map"
	desc = "A framed picture of the station."
	icon_state = "map-left-MS"

/obj/structure/sign/map/meta/right
	name = "station map"
	desc = "A framed picture of the station."
	icon_state = "map-right-MS"

/obj/structure/sign/securearea
	name = "SECURE AREA"
	desc = "A warning sign which reads 'SECURE AREA'."
	icon_state = "securearea"

/obj/structure/sign/parking
	name = "PARKING AREA"
	desc = "A sign which indicates that this is a designated area for parking vehicles."
	icon_state = "parking"

/obj/structure/sign/biohazard
	name = "BIOHAZARD"
	desc = "A warning sign which reads 'BIOHAZARD'."
	icon_state = "bio"

/obj/structure/sign/electricshock
	name = "HIGH VOLTAGE"
	desc = "A warning sign which reads 'HIGH VOLTAGE'."
	icon_state = "shock"

/obj/structure/sign/examroom
	name = "EXAM"
	desc = "A guidance sign which reads 'EXAM ROOM'."
	icon_state = "examroom"

/obj/structure/sign/vacuum
	name = "HARD VACUUM AHEAD"
	desc = "A warning sign which reads 'HARD VACUUM AHEAD'."
	icon_state = "space"

/obj/structure/sign/deathsposal
	name = "DISPOSAL LEADS TO SPACE"
	desc = "A warning sign which reads 'DISPOSAL LEADS TO SPACE'."
	icon_state = "deathsposal"

/obj/structure/sign/pods
	name = "ESCAPE PODS"
	desc = "A warning sign which reads 'ESCAPE PODS'."
	icon_state = "pods"

/obj/structure/sign/fire
	name = "DANGER: FIRE"
	desc = "A warning sign which reads 'DANGER: FIRE'."
	icon_state = "fire"

/obj/structure/sign/nosmoking_1
	name = "NO SMOKING"
	desc = "A warning sign which reads 'NO SMOKING'."
	icon_state = "nosmoking"

/obj/structure/sign/nosmoking_2
	name = "NO SMOKING"
	desc = "A warning sign which reads 'NO SMOKING'."
	icon_state = "nosmoking2"

/obj/structure/sign/redcross
	name = "Medbay"
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here.'"
	icon_state = "redcross"

/obj/structure/sign/greencross
	name = "Medbay"
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here.'"
	icon_state = "greencross"

/obj/structure/sign/goldenplaque
	name = "The Most Robust Men Award for Robustness"
	desc = "\"To be robust is not an action or a way of life, but a mental state. Only those with the force of will strong enough to act during a crisis, saving friend from foe, acting when everyone else may think and act against you, are truly robust. Stay robust, my friends.\""
	icon_state = "goldenplaque"

/obj/structure/sign/kiddieplaque
	name = "\improper AI developer's plaque"
	desc = "Next to the extremely long list of names and job titles, there is a drawing of a little child. The child appears to be retarded. Beneath the image, someone has scratched the word \"PACKETS\"."
	icon_state = "kiddieplaque"

/obj/structure/sign/atmosplaque
	name = "\improper FEA Atmospherics Division plaque"
	desc = "This plaque commemorates the fall of the Atmos FEA division. For all the charred, dizzy, and brittle men who have died in its hands."
	icon_state = "atmosplaque"

/obj/structure/sign/science			//These 3 have multiple types, just var-edit the icon_state to whatever one you want on the map
	name = "SCIENCE!"
	desc = "A warning sign which reads 'SCIENCE!'."
	icon_state = "science1"

/obj/structure/sign/chemistry
	name = "CHEMISTRY"
	desc = "A warning sign which reads 'CHEMISTRY'."
	icon_state = "chemistry1"

/obj/structure/sign/chemtable
	name = "The Periodic Table"
	desc = "A very colorful and detailed table of all the chemical elements you could blow up or burn down a chemistry laboratory with, titled 'The Space Periodic Table - To be continued'. Just the mere sight of it makes you feel smarter."
	icon_state = "periodic"

/obj/structure/sign/botany
	name = "HYDROPONICS"
	desc = "A warning sign which reads 'HYDROPONICS'."
	icon_state = "hydro1"

/obj/structure/sign/directions/science
	name = "Science department"
	desc = "A direction sign, pointing out which way Science department is."
	icon_state = "direction_sci"

/obj/structure/sign/directions/engineering
	name = "Engineering department"
	desc = "A direction sign, pointing out which way Engineering department is."
	icon_state = "direction_eng"

/obj/structure/sign/directions/security
	name = "Security department"
	desc = "A direction sign, pointing out which way Security department is."
	icon_state = "direction_sec"

/obj/structure/sign/directions/medical
	name = "Medical Bay"
	desc = "A direction sign, pointing out the direction of the medical bay."
	icon_state = "direction_med"

/obj/structure/sign/directions/evac
	name = "Escape Arm"
	desc = "A direction sign, pointing out which way escape shuttle dock is."
	icon_state = "direction_evac"

/obj/structure/sign/crime
	name = "CRIME DOES NOT PAY"
	desc = "A warning sign which suggests that you reconsider your poor life choices."
	icon_state = "crime"

/obj/structure/sign/chinese
	name = "incomprehensible sign"
	desc = "A sign written using traditional chinese characters. A native Sol Common speaker might understand it."

/obj/structure/sign/chinese/restricted_area
	icon_state = "CH_restricted_area"

/obj/structure/sign/chinese/caution
	icon_state = "CH_caution"

/obj/structure/sign/chinese/danger
	icon_state = "CH_danger"

/obj/structure/sign/chinese/electrical_equipment
	icon_state = "CH_electrical_equipment"

/obj/structure/sign/chinese/access_restricted
	icon_state = "CH_access_restricted"

/obj/structure/sign/chinese/notice
	icon_state = "CH_notice"

/obj/structure/sign/chinese/security
	icon_state = "CH_security"

/obj/structure/sign/chinese/engineering
	icon_state = "CH_engineering"

/obj/structure/sign/chinese/science
	icon_state = "CH_science"

/obj/structure/sign/chinese/medbay
	icon_state = "CH_medbay"

/obj/structure/sign/chinese/evacuation
	icon_state = "CH_evacuation"

/obj/structure/sign/russian
	name = "incomprehensible sign"
	desc = "A sign written in russian."

/obj/structure/sign/russian/electrical_danger
	icon_state = "RU_electrical_danger"

/obj/structure/sign/russian/caution
	icon_state = "RU_caution"

/obj/structure/sign/russian/staff_only
	icon_state = "RU_staff_only"

/obj/structure/sign/shard
	icon_state = "shard_b"
	name = "SUPERMATTER SHARD"
	desc = "A sign which reads 'SUPERMATTER SHARD'."

/obj/structure/sign/shard/red
	icon_state = "shard_r"

/obj/structure/sign/shard/yellow
	icon_state = "shard_y"

/obj/structure/sign/shard/circle
	icon_state = "shard_circle"

/obj/structure/sign/pox
	name = "NO VOX ALLOWED"
	icon_state = "novox1-b"
	desc = "A sign which reads 'NO VOX ALLOWED'."

/obj/structure/sign/pox/no_cross
	icon_state = "novox2-b"

/obj/structure/sign/pox/red
	icon_state = "novox1-r"

/obj/structure/sign/pox/red/no_cross
	icon_state = "novox2-r"

/obj/structure/sign/pox/red/cicle
	icon_state = "novox_circle1"

/obj/structure/sign/pox/red/cicle/no_cross
	icon_state = "novox_circle2"