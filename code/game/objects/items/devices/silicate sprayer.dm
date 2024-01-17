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
	return A.silicate_act(src, user)

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
