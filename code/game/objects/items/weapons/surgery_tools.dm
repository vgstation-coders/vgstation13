/obj/item/tool/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/surgery_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/surgery_tools.dmi')
	item_state = "retractor"
	starting_materials = list(MAT_IRON = 10000, MAT_GLASS = 5000)
	melt_temperature = MELTPOINT_STEEL
	w_type = RECYK_METAL
	flags = FPRINT
	siemens_coefficient = 1
	w_class = W_CLASS_TINY
	origin_tech = Tc_MATERIALS + "=1;" + Tc_BIOTECH + "=1"
	surgerysound = 'sound/items/retractor.ogg'

/obj/item/tool/retractor/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is pulling \his eyes out with the [src.name]! It looks like \he's  trying to commit suicide!</span>")
	return (SUICIDE_ACT_BRUTELOSS)

/obj/item/tool/retractor/manager
	name = "surgical incision manager"
	desc = "A true extension of the surgeon's body, this marvel instantly cuts the organ, clamps any bleeding, and retracts the skin, allowing for the immediate commencement of therapeutic steps."
	icon_state = "incisionmanager"
	item_state = "incisionmanager"
	force = 7.5
	toolspeed = 0.5
	origin_tech = Tc_MATERIALS + "=5;" + Tc_BIOTECH + "=5;" + Tc_ENGINEERING + "=4"
	surgerysound = 'sound/items/hemostat.ogg'

/obj/item/tool/retractor/manager/New()
	..()
	icon_state = "incisionmanager_off"


/obj/item/tool/hemostat
	name = "hemostat"
	desc = "You think you've seen this before."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/surgery_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/surgery_tools.dmi')
	item_state = "hemostat"
	starting_materials = list(MAT_IRON = 5000, MAT_GLASS = 2500)
	w_type = RECYK_METAL
	flags = FPRINT
	siemens_coefficient = 1
	w_class = W_CLASS_TINY
	origin_tech = Tc_MATERIALS + "=1;" + Tc_BIOTECH + "=1"
	attack_verb = list("attacks", "pinches")
	surgerysound = 'sound/items/hemostat.ogg'


/obj/item/tool/hemostat/pico //Removes implanted things with 100% success as well.
	name = "precision grasper"
	desc = "A thin rod with pico manipulators embedded in it allowing for fast and precise extraction."
	icon_state = "pico_grasper"
	item_state = "pico_grasper"
	origin_tech = Tc_MATERIALS + "=5;" + Tc_BIOTECH + "=5;" + Tc_ENGINEERING + "=4"
	toolspeed = 0.5


/obj/item/tool/hemostat/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is pulling \his eyes out with the [src.name]! It looks like \he's  trying to commit suicide!</span>")
	return (SUICIDE_ACT_BRUTELOSS)


/obj/item/tool/cautery
	name = "cautery"
	desc = "This stops bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/surgery_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/surgery_tools.dmi')
	item_state = "cautery"
	starting_materials = list(MAT_IRON = 5000, MAT_GLASS = 2500)
	w_type = RECYK_ELECTRONIC
	flags = FPRINT
	siemens_coefficient = 1
	w_class = W_CLASS_TINY
	origin_tech = Tc_MATERIALS + "=1;" + Tc_BIOTECH + "=1"
	attack_verb = list("burns")
	hitsound = "sound/weapons/welderattack.ogg"
	heat_production = 500
	source_temperature = TEMPERATURE_HOTMETAL
	surgerysound = 'sound/items/cautery.ogg'


/obj/item/tool/cautery/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is burning \his eyes out with the [src.name]! It looks like \he's  trying to commit suicide!</span>")
	return (SUICIDE_ACT_BRUTELOSS)


/obj/item/tool/cautery/laser
	name = "basic laser cautery"
	desc = "A laser cautery module detached from a basic laser scalpel. You can attach it to a laser scalpel."
	icon_state = "lasercautery_T1"
	item_state = "laserscalpel1"
	sharpness_flags = HOT_EDGE
	damtype = "fire"
	force = 10.0
	throwforce = 5.0
	toolspeed = 0.6
	heat_production = 1500
	source_temperature = TEMPERATURE_PLASMA
	sterility = 100

/*
/obj/item/tool/cautery/laser/old //unused laser cautery. For the laser scalpel
	name = "laser cautery"
	desc = "A laser cautery."
	icon_state = "lasercautery_old"
	item_state = "laserscalpel2old"
	force = 12.0
	toolspeed = 0.5
*/

/obj/item/tool/cautery/laser/tier2
	name = "high-precision laser cautery"
	desc = "A laser cautery module detached from a high-precision laser scalpel. You can attach it to a laser scalpel."
	icon_state = "lasercautery_T2"
	item_state = "laserscalpel2"
	force = 15.0
	toolspeed = 0.4

/obj/item/tool/surgicaldrill
	name = "surgical drill"
	desc = "You can drill using this item. You dig?"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/surgery_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/surgery_tools.dmi')
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
	surgerysound = 'sound/items/surgicaldrill.ogg'

/obj/item/tool/surgicaldrill/diamond
	name = "diamond surgical drill"
	desc = "Yours is the drill that will pierce the tiny heavens!"
	icon_state = "diamond_drill"
	origin_tech = Tc_MATERIALS + "=5;" + Tc_BIOTECH + "=5;" + Tc_ENGINEERING + "=4"
	toolspeed = 0.1 //It's near instant like the mining one.

/obj/item/tool/surgicaldrill/suicide_act(var/mob/living/user)
	to_chat(viewers(user), pick("<span class='danger'>[user] is pressing the [src.name] to \his temple and activating it! It looks like \he's trying to commit suicide.</span>", \
						"<span class='danger'>[user] is pressing [src.name] to \his chest and activating it! It looks like \he's trying to commit suicide.</span>"))
	return (SUICIDE_ACT_BRUTELOSS)


/obj/item/tool/scalpel
	name = "scalpel"
	desc = "Cut, cut, and once more cut."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/surgery_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/surgery_tools.dmi')
	item_state = "scalpel"
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
	surgerysound = 'sound/items/scalpel.ogg'

/obj/item/tool/scalpel/laser
	name = "basic laser scalpel"
	desc = "A scalpel augmented with a directed laser, allowing for bloodless incisions and built-in cautery. This one looks basic and could be improved."
	icon_state = "scalpel_laser1"
	item_state = "laserscalpel1"
	heat_production = 1000000
	source_temperature = TEMPERATURE_PLASMA //Even if it's laser based, it depends on plasma
	damtype = "fire"
	sharpness_flags = SHARP_TIP | SHARP_BLADE | HOT_EDGE
	toolspeed = 0.6
	sterility = 100
	var/cauterymode = 0 //1 = cautery enabled
	var/obj/item/tool/cautery/laser/held

/obj/item/tool/scalpel/laser/New()
	..()
	icon_state = "scalpel_laser1_off"
	held = new /obj/item/tool/cautery/laser(src)


/obj/item/tool/scalpel/laser/attack_self(mob/user)
	if(!cauterymode && held)
		to_chat(user, "You disable the blade and switch to the scalpel's cautery tool.")
		heat_production = 1600
		sharpness = 0
		sharpness_flags = 0
	else if(!held)
		to_chat(user, "\The [src] lacks a cautery attachment.")
		return
	else
		to_chat(user, "You return the scalpel to cutting mode.")
		heat_production = initial(heat_production)
		sharpness = initial(sharpness)
		sharpness_flags = initial(sharpness_flags)
	cauterymode = !cauterymode

/obj/item/tool/scalpel/laser/examine(mob/user)
	..()
	if(!cauterymode)
		to_chat(user, "\The [src] is in cutting mode.")
	else
		to_chat(user, "\The [src] is in cautery mode.")

/obj/item/tool/scalpel/laser/attackby(var/obj/item/used_item, mob/user)
	if(used_item.is_screwdriver(user) && cauterymode)
		if(held)
			to_chat(user, "<span class='notice'>You detach \the [held] and \the [src] switches to cutting mode.</span>")
			used_item.playtoolsound(src, 10)
			held.add_fingerprint(user)
			held.forceMove(get_turf(src))
			held = null
			heat_production = initial(heat_production)
			sharpness = initial(sharpness)
			sharpness_flags = initial(sharpness_flags)
			cauterymode = 0
	else if(istype(used_item, /obj/item/tool/cautery/laser))
		if(held)
			to_chat(user, "<span class='notice'>There's already a cautery attached to \the [src].</span>")
		else if(!held && user.drop_item(used_item, src))
			to_chat(user, "<span class='notice'>You attach \the [used_item] to \the [src].</span>")
			playsound(src, "sound/items/screwdriver.ogg", 10, 1)
			src.held = used_item
		else
			to_chat(user, "<span class='danger'>You can't let go of \the [used_item]!</span>")

/*
/obj/item/tool/scalpel/laser/old //unused laser scalpel
	name = "laser scalpel"
	desc = "A laser scalpel."
	icon_state = "scalpel_laser_old"
	item_state = "laserscalpel2old"
	toolspeed = 0.5

/obj/item/tool/scalpel/laser/old/New()
	..()
	icon_state = "scalpel_laser_old_off"
	held = new /obj/item/tool/cautery/laser/old(src)
*/

/obj/item/tool/scalpel/laser/tier2
	name = "high-precision laser scalpel"
	desc = "A scalpel augmented with a directed laser, allowing for bloodless incisions and built-in cautery. This one looks to be the pinnacle of precision energy cutlery!"
	icon_state = "scalpel_laser2"
	item_state = "laserscalpel2"
	force = 15.0
	toolspeed = 0.4
	heat_production = 10000000

/obj/item/tool/scalpel/laser/tier2/New()
	..()
	icon_state = "scalpel_laser2_off"
	held = new /obj/item/tool/cautery/laser/tier2(src)


/obj/item/tool/circular_saw
	name = "circular saw"
	desc = "For heavy duty cutting."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw3"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/surgery_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/surgery_tools.dmi')
	item_state = "saw3"
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
	surgerysound = 'sound/items/circularsaw.ogg'

	crit_chance = 2*CRIT_CHANCE_MELEE

/obj/item/tool/circular_saw/plasmasaw //Orange transparent chainsaw!
	name = "plasma saw"
	desc = "Perfect for cutting through ice."
	icon_state = "plasmasaw"
	item_state = "plasmasaw"
	force = 18.0
	sharpness = 1.3
	toolspeed = 0.5
	sharpness_flags = SHARP_BLADE | SERRATED_BLADE | CHOPWOOD | HOT_EDGE
	origin_tech = Tc_MATERIALS + "=5;" + Tc_BIOTECH + "=5;" + Tc_ENGINEERING + "=4;" + Tc_PLASMATECH + "=3"
	heat_production = 3000
	source_temperature = TEMPERATURE_PLASMA

/obj/item/tool/circular_saw/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is sawing \his head in two with the [src.name]! It looks like \he's  trying to commit suicide!</span>")
	return (SUICIDE_ACT_BRUTELOSS)


/obj/item/tool/bonegel
	name = "bone gel"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone-gel"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/surgery_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/surgery_tools.dmi')
	item_state = "bonegel"
	force = 0
	throwforce = 1.0
	w_class = W_CLASS_TINY
	autoignition_temperature = AUTOIGNITION_ORGANIC
	surgerysound = 'sound/items/bonegel.ogg'

/obj/item/tool/bonegel/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is eating the [src.name]! It looks like \he's  trying to commit suicide!</span>")//Don't eat glue kids.

	return (SUICIDE_ACT_TOXLOSS)


/obj/item/tool/FixOVein
	name = "fixOVein"
	desc = "A small tube that contains synthetic vein to repair or replace damaged veins."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fixovein"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/surgery_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/surgery_tools.dmi')
	item_state = "fixovein"
	force = 0
	throwforce = 1.0
	w_class = W_CLASS_TINY
	autoignition_temperature = AUTOIGNITION_ORGANIC
	origin_tech = Tc_MATERIALS + "=1;" + Tc_BIOTECH + "=3"
	var/usage_amount = 10
	surgerysound = 'sound/items/fixovein.ogg'

/obj/item/tool/FixOVein/clot
	name = "capillary laying operation tool" //C.L.O.T.
	desc = "A canister like tool that has two containers on it that stores synthetic vein or biofoam. There's a small processing port on the side where gauze can be inserted to produce biofoam."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "clot"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/surgery_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/surgery_tools.dmi')
	item_state = "clot"
	sharpness = null
	sharpness_flags = null
	toolspeed = 0.5
	origin_tech = Tc_MATERIALS + "=5;" + Tc_BIOTECH + "=5;" + Tc_ENGINEERING + "=4"
	var/foam = 0

/obj/item/tool/FixOVein/clot/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>\The [src] contains [foam] unit[foam > 1 ? "s" : ""][foam == 0 ? "s" : ""] of biofoam.</span>")

/obj/item/tool/FixOVein/clot/attack_self(mob/user)
	if(foam)
		if(!sharpness)
			sharpness= 0.5
			sharpness_flags = SHARP_TIP
			icon_state = "clot-F"
		else
			sharpness = null
			sharpness_flags = null
			icon_state = "clot"
		to_chat(user, "<span class='notice'>You toggle \the [src]'s tip to [sharpness == 0.5 ? "inject biofoam" : "repair veins"].</span>")
	else
		to_chat(user, "<span class='notice'>\The [src] requires biofoam to use the injection tip.</span")

/obj/item/tool/FixOVein/clot/attackby(var/obj/item/stack/W, mob/user)
	if((istype(W, /obj/item/stack/medical)) && (foam < 5))
		if(istype(W, /obj/item/stack/medical/bruise_pack))
			foam += 1
			to_chat(user, "<span class='notice'>You insert a bit of \the [W] into \the [src].</span>")
			W.use(1)
			return
		else if(istype(W, /obj/item/stack/medical/advanced/bruise_pack))
			foam = 5
			to_chat(user, "<span class='notice'>You insert a bit of \the [W] into \the [src].</span>")
			W.use(1)
		else
			to_chat(user, "<span class='notice'>You can't see any way to use \the [W] on \the [src].</span>")
	else
		to_chat(user, "<span class='warning'>[foam == 5 ? "The [src] is full!" : ""]</span> <span class='notice'>You can't see any way to use \the [W] on \the [src].</span>")


/obj/item/tool/bonesetter
	name = "bone setter"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone setter"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/surgery_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/surgery_tools.dmi')
	item_state = "bonesetter"
	force = 8.0
	throwforce = 9.0
	w_class = W_CLASS_TINY
	throw_speed = 3
	throw_range = 5
	attack_verb = list("attacks", "hits", "bludgeons")
	starting_materials = list(MAT_IRON = 10000, MAT_GLASS = 5000)
	w_type = RECYK_METAL
	origin_tech = Tc_MATERIALS + "=1;" + Tc_BIOTECH + "=1"
	surgerysound = 'sound/items/bonesetter.ogg'


//allows you to replace the bone setter in switchtools with it being a setter child rather than a bonegel child
/obj/item/tool/bonesetter/bone_mender
	name = "bone mender"
	desc = "A favorite among skeletons. It even sounds like a skeleton too."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone-mender"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/surgery_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/surgery_tools.dmi')
	item_state = "bonemender"
	toolspeed = 0.5
	origin_tech = Tc_MATERIALS + "=5;" + Tc_BIOTECH + "=5;" + Tc_ENGINEERING + "=4"


/obj/item/weapon/revivalprod
	name = "revival prod"
	desc = "A revival prod used to awaken sleeping patients."
	//icon = 'icons/obj/surgery.dmi'
	icon_state = "stun baton"
	force = 0

/obj/item/weapon/revivalprod/attack(mob/target,mob/user)
	if(target.lying)
		target.sleeping = max(0,target.sleeping-10)
		if(target.sleeping == 0)
			target.resting = 0
		target.AdjustParalysis(-3)
		target.AdjustStunned(-3)
		target.AdjustKnockdown(-3)
		playsound(target, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		user.visible_message(
			"<span class='notice'>[user] prods [target] trying to wake \him up!</span>",
			"<span class='notice'>You prod [target] trying to wake \him up!</span>"
			)
	else
		return ..()
