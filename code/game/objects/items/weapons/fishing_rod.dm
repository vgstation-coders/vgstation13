#define MAX_FISHING_TIME 160
#define MAX_LINE_TENSION 100
#define TENSION_DELTA 15 // max rodtension decay per tick/max increase per attack_self
#define FISHPULL_UPDATES 16 // amount of times the fish pulling code will tick during MAX_FISHING_TIME
#define FISHPULL_BASELINE 40 // used in calculating pulling strength of a catch

// -----------------------------
//         Bait Datums
// -----------------------------

// Base datum for bait_type
// bait: The object to be used as bait
// fish: list of fish you can catch and their probability
//       uses the format list(<fish> = <absolute probability>, ...)
//			where <fish> is the typepath of the object you can catch
//       NOTE: The fishing rod checks the fish in order.  Don't put a probability 100 fish before the last entry.
/datum/bait_type
	var/bait = null
	var/list/fish = list()

/datum/bait_type/proc/get_fish()
	var/fish_caught = 0
	for(var/fish_type in fish)
		if(prob(fish[fish_type]))
			fish_caught = fish_type
			break
	return fish_caught

/datum/bait_type/standard_bait
	bait = /obj/item/weapon/reagent_containers/food/snacks/bait
	fish = list(
		/obj/item/weapon/reagent_containers/food/snacks/fish/rainbowtrout = 1,
		/obj/item/weapon/reagent_containers/food/snacks/fish/perch = 20,
		/obj/item/weapon/reagent_containers/food/snacks/fish/walleye = 20,
		/obj/item/weapon/reagent_containers/food/snacks/fish/salmon = 20,
		/obj/item/weapon/reagent_containers/food/snacks/fish/bream = 100,
		)

/datum/bait_type/clown
	bait = /obj/item/clothing/mask/gas/clown_hat
	fish = list(
		/mob/living/simple_animal/hostile/carp/clown = 100,
		)


/atom/proc/can_fish()
	return FALSE

/obj/machinery/bluespace_pond/can_fish()
	return TRUE

/turf/unsimulated/beach/water/deep/can_fish()
	return TRUE

// -----------------------------
//         Fishing Rod
// -----------------------------

/obj/item/weapon/fishingrod
	name = "fishing rod"
	desc = "Go catch the big one!"
	icon = 'icons/obj/items.dmi'
	icon_state = "fishingrod"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	hitsound = "sound/weapons/toolhit.ogg"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	force = 3.0
	throwforce = 3.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_MEDIUM
	starting_materials = list(MAT_GLASS = 100)
	w_type = RECYK_GLASS
	melt_temperature = MELTPOINT_GLASS
	origin_tech = Tc_ENGINEERING + "=1"
	attack_verb = list("smacks", "whacks", "whips", "belts", "lashes")
	var/obj/effect/decal/rod_line/line_decal // decal for the fishing line in the water
	var/tmp/busy = 0 //check if in use to stop bait scumming
	var/obj/item/weapon/hookeditem
	var/fishstage = 50 // when fishstage hits 0, we catch the fish, if it goes above 100, we lose the fish
	var/rodtension = 0 // if tension hits MAX_LINE_TENSION the line snaps, pulling power is based on tension scaling from 0=no pulling  and  (MAX_LINE_TENSION - 1)=strongest pull
	var/list/bait_types = list( // The types of bait this rod is able to use
		/datum/bait_type/standard_bait,
		/datum/bait_type/clown,
		)

/obj/item/weapon/fishingrod/New()
	..()
	line_decal = new

/obj/item/weapon/fishingrod/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is whipping \his head open with \the [src]! It looks like \he took the bait!</span>")
	return(BRUTELOSS)

/obj/item/weapon/fishingrod/afterattack(atom/A, mob/user, proximity_flag)
	if(!hookeditem || busy || !proximity_flag || get_dist(src, A) == 0)
		return 1
	var/turf/A_turf = get_turf(A)
	if(!A_turf)
		return 1 // item is in nullspace
	if(!A.can_fish())
		return 1
	var/datum/bait_type/bait_fish = find_bait(hookeditem)
	if(bait_fish)
		busy = 1
		to_chat(user, "<span class='notice'>You cast a line into the water.</span>")
		line_decal.forceMove(A_turf)
		line_decal.dir = get_dir(A_turf, src)
		var/atom/movable/fish_caught = bait_fish.get_fish()
		qdel(hookeditem)
		hookeditem = null
		if(fish_caught)
			hookeditem = new fish_caught()
		if(!hookeditem)
			to_chat(user, "<span class='notice'>The fish took your bait!</span>")
		if(do_fishing(user, A))
			to_chat(user, "<span class='notice'>You caught \a [hookeditem]!</span>")
		else
			qdel(hookeditem)
			hookeditem = null
			to_chat(user, "<span class='warning'>\The fish got away!</span>")
		line_decal.forceMove(loc)
		busy = 0
	else
		to_chat(user, "<span class='notice'>You cannot use \the [hookeditem] as bait.</span>")

/obj/item/weapon/fishingrod/attack_self(mob/user)
	if(busy)
		rodtension += rand(5, TENSION_DELTA)
		return
	if(hookeditem)
		to_chat(user, "<span class='notice'>You remove \the [hookeditem] from \the [src].</span>")
		if(isitem(hookeditem)) // put_in_hands() doesn't handle non obj/item inputs
			user.put_in_hands(hookeditem)
		else
			hookeditem.forceMove(user.loc)
		hookeditem = null

/obj/item/weapon/fishingrod/attackby(obj/item/W, mob/user)
	..()
	if(busy)
		return
	var/datum/bait_type/bait_fish = find_bait(W)
	if(bait_fish)
		if(hookeditem)
			if(user.drop_item(W, src))
				var/atom/movable/oldbait = hookeditem
				hookeditem = W
				to_chat(user, "<span class='notice'>You swap the bait on \the [src].</span>")
				if(isitem(oldbait)) // put_in_hands() doesn't handle non obj/item inputs
					user.put_in_hands(oldbait)
					return
				oldbait.forceMove(user.loc)
				return
		else
			if(user.drop_item(W, src))
				hookeditem = W
				to_chat(user, "<span class='notice'>You bait \the [src] with \the [W].</span>")
				return
	to_chat(user, "<span class='notice'>You cannot bait \the [src] with \the [W].</span>")

// checks if object B is a valid type of bait and returns a bait_type datum or 0 if no bait_type exists for the obj
/obj/item/weapon/fishingrod/proc/find_bait(var/obj/item/B)
	for(var/typepath in bait_types)
		var/datum/bait_type/BT = typepath
		if(istype(B, initial(BT.bait)))
			BT = new typepath()
			return BT
	return 0

// handles the main fishing loop
/obj/item/weapon/fishingrod/proc/do_fishing(var/mob/user, var/atom/target)
	if(!user || !target || !hookeditem)
		return 0
	busy = 1
	fishstage = rand(40, 60)
	rodtension = rand(20, 40)
	var/start_loc = user.loc
	var/target_start_loc = target.loc
	var/sleepfraction = MAX_FISHING_TIME / FISHPULL_UPDATES

	var/image/progbar
	if(user.client)//user.client.prefs.progress_bars)
		progbar = image("icon" = 'icons/effects/doafter_icon.dmi', "loc" = user, "icon_state" = "prog_bar_[round(fishstage, 10)]")
		progbar.pixel_z = WORLD_ICON_SIZE
		progbar.plane = HUD_PLANE
		progbar.layer = HUD_ABOVE_ITEM_LAYER
		progbar.appearance_flags = RESET_COLOR
		user.client.images |= progbar

	var/endtime = world.time + MAX_FISHING_TIME
	var/success = FALSE
	while(world.time < endtime)
		sleep(sleepfraction)
		if(!user || !hookeditem || user.isStunned() || !(user.loc == start_loc) || !(target.loc == target_start_loc) || !(user.find_held_item_by_type(src)))
			break
		if(rodtension >= MAX_LINE_TENSION)
			break
		if(istype(hookeditem, /obj/item/weapon/reagent_containers/food/snacks/fish)) // Only fish have a length and weight so we'll just use default values for non-fish items
			fish_pull()
		else
			other_pull(FISHPULL_BASELINE)
		rodtension -= rand(0, TENSION_DELTA)
		if(fishstage <= 0) // we caught the fish
			success = TRUE
			break
		progbar.icon_state = "prog_bar_[round(fishstage, 10)]"
		user.client.images |= progbar
	if(progbar)
		progbar.icon_state = "prog_bar_stopped"
		spawn(2)
			if(user && user.client)
				user.client.images -= progbar
				if(progbar)
					progbar.loc = null
	if(success)
		return 1
	return 0

// calculate the relative weight of the fish compared to the default weight value
// this gets normalized where the default weight has a fishstrength of 40, lightest possible fish has fishstrength 20 and heaviest possible has fishstrength of 60
/obj/item/weapon/fishingrod/proc/fish_pull()
	if(hookeditem && istype(hookeditem, /obj/item/weapon/reagent_containers/food/snacks/fish))
		var/obj/item/weapon/reagent_containers/food/snacks/fish/F = hookeditem
		var/halfweight = initial(F.weight) / 2
		// converts the fish weight into a range from 0.0 (lightest possible) to 1.0 (heaviest possible) and then normalises to 20-60 fish_strength scale
		var/normalisedstrength = (F.weight - halfweight) / (initial(F.weight) * 1.5 - halfweight) * FISHPULL_BASELINE + (FISHPULL_BASELINE/2)
		other_pull(normalisedstrength)

// accepts a value from 20-60 determining the strength of the fish on the line, 20 being the weakest value
/obj/item/weapon/fishingrod/proc/other_pull(var/fish_strength)
	var/pullamount = calculate_pull(Clamp(fish_strength, 20, 60))
	fishstage += pullamount

// calculates whether to reel the fish in or not, and by how much we are reeling in
/obj/item/weapon/fishingrod/proc/calculate_pull(var/fish_strength)
	return round(((-34 * log(-0.1 * (rodtension - 105)) + 80) - fish_strength) / -3)

// decal for tile being fished
/obj/effect/decal/rod_line
	name = "rod line"
	icon = 'icons/effects/effects.dmi'
	icon_state = "rod_line"
	dir = NORTH
	plane = OBJ_PLANE
	layer = ABOVE_OBJ_LAYER
	anchored = 1
	mouse_opacity = 0
	w_type = NOT_RECYCLABLE
