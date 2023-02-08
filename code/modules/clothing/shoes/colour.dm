/obj/item/clothing/shoes/black
	name = "black shoes"
	icon_state = "black"
	_color = "black"
	desc = "A pair of black shoes."
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/shoes/brown
	name = "brown shoes"
	desc = "A pair of brown shoes."
	icon_state = "brown"
	_color = "brown"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/shoes/brown/captain
	_color = "captain"	//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/brown/hop
	_color = "hop"		//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/brown/ce
	_color = "chief"	//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/brown/rd
	name = "research director's steel-toed derbys"
	desc = "You need to kick more cyborgs at research conferences than you would think."
	icon_state = "director"
	_color = "director"
	bonus_kick_damage = 5

/obj/item/clothing/shoes/brown/rd/impact_dampen(atom/source, damage)
	return 0

/obj/item/clothing/shoes/brown/cmo
	sterility = 100
	_color = "medical"	//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/brown/cargo
	_color = "cargo"	//Exists for washing machines. Is not different from brown shoes in any way.


/obj/item/clothing/shoes/blue
	name = "blue shoes"
	icon_state = "blue"
	_color = "blue"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)

/obj/item/clothing/shoes/green
	name = "green shoes"
	icon_state = "green"
	_color = "green"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)

/obj/item/clothing/shoes/yellow
	name = "yellow shoes"
	icon_state = "yellow"
	_color = "yellow"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)

/obj/item/clothing/shoes/purple
	name = "purple shoes"
	icon_state = "purple"
	_color = "purple"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)

/obj/item/clothing/shoes/red
	name = "red shoes"
	desc = "Stylish red shoes."
	icon_state = "red"
	_color = "red"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)

/obj/item/clothing/shoes/red/redcoat
	_color = "redcoat"	//Exists for washing machines. Is not different from normal shoes in any way.

/obj/item/clothing/shoes/white
	name = "white shoes"
	icon_state = "white"
	permeability_coefficient = 0.01
	_color = "white"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	sterility = 100

/obj/item/clothing/shoes/leather
	name = "leather shoes"
	desc = "A sturdy pair of leather shoes."
	icon_state = "leather"
	_color = "leather"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)

/obj/item/clothing/shoes/rainbow
	name = "rainbow shoes"
	desc = "Very gay shoes."
	icon_state = "rain_bow"
	_color = "rainbow"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)

/obj/item/clothing/shoes/orange
	name = "orange shoes"
	icon_state = "orange"
	_color = "orange"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/shoes/orange/attack_self(mob/user as mob)
	if(chain)
		slowdown = NO_SLOWDOWN
		chain.forceMove(user.loc)
		chain.on_restraint_removal(user)
		chain = null
		icon_state = "orange"

/obj/item/clothing/shoes/orange/attackby(var/obj/O, mob/user)
	..()
	if(!chain)
		if(istype(O, /obj/item/weapon/handcuffs) && user.drop_item(O,src))
			chain = O
		else if(istype(O, /obj/item/weapon/autocuffer))
			chain = new /obj/item/weapon/handcuffs/cyborg(src)
		else
			return

		slowdown = SHACKLE_SHOES_SLOWDOWN
		icon_state = "orange1"
		chain.forceMove(src)
