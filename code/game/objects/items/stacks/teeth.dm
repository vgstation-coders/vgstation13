/obj/item/stack/animal/teeth
	name = "teeth"
	singular_name = "tooth"
	irregular_plural = "teeth"
	icon = 'icons/obj/butchering_products.dmi'
	icon_state = "tooth"
	amount = 1
	max_amount = 50
	w_class = 1
	throw_speed = 4
	throw_range = 10

/obj/item/stack/animal/teeth/attackby(obj/item/W, mob/user)
	.=..()

	if(istype(W,/obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W

		if(src.amount < 10)
			user << "<span class='info'>You need at least 10 teeth to create a necklace.</span>"
			return

		if(C.use(5))
			user.drop_item(src)

			var/obj/item/clothing/mask/necklace/teeth/X = new(get_turf(src))

			X.animal_type = src.animal_type
			X.teeth_amount = amount
			X.update_name()
			user.put_in_active_hand(X)
			user << "<span class='info'>You create a [X.name] out of [amount] [src] and \the [C].</span>"

			qdel(src)
		else
			user << "<span class='info'>You need at least 5 lengths of cable to do this!</span>"
