/obj/item/clothing/mask/stone
	name = "stone mask"
	desc = "An old, cracked stone mask. Its mouth seems to sport a pair of fangs."
	icon_state = "stone"
	item_state = "stone"
	flags = FPRINT
	body_parts_covered = FACE
	w_class = 2
	siemens_coefficient = 0 //it's made of stone, after all
	var/spikes_out = 0 //whether the spikes are extended
	var/infinite = 0 //by default the mask is destroyed after one use
	var/blood_to_give = 300 //seeing as the new vampire won't have had a whole round to prepare, they get some blood free

/obj/item/clothing/mask/stone/mob_can_equip(mob/M, slot, disable_warning = 0, automatic = 0)
	if(spikes_out)
		to_chat(M, "<span class='warning'>You can't get the mask over your face with its stone spikes in the way!</span>")
		return CANNOT_EQUIP
	else
		if(!istype(M, /mob/living/carbon/human))
			to_chat(M, "<span class='warning'>You can't seem to get the mask to fit correctly over your face.</span>")
			return CANNOT_EQUIP
		else
			return ..()

/obj/item/clothing/mask/stone/equipped(mob/M as mob, wear_mask)
	if(!istype(M, /mob/living/carbon/human)) //just in case a non-human somehow manages to equip it
		forceMove(M.loc)
	spikes()

/obj/item/clothing/mask/stone/proc/spikes()
	icon_state = "stone_spikes"
	spikes_out = 1
	if(istype(loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc
		H.visible_message("<span class='warning'>Stone spikes shoot out from the sides of \the [src]!</span>")
		if(H.wear_mask == src) //the mob is wearing this mask
			if(H.mind)
				if(isantagbanned(H) || jobban_isbanned(H, "vampire"))
					to_chat(H, "<span class='danger'>[src] seems to actively reject your advances. You are cursed!</span>")
					H.sleeping+=rand(20, 50)
					H.hallucination+=rand(100,500)
					H.u_equip(src, 1)
					return
				var/datum/role/vampire/V = isvampire(H)
				if(!V) //They are not already a vampire
					to_chat(H, "<span class='danger'>The mask's stone spikes pierce your skull and enter your brain!</span>")
					if (makeLateVampire(H, blood_to_give)) // If we could create them
						log_admin("[H] has become a vampire using a stone mask.")
						if (!infinite)
							crumble()
					return
				else
					to_chat(H, "<span class='notice'>The stone spikes pierce your skull, but nothing happens. Perhaps vampires cannot benefit further from use of the mask.</span>")
	else
		visible_message("<span class='warning'>Stone spikes shoot out from the sides of \the [src]!</span>")
	sleep(10)
	spikes_out = 0
	if(istype(loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc
		H.visible_message("<span class='notice'>\The [src]'s stone spikes retract back into itself.</span>")
	else
		visible_message("<span class='notice'>\The [src]'s stone spikes retract back into itself.</span>")
	icon_state = initial(icon_state)

/obj/item/clothing/mask/stone/proc/crumble()
	if(istype(loc, /mob/living))
		loc.visible_message("<span class='info'>\The [src] crumbles into dust...</span>")
	else
		visible_message("<span class='info'>\The [src] crumbles into dust...</span>")
	qdel(src)

/obj/item/clothing/mask/stone/acidable()
	return 0

/obj/item/clothing/mask/stone/infinite //this mask can be used any number of times
	infinite = 1

/proc/makeLateVampire(var/mob/living/carbon/human/H, var/blood_to_give)
	var/datum/faction/vampire/Fac_vamp = new
	var/datum/role/vampire/vamp =  new(H.mind, Fac_vamp, override = TRUE)
	if (!vamp || !Fac_vamp)
		return FALSE
	ticker.mode.factions += Fac_vamp
	vamp.OnPostSetup()
	vamp.Greet(GREET_ROUNDSTART)
	vamp.AnnounceObjectives()
	update_faction_icons()
	spawn(10)	//Unlocking their abilities produces a lot of text, I want to give them a chance to see that they have objectives
		vamp.blood_total = blood_to_give
		vamp.blood_usable = blood_to_give
		to_chat(H, "<span class='notice'>You have accumulated [vamp.blood_total] [vamp.blood_total > 1 ? "units" : "unit"] of blood and have [vamp.blood_usable] left to use.</span>")
		vamp.check_vampire_upgrade()
		vamp.update_vamp_hud()
	return TRUE