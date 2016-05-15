/obj/item/clothing/mask/gas
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply."
	icon_state = "gas_alt"
	flags = FPRINT  | BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	w_class = W_CLASS_MEDIUM
	can_flip = 1
	action_button_name = "Toggle Mask"
	item_state = "gas_alt"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	siemens_coefficient = 0.9
	species_fit = list(VOX_SHAPED)
	body_parts_covered = FACE
	pressure_resistance = ONE_ATMOSPHERE
	var/canstage = 1
	var/stage = 0


/obj/item/clothing/mask/gas/attackby(obj/item/W,mob/user)
	..()
	if(!canstage)
		to_chat(user, "<span class = 'warning'>\The [W] won't fit on \the [src].</span>")
		return
	if(istype(W,/obj/item/clothing/suit/spaceblanket) && !stage)
		stage = 1
		to_chat(user,"<span class='notice'>You add \the [W] to \the [src].</span>")
		qdel(W)
		icon_state = "gas_mask1"
	if(istype(W,/obj/item/stack/cable_coil) && stage == 1)
		var/obj/item/stack/cable_coil/C = W
		if(C.amount <= 4)
			return
		icon_state = "gas_mask2"
		to_chat(user,"<span class='notice'>You tie up \the [src] with \the [W].</span>")
		stage = 2
	if(istype(W,/obj/item/clothing/head/hardhat/red) && stage == 2)
		to_chat(user,"<span class='notice'>You finish the ghetto helmet.</span>")
		var/obj/ghetto = new /obj/item/clothing/head/helmet/space/rig/ghettorig (src.loc)
		qdel(src)
		qdel(W)
		user.put_in_hands(ghetto)

/obj/item/clothing/mask/gas/togglemask()
	..()
	if(is_flipped == 1 && stage > 0)
		switch(stage)
			if(1)
				icon_state = "gas_mask1"
			if(2)
				icon_state = "gas_mask2"


//Plague Dr suit can be found in clothing/suits/bio.dm
/obj/item/clothing/mask/gas/plaguedoctor
	name = "plague doctor mask"
	desc = "A modernised version of the classic design, this mask will not only filter out toxins but it can also be connected to an air supply."
	icon_state = "plaguedoctor"
	item_state = "gas_mask"
	armor = list(melee = 0, bullet = 0, laser = 2,energy = 2, bomb = 0, bio = 75, rad = 0)
	species_fit = list(VOX_SHAPED)
	can_flip = 0
	canstage = 0

/obj/item/clothing/mask/gas/swat
	name = "\improper SWAT mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "swat"
	siemens_coefficient = 0.7
	species_fit = list(VOX_SHAPED)
	can_flip = 0
	canstage = 0

/obj/item/clothing/mask/gas/syndicate
	name = "syndicate mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "swat"
	siemens_coefficient = 0.7
	species_fit = list(VOX_SHAPED)
	can_flip = 0
	canstage = 0

/obj/item/clothing/mask/gas/voice
	name = "gas mask"
	//desc = "A face-covering mask that can be connected to an air supply. It seems to house some odd electronics."
	var/mode = 0// 0==Scouter | 1==Night Vision | 2==Thermal | 3==Meson
	var/voice = "Unknown"
	var/vchange = 1//This didn't do anything before. It now checks if the mask has special functions/N
	canstage = 0
	origin_tech = "syndicate=4"
	action_button_name = "Toggle Mask"
	species_fit = list(VOX_SHAPED)
	var/list/clothing_choices = list()

/obj/item/clothing/mask/gas/voice/New()
	..()
	for(var/Type in typesof(/obj/item/clothing/mask) - list(/obj/item/clothing/mask, /obj/item/clothing/mask/gas/voice))
		clothing_choices += new Type
	return

/obj/item/clothing/mask/gas/voice/attackby(obj/item/I, mob/user)
	..()
	if(!istype(I, /obj/item/clothing/mask) || istype(I, src.type))
		return 0
	else
		var/obj/item/clothing/mask/M = I
		if(src.clothing_choices.Find(M))
			to_chat(user, "<span class='warning'>[M.name]'s pattern is already stored.</span>")
			return
		src.clothing_choices += M
		to_chat(user, "<span class='notice'>[M.name]'s pattern absorbed by \the [src].</span>")
		return 1
	return 0

/obj/item/clothing/mask/gas/voice/verb/change()
	set name = "Change Mask Form"
	set category = "Object"
	set src in usr

	var/obj/item/clothing/mask/A
	A = input("Select Form to change it to", "BOOYEA", A) as null|anything in clothing_choices
	if(!A ||(usr.stat))
		return

	desc = null
	permeability_coefficient = 0.90

	desc = A.desc
	name = A.name
	flags = A.flags
	icon = A.icon
	icon_state = A.icon_state
	item_state = A.item_state
	can_flip = A.can_flip
	body_parts_covered = A.body_parts_covered
	usr.update_inv_wear_mask(1)	//so our overlays update.

/obj/item/clothing/mask/gas/voice/attack_self(mob/user)
	vchange = !vchange
	to_chat(user, "<span class='notice'>The voice changer is now [vchange ? "on" : "off"]!</span>")

/obj/item/clothing/mask/gas/clown_hat
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	icon_state = "clown"
	item_state = "clown_hat"
	species_fit = list(VOX_SHAPED)
	can_flip = 0
	canstage = 0

/obj/item/clothing/mask/gas/clown_hat/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/clothing/shoes/clown_shoes))
		new /mob/living/simple_animal/hostile/retaliate/cluwne/goblin(get_turf(src))
		qdel(W)
		qdel(src)

/obj/item/clothing/mask/gas/clown_hat/wiz
	name = "purple clown wig and mask"
	desc = "Some pranksters are truly magical."
	icon_state = "wizzclown"
	item_state = "wizzclown"
	can_flip = 0
	canstage = 0
	//TODO species_fit = list("Vox")

/obj/item/clothing/mask/gas/virusclown_hat //why isn't this just a subtype of clown_hat???????
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	icon_state = "clown"
	item_state = "clown_hat"
	species_fit = list(VOX_SHAPED)
	can_flip = 0
	canstage = 0

/obj/item/clothing/mask/gas/sexyclown
	name = "sexy-clown wig and mask"
	desc = "A feminine clown mask for the dabbling crossdressers or female entertainers."
	icon_state = "sexyclown"
	item_state = "sexyclown"
	species_fit = list(VOX_SHAPED)
	can_flip = 0
	canstage = 0

/obj/item/clothing/mask/gas/mime
	name = "mime mask"
	desc = "The traditional mime's mask. It has an eerie facial posture."
	icon_state = "mime"
	item_state = "mime"
	species_fit = list(VOX_SHAPED)
	can_flip = 0
	canstage = 0
	var/muted = 0

/obj/item/clothing/mask/gas/mime/treat_mask_speech(var/datum/speech/speech)
	if(src.muted)
		speech.message=""

/obj/item/clothing/mask/gas/monkeymask
	name = "monkey mask"
	desc = "A mask used when acting as a monkey."
	icon_state = "monkeymask"
	item_state = "monkeymask"
	species_fit = list(VOX_SHAPED)
	can_flip = 0
	canstage = 0

/obj/item/clothing/mask/gas/sexymime
	name = "sexy mime mask"
	desc = "A traditional female mime's mask."
	icon_state = "sexymime"
	item_state = "sexymime"
	species_fit = list(VOX_SHAPED)
	can_flip = 0
	canstage = 0

/obj/item/clothing/mask/gas/death_commando
	name = "Death Commando Mask"
	icon_state = "death"
	item_state = "death"
	siemens_coefficient = 0.2
	species_fit = list(VOX_SHAPED)
	can_flip = 0
	canstage = 0

/obj/item/clothing/mask/gas/cyborg
	name = "cyborg visor"
	desc = "Beep boop"
	icon_state = "death"
	species_fit = list(VOX_SHAPED)
	can_flip = 0
	canstage = 0

/obj/item/clothing/mask/gas/owl_mask
	name = "owl mask"
	desc = "Twoooo!"
	icon_state = "owl"
	species_fit = list(VOX_SHAPED)
	can_flip = 0
	canstage = 0