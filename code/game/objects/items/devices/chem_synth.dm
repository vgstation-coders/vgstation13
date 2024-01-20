#define MATTER_PER_REAGENT 0.05
#define POWER_PER_REAGENT 15
#define MAX_MATTER 30
#define MODE_SYNTHING 0
#define MODE_SCANNING 1

/obj/item/device/chem_synth
	name = "\improper chemical synthesizer"
	desc = "This hand-held device converts compressed matter into chemical reagents."
	icon = 'icons/obj/RCD.dmi'
	icon_state = "chem_synth"

	flags = FPRINT
	siemens_coefficient = 1
	w_class = W_CLASS_MEDIUM
	origin_tech = Tc_ENGINEERING + "=4;" + Tc_MATERIALS + "=5;" + Tc_POWERSTORAGE + "=3"

	var/active_reagent = "";
	var/list/reagents_scanned = list(
	)

	var/list/can_scan = list(
		HYDROGEN,
		LITHIUM,
		CARBON,
		NITROGEN,
		OXYGEN,
		FLUORINE,
		SODIUM,
		ALUMINUM,
		SILICON,
		PHOSPHORUS,
		SULFUR,
		CHLORINE,
		POTASSIUM,
		IRON,
		COPPER,
		MERCURY,
		RADIUM,
		WATER,
		ETHANOL,
		SUGAR,
		SACID,
		TUNGSTEN,
		PLASMA
	)

	var/list/cant_scan = list()
	var/use_blacklist_instead_of_whitelist = 0
	var/matter = 0
	var/max_matter = MAX_MATTER
	var/mode = MODE_SYNTHING //operation mode. 0 = synthing, 1 = scanning
	var/synth_amount = 10 //how many units to synthesize

/obj/item/device/chem_synth/New()
	. = ..()
	reagents_scanned = sortList(reagents_scanned)

/obj/item/device/chem_synth/verb/set_synth_amount()
	set name = "Set synthesized amount"
	set category = "Object"
	set src in range(0)
	if(usr.incapacitated())
		return
	var/amount = input(usr, "How many units per synthesis do you want \the [src] to produce?", "Chemical Synthesizer") as num
	amount = clamp(round(amount, 1), 0, 1000)
	if(amount)
		synth_amount = amount
	to_chat(usr, "<span class='notice'>\The [src] will now synthesize [synth_amount] units per use.</span>")

/obj/item/device/chem_synth/AltClick()
	if(is_holder_of(usr, src))
		set_synth_amount()
		return
	return ..()

/obj/item/device/chem_synth/preloaded
	matter = MAX_MATTER

//uses no compressed matter or power and can scan **anything**
/obj/item/device/chem_synth/admin
	name = "\improper advanced chemical synthesizer"
	desc = "This hand-held device synthesizes chemicals out of thin air."
	can_scan = list()
	use_blacklist_instead_of_whitelist = 1

/obj/item/device/chem_synth/robot/service
	name = "\improper drink synthesizer"
	desc = "This chemical synthesizer is specialized for synthesizing beverages."
	icon_state = "chem_synth_borg"
	reagents_scanned = list(
		WATER,
		BEER,
		WHISKEY,
		COLA,
		COFFEE,
		TEA,
		ICE = T0C,
		BLACKCOLOR
	)

	can_scan = list(
		BEER,
		WHISKEY,
		TEQUILA,
		VODKA,
		VERMOUTH,
		RUM,
		COGNAC,
		WINE,
		SAKE,
		TRIPLESEC,
		BITTERS,
		CINNAMONWHISKY,
		SCHNAPPS,
		BLUECURACAO,
		KAHLUA,
		ALE,
		CHAMPAGNE,
		PWINE, //this is in the booze-o-mat and not being able to scan it bothers me
		ICE = T0C,
		WATER,
		GIN,
		SODAWATER,
		COLA,
		CREAM,
		TOMATOJUICE,
		ORANGEJUICE,
		LIMEJUICE,
		TONIC,
		SPACEMOUNTAINWIND,
		LEMON_LIME,
		DR_GIBB,
		TEA,
		GREENTEA,
		REDTEA,
		COFFEE,
		MILK,
		HOT_COCO,
		SOYMILK,
		BLACKCOLOR,
		SPORTDRINK //why not
	)

/obj/item/device/chem_synth/robot/service/emag_act(mob/user)
	reagents_scanned += BEER2 //chloral hydrate disguised as beer
	reagents_scanned += POTASSIUM //for explosions

	//to create anti-lung gas
	reagents_scanned += AMMONIA
	reagents_scanned += BLEACH

	reagents_scanned = sortList(reagents_scanned)

/obj/item/device/chem_synth/examine(mob/user)
	..()
	if(istype(src, /obj/item/device/chem_synth/robot))
		to_chat(user, "It's been set to draw power from a power cell.")
	else if(istype(src, /obj/item/device/chem_synth/admin))
		//this space intentionally left blank
	else
		to_chat(user, "It currently holds [matter]/[max_matter] compressed matter.")

/obj/item/device/chem_synth/attackby(var/obj/O, mob/user)
	if(istype(src, /obj/item/device/chem_synth/robot))
		return ..()
	if(istype(O, /obj/item/stack/rcd_ammo))
		var/obj/item/stack/rcd_ammo/RA = O
		if(matter + 10 > max_matter)
			to_chat(user, "<span class='warning'>\The [src] can't hold any more compressed matter.</span>")
			return
		else
			matter += 10
			playsound(src, 'sound/machines/click.ogg', 20, 1)
			RA.use(1)
			to_chat(user, "<span class='notice'>\The [src] now holds [matter]/[max_matter] compressed matter.</span>")
	return ..()

/obj/item/device/chem_synth/attack_self(mob/user)
	mode = !mode
	if(mode == MODE_SYNTHING)
		if(select_chemical(user))
			to_chat(user, "<span class='notice'>You switch \the [src] to [active_reagent ? "synthesize " + reagent_id_to_name(active_reagent) : "synthesis mode"].</span>")
		else
			to_chat(user, "<span class='warning'>ERROR: Memory banks empty. Scan some reagents first.</span>")
			mode = MODE_SCANNING
	else
		to_chat(user, "<span class='notice'>You switch \the [src] to scanning mode.</span>")

/obj/item/device/chem_synth/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return 0
	if(!istype(target, /obj/item/weapon/reagent_containers))
		return ..()
	if(reagents_scanned.len == 0)
		//automatically switch to scanning if we have no scanned reagents
		mode = MODE_SCANNING
	if(mode == MODE_SYNTHING) //synthesize into a container
		if(!active_reagent)
			select_chemical(user)
		if(!active_reagent)
			to_chat(user, "<span class='warning'>ERROR: No reagent data selected.</span>")
			return
		if(!synthesize_chemical(user, active_reagent, target))
			to_chat(user, "<span class='warning'>ERROR: Unable to synthesize. Please try again, or a different container.</span>")
			return
	else //scan the primary reagent of a container
		var/obj/item/weapon/reagent_containers/container = target
		var/datum/reagents/reagents = container.reagents
		if(!reagents || !reagents.total_volume)
			return ..()
		var/primary = reagents.get_master_reagent_id()
		if(reagents_scanned.Find(primary))
			return
		if(!use_blacklist_instead_of_whitelist)
			if(!can_scan.Find(primary))
				to_chat(user, "<span class='warning'>\The [src] cannot scan this type of material.</span>")
				return
		else
			if(cant_scan.Find(primary))
				to_chat(user, "<span class='warning'>\The [src] cannot scan this type of material.</span>")
				return
		var/temp = can_scan[primary]
		if(temp != null)
			reagents_scanned[primary] = temp
		else
			reagents_scanned.Add(primary)
		reagents_scanned = sortList(reagents_scanned)
		to_chat(user, "<span cl ass='notice'>You successfully scan \the [reagent_id_to_name(primary)] into \the [src]'s chemical banks.</span>")
	return ..()

/obj/item/device/chem_synth/proc/reagent_id_to_name(var/reagent)
	return chemical_reagents_list[reagent].name

/obj/item/device/chem_synth/proc/select_chemical(mob/user)
	if(reagents_scanned.len)
		var/list/humanreadable = list()
		for(var/R in reagents_scanned)
			if(R == BEER2) //ugly hack to give serviceborg chloral beer a name other than "Beer"
				humanreadable["Chloral Hydrate (disguised as beer)"] = R
			else
				humanreadable[reagent_id_to_name(R)] = R
		var/selection = input("Select the chemical you'd like to synthesize", "Chemical Synthesizer") as null|anything in humanreadable
		if(selection)
			active_reagent = humanreadable[selection]
			return 1
		else
			return 1
	else
		return 0

/obj/item/device/chem_synth/proc/synthesize_chemical(mob/user, var/reagent, var/container)
	if(!container || !reagents_scanned.Find(reagent))
		return 0
	var/obj/item/weapon/reagent_containers/reagent_container = container
	var/datum/reagents/reagents = reagent_container.reagents
	if(!reagents)
		if(!reagent_container.gcDestroyed)
			reagent_container.create_reagents(reagent_container.volume)
		else
			QDEL_NULL(reagent_container)
			return 0
	var/space = reagents.maximum_volume - reagents.total_volume
	if(space == 0)
		to_chat(user, "<span class='notice'>\The [reagent_container] is full.</span>")
		return 1

	var/temperature = reagents_scanned[reagent] ? reagents_scanned[reagent] : T0C+20

	var/to_add = min(synth_amount, space)
	if(take_cost(to_add, 1.0, user))
		reagents.add_reagent(reagent, to_add, reagtemp = temperature)
		to_chat(user, "<span class='notice'>You fill \the [reagent_container][reagent_container.is_full() ? " to the brim" : ""] with [to_add] units of [reagent_id_to_name(reagent)].</span>")
	return 1

/obj/item/device/chem_synth/proc/take_cost(var/amount, var/rarity_multiplier, mob/user)
	if(!amount)
		return 0
	var/matter_used = amount * rarity_multiplier * MATTER_PER_REAGENT
	if(matter >= matter_used)
		matter -= matter_used
		return 1
	to_chat(user, "<span class='warning'>\The [src] does not hold enough compressed matter to create this much.</span>")
	return 0

/obj/item/device/chem_synth/robot/take_cost(var/amount, var/rarity_multiplier, mob/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/robo = user
		var/used = robo.cell.use(amount * rarity_multiplier * POWER_PER_REAGENT)
		if(!used)
			to_chat(user, "<span class='warning'>You cannot synthesize this much without shutting down!</span>")
		return used
	return 0

/obj/item/device/chem_synth/admin/take_cost(var/amount, var/rarity_multiplier, mob/user)
	return 1

#undef MATTER_PER_REAGENT
#undef POWER_PER_REAGENT
#undef MAX_MATTER
#undef MODE_SYNTHING
#undef MODE_SCANNING
