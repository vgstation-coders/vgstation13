/datum/species/krampus // /vg/
	name = "Krampus"
	override_icon = 'icons/mob/human_races/krampus.dmi'
	icobase = 'icons/mob/human_races/krampus.dmi'
	deform = 'icons/mob/human_races/krampus.dmi'
	known_languages = list(LANGUAGE_CLATTER)
	attack_verb = "punishes"

	//flags = IS_WHITELISTED /*| HAS_LIPS | HAS_TAIL | NO_EAT | NO_BREATHE | NON_GENDERED*/ | NO_BLOOD
	// These things are just really, really griefy. IS_WHITELISTED removed for now - N3X
	flags = NO_BLOOD | NO_BREATHE | NO_PAIN

	default_mutations=list(M_NO_BREATH,M_NO_SHOCK,M_RUN)

	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000


/mob/living/carbon/human/krampus
	real_name = "Krampus"
	status_flags = GODMODE|CANPUSH

/mob/living/carbon/human/krampus/New(var/new_loc)
	h_style = "Bald"
	..(new_loc, "Krampus")
	maxHealth = INFINITY
	health = maxHealth
	var/obj/item/weapon/krampus/sack = new /obj/item/weapon/krampus(src)
	put_in_hands(sack)

/mob/living/carbon/human/krampus/proc/sack_em(var/mob/M)
	if(!istype(M))
		return

	var/datum/admins/Krampus = client.holder
	if(!(Krampus && check_rights(R_BAN)))
		return

	var/youwillneverhide = M.ckey
	var/response = alert("Ban them, or just sack them?",,"Ban", "Sack", "Cancel")
	if(response == "Cancel" || !M)
		return

	forceMove(get_turf(M))
	M.drop_all()
	M.forceMove(src) //need somewhere to store them while they're getting banned
	to_chat(world, "<span class='sinister'>Krampus just sacked [M]. What a naughty little brat.<span>")
	log_admin("[key_name_admin(src)] sacked [key_name_admin(M)].")

	if(response == "Ban")
		if(M.ckey != youwillneverhide)
			M.ghostize(0)//In case of someone who mindswapped into them or something while responding, you don't want them getting disconnected and being able to re-join from lobby.
			M.ckey = youwillneverhide
		Krampus.newban(M)

	qdel(M)

/obj/item/weapon/krampus
	name = "Krampus's Sack"
	desc = "Krampus's sack that he shoves naughty spacemen in."
	icon = 'icons/mob/human_races/krampus.dmi' //you're holding a mini krampus :^)
	icon_state = null
	cant_drop = 1

/obj/item/weapon/krampus/attack(mob/target, mob/user) //lack of adjacency check intentional, Krampus teleports to them on sackage.
	var/mob/living/carbon/human/krampus/K = user
	if(!istype(K))
		to_chat(user, "<span class='danger'>You've been a very naughty little brat.</span>")
		user.death()
	K.sack_em(target)

// I'M THE KRAMPUS, BITCH
/mob/living/carbon/human/krampus/Stun(amount)
	return

/mob/living/carbon/human/krampus/Knockdown(amount)
	return

/mob/living/carbon/human/krampus/Paralyse(amount)
	return

/mob/living/carbon/human/krampus/eyecheck()
	return 2 // Immune to flashes

/mob/living/carbon/human/krampus/ex_act(severity)
	return

/mob/living/carbon/human/krampus/blob_act(destroy)
	return

/mob/living/carbon/human/krampus/singularity_pull()
	return

/mob/living/carbon/human/krampus/singularity_act()
	return

/mob/living/carbon/human/krampus/shuttle_act(shuttle)
	return

/mob/living/carbon/human/krampus/gib()
	return

/mob/living/carbon/human/krampus/dust()
	return