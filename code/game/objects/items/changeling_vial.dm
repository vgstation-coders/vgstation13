/obj/item/changeling_vial
	name = "secure vial"
	desc = "An old, dusty vial. The secure cap on the top doesn't look like it will be easy to remove."
	icon = 'icons/obj/items.dmi'
	icon_state = "secure_vial"
	flags = FPRINT
	w_class = 1
	mech_flags = MECH_SCAN_FAIL
	var/genomes_to_give = 10 //seeing as the new changeling won't have had a whole round to prepare, they get some genomes free

/obj/item/changeling_vial/Destroy()
	new /datum/artifact_postmortem_data(src)
	..()

/obj/item/changeling_vial/attack_self(mob/user as mob)
	if(ishuman(user) && !(isantagbanned(user) || jobban_isbanned(user, CHANGELING)))
		var/mob/living/carbon/human/H = user
		if(H.mind)
			var/datum/mind/M = H.mind
			if(!ischangeling(H))
				user.visible_message("<span class='warning'>As [user] crushes the vial, a mass of black goo leaps at \his face!.</span>","<span class='warning'>As you try to remove the cap, you crush the vial in your hand!</span> <span class='danger'>A mass of black goo leaps at you from the vial!</span>")
				playsound(src, "shatter", 20, 1)
				qdel(src)
				H.sleeping += 10
				sleep(100)
				to_chat(H, "<span class='sinister'>You feel your consciousness slipping away...</span>")
				sleep(100)
				var/datum/role/changeling/C = new(M)
				if(C)
					C.powerpoints = clamp(genomes_to_give, 0, 100)
					C.OnPostSetup()
				var/datum/faction/changeling/hivemind = find_active_faction_by_type(/datum/faction/changeling)
				if(!hivemind)
					hivemind = ticker.mode.CreateFaction(/datum/faction/changeling)
					hivemind.OnPostSetup()
				hivemind?.HandleRecruitedRole(C) 
				to_chat(H, "<B><span class='red'>Finally, we once again have a suitable body. We are once again a proper changeling!</span></B>")
				var/wikiroute = role_wiki[CHANGELING]
				to_chat(H, "<span class='info'><a HREF='?src=\ref[H];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
				log_admin("[H] has become a changeling using a changeling vial.")
			else
				to_chat(user, "[H.mind ? 1 : 0] && [H.mind.GetRole(CHANGELING)]")
				to_chat(user, "<span class='notice'>You attempt to remove \the [src]'s cap, but the changeling inside it informs you of its presence. You decide to leave it be.</span>")
	else
		to_chat(user, "<span class='notice'>You try to remove \the [src]'s cap, but it won't budge.</span>")

/obj/item/changeling_vial/dissolvable()
	return 0
