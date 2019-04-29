/obj/item/device/does_not_tip_backdoor
	name = "\improper PDA"
	desc = "The screen seems to be blank."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	w_class = W_CLASS_TINY
	flags = FPRINT

/obj/item/device/does_not_tip_backdoor/attack_self(var/mob/user)
	if(alert(user, "A cryptic message appears on the screen: \"Are you sure you want to do it?\".", name, "Yes", "No") != "Yes")
		return
	if(user.incapacitated() || !Adjacent(user))
		return
	station_does_not_tip = !station_does_not_tip
	to_chat(user, "<span class='notice'>\The [src]'s screen flashes [station_does_not_tip ? "red" : "green"] for a moment.</span>")
