////////////////////////////////////////////////////////////////////////////////
/// Droppers.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/dropper
	name = "Dropper"
	desc = "A dropper. Transfers 5 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dropper0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(1,2,3,4,5)
	volume = 5
	// List of types that can be injected regardless of the CONTAINEROPEN flag
	// TODO Remove snowflake
	var/injectable_types = list(/obj/item/weapon/reagent_containers/food,
	                            /obj/item/slime_extract,
	                            /obj/item/clothing/mask/cigarette,
	                            /obj/item/weapon/storage/fancy/cigarettes,
	                            /obj/item/weapon/implantcase/chem,
	                            /obj/item/weapon/reagent_containers/pill/time_release,
	                            /obj/item/weapon/fossil/egg)

/obj/item/weapon/reagent_containers/dropper/update_icon()
	icon_state = "dropper[(reagents.total_volume ? 1 : 0)]"

/obj/item/weapon/reagent_containers/dropper/attack(var/mob/M, var/mob/user)
	if(!reagents.total_volume && M.is_open_container())
		to_chat(user, "<span class='warning'>That doesn't make much sense.</span>")
		return
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Squirt attempt with [src.name] by [user.name] ([user.ckey]). Reagents: [reagents.get_reagent_ids(1)]</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to use the [src.name] to squirt [M.name] ([M.key]). Reagents: [reagents.get_reagent_ids(1)]</font>")
	user.visible_message("<span class='notice'>[user] tries to squirt something into [M]'s eyes.</span>", "<span class='notice'>You try to squirt something into [M]'s eyes.</span>")
	if (!do_mob(user, M, 2 SECONDS))
		user.visible_message("<span class='danger'>[user] tries to squirt something into [M]'s eyes, but fails!</span>", "<span class='danger'>You try to squirt something into [M]'s eyes, but fails!</span>")
		return
	if(ishuman(M))
		var/mob/living/carbon/human/victim = M
		var/obj/item/safe_thing = victim.get_body_part_coverage(EYES)
		if(safe_thing)
			user.visible_message("<span class='danger'>[user] tries to squirt something into [M]'s eyes, but fails!</span>", "<span class='danger'>You try to squirt something into [M]'s eyes, but fails!</span>")
			src.reagents.reaction_dropper(safe_thing)
			src.reagents.remove_any(amount_per_transfer_from_this)
			update_icon()
			return
	user.visible_message("<span class='danger'>[user] squirts something into [M]'s eyes!</span>", "<span class='notice'>You squirt something into [M]'s eyes.</span>")
	src.reagents.reaction_dropper(M)
	src.reagents.remove_any(amount_per_transfer_from_this)
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been squirted with [src.name] by [user.name] ([user.ckey]). Reagents: [reagents.get_reagent_ids(1)]</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to squirt [M.name] ([M.key]). Reagents: [reagents.get_reagent_ids(1)]</font>")
	msg_admin_attack("[user.name] ([user.ckey]) squirted [M.name] ([M.key]) with [src.name]. Reagents: [reagents.get_reagent_ids(1)] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user
		M.assaulted_by(user)
	update_icon()
	return

/obj/item/weapon/reagent_containers/dropper/afterattack(obj/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return

	if(!target.reagents)
		if(reagents.total_volume)
			if(istype(target, /obj/machinery/artifact))
				reagents.clear_reagents()
				to_chat(user, "<span class='notice'>You squirt the solution onto the [target]!</span>")
				update_icon()
		return
	if(reagents.total_volume)

		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[target] is full.</span>")
			return

		if(!target.is_open_container() && !ismob(target) && !is_type_in_list(target, injectable_types)) //You can inject humans and food but you cant remove the shit.
			to_chat(user, "<span class='warning'>You cannot directly fill this object.</span>")
			return

		var/trans = 0
		trans = src.reagents.trans_to(target, amount_per_transfer_from_this, log_transfer = TRUE, whodunnit = user)
		to_chat(user, "<span class='notice'>You transfer [trans] units of the solution.</span>")
		update_icon()

	else
		if(ismob(target))
			return
		if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers))
			to_chat(user, "<span class='warning'>You cannot directly remove reagents from [target].</span>")
			return
		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty.</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, log_transfer = TRUE, whodunnit = user)

		to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the solution.</span>")

		update_icon()

	return

/obj/item/weapon/reagent_containers/dropper/baster
	name = "baster"
	desc = "A specialized tool for precise addition of chemicals."
	icon_state = "baster"
	possible_transfer_amounts = list(1,2,3,4,5,10,15)
	volume = 15

/obj/item/weapon/reagent_containers/dropper/baster/update_icon()
	return

/obj/item/weapon/reagent_containers/dropper/robodropper
	name = "Industrial Dropper"
	desc = "A larger dropper. Transfers 10 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dropper0"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1,2,3,4,5,6,7,8,9,10)
	volume = 10

////////////////////////////////////////////////////////////////////////////////
/// Droppers. END
////////////////////////////////////////////////////////////////////////////////
