/obj/item/device/flashlight
	name = "flashlight"
	desc = "A hand-held emergency light."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight"
	item_state = "flashlight"
	origin_tech = Tc_ENGINEERING + "=1"
	w_class = W_CLASS_SMALL
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	starting_materials = list(MAT_IRON = 50, MAT_GLASS = 20)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_STEEL // Assuming big beefy fucking maglite.
	actions_types = list(/datum/action/item_action/toggle_light)
	light_type = LIGHT_SOFT
	lighting_flags = MOVABLE_LIGHT
	var/on = 0
	light_range = 4
	var/has_sound = 1 //The CLICK sound when turning on/off
	var/sound_on = 'sound/items/flashlight_on.ogg'
	var/sound_off = 'sound/items/flashlight_off.ogg'

/obj/item/device/flashlight/initialize()
	..()
	if(on)
		icon_state = "[initial(icon_state)]-on"
		set_light()
	else
		icon_state = initial(icon_state)
		kill_light()

/obj/item/device/flashlight/proc/update_brightness(var/mob/user = null, var/playsound = 1)
	if(on)
		icon_state = "[initial(icon_state)]-on"
		set_light()
		if(playsound && has_sound)
			if(get_turf(src))
				playsound(src, sound_on, 50, 1)
	else
		icon_state = initial(icon_state)
		kill_light()
		if(playsound && has_sound)
			playsound(src, sound_off, 50, 1)

/obj/item/device/flashlight/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "You cannot turn the light on while in this [user.loc].")//To prevent some lighting anomalities.

		return 0
	on = !on
	update_brightness(user)
	return 1

/obj/item/device/flashlight/attack_animal(mob/living/simple_animal/M)
	if(M.melee_damage_upper == 0)
		return
	else if (on && isspider(M))
		on = FALSE
		M.do_attack_animation(src, M)
		update_brightness(M,1)

/obj/item/device/flashlight/attack(mob/living/M as mob, mob/living/user as mob)
	add_fingerprint(user)
	if(on && user.zone_sel.selecting == "eyes")

		if((clumsy_check(user) || user.getBrainLoss() >= 60) && prob(50))	//too dumb to use flashlight properly
			return ..()	//just hit them in the head

		if (!user.dexterity_check())
			to_chat(user, "<span class='notice'>You don't have the dexterity to do this!</span>")
			return

		var/mob/living/carbon/human/H = M	//mob has protective eyewear
		if(istype(M, /mob/living/carbon/human))
			var/obj/item/eye_protection = H.get_body_part_coverage(EYES)
			if(eye_protection)
				to_chat(user, "<span class='notice'>You're going to need to remove their [eye_protection] first.</span>")
				return

		if(M == user)	//they're using it on themselves
			if(!M.blinded)
				M.flash_eyes(visual = 1)
				M.visible_message("<span class='notice'>[M] directs [src] to \his eyes.</span>", \
									 "<span class='notice'>You wave the light in front of your eyes! Trippy!</span>")
			else
				M.visible_message("<span class='notice'>[M] directs [src] to \his eyes.</span>", \
									 "<span class='notice'>You wave the light in front of your eyes.</span>")
			return

		user.visible_message("<span class='notice'>[user] directs [src] to [M]'s eyes.</span>", \
							 "<span class='notice'>You direct [src] to [M]'s eyes.</span>")

		if(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/carbon/monkey))	//robots and aliens are unaffected
			if(M.stat == DEAD || M.sdisabilities & BLIND)	//mob is dead or fully blind
				to_chat(user, "<span class='notice'>[M] pupils does not react to the light!</span>")
			else if(M_XRAY in M.mutations)	//mob has X-RAY vision
				M.flash_eyes(visual = 1)
				to_chat(user, "<span class='notice'>[M] pupils give an eerie glow!</span>")
			else	//they're okay!
				if(!M.blinded)
					M.flash_eyes(visual = 1)
					to_chat(user, "<span class='notice'>[M]'s pupils narrow.</span>")
	else
		return ..()

/obj/item/device/flashlight/pen
	name = "penlight"
	desc = "A pen-sized light, used by medical staff."
	icon_state = "penlight"
	item_state = ""
	flags = FPRINT
	siemens_coefficient = 1
	light_range = 2
	has_sound = 0

/obj/item/device/flashlight/tactical
	name = "tactical light"
	desc = "A compact, tactical flashlight with automatic self-attaching screws. Fits on armor and headgear."
	icon_state = "taclight"
	item_state = ""

/obj/item/device/flashlight/tactical/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return 0
	if(istype(target, /obj/item/clothing/head) || istype(target, /obj/item/clothing/suit/armor))
		var/obj/item/clothing/C = target
		var/obj/item/clothing/accessory/taclight/TL = new()
		if(C.check_accessory_overlap(TL))
			to_chat(user, "<span class='notice'>You cannot attach more accessories of this type to \the [C].</span>")
			return
		if(user.drop_item(src))
			to_chat(user, "<span class='notice'>You attach \the [src] to \the [C].</span>")
			TL.source_light = src
			C.attach_accessory(TL)
			transfer_fingerprints(src,TL)
			forceMove(TL)
		return 1
	else
		to_chat(user, "<span class='notice'>\The [src] cannot be attached to that.</span>")
	return ..()


// the desk lamps are a bit special
/obj/item/device/flashlight/lamp
	name = "desk lamp"
	desc = "A desk lamp with an adjustable mount."
	icon_state = "lamp"
	item_state = "lamp"
	light_range = 5
	light_type = LIGHT_SOFT
	w_class = W_CLASS_LARGE
	flags = FPRINT
	siemens_coefficient = 1
	starting_materials = null
	on = 1

/obj/item/device/flashlight/lamp/cultify()
	new /obj/structure/cult_legacy/pylon(loc)
	qdel(src)

// green-shaded desk lamp
/obj/item/device/flashlight/lamp/green
	desc = "A classic green-shaded desk lamp."
	icon_state = "lampgreen"
	item_state = "lampgreen"
	light_range = 5


/obj/item/device/flashlight/lamp/verb/toggle_light()
	set name = "Toggle light"
	set category = "Object"
	set src in oview(1)

	if(!usr.stat)
		attack_self(usr)

// FLARES

/obj/item/device/flashlight/flare
	name = "flare"
	desc = "A red Nanotrasen issued flare. There are instructions on the side, it reads 'pull cord, make light'."
	w_class = W_CLASS_SMALL
	light_range = 4
	light_power = 2.5 // Pretty bright.
	light_type = LIGHT_SOFT_FLICKER
	icon_state = "flare"
	item_state = "flare"
	actions_types = list(/datum/action/item_action/toggle_light)
	sound_on = "sound/items/flare_on.ogg"
	sound_off = ""
	var/fuel = 0
	var/on_damage = 7
	heat_production = 1500
	source_temperature = TEMPERATURE_FLAME
	var/H_color = ""

	light_type = LIGHT_SOFT_FLICKER
	light_color = LIGHT_COLOR_FLARE

/obj/item/device/flashlight/flare/New()
	fuel = rand(300, 500) // Sorry for changing this so much but I keep under-estimating how long X number of ticks last in seconds.
	..()

/obj/item/device/flashlight/flare/examine(mob/user)
	..()
	if(on)
		to_chat(user, "<span class='info'>The flare is lit.</span>")
	else if(fuel)
		to_chat(user, "<span class='info'>The flare is ready to be used.</span>")
	else
		to_chat(user, "<span class='info'>The flare has been expended.</span>")

/obj/item/device/flashlight/flare/process()
	var/turf/pos = get_turf(src)
	if(pos)
		pos.hotspot_expose(heat_production, 5,surfaces=istype(loc,/turf))
	fuel = max(fuel - 1, 0)
	if(!fuel || !on)
		turn_off()
		if(!fuel)
			src.icon_state = "[initial(icon_state)]-empty"
		processing_objects -= src

/obj/item/device/flashlight/flare/proc/turn_off()
	on = 0
	src.force = initial(src.force)
	src.damtype = initial(src.damtype)
	if(ismob(loc))
		var/mob/U = loc
		update_brightness(U)
	else
		update_brightness()

/obj/item/device/flashlight/flare/attack_self(mob/user)

	// Usual checks
	if(!fuel)
		to_chat(user, "<span class='notice'>It's out of fuel.</span>")
		return
	if(on)
		return
	// All good, turn it on.
	user.visible_message("<span class='notice'>[user] activates the flare.</span>", "<span class='notice'>You pull the cord on the flare, activating it!</span>")
	Light(user)


/obj/item/device/flashlight/flare/attack_animal(mob/living/simple_animal/M)
	return

/obj/item/device/flashlight/flare/proc/Light(var/mob/user as mob)
	on = 1
	src.force = on_damage
	src.damtype = "fire"
	processing_objects += src
	if(user)
		update_brightness(user)
	else
		update_brightness()

/obj/item/device/flashlight/flare/is_hot()
	if(on)
		return source_temperature
	return 0

/obj/item/device/flashlight/flare/suicide_act(var/mob/living/user)
	if(!on)
		Light(user)
	to_chat(viewers(user), "<span class='danger'>[user] is swallowing a lit flare! It looks like \he's trying to commit suicide.</span>")
	qdel(src)
	if(!fuel)
		return (SUICIDE_ACT_TOXLOSS)
	user.IgniteMob()
	return (SUICIDE_ACT_TOXLOSS|SUICIDE_ACT_FIRELOSS)

/obj/item/device/flashlight/flare/ever_bright/New()
	. = ..()
	fuel = INFINITY
	Light()

// SLIME LAMP
/obj/item/device/flashlight/lamp/slime
	name = "slime lamp"
	desc = "A lamp powered by a slime core. You can adjust its brightness by touching it."
	icon_state = "slimelamp"
	item_state = ""
	origin_tech = Tc_BIOTECH + "=3"
	light_color = LIGHT_COLOR_SLIME_LAMP
	on = 0
	luminosity = 2
	has_sound = 0
	var/brightness_max = 6
	var/brightness_min = 2

/obj/item/device/flashlight/lamp/slime/initialize()
	..()
	if(on)
		icon_state = "[initial(icon_state)]-on"
		set_light(brightness_max)
	else
		icon_state = initial(icon_state)
		set_light(brightness_min)

/obj/item/device/flashlight/lamp/slime/proc/slime_brightness(var/mob/user = null)
	if(on)
		icon_state = "[initial(icon_state)]-on"
		set_light(brightness_max)
	else
		icon_state = initial(icon_state)
		set_light(brightness_min)

/obj/item/device/flashlight/lamp/slime/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "You cannot turn the light on while in this [user.loc].")
		return 0
	on = !on
	slime_brightness(user)
	return 1

//EMP FLASHLIGHT
/obj/item/device/flashlight/emp //EMP flashlight for syndicate boys and girls. Idea secured from TG
	origin_tech = Tc_SYNDICATE + "=3;" + Tc_ENGINEERING + "=1" //Tech levels when deconstructed in a Destructive Analyzer
//Default description as flashlight but defined proc below determines if you can see the counter and timer.
	var/charge_max = 4 //The amount of charges it stores. Also uses vars so admins can tamper with this
	var/charge_current = 4 //The amount of charges it spawns with
	var/charge_tick = 0 //In our case, it is used as a 'timer' until you gain a new charge.
	var/processing = FALSE
	var/charge_seconds = 0 //For the timer

/obj/item/device/flashlight/emp/New() //If it exists, it will be processed (constantly updated). Taken from advanced energy gun code
	..() //The "New" process does everything normally except...
	processing_objects.Add(src) //Adds the item to the list of processing items. src is the flashlight (source)

/obj/item/device/flashlight/emp/Destroy() //If it no longer exists, it will no longer be processed to prevent unnecessary lag
	processing_objects.Remove(src) //Removes from list of processed items
	..() //Do the rest of the destroy process

/obj/item/device/flashlight/emp/process() //EMP flashlight process
	if(charge_current >= charge_max) //Performance stuff
		processing = FALSE
		processing_objects.Remove(src)
	charge_tick++ //Post-increment charge_tick. It increases by 1 every time it is processed.
	charge_seconds = (charge_tick*2) //For timer
	if(charge_tick < 15) //15 ticks required until you gain a flashlight charge
		return 0 //If it's not 15 ticks then cancel the process until it is called again next tick
	charge_tick = 0 //If it's 15 ticks reset to 0
	charge_current = min(charge_current+1, charge_max) //Either add +1 to charge_current (give it another charge in our case), or remain at the value determined by charge_max, depends on which value is lower
	return 1

/obj/item/device/flashlight/emp/afterattack(atom/movable/A, mob/user, proximity) //Can use it on anyone and anything as long as you are near them
	. = ..() //I don't really grasp the idea of what this does but it's important
	if(!proximity) //If you are not near whatever you use this on...
		return 0 //Cancel the whole thing
	if(!processing) //Performance stuff
		processing = TRUE
		processing_objects.Add(src)
	if (charge_current > 0) //If you don't have 0 "current charge"
		charge_current -= 1 //Reduce the charge counter by 1
		if(ismob(A)) //If whatever you attack is a person
			var/mob/M = A //Makes A count as M
			log_attack("<span class='bad'>[user.name] ([user.ckey]) has used an EMP flashlight on [M.name] ([M.ckey])!</span>") //Admin logs when checking someone's attack logs
			M.visible_message("<span class='danger'>[user] has blasted [A] with a pulse! </span>", \
			"<span class='userdanger'>You have been blasted with a pulse!</span>") //What other people see when someone blasts someone with EMP and what you see if someone blasts you, respectively
		else //If whatever you attack is not a person
			log_attack("<span class='bad'>[user.name] ([user.ckey]) has used an EMP flashlight on [A.name]!</span>") //Admin logs show what item you used the EMP flashlight on
			A.visible_message("<span class='danger'>[user] has blasted [A]!</span>") //What people see when someone EMPs an object
		to_chat(user, "The EMP flashlight has [charge_current] charges left.") //Shows the user how many charges are left on the EMP.
		A.emp_act(2) //Light EMP pulse
	else //If you are in proximity but there are no charges
		to_chat (user, "<span class='warning'>\The [src] must take time to recharge.</span>") //Wait for the EMP flashlight to recharge

/obj/item/device/flashlight/emp/examine(mob/user) //What happens if you examine
	..() //Examine is normal except for the to_chat appearing afterwards
	if(is_holder_of(user, src)) //If you hold it
		to_chat(user, "Charges: <span class='bad'>[charge_current]/4</span>") //Shows you in red how many charges are left out of how many
		to_chat(user, "Timer: <span class='good'>[charge_seconds]/30</span>") //Shows you in green the timer until 30 seconds
