// Reagents to log when splashing non-mobs (all mob splashes are logged automatically)
var/list/LOGGED_SPLASH_REAGENTS = list(FUEL, THERMITE)

/obj/item/weapon/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	w_class = W_CLASS_TINY
	var/amount_per_transfer_from_this = 5
	var/possible_transfer_amounts = list(5,10,15,25,30)
	var/volume = 30
	var/amount_per_imbibe = 5

/obj/item/weapon/reagent_containers/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in range(0)
	if(usr.incapacitated())
		return
	var/N = input("Amount per transfer from this:","[src]") as null|anything in possible_transfer_amounts
	if (N)
		amount_per_transfer_from_this = N

/obj/item/weapon/reagent_containers/verb/empty_contents() //Just dump it out on the floor
	set name = "Dump contents"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		to_chat(usr, "<span class='warning'>You can't do that while incapacitated.</span>")
		return
	if(!is_open_container(src))
		to_chat(usr, "<span class='warning'>You can't, \the [src] is closed.</span>")
		return
	if(src.is_empty())
		to_chat(usr, "<span class='warning'>\The [src] is empty.</span>")
		return
	if(isturf(usr.loc))
		if(reagents.total_volume > 10) //Beakersplashing only likes to do this sound when over 10 units
			playsound(get_turf(src), 'sound/effects/slosh.ogg', 25, 1)
		usr.investigation_log(I_CHEMS, "has emptied \a [src] ([type]) containing [reagents.get_reagent_ids(1)] onto \the [usr.loc].")
		reagents.reaction(usr.loc)
		spawn()
			src.reagents.clear_reagents()
		usr.visible_message("<span class='warning'>[usr] splashes something onto the floor!</span>",
						 "<span class='notice'>You empty \the [src] onto the floor.</span>")

/obj/item/weapon/reagent_containers/proc/drain_into(mob/user, var/atom/where) //We're flushing our contents down the drain!
	if(usr.incapacitated())
		to_chat(usr, "<span class='warning'>You can't do that while incapacitated.</span>")
		return
	if(!is_open_container(src))
		to_chat(usr, "<span class='warning'>You can't, \the [src] is closed.</span>")
		return
	if(src.is_empty())
		to_chat(usr, "<span class='warning'>\The [src] is empty.</span>")
		return
	playsound(get_turf(src), 'sound/effects/slosh.ogg', 25, 1)
	spawn()
		src.reagents.clear_reagents()
	to_chat(user, "<span class='notice'>You flush \the [src] down \the [where].</span>")


/obj/item/weapon/reagent_containers/AltClick()
	if(is_holder_of(usr, src) && possible_transfer_amounts)
		set_APTFT()
		return
	return ..()

/obj/item/weapon/reagent_containers/New()
	..()
	create_reagents(volume)

	if(!is_open_container(src))
		src.verbs -= /obj/item/weapon/reagent_containers/verb/empty_contents
	if(!possible_transfer_amounts)
		src.verbs -= /obj/item/weapon/reagent_containers/verb/set_APTFT

/obj/item/weapon/reagent_containers/attack_self(mob/user as mob)
	return

/obj/item/weapon/reagent_containers/attack(mob/M as mob, mob/user as mob, def_zone)
	//If harm intent, splash it on em, else try to feed em it

	if(!M.reagents)
		return

	if(!is_open_container())
		to_chat(user, "<span class='warning'>You can't, \the [src] is closed.</span>")//Added this here and elsewhere to prevent drinking, etc. from closed drink containers. - Hinaichigo
		return

	if(!src.reagents.total_volume)
		to_chat(user, "<span class='warning'>\The [src] is empty.<span>")
		return 0

	if(user.a_intent != I_HELP)
		if(src.reagents)
			transfer(M, user, splashable_units = -1)
			playsound(get_turf(M), 'sound/effects/slosh.ogg', 25, 1)
			return 1


	else if(M == user)
		imbibe(user)
		return 1

	else if(ishuman(M))
		user.visible_message("<span class='danger'>[user] attempts to feed [M] \the [src].</span>", "<span class='danger'>You attempt to feed [M] \the [src].</span>")

		if(!do_mob(user, M, 30))
			return 1

		user.visible_message("<span class='danger'>[user] feeds [M] \the [src].</span>", "<span class='danger'>You feed [M] \the [src].</span>")

		add_attacklogs(user, M, "force-fed", src, "amount:[amount_per_imbibe], container containing [reagentlist(src)]", adminwarn = FALSE)
		/*M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: [reagentlist(src)]</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [M.name] by [M.name] ([M.ckey]) Reagents: [reagentlist(src)]</font>")
		log_attack("<font color='red'>[user.name] ([user.ckey]) fed [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")*/

		if(reagents.total_volume)
			imbibe(M)

			return 0


// this prevented pills, food, and other things from being picked up by bags.
// possibly intentional, but removing it allows us to not duplicate functionality.
// -Sayu (storage consolidation)
/*
/obj/item/weapon/reagent_containers/attackby(obj/item/I as obj, mob/user as mob)
	return
*/

/**
 * This usually handles reagent transfer between containers and splashing the contents.
 * Please see `transfer()` for a general reusable proc for that.
 *
 * If you're wondering why you're splashing machinery that accepts beakers when
 * inserting them, it's because the machine is returning `FALSE` on `attackby()`,
 * which causes `afterattack()` to be called. Return 1 instead on those cases.
 *
 * If your container is splashing/transferring things at a distance, your `afterattack()`
 * isn't checking for adjacency. For that, check that `adjacency_flag` is `TRUE`.
 */
/obj/item/weapon/reagent_containers/afterattack(var/obj/target, var/mob/user, var/adjacency_flag, var/click_params)
	return

/**
 * Transfer reagents between reagent_containers/reagent_dispensers.
 */
/proc/transfer_sub(var/atom/source, var/atom/target, var/amount, var/mob/user, var/log_transfer = FALSE)
	// Typecheck shenanigans
	var/source_empty
	var/target_full

	if (istype(source, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/S = source
		source_empty = S.is_empty()
	else if (istype(source, /obj/structure/reagent_dispensers))
		var/obj/structure/reagent_dispensers/S = source
		source_empty = S.is_empty()
	else
		//ASSERT(istype(source.reagents))
		source_empty = source.reagents.is_empty()
		//warning("Called transfer_sub() with a non-compatible source type ([source.type], [source], \ref[source])")
		//return


	if (istype(target, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/T = target
		target_full = T.is_full()
	// Reagent dispensers can't be refilled (yet) through normal means (TODO?)
	/*else if (istype(target, /obj/structure/reagent_dispensers))
		var/obj/structure/reagent_dispensers/T = target
		target_full = T.is_full()*/
	else
		if(ismob(target))
			return null
		//ASSERT(istype(target.reagents))
		if(!istype(target.reagents))
			return
		target_full = target.reagents.is_full()
		//warning("Called transfer_sub() with a non-compatible target type ([target.type], [target], \ref[target])")
		//return

	// Actual transfer checks
	if (source_empty)
		to_chat(user, "<span class='warning'>\The [source] is empty.</span>")
		return -1

	if (target_full)
		to_chat(user, "<span class='warning'>\The [target] is full.</span>")
		return -1

	return source.reagents.trans_to(target, amount, log_transfer = log_transfer, whodunnit = user)

/**
 * Helper proc to handle reagent splashes. A negative `amount` will splash all the reagents.
 */
/proc/splash_sub(var/datum/reagents/reagents, var/atom/target, var/amount, var/mob/user = null)
	if (amount == 0 || reagents.is_empty())
		if(user)
			to_chat(user, "<span class='warning'>There's nothing to splash with!</span>")
		return -1

	reagents.reaction(target, TOUCH)

	if (amount > 0)
		if(user)
			user.investigation_log(I_CHEMS, "has splashed [amount]u of [reagents.get_reagent_ids()] from \a [reagents.my_atom] \ref[reagents.my_atom] onto \the [target].")
		reagents.remove_any(amount)
		if(user)
			if(user.Adjacent(target))
				user.visible_message("<span class='warning'>\The [target] has been splashed with something by [user]!</span>",
			                     "<span class='notice'>You splash some of the solution onto \the [target].</span>")
	else
		if(user)
			user.investigation_log(I_CHEMS, "has splashed [reagents.get_reagent_ids(1)] from \a [reagents.my_atom] \ref[reagents.my_atom] onto \the [target].")
		reagents.clear_reagents()
		if(user)
			if(user.Adjacent(target))
				user.visible_message("<span class='warning'>\The [target] has been splashed with something by [user]!</span>",
			                     "<span class='notice'>You splash the solution onto \the [target].</span>")

/**
 * Transfers reagents to other containers/from dispensers. Handles splashing as well.
 *
 * Use this to avoid having duplicate code on every container. Note that this procedure doesn't check for
 * adjacency between the source and the target.
 *
 * @param target What to check for transferring/splashing.
 * @param user The mob performing the transfer.
 * @param can_send Whether we are allowed to transfer our reagents to the target.
 * @param can_receive Whether we are allowed to transfer from `reagent_dispensers`
 * @param splashable_units How many units of reagents should be splashed. -1 for all of them, 0 to disable splashing.
 *
 * @return If we have transferred reagents, the amount transferred; otherwise, -1 if the transfer has failed, 0 if was a splash.
 */
/obj/item/weapon/reagent_containers/proc/transfer(var/atom/target, var/mob/user, var/can_send = TRUE, var/can_receive = TRUE, var/splashable_units = 0)
	if (!istype(target) || !is_open_container())
		return -1

	var/success
	// Transfer from dispenser
	if (can_receive && istype(target, /obj/structure/reagent_dispensers))
		var/tx_amount = transfer_sub(target, src, target:amount_per_transfer_from_this, user)
		if (tx_amount > 0)
			to_chat(user, "<span class='notice'>You fill \the [src][src.is_full() ? " to the brim" : ""] with [tx_amount] units of the contents of \the [target].</span>")

		return tx_amount
	// Transfer to container
	else if (can_send /*&& target.reagents**/)
		var/obj/container = target
		if (!container.is_open_container() && istype(container,/obj/item/weapon/reagent_containers))
			return -1

		if(target.is_open_container())
			success = transfer_sub(src, target, amount_per_transfer_from_this, user, log_transfer = TRUE)

		if(success)
			if (success > 0)
				to_chat(user, "<span class='notice'>You transfer [success] units of the solution to \the [target].</span>")

			return (success)

	if(!success)
		// Mob splashing
		if(splashable_units != 0)
			var/to_splash = reagents.total_volume
			if(ismob(target))
				if (src.is_empty() || !target.reagents)
					return -1

				var/mob/living/M = target

				// Log the 'attack'
				var/list/splashed_reagents = english_list(get_reagent_names())
				add_logs(user, M, "splashed", admin = TRUE, object = src, addition = "Reagents: [splashed_reagents]")

				// Splash the target
				splash_sub(reagents, M, splashable_units, user)
				return (to_splash)
			// Non-mob splashing
			else
				if(!src.is_empty())
					for (var/reagent_id in LOGGED_SPLASH_REAGENTS)
						if (reagents.has_reagent(reagent_id))
							add_gamelogs(user, "poured '[reagent_id]' onto \the [target]", admin = TRUE, tp_link = TRUE, tp_link_short = FALSE, span_class = "danger")

					// Splash the thing
					splash_sub(reagents, target, splashable_units, user)
					return (to_splash)
	return 0

/obj/item/weapon/reagent_containers/proc/is_empty()
	return reagents.total_volume <= 0

/obj/item/weapon/reagent_containers/proc/is_full()
	return reagents.total_volume >= reagents.maximum_volume

/obj/item/weapon/reagent_containers/proc/can_transfer_an_APTFT()
	return reagents.total_volume >= amount_per_transfer_from_this

/obj/item/weapon/reagent_containers/proc/get_reagent_names()
	var/list/reagent_names = list()
	for (var/datum/reagent/R in reagents.reagent_list)
		reagent_names += R.name

	return reagent_names

/obj/item/weapon/reagent_containers/proc/get_reagent_ids()
	var/list/reagent_ids = list()
	for (var/datum/reagent/R in reagents.reagent_list)
		reagent_ids += R.id

	return reagent_ids

/obj/item/weapon/reagent_containers/proc/reagentlist(var/obj/item/weapon/reagent_containers/snack) //Attack logs for regents in pills
	var/data
	if(snack.reagents.reagent_list && snack.reagents.reagent_list.len) //find a reagent list if there is and check if it has entries
		for (var/datum/reagent/R in snack.reagents.reagent_list) //no reagents will be left behind
			data += "[R.id]([R.volume] unit\s); " //Using IDs because SOME chemicals(I'm looking at you, chlorhydrate-beer) have the same names as other chemicals.
		return data
	else
		return "No reagents"

/obj/item/weapon/reagent_containers/proc/show_list_of_reagents(mob/user) //Displays a list of the reagents to a mob, formatted for reading
	to_chat(user, "It contains:")
	if(!reagents.total_volume)
		to_chat(user, "<span class='info'>Nothing.</span>")
	else
		if(reagents.reagent_list.len)
			for(var/datum/reagent/R in reagents.reagent_list)
				to_chat(user, "<span class='info'>[R.volume] units of [R.name]</span>")

/obj/item/weapon/reagent_containers/proc/fits_in_iv_drip()
	return 0

/obj/item/weapon/reagent_containers/proc/imbibe(mob/user) //Drink the liquid within
	to_chat(user, "<span  class='notice'>You swallow a gulp of \the [src].</span>")
	playsound(user.loc,'sound/items/drink.ogg', rand(10,50), 1)

	if(isrobot(user))
		reagents.remove_any(amount_per_imbibe)
		return 1
	if(reagents.total_volume)
		if(can_drink(user))
			reagents.reaction(user, INGEST)
			spawn(5)
				reagents.trans_to(user, amount_per_imbibe)

	return 1

/obj/item/weapon/reagent_containers/proc/can_drink(mob/user)
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species.chem_flags & NO_DRINK)
			reagents.reaction(get_turf(H), TOUCH)
			H.visible_message("<span class='warning'>The contents in [src] fall through and splash onto the ground, what a mess!</span>")
			reagents.remove_any(amount_per_imbibe)
			return 0


	return 1
