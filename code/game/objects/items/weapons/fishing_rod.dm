#define TIME_TO_CATCH_MIN 60
#define TIME_TO_CATCH_MAX 160

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
	var/obj/effect/decal/rod_line/line_decal = new // decal for the fishing line in the water
	var/tmp/busy = 0 //check if in use to stop bait scumming
	var/obj/item/weapon/hookeditem
	var/list/fishables = list( //list of atoms that can be fished
		/obj/machinery/bluespace_pond,
		/turf/unsimulated/beach/water/deep,
		)
	var/list/bait_types = list( // The types of bait this rod is able to use
		/datum/bait_type/standard_bait,
		/datum/bait_type/clown,
		)

/obj/item/weapon/fishingrod/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is whipping \his head open with \the [src]! It looks like \he took the bait!</span>")
	return(BRUTELOSS)

/obj/item/weapon/fishingrod/afterattack(var/atom/A, var/mob/user, proximity_flag)
	if(!hookeditem || busy || !proximity_flag || get_dist(src, A) == 0)
		return 1
	var/turf/A_turf = get_turf(A)
	if(!A_turf)
		return 1 // item is in nullspace
	var/can_fish = FALSE
	for(var/F in fishables)
		if(istype(A, F))
			can_fish = TRUE
			break
	if(!can_fish)
		return 1
	var/datum/bait_type/bait_fish = find_bait(hookeditem)
	if(bait_fish)
		busy = 1
		to_chat(user, "<span class='notice'>You cast a line into the water.</span>")
		line_decal.forceMove(A_turf)
		line_decal.dir = get_dir(A_turf, src)
		if(do_after(user, A, TIME_TO_CATCH, 10, FALSE)) // must be able to drink beer while fishing
			qdel(hookeditem)
			hookeditem = null
			var/fish_caught = 0
			for(var/fish_type in bait_fish.fish)
				if(prob(bait_fish.fish[fish_type]))
					fish_caught = fish_type
					hookeditem = new fish_caught()
					to_chat(user, "<span class='notice'>You caught a [hookeditem.name]!</span>")
					break
			if(!fish_caught)
				to_chat(user, "<span class='notice'>The fish took your bait!</span>")
		line_decal.forceMove(loc)
		busy = 0
	else
		to_chat(user, "<span class='notice'>You cannot use \the [hookeditem] as bait.</span>")

/obj/item/weapon/fishingrod/attackby(obj/item/W, mob/user)
	..()
	var/datum/bait_type/bait_fish = find_bait(W)
	if(bait_fish)
		if(hookeditem)
			if(user.drop_item(W, src))
				var/atom/movable/oldbait = hookeditem
				hookeditem = W
				to_chat(user, "<span class='notice'>You swap the bait on \the [name].</span>")
				if(isitem(oldbait)) // put_in_hands() doesn't handle non obj/item inputs
					user.put_in_hands(oldbait)
					return
				oldbait.forceMove(user.loc)
				return
		else
			if(user.drop_item(W, src))
				hookeditem = W
				to_chat(user, "<span class='notice'>You bait \the [name] with \the [W].</span>")
				return
	to_chat(user, "<span class='notice'>You cannot bait \the [name] with \the [W].</span>")

// checks if object B is a valid type of bait and returns a bait_type datum or 0 if no bait_type exists for the obj
/obj/item/weapon/fishingrod/proc/find_bait(var/obj/item/B)
	for(var/typepath in bait_types)
		var/datum/bait_type/BT = typepath
		if(istype(B, initial(BT.bait)))
			BT = new typepath()
			return BT
	return 0

// TODO: Implement this proc
/obj/item/weapon/fishingrod/proc/do_fishing(var/mob/user as mob, var/atom/target)
	var/holding = user.get_active_hand()
	var/start_loc = user.loc
	var/target_start_loc = target.loc
	var/fishingtime = ((TIME_TO_CATCH_MAX-TIME_TO_CATCH_MIN) * rand() + TIME_TO_CATCH_MIN) / 10
	for(var/i = 1; i <= 10; i++)
		sleep(fishingtime)
		if(!user || user.isStunned() || !(user.loc == start_loc) || !(target.loc == target_start_loc) || !(user.find_held_item_by_type(src)))
			return 0
	return 1

/obj/item/weapon/fishingrod/attack_self(var/mob/user)
	if(hookeditem && !busy)
		to_chat(user, "<span class='notice'>You remove \the [hookeditem] from \the [name].</span>")
		if(isitem(hookeditem)) // put_in_hands() doesn't handle non obj/item inputs
			user.put_in_hands(hookeditem)
		else
			hookeditem.forceMove(user.loc)
		hookeditem = null

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
