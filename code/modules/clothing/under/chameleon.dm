/obj/item/clothing/under/chameleon
//starts off as black
	name = "black jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	_color = "black"
	desc = "It's a plain jumpsuit. It seems to have a small dial on the wrist."
	origin_tech = Tc_SYNDICATE + "=3"
	siemens_coefficient = 0.8
	species_fit = list(GREY_SHAPED)
	var/list/clothing_choices = list()

	New()
		..()
		verbs += /obj/item/clothing/under/chameleon/proc/Change_Color
		for(var/U in typesof(/obj/item/clothing/under/color)-(/obj/item/clothing/under/color))
			var/obj/item/clothing/under/V = new U
			src.clothing_choices += V

		for(var/U in typesof(/obj/item/clothing/under/rank)-(/obj/item/clothing/under/rank))
			var/obj/item/clothing/under/V = new U
			src.clothing_choices += V
		return


	attackby(obj/item/clothing/under/U as obj, mob/user as mob)
		..()
		if(istype(U, /obj/item/clothing/under/chameleon))
			to_chat(user, "<span class='warning'>Nothing happens.</span>")
			return
		if(istype(U, /obj/item/clothing/under))
			if(src.clothing_choices.Find(U))
				to_chat(user, "<span class='warning'>Pattern is already recognised by the suit.</span>")
				return
			src.clothing_choices += U
			to_chat(user, "<span class='warning'>Pattern absorbed by the suit.</span>")


	emp_act(severity)
		name = "psychedelic"
		desc = "Groovy!"
		icon_state = "psyche"
		_color = "psyche"
		spawn(200)
			name = "Black Jumpsuit"
			icon_state = "bl_suit"
			_color = "black"
			desc = null
		..()


/obj/item/clothing/under/chameleon/proc/Change_Color()
	if(icon_state == "psyche")
		to_chat(usr, "<span class='warning'>Your suit is malfunctioning.</span>")
		return

	var/obj/item/clothing/under/A
	A = input("Select the jumpsuit's new appearance.", "BOOYEA", A) in clothing_choices
	if(!A)
		return

	desc = null
	permeability_coefficient = 0.90

	desc = A.desc
	name = A.name
	icon_state = A.icon_state
	item_state = A.item_state
	_color = A._color
	usr.update_inv_w_uniform()	//so our overlays update.


/obj/item/clothing/under/chameleon/all/New()
	..()
	var/blocked = list(/obj/item/clothing/under/chameleon, /obj/item/clothing/under/chameleon/all, /obj/item/clothing/under)
	//to prevent an infinite loop
	for(var/U in typesof(/obj/item/clothing/under)-blocked)
		var/obj/item/clothing/under/V = new U
		src.clothing_choices += V

/obj/item/clothing/under/chameleon/cold
	heat_conductivity = 1000
	var/registered_user = null

/obj/item/clothing/under/chameleon/cold/attack_self(mob/user as mob)
	if(!registered_user || registered_user == user)
		if(!registered_user)
			to_chat(usr, "You are registered as the user of this suit")
			registered_user = user
		if(!(/obj/item/clothing/under/chameleon/proc/Change_Color in verbs))
			verbs |= /obj/item/clothing/under/chameleon/proc/Change_Color
			return
		if(/obj/item/clothing/under/chameleon/proc/Change_Color in verbs)
			verbs &= ~/obj/item/clothing/under/chameleon/proc/Change_Color
			return
/obj/item/clothing/under/chameleon/cold/attackby(obj/item/clothing/under/U as obj, mob/user as mob)
	if(registered_user == user)
		..()