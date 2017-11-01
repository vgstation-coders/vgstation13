/obj/item/weapon/reagent_containers/food/snacks/monkeycube
	name = "monkey cube"
	desc = "Just add water!"
	icon_state = "monkeycube"
	bitesize = 12
	food_flags = FOOD_MEAT
	var/mob/living/carbon/contained_mob = new /mob/living/carbon/monkey(null) //Storing it in nullspace is fine

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/New()
	..()
	reagents.add_reagent(NUTRIMENT,10)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/Destroy()
	if(contained_mob)
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

	to_chat(M, "<span class = 'warning'>Something inside of you suddently expands!</span>")

	if (istype(M, /mob/living/carbon/human))
		//Do not try to understand.
		var/obj/item/weapon/surprise = new/obj/item/weapon(M)
		surprise.icon = contained_mob.icon
		surprise.icon_state = contained_mob.icon_state
		surprise.name = "malformed [contained_mob.name]"
		surprise.desc = "Looks like \a very deformed [contained_mob.name], a little small for its kind. It shows no signs of life."
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
		contained_mob.forceMove(get_turf(M))
		contained_mob.name = "malformed [initial(name)]"
		contained_mob.transform *= 0.6
		contained_mob.add_blood(M)
		M.gib()
	..()

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/proc/Expand()

	for(var/mob/M in viewers(src,7))
		to_chat(M, "<span class='warning'>\The [src] expands!</span>")
	contained_mob.forceMove(get_turf(src))
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
	contained_mob = new /mob/living/carbon/monkey/tajara(null)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/farwacube
	name = "farwa cube"
	contained_mob = new /mob/living/carbon/monkey/tajara(null)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/stokcube
	name = "stok cube"
	contained_mob = new /mob/living/carbon/monkey/unathi(null)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/stokcube
	name = "stok cube"
	contained_mob = new /mob/living/carbon/monkey/unathi(null)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/neaeracube
	name = "neaera cube"
	contained_mob = new /mob/living/carbon/monkey/skrell(null)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/neaeracube
	name = "neaera cube"
	contained_mob = new /mob/living/carbon/monkey/skrell(null)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/humancube
	name = "humanoid cube"
	desc = "Freshly compressed. Add water to release the creature within."
	contained_mob = null
