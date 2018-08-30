////////////////////////////////////////////////////////////////////////////////
/// HYPOSPRAY
////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/hypospray
	name = "hypospray"
	desc = "The DeForest Medical Corporation hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	icon_state = "hypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = null
	flags = FPRINT  | OPENCONTAINER
	slot_flags = SLOT_BELT

/obj/item/weapon/reagent_containers/hypospray/attack_paw(mob/user as mob)
	return src.attack_hand(user)


/obj/item/weapon/reagent_containers/hypospray/New() //comment this to make hypos start off empty
	..()
	reagents.add_reagent(DOCTORSDELIGHT, 30)
	return

/obj/item/weapon/reagent_containers/hypospray/creatine/New() // TESTING!
	..()
	reagents.remove_reagent(DOCTORSDELIGHT, 30)
	reagents.add_reagent(CREATINE, 30)
	return

/obj/item/weapon/reagent_containers/hypospray/attack(mob/M as mob, mob/user as mob)
	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty.</span>")
		return
	if (!( istype(M, /mob) ))
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species && (H.species.chem_flags & NO_INJECT))
			to_chat(user, "<span classs='notice'>\The [src]'s needle fails to pierce [H]")
			return

	var/inject_message = "<span class='notice'>You inject [M] with [src].</span>"
	if(M == user)
		inject_message = "<span class='notice'>You inject yourself with [src].</span>"
	else if(clumsy_check(user) && prob(50))
		inject_message = "<span class='notice'>Oops! You inject yourself with [src] by accident.</span>"
		M = user

	if (reagents.total_volume)
		user.do_attack_animation(M, src)
		user.visible_message("<span class='warning'>[M == user ? "[user] injects \himself" : "[user] injects [M]"] with [src].</span>", \
		"[inject_message]")
		to_chat(M, "<span class='warning'>You feel a tiny prick!</span>")
		playsound(src, 'sound/items/hypospray.ogg', 50, 1)

		src.reagents.reaction(M, INGEST)
		if(M.reagents)

			var/list/injected = list()
			for(var/datum/reagent/R in src.reagents.reagent_list)
				injected += R.name
			var/contained = english_list(injected)
			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected with [src.name] by [user.name] ([user.ckey]). Reagents: [contained]</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to inject [M.name] ([M.key]). Reagents: [contained]</font>")
			msg_admin_attack("[user.name] ([user.ckey]) injected [M.name] ([M.key]) with [src.name]. Reagents: [contained] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			log_attack("<font color='red'>[user.name] ([user.ckey]) injected [M.name] ([M.ckey]) with [src.name] Reagents: [contained]</font>" )
			if(!iscarbon(user))
				M.LAssailant = null
			else
				M.LAssailant = user

			var/trans = reagents.trans_to(M, amount_per_transfer_from_this)
			to_chat(user, "<span class='notice'>[trans] units injected. [reagents.total_volume] units remaining in [src].</span>")

	return

/obj/item/weapon/reagent_containers/hypospray/autoinjector
	name = "autoinjector"
	desc = "A rapid and safe way to administer small amounts of drugs by untrained or trained personnel."
	icon_state = "autoinjector1"
	item_state = "autoinjector"
	amount_per_transfer_from_this = 5
	volume = 5
	flags = FPRINT

/obj/item/weapon/reagent_containers/hypospray/autoinjector/attack(mob/M as mob, mob/user as mob)
	..()
//	if(reagents.total_volume <= 0) //Prevents autoinjectors to be refilled.
//		flags &= ~OPENCONTAINER
	update_icon()

/obj/item/weapon/reagent_containers/hypospray/autoinjector/update_icon()
	if(reagents.total_volume > 0)
		icon_state = "autoinjector1"
	else
		icon_state = "autoinjector0"

/obj/item/weapon/reagent_containers/hypospray/autoinjector/examine(mob/user)
	..()
	if(reagents && reagents.reagent_list.len)
		to_chat(user, "<span class='info'>It is ready for injection.</span>")
	else
		to_chat(user, "<span class='info'>The [name] has been spent.</span>")

/obj/item/weapon/reagent_containers/hypospray/autoinjector/biofoam_injector
	name = "biofoam injector"
	desc = "A small, single-use device used to administer biofoam in the field."
	icon_state = "biofoam1"
	amount_per_transfer_from_this = 15
	volume = 15
	flags = FPRINT

/obj/item/weapon/reagent_containers/hypospray/autoinjector/biofoam_injector/New()
	..()
	reagents.remove_reagent(DOCTORSDELIGHT, 30)
	reagents.add_reagent(BIOFOAM, 15)
	return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/biofoam_injector/update_icon()
	if(reagents.total_volume > 0)
		icon_state = "biofoam1"
	else
		icon_state = "biofoam0"
