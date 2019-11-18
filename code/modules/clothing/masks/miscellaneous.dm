/obj/item/clothing/mask/muzzle
	name = "muzzle"
	desc = "To stop that awful noise."
	icon_state = "muzzle"
	item_state = "muzzle"
	flags = FPRINT
	w_class = W_CLASS_SMALL
	gas_transfer_coefficient = 0.90
	species_fit = list(VOX_SHAPED)
	origin_tech = Tc_BIOTECH + "=2"
	body_parts_covered = MOUTH

//Monkeys can not take the muzzle off of themself! Call PETA!
/obj/item/clothing/mask/muzzle/attack_paw(mob/user as mob)
	if (src == user.wear_mask)
		return
	else
		..()
	return


/obj/item/clothing/mask/surgical
	name = "sterile mask"
	desc = "A sterile mask designed to help prevent the spread of diseases."
	icon_state = "sterile"
	item_state = "sterile"
	w_class = W_CLASS_TINY
	flags = FPRINT
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 25, rad = 0)
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	sterility = 100
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT

/obj/item/clothing/mask/fakemoustache
	name = "fake moustache"
	desc = "Warning: moustache is fake."
	icon_state = "fake-moustache"
	flags = FPRINT
	body_parts_covered = BEARD
	hides_identity = HIDES_IDENTITY_ALWAYS

//scarves (fit in in mask slot)
/obj/item/clothing/mask/scarf
	flags = FPRINT
	actions_types = list(/datum/action/item_action/toggle_mask)
	w_class = W_CLASS_SMALL
	gas_transfer_coefficient = 0.90
	can_flip = 1
	heat_conductivity = INS_MASK_HEAT_CONDUCTIVITY

/obj/item/clothing/mask/scarf/blue
	name = "blue neck scarf"
	desc = "A blue neck scarf."
	icon_state = "blue_scarf"
	item_state = "blue_scarf"


/obj/item/clothing/mask/scarf/red
	name = "red scarf"
	desc = "A red neck scarf."
	icon_state = "red_scarf"
	item_state = "red_scarf"


/obj/item/clothing/mask/scarf/green
	name = "green scarf"
	desc = "A green and red line patterned scarf."
	icon_state = "green_scarf"
	item_state = "green_scarf"

/obj/item/clothing/mask/balaclava
	name = "balaclava"
	desc = "LOADSAMONEY"
	icon_state = "balaclava"
	item_state = "balaclava"
	flags = FPRINT|HIDEHAIRCOMPLETELY
	body_parts_covered = HIDEHAIR | MOUTH
	w_class = W_CLASS_SMALL
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	hides_identity = HIDES_IDENTITY_ALWAYS

/obj/item/clothing/mask/balaclava/skimask
	heat_conductivity = INS_MASK_HEAT_CONDUCTIVITY
	name = "ski mask"
	desc = "This NT-brand skimask is sure to keep you warm."

/obj/item/clothing/mask/neorussian
	name = "neo-Russian mask"
	desc = "Somehow, it makes you act and look way more polite than usual."
	icon_state = "nr_mask"
	item_state = "nr_mask"
	body_parts_covered = FACE
	heat_conductivity = INS_MASK_HEAT_CONDUCTIVITY

/obj/item/clothing/mask/pig
	name = "pig mask"
	desc = "A rubber pig mask."
	icon_state = "pig"
	item_state = "pig"
	flags = FPRINT
	body_parts_covered = FACE
	w_class = W_CLASS_SMALL
	siemens_coefficient = 0.9

/obj/item/clothing/mask/horsehead
	name = "horse head mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a horse."
	icon_state = "horsehead"
	item_state = "horsehead"
	flags = FPRINT
	body_parts_covered = FACE
	w_class = W_CLASS_SMALL
	var/voicechange = 0
	siemens_coefficient = 0.9

/obj/item/clothing/mask/horsehead/affect_speech(var/datum/speech/speech, var/mob/living/L)
	if(src.voicechange)
		speech.message = pick("NEEIIGGGHHHH!", "NEEEIIIIGHH!", "NEIIIGGHH!", "HAAWWWWW!", "HAAAWWW!")

/obj/item/clothing/mask/horsehead/magic
	voicechange = 1		//NEEEEIIGHH

/obj/item/clothing/mask/horsehead/magic/dropped(mob/user as mob)
	canremove = 1
	..()

/obj/item/clothing/mask/horsehead/magic/equipped(var/mob/user, var/slot)
	if (slot == slot_wear_mask)
		canremove = 0		//curses!
	..()

/obj/item/clothing/mask/horsehead/reindeer //christmas edition
	name = "reindeer head mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a reindeer."
	icon_state = "reindeerhead"
	item_state = "reindeerhead"

/obj/item/clothing/mask/chapmask
	name = "venetian mask"
	desc = "A plain porcelain mask that covers the entire face. Standard attire for particularly unspeakable religions. The eyes are wide shut."
	icon_state = "chapmask"
	item_state = "chapmask"
	flags = FPRINT
	body_parts_covered = FACE
	w_class = W_CLASS_SMALL
	gas_transfer_coefficient = 0.90

/obj/item/clothing/mask/bandana
	name = "bandana"
	desc = "A colorful bandana."
	actions_types = list(/datum/action/item_action/toggle_mask)
	w_class = W_CLASS_TINY
	can_flip = 1

obj/item/clothing/mask/bandana/red
	name = "red bandana"
	icon_state = "bandred"

obj/item/clothing/mask/joy
	name = "joy mask"
	desc = "Express your happiness or hide your sorrows with this laughing face with crying tears of joy cutout."
	icon_state = "joy"

/obj/item/clothing/mask/vamp_fangs
	name = "false fangs"
	desc = "For when you want people to think you're a vampire. Glows in the dark!"
	icon_state = "fangs"
	item_state = "fangs"
	var/light_absorbed = 0
	var/glowy_fangs
	var/image/glow_fangs

/obj/item/clothing/mask/vamp_fangs/New()
	..()
	glow_fangs = image("icon" = 'icons/mob/mask.dmi',"icon_state" = "fangs_glow", "layer" = ABOVE_LIGHTING_LAYER)
	glow_fangs.plane = LIGHTING_PLANE

/obj/item/clothing/mask/vamp_fangs/equipped(mob/M, var/slot)
	..()
	var/mob/living/carbon/human/H = M
	if(!istype(H))
		return
	if(slot == slot_wear_mask && light_absorbed > 1)
		glowy_fangs = TRUE
		if(icon_state != "fangs_glow")
			icon_state = "fangs_glow"
		H.overlays += glow_fangs

/obj/item/clothing/mask/vamp_fangs/unequipped(mob/living/carbon/human/user, var/from_slot = null)
	if(from_slot == slot_wear_mask)
		user.overlays -= glow_fangs

/obj/item/clothing/mask/vamp_fangs/OnMobLife(var/mob/living/carbon/human/wearer)
	var/turf/T = get_turf(wearer)
	var/light_amount = T.get_lumcount()
	if(light_amount < 0)
		light_absorbed = max(0, light_absorbed/1.25)
	else
		light_absorbed = min(10, light_absorbed+=light_amount/2)

	if(light_absorbed < 1 && glowy_fangs)
		glowy_fangs = FALSE
		icon_state = "fangs"
		wearer.overlays -= glow_fangs

	if(light_absorbed >= 1 && !glowy_fangs)
		glowy_fangs = TRUE
		icon_state = "fangs_glow"
		wearer.overlays += glow_fangs


/obj/item/clothing/mask/goldface
	name = "golden mask"
	desc = "Previously used in strange pantomimes, after one of the actors went mad on stage these masks have avoided use. You swear its face contorts when you're not looking."
	icon_state = "goldenmask"
	item_state = "goldenmask"

/obj/item/clothing/mask/goldface/equipped()
	..()
	update_icon()

/obj/item/clothing/mask/goldface/unequipped()
	..()
	update_icon()

/obj/item/clothing/mask/goldface/update_icon()
	icon_state = pick("goldenmask","goldenmask_anger","goldenmask_joy","goldenmask_despair")


/obj/item/clothing/mask/holopipe
	name = "holo pipe"
	desc = "It is not a pipe."
	icon_state = "holopipe_off"
	item_state = "holopipe_off"
	var/activated = 0


/obj/item/clothing/mask/holopipe/proc/activate(var/mob/user as mob)
	if(!user.incapacitated())
		src.activated = !src.activated
		if(src.activated)
			icon_state = "holopipe_on"
			item_state = "holopipe_on"
			to_chat(user, "You activate the holo pipe.")
			user.update_inv_wear_mask()
		else
			icon_state = "holopipe_off"
			item_state = "holopipe_off"
			to_chat(user, "You deactivate the holo pipe.")
			user.update_inv_wear_mask()

/obj/item/clothing/mask/holopipe/attack_self(var/mob/user)
	activate(user)

/obj/item/clothing/mask/holopipe/verb/activate_pipe()
	set category = "Object"
	set name = "Toggle pipe"
	set src in usr
	if(!usr.incapacitated())
		activate(usr)