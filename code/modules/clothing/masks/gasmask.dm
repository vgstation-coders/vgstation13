/obj/item/clothing/mask/gas
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply."
	icon_state = "gas_alt"
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	w_class = W_CLASS_MEDIUM
	can_flip = 1
	item_state = "gas_alt"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	siemens_coefficient = 0.9
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
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
		var/obj/ghetto = new /obj/item/clothing/head/helmet/space/ghetto (src.loc)
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
	body_parts_covered = FULL_HEAD | BEARD
	species_fit = list(VOX_SHAPED)
	can_flip = 0
	canstage = 0
	sterility = 100

/obj/item/clothing/mask/gas/swat
	name = "\improper SWAT mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "swat"
	siemens_coefficient = 0.7
	species_fit = list(VOX_SHAPED)
	can_flip = 0
	canstage = 0

/obj/item/clothing/mask/gas/ert
	name = "antique gas mask"
	desc = "A face-covering mask that can be connected to an air supply."
	icon_state = "ert"
	siemens_coefficient = 0.7
	species_fit = list(VOX_SHAPED)
	w_class = W_CLASS_SMALL
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
	origin_tech = Tc_SYNDICATE + "=4"
	actions_types = list(/datum/action/item_action/toggle_mask, /datum/action/item_action/change_appearance_mask, /datum/action/item_action/toggle_voicechanger)
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	permeability_coefficient = 0.90
	var/static/list/clothing_choices

/obj/item/clothing/mask/gas/voice/New()
	..()
	if(!clothing_choices)
		var/list/choices = list()
		for(var/Type in existing_typesof(/obj/item/clothing/mask) - /obj/item/clothing/mask - typesof(/obj/item/clothing/mask/gas/voice))
			var/obj/item/clothing/mask/mask_type = Type
			choices[initial(mask_type.name)] = mask_type
		clothing_choices = choices

/datum/action/item_action/change_appearance_mask
	name = "Change Mask Appearance"

/datum/action/item_action/change_appearance_mask/Trigger()
	var/obj/item/clothing/mask/gas/voice/T = target
	if(!istype(T))
		return
	T.change()

/obj/item/clothing/mask/gas/voice/proc/change()
	var/choice = input(usr, "Select Form to change it to", "BOOYEA") as null|anything in clothing_choices
	if(!choice || !usr.Adjacent(src) || usr.incapacitated())
		return

	// `clothing_choices` is an associative list of (name => type path)
	// so `chosen_type` is the type path of the chosen mask.
	// we abuse `initial()` to read vars from that type path,
	// avoiding the creation of a dummy object
	var/obj/item/clothing/mask/chosen_type = clothing_choices[choice]

	// Don't change this to set `appearance`, it will mess with the plane/layer if this thing is equipped
	name = initial(chosen_type.name)
	desc = initial(chosen_type.desc)
	icon = initial(chosen_type.icon)
	icon_state = initial(chosen_type.icon_state)
	flags = initial(chosen_type.flags)
	item_state = initial(chosen_type.item_state)
	can_flip = initial(chosen_type.can_flip)
	body_parts_covered = initial(chosen_type.body_parts_covered)
	hides_identity = initial(chosen_type.hides_identity)
	usr.update_inv_wear_mask(1)	//so our overlays update.

/obj/item/clothing/mask/gas/voice/attack_self(mob/user)
	vchange = !vchange
	to_chat(user, "<span class='notice'>The voice changer is now [vchange ? "on" : "off"]!</span>")

/obj/item/clothing/mask/gas/voice/detective
	name = "fake moustache"
	desc = "Warning: moustache is fake."
	icon_state = "fake-moustache"
	w_class = W_CLASS_TINY
	actions_types = list(/datum/action/item_action/toggle_voicechanger)

/obj/item/clothing/mask/gas/clown_hat
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	icon_state = "clown"
	item_state = "clown_hat"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	can_flip = 0
	canstage = 0

/obj/item/clothing/mask/gas/clown_hat/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/clothing/shoes/clown_shoes))
		new /mob/living/simple_animal/hostile/retaliate/cluwne/goblin(get_turf(src))
		qdel(W)
		qdel(src)

/obj/item/clothing/mask/gas/clown_hat/stickymagic
	canremove = 0

/obj/item/clothing/mask/gas/clown_hat/stickymagic/acidable()
	return 0

/obj/item/clothing/mask/gas/clown_hat/wiz
	name = "purple clown wig and mask"
	desc = "Some pranksters are truly magical."
	icon_state = "wizzclown"
	item_state = "wizzclown"
	can_flip = 0
	canstage = 0
	//TODO species_fit = list("Vox")

/obj/item/clothing/mask/gas/clown_hat/virus //why isn't this just a subtype of clown_hat??????? //Is now
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask. <span class = 'notice'>On second look, it looks like it's coming out of the wearers skin!</span>"

/obj/item/clothing/mask/gas/clown_hat/virus/dropped(mob/user as mob)
	canremove = 1
	..()

/obj/item/clothing/mask/gas/clown_hat/virus/equipped(var/mob/user, var/slot)
	if (slot == slot_wear_mask)
		canremove = 0
		can_flip = 0
	..()


/obj/item/clothing/mask/gas/sexyclown
	name = "sexy-clown wig and mask"
	desc = "A feminine clown mask for the dabbling crossdressers or female entertainers."
	icon_state = "sexyclown"
	item_state = "sexyclown"
	species_fit = list(VOX_SHAPED)
	can_flip = 0
	canstage = 0

/obj/item/clothing/mask/gas/lola
	name = "fighting clown mask"
	desc = "Honk!"
	icon_state = "lola"
	item_state = "lola"
	can_flip = 0
	canstage = 0

/obj/item/clothing/mask/gas/mime
	name = "mime mask"
	desc = "The traditional mime's mask. It has an eerie facial posture."
	icon_state = "mime"
	item_state = "mime"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	can_flip = 0
	canstage = 0
	var/muted = 0

/obj/item/clothing/mask/gas/mime/affect_speech(var/datum/speech/speech, var/mob/living/L)
	if(src.muted)
		speech.message=""

/obj/item/clothing/mask/gas/mime/stickymagic
	canremove = 0
	muted = 1

/obj/item/clothing/mask/gas/mime/stickymagic/acidable()
	return 0

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
	desc = "Beep boop."
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
