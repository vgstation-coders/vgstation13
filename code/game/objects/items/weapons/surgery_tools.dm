/obj/item/weapon/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	item_state = "retractor"
	starting_materials = list(MAT_IRON = 10000, MAT_GLASS = 5000)
	melt_temperature = MELTPOINT_STEEL
	w_type = RECYK_METAL
	flags = FPRINT
	siemens_coefficient = 1
	w_class = W_CLASS_TINY
	origin_tech = Tc_MATERIALS + "=1;" + Tc_BIOTECH + "=1"

/obj/item/weapon/retractor/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is pulling \his eyes out with the [src.name]! It looks like \he's  trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/weapon/retractor/manager
	name = "surgical incision manager"
	desc = "A true extension of the surgeon's body, this marvel instantly cuts the organ, clamps any bleeding, and retracts the skin, allowing for the immediate commencement of therapeutic steps."
	icon_state = "incisionmanager"
	item_state = "incisionmanager"
	force = 7.5
	surgery_speed = 0.5
	origin_tech = Tc_MATERIALS + "=5;" + Tc_BIOTECH + "=5;" + Tc_ENGINEERING + "=4"

/obj/item/weapon/retractor/manager/New()
	..()
	icon_state = "incisionmanager_off"

	
/obj/item/weapon/hemostat
	name = "hemostat"
	desc = "You think you have seen this before."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	item_state = "hemostat"
	starting_materials = list(MAT_IRON = 5000, MAT_GLASS = 2500)
	w_type = RECYK_METAL
	flags = FPRINT
	siemens_coefficient = 1
	w_class = W_CLASS_TINY
	origin_tech = Tc_MATERIALS + "=1;" + Tc_BIOTECH + "=1"
	attack_verb = list("attacks", "pinches")


/obj/item/weapon/hemostat/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is pulling \his eyes out with the [src.name]! It looks like \he's  trying to commit suicide!</span>")
	return (BRUTELOSS)


/obj/item/weapon/cautery
	name = "cautery"
	desc = "This stops bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	item_state = "cautery"
	starting_materials = list(MAT_IRON = 5000, MAT_GLASS = 2500)
	w_type = RECYK_ELECTRONIC
	flags = FPRINT
	siemens_coefficient = 1
	w_class = W_CLASS_TINY
	origin_tech = Tc_MATERIALS + "=1;" + Tc_BIOTECH + "=1"
	attack_verb = list("burns")

/obj/item/weapon/cautery/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is burning \his eyes out with the [src.name]! It looks like \he's  trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/weapon/cautery/is_hot()
	return 1


/obj/item/weapon/surgicaldrill
	name = "surgical drill"
	desc = "You can drill using this item. You dig?"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	item_state = "surgicaldrill"
	hitsound = 'sound/weapons/circsawhit.ogg'
	starting_materials = list(MAT_IRON = 15000, MAT_GLASS = 10000)
	w_type = RECYK_ELECTRONIC
	flags = FPRINT
	siemens_coefficient = 1
	force = 15.0
	w_class = W_CLASS_MEDIUM
	origin_tech = Tc_MATERIALS + "=1;" + Tc_BIOTECH + "=1"
	attack_verb = list("drills")

/obj/item/weapon/surgicaldrill/suicide_act(mob/user)
	to_chat(viewers(user), pick("<span class='danger'>[user] is pressing the [src.name] to \his temple and activating it! It looks like \he's trying to commit suicide.</span>", \
						"<span class='danger'>[user] is pressing [src.name] to \his chest and activating it! It looks like \he's trying to commit suicide.</span>"))
	return (BRUTELOSS)


/obj/item/weapon/scalpel
	name = "scalpel"
	desc = "Cut, cut, and once more cut."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	hitsound = "sound/weapons/bladeslice.ogg"
	flags = FPRINT
	siemens_coefficient = 1
	sharpness = 1.5
	sharpness_flags = SHARP_TIP | SHARP_BLADE
	force = 10.0
	w_class = W_CLASS_TINY
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	starting_materials = list(MAT_IRON = 10000, MAT_GLASS = 5000)
	w_type = RECYK_METAL
	origin_tech = Tc_MATERIALS + "=1;" + Tc_BIOTECH + "=1"
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")

/obj/item/weapon/scalpel/suicide_act(mob/user)
	to_chat(viewers(user), pick("<span class='danger'>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
						"<span class='danger'>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
						"<span class='danger'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>"))
	return (BRUTELOSS)


/obj/item/weapon/scalpel/laser
	heat_production = 0
	damtype = "fire"
	sharpness_flags = SHARP_TIP | SHARP_BLADE | HOT_EDGE
	var/cauterymode = 0 //1 = cautery enabled

/obj/item/weapon/scalpel/laser/attack_self(mob/user)
	if(!cauterymode)
		to_chat(user, "You disable the blade and switch to the scalpel's cautery tool.")
		heat_production = 1600
		sharpness = 0
		sharpness_flags = 0
	else
		to_chat(user, "You return the scalpel to cutting mode.")
		heat_production = 0
		sharpness = initial(sharpness)
		sharpness_flags = initial(sharpness_flags)
	cauterymode = !cauterymode

/obj/item/weapon/scalpel/laser/tier1
	name = "basic laser scalpel"
	desc = "A scalpel augmented with a directed laser, allowing for bloodless incisions and built-in cautery. This one looks basic and could be improved."
	icon_state = "scalpel_laser1"
	item_state = "laserscalpel1"
	surgery_speed = 0.6

/obj/item/weapon/scalpel/laser/tier1/New()
	..()
	icon_state = "scalpel_laser1_off"

/obj/item/weapon/scalpel/laser/tier2
	name = "high-precision laser scalpel"
	desc = "A scalpel augmented with a directed laser, allowing for bloodless incisions and built-in cautery. This one looks to be the pinnacle of precision energy cutlery!"
	icon_state = "scalpel_laser2"
	item_state = "laserscalpel2"
	force = 15.0
	surgery_speed = 0.4

/obj/item/weapon/scalpel/laser/tier2/New()
	..()
	icon_state = "scalpel_laser2_off"


/obj/item/weapon/circular_saw
	name = "circular saw"
	desc = "For heavy duty cutting."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw3"
	hitsound = 'sound/weapons/circsawhit.ogg'
	flags = FPRINT
	siemens_coefficient = 1
	sharpness = 1
	sharpness_flags = SHARP_BLADE | SERRATED_BLADE | CHOPWOOD
	force = 15.0
	w_class = W_CLASS_MEDIUM
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	starting_materials = list(MAT_IRON = 20000, MAT_GLASS = 10000)
	w_type = RECYK_ELECTRONIC
	origin_tech = Tc_MATERIALS + "=1;" + Tc_BIOTECH + "=1"
	attack_verb = list("attacks", "slashes", "saws", "cuts")


/obj/item/weapon/circular_saw/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is sawing \his head in two with the [src.name]! It looks like \he's  trying to commit suicide!</span>")
	return (BRUTELOSS)


/obj/item/weapon/bonegel
	name = "bone gel"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone-gel"
	item_state = "bonegel"
	force = 0
	throwforce = 1.0
	w_class = W_CLASS_TINY

/obj/item/weapon/bonegel/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is eating the [src.name]! It looks like \he's  trying to commit suicide!</span>")//Don't eat glue kids.

	return (TOXLOSS)


/obj/item/weapon/FixOVein
	name = "FixOVein"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fixovein"
	item_state = "fixovein"
	force = 0
	throwforce = 1.0
	w_class = W_CLASS_TINY
	origin_tech = Tc_MATERIALS + "=1;" + Tc_BIOTECH + "=3"
	var/usage_amount = 10

/obj/item/weapon/bonesetter
	name = "bone setter"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone setter"
	item_state = "bonesetter"
	force = 8.0
	throwforce = 9.0
	w_class = W_CLASS_TINY
	throw_speed = 3
	throw_range = 5
	attack_verb = list("attacks", "hits", "bludgeons")


/obj/item/weapon/revivalprod
	name = "revival prod"
	desc = "A revival prod used to awaken sleeping patients."
	//icon = 'icons/obj/surgery.dmi'
	icon_state = "stun baton"
	force = 0


/obj/item/weapon/revivalprod/attack(mob/target,mob/user)
	if(target.lying)
		target.sleeping = max(0,target.sleeping-5)
		if(target.sleeping == 0)
			target.resting = 0
		target.AdjustParalysis(-3)
		target.AdjustStunned(-3)
		target.AdjustKnockdown(-3)
		playsound(get_turf(target), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		target.visible_message(
			"<span class='notice'>[user] prods [target] trying to wake \him up!</span>",
			"<span class='notice'>You prod [target] trying to wake \him up!</span>",
			)
	else
		return ..()
