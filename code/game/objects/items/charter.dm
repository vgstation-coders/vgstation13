/obj/item/station_charter
	name = "station charter"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "contract1"
	autoignition_temperature = AUTOIGNITION_PAPER
	fire_fuel = 1
	throwforce = 0
	w_class = W_CLASS_TINY
	w_type = RECYK_WOOD
	throw_range = 1
	throw_speed = 1
	desc = "An official document entrusting the governance of the station and surrounding space to the Captain."
	var/used = FALSE

/obj/item/station_charter/attack_self(mob/living/user)
	if(used)
		user << "The station has already been named."
		return
	used = TRUE

	var/new_name = input(user, "What do you want to name [station_name()]? Keep in mind particularly terrible names may attract the attention of your employers.")  as text|null
	if(new_name)
		world.name = new_name
		station_name = new_name

	else
		used = FALSE
