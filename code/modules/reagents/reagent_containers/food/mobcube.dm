/obj/item/weapon/reagent_containers/food/snacks/monkeycube
	name = "monkey cube"
	desc = "Just add water!"
	icon_state = "monkeycube"
	bitesize = 12
	food_flags = FOOD_MEAT
	edible_by_utensil = FALSE
	var/contained_mob = /mob/living/carbon/monkey

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/New()
	..()
	reagents.add_reagent(NUTRIMENT,10)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/Destroy()
	if(contained_mob && isdatum(contained_mob))
		qdel(contained_mob)
		contained_mob = null
	..()

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/afterattack(obj/O, mob/user,proximity)
	if(!proximity)
		return
	if(istype(O,/obj/structure/sink) && !wrapped)
		to_chat(user, "<span class='notice'>You place [src] under a stream of water...</span>")
		return Expand()
	..()

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/after_consume(var/mob/M)

	if(!contained_mob)
		return
	if(ispath(contained_mob))
		contained_mob = new contained_mob(src)
	if(!ismob(contained_mob)) //Somehow
		return
	var/mob/C = contained_mob

	to_chat(M, "<span class = 'warning'>Something inside of you suddently expands!</span>")

	if (istype(M, /mob/living/carbon/human))
		//Do not try to understand.
		var/obj/item/weapon/surprise = new/obj/item/weapon(M)
		surprise.icon = C.icon
		surprise.icon_state = C.icon_state
		surprise.name = "malformed [C.name]"
		surprise.desc = "Looks like \a very deformed [C.name], a little small for its kind. It shows no signs of life."
		qdel(contained_mob)
		surprise.transform *= 0.6
		surprise.add_blood(M)
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/E = H.get_organ(LIMB_CHEST)
		E.fracture()
		for (var/datum/organ/internal/I in E.internal_organs)
			I.take_damage(rand(I.min_bruised_damage, I.min_broken_damage+1))

		if (!E.hidden && prob(60)) //set it snuggly
			E.hidden = surprise
			E.cavity = 0
		else 		//someone is having a bad day
			E.createwound(CUT, 30)
			E.embed(surprise)
	else if (ismonkey(M))
		M.visible_message("<span class='danger'>[M] suddenly tears in half!</span>")
		C.forceMove(get_turf(M))
		C.name = "malformed [initial(name)]"
		C.transform *= 0.6
		C.add_blood(M)
		M.gib()
	..()

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/proc/Expand()

	for(var/mob/M in viewers(src,7))
		to_chat(M, "<span class='warning'>\The [src] expands!</span>")
	if(!contained_mob)
		return
	if(ispath(contained_mob))
		new contained_mob(get_turf(src))
	else if(ismob(contained_mob))
		var/mob/C = contained_mob
		C.forceMove(get_turf(src))
	contained_mob = null
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/proc/Unwrap(mob/user as mob)

	icon_state = "monkeycube"
	desc = "Just add water!"
	to_chat(user, "You unwrap the cube.")
	wrapped = 0
	return

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped
	desc = "Still wrapped in some paper."
	icon_state = "monkeycubewrap"
	wrapped = 1


/obj/item/weapon/reagent_containers/food/snacks/monkeycube/farwacube
	name = "farwa cube"
	contained_mob = /mob/living/carbon/monkey/tajara

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/farwacube
	name = "farwa cube"
	contained_mob = /mob/living/carbon/monkey/tajara

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/stokcube
	name = "stok cube"
	contained_mob = /mob/living/carbon/monkey/unathi

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/stokcube
	name = "stok cube"
	contained_mob = /mob/living/carbon/monkey/unathi

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/neaeracube
	name = "neaera cube"
	contained_mob = /mob/living/carbon/monkey/skrell

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/neaeracube
	name = "neaera cube"
	contained_mob = /mob/living/carbon/monkey/skrell

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/humancube
	name = "humanoid cube"
	desc = "Freshly compressed. Add water to release the creature within."
	contained_mob = null

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/mousecube
	name = "lab mouse cube"
	contained_mob = /mob/living/simple_animal/mouse/balbc

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/mousecube
	name = "lab mouse cube"
	contained_mob = /mob/living/simple_animal/mouse/balbc
