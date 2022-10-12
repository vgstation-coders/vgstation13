// Silicate sprayer, load it with silicate, and you can fix damaged windows with it!
// No not the OS, nobody can fix that trainwreck.

#define SILICATE_PER_DAMAGE				0.05	// Units of silicate used to repair 1 point of damage.
#define MAX_WINDOW_HEALTH_MULTIPLIER	2		// How many times of the original health you can add to a window with the advanced silicate sprayer.
#define SILICATE_PER_REINFORCE			0.1		// Silicate used to reinforce 1 unit of health on a window.
#define MODE_REPAIR		0
#define MODE_REINFORCE	1

/obj/item/device/silicate_sprayer
	name = "\improper Silicate Sprayer"
	desc = "Used to repair damaged windows with silicate."

	icon = 'icons/obj/device.dmi'
	icon_state = "silicate sprayer"
	item_state = "silicate"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')

	w_class = W_CLASS_SMALL
	flags = FPRINT | OPENCONTAINER

	origin_tech = Tc_ENGINEERING + "=2"


	var/start_filled = TRUE
	var/max_silicate = 50
	var/silicate_per_state = 5 // Used in the calculation for the icon states for the meter.

// Empty for in the autolathe.
/obj/item/device/silicate_sprayer/empty
	start_filled = FALSE

/obj/item/device/silicate_sprayer/New()
	. = ..()
	create_reagents(max_silicate)

	if(start_filled)
		reagents.add_reagent(SILICATE, max_silicate)

	update_icon()

/obj/item/device/silicate_sprayer/proc/get_amount()
	return reagents.get_reagent_amount(SILICATE)

/obj/item/device/silicate_sprayer/examine(var/mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>It contains [get_amount()]/[max_silicate] units of silicate!</span>")

/obj/item/device/silicate_sprayer/proc/remove_silicate(var/amount = 0)
	reagents.remove_reagent(SILICATE, amount)

	update_icon()

/obj/item/device/silicate_sprayer/update_icon()
	overlays.Cut()

	var/amount = get_amount()

	if(!amount)
		return

	var/i = 0

	// Floor if above 50%, else we Ceil.
	if(amount >= max_silicate / 2)
		i = Floor(amount / silicate_per_state, 1)

	else
		i = Ceiling(amount / silicate_per_state, 1)

	overlays += image(icon = icon, icon_state = "silicate sprayer [i]")

/obj/item/device/silicate_sprayer/on_reagent_change()
	update_icon()

/obj/item/device/silicate_sprayer/preattack(var/atom/A, var/mob/user)
	if(get_dist(A, user) > 1) // I purposely don't use proximity_flag so you can get to windows without needing adjacency. (window behind another window for example.)
		return

	if(iswindow(A)) // We can only fix windows.
		return preattack_window(A, user)
	else if(istype(A, /turf/simulated/floor/glass))
		return preattack_glassfloor(A, user)
	return 0

/obj/item/device/silicate_sprayer/proc/preattack_glassfloor(var/atom/A, var/mob/user)
	if(!get_amount())
		to_chat(user, "<span class='notice'>\The [src] is out of silicate!</span>")
		return 1

	var/turf/simulated/floor/glass/T = A

	var/diff = initial(T.health) - T.health
	if(!diff) // Not damaged.
		to_chat(user, "<span class='notice'>\The [T] is already in perfect condition!</span>")
		return 1

	diff = min(diff, get_amount() / SILICATE_PER_DAMAGE)

	T.health += diff
	T.healthcheck(user, FALSE)

	user.visible_message("<span class='notice'>[user] repairs \the [T] with their [name]!</span>", "<span class='notice'>You repair \the [T] with your [name].</span>")
	playsound(T, 'sound/effects/refill.ogg', 10, 1, -6)

	remove_silicate(diff * SILICATE_PER_DAMAGE)

	return 1
/obj/item/device/silicate_sprayer/proc/preattack_window(var/atom/A, var/mob/user)
	if(!get_amount())
		to_chat(user, "<span class='notice'>\The [src] is out of silicate!</span>")
		return 1

	var/obj/structure/window/W = A

	var/diff = initial(W.health) - W.health
	if(!diff) // Not damaged.
		to_chat(user, "<span class='notice'>\The [W] is already in perfect condition!</span>")
		return 1

	diff = min(diff, get_amount() / SILICATE_PER_DAMAGE)

	W.health += diff
	W.healthcheck(user, FALSE)

	user.visible_message("<span class='notice'>[user] repairs \the [W] with their [name]!</span>", "<span class='notice'>You repair \the [W] with your [name].</span>")
	playsound(src, 'sound/effects/refill.ogg', 10, 1, -6)

	remove_silicate(diff * SILICATE_PER_DAMAGE)

	return 1


// Advanced subtype that can reinforce windows!
/obj/item/device/silicate_sprayer/advanced
	name = "\improper Advanced Silicate Sprayer"
	desc = "An advanced tool used to repair and reinforce windows."

	icon_state = "silicate sprayer advanced"
	item_state = "advsilicate"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')

	max_silicate = 100
	silicate_per_state = 10

	origin_tech = Tc_MATERIALS + "=3;" + Tc_ENGINEERING + "=4"

	var/mode = MODE_REPAIR

/obj/item/device/silicate_sprayer/advanced/empty
	start_filled = FALSE

/obj/item/device/silicate_sprayer/advanced/attack_self(var/mob/user)
	mode = !mode
	to_chat(user, "<span class='notice'>\The [src] is now set to [mode == MODE_REINFORCE ? "reinforce" : "repair"] windows.</span>")
	update_icon()
	return 1

/obj/item/device/silicate_sprayer/advanced/update_icon()
	. = ..()
	if(mode == MODE_REINFORCE)
		overlays += image(icon = icon, icon_state = "silicate sprayer reinforce")

/obj/item/device/silicate_sprayer/advanced/examine(var/mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>It is set to [mode == MODE_REINFORCE ? "reinforce" : "repair"] windows.</span>")

/obj/item/device/silicate_sprayer/advanced/preattack(var/atom/A, var/mob/user)
	if(get_dist(A, user) > 1) // I purposely don't use proximity_flag so you can get to windows without needing adjacency. (window behind another window for example.)
		return

	if(iswindow(A))
		return preattack_window(A, user)
	else if(istype(A, /turf/simulated/floor/glass))
		return preattack_glassfloor(A, user)

/obj/item/device/silicate_sprayer/advanced/preattack_window(var/atom/A, var/mob/user)
	if(!get_amount())
		to_chat(user, "<span class='notice'>\The [src] is out of silicate!</span>")
		return 1

	var/obj/structure/window/W = A
	var/initial_health = initial(W.health)

	if(mode == MODE_REPAIR || W.health < initial_health) // Call the parent to repair, always repair if it's damaged.
		return ..()

	var/extra_health = W.health - initial_health

	if(W.health >= initial_health * MAX_WINDOW_HEALTH_MULTIPLIER)
		to_chat(user, "<span class='notice'>You can't reinforce \the [W] any further!</span>")
		return 1

	var/repair_amt = min(get_amount() / SILICATE_PER_REINFORCE, (initial_health * MAX_WINDOW_HEALTH_MULTIPLIER) - (initial_health + extra_health))

	W.health += repair_amt
	W.healthcheck(user, FALSE)

	user.visible_message("<span class='notice'>[user] reinforced \the [W] with their [name]!</span>", "<span class='notice'>You reinforce \the [W] with your [name].</span>")
	playsound(src, 'sound/effects/refill.ogg', 10, 1, -6)

	remove_silicate(repair_amt * SILICATE_PER_REINFORCE)

	return 1

/obj/item/device/silicate_sprayer/advanced/preattack_glassfloor(var/atom/A, var/mob/user)
	if(!get_amount())
		to_chat(user, "<span class='notice'>\The [src] is out of silicate!</span>")
		return 1

	var/turf/simulated/floor/glass/G = A
	var/initial_health = initial(G.health)

	if(mode == MODE_REPAIR || G.health < initial_health) // Call the parent to repair, always repair if it's damaged.
		return ..()

	var/extra_health = G.health - initial_health

	if(G.health >= initial_health * MAX_WINDOW_HEALTH_MULTIPLIER)
		to_chat(user, "<span class='notice'>You can't reinforce \the [G] any further!</span>")
		return 1

	var/repair_amt = min(get_amount() / SILICATE_PER_REINFORCE, (initial_health * MAX_WINDOW_HEALTH_MULTIPLIER) - (initial_health + extra_health))

	G.health += repair_amt
	G.healthcheck(user)

	user.visible_message("<span class='notice'>[user] reinforced \the [G] with their [name]!</span>", "<span class='notice'>You reinforce \the [G] with your [name].</span>")
	playsound(src, 'sound/effects/refill.ogg', 10, 1, -6)

	remove_silicate(repair_amt * SILICATE_PER_REINFORCE)

	return 1

#undef MODE_REPAIR
#undef MODE_REINFORCE
