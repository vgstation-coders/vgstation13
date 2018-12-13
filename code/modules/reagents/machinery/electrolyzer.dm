/obj/item/weapon/electrolyzer
	name = "Electrolyzer"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "chemg_wired"
	item_state = "chemg_wired"
	desc = "A refurbished grenade-casing jury rigged to split simple chemicals."
	w_class = W_CLASS_SMALL
	force = 2.0
	var/list/beakers = new/list()
	var/list/allowed_containers = list(/obj/item/weapon/reagent_containers/glass, /obj/item/weapon/reagent_containers/food/drinks/soda_cans/)

/obj/item/weapon/electrolyzer/New()
	. = ..()

/obj/item/weapon/electrolyzer/attack_self(mob/user as mob)
	if(beakers.len)
		for(var/obj/B in beakers)
			if(istype(B))
				beakers -= B
				user.put_in_hands(B)
	to_chat(user, "<span class='notice'>You remove the containers from the electrolyzer.</span>")

/obj/item/weapon/electrolyzer/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iswirecutter(W))
		if(beakers.len)
			to_chat(user, "<span class='warning'>The electrolyzer contains beakers!</span>")
			return
		else
			to_chat(user, "<span class='notice'>You disassemble the electrolyzer.</span>")
			var/turf/T = get_turf(src)
			new /obj/item/stack/cable_coil(T,2)
			new /obj/item/weapon/grenade/chem_grenade(T)
			qdel(src)
			return
	else if(is_type_in_list(W, allowed_containers))
		var/obj/item/weapon/reagent_containers/glass/G = W
		if(G.w_class > W_CLASS_SMALL)
			to_chat(user, "<span class='warning'>\The [G] is too big to fit.</span>")
			return
		if(G.reagents.reagent_list.len > 1)
			to_chat(user, "<span class='warning'>That mixture is too complex!</span>")
			return
		if(beakers.len == 2)
			to_chat(user, "<span class='warning'>The grenade can not hold more containers.</span>")
			return
		else if(beakers.len == 1)
			var/obj/item/weapon/reagent_containers/glass/other = beakers[1]
			if(other.reagents.total_volume && !G.reagents.total_volume) //We already have one inserted beaker. It must occupy slot 1. Is it empty or active?
				to_chat(user, "<span class='notice'>You add \the [G] to the electrolyzer as the empty container.</span>")
				insert_beaker(G,user)
			else if(!other.reagents.total_volume && G.reagents.total_volume)
				to_chat(user, "<span class='notice'>You add \the [G] to the electrolyzer as the active container.</span>")
				insert_beaker(G,user)
			else
				to_chat(user, "<span class='warning'>The electrolyzer requires one active beaker and one empty beaker!</span>")
				return
		else
			to_chat(user, "<span class='notice'>You add \the [G] to the electrolyzer as the [G.reagents.total_volume ? "active" : "empty"] container.</span>")
			insert_beaker(G,user)
	else if(istype(W, /obj/item/weapon/cell))
		if(beakers.len < 2)
			to_chat(user, "<span class='warning'>The electrolyzer requires one active beaker and one empty beaker!</span>")
			return
		var/obj/item/weapon/cell/C = W
		var/obj/item/weapon/reagent_containers/active = null
		var/obj/item/weapon/reagent_containers/empty = null
		var/datum/chemical_reaction/unreaction = null
		for(var/obj/item/weapon/reagent_containers/B in beakers)
			if(B.reagents.reagent_list.len > 1) //This only fires if their power ran out with a first cell and they try electrolyzing again without removing the old mix
				to_chat(user, "<span class='warning'>That mixture is too complex!</span>")
				return
			else if(B.reagents.reagent_list.len == 1)
				active = B
			else if (!B.reagents.reagent_list.len)
				empty = B
			else
				to_chat(user, "<span class='warning'>An error has occured. Your beaker had between 0 and 1 reagents. Please report this message.</span>")
		if(!active || !empty)
			to_chat(user, "<span class='warning'>There must be both an empty and active beaker.</span>")
			return
		var/datum/reagent/target = active.reagents.reagent_list[1] //Should only have one thing anyway
		for(var/R in typesof(/datum/chemical_reaction/))
			var/datum/chemical_reaction/check = new R
			if(check.id == target.id)
				unreaction = check
				break
		if(!unreaction)
			to_chat(user, "<span class='notice'>The system didn't react...</span>")
			return
		var/total_reactions = round(active.reagents.total_volume / unreaction.result_amount)
		var/primary = 1
		if(C.charge<30*total_reactions)
			total_reactions = round(C.charge/30) //In the case that we don't have ENOUGH charge, this will react us as often as we can
		C.charge -= (30*total_reactions)
		var/amount_to_electrolyze = total_reactions*unreaction.result_amount
		active.reagents.remove_reagent(unreaction.result,amount_to_electrolyze) //This moves over the reactive bulk, and leaves behind the amount too small to react
		for(var/E in unreaction.required_reagents)
			var/reagent_ID = E
			if(islist(E))
				var/list/L = E
				reagent_ID = L[1] //the first element should be the synthetic version of the chemical. why don't the lists start at 0?
			if(primary)
				active.reagents.add_reagent(reagent_ID, unreaction.required_reagents[E]*total_reactions) //Put component amount * reaction count back in primary
				primary = 0
			else
				empty.reagents.add_reagent(reagent_ID, unreaction.required_reagents[E]*total_reactions)
		investigation_log(I_CHEMS, "was used by [key_name(user)] to electrolyze [amount_to_electrolyze]u of [unreaction.result].")
		to_chat(user, "<span class='warning'>The system electrolyzes!</span>")
		spark(src, 5, FALSE)
	else
		..()

/obj/item/weapon/electrolyzer/proc/insert_beaker(obj/item/weapon/W as obj, mob/user as mob)
	if(user.drop_item(W, src))
		W.forceMove(src)
		beakers += W
	else
		to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
		return
