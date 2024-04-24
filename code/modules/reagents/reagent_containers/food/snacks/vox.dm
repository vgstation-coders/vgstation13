/obj/item/weapon/reagent_containers/food/snacks/pie/nofruitpie
	name = "no-fruit pie"
	desc = "It doesn't really taste like anything."
	icon_state = "nofruitpie"
	trash = /obj/item/trash/pietin
	reagents_to_add = list(NOTHING = 20)
	bitesize = 10
	var/list/available_snacks = list()
	var/switching = 0
	var/current_path = null
	var/counter = 1

/obj/item/weapon/reagent_containers/food/snacks/pie/nofruitpie/New()
	..()
	available_snacks = existing_typesof(/obj/item/weapon/reagent_containers/food/snacks) - typesof(/obj/item/weapon/reagent_containers/food/snacks/grown) - typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable)
	available_snacks = shuffle(available_snacks)

/obj/item/weapon/reagent_containers/food/snacks/pie/nofruitpie/verb/pick_leaf()
	set name = "Pick no-fruit pie leaf"
	set category = "Object"
	set src in range(1)

	var/mob/user = usr
	if(!user.Adjacent(src))
		return
	if(user.isUnconscious())
		to_chat(user, "You can't do that while unconscious.")
		return

	if(!switching)
		randomize()
	else
		getnofruit(user, user.get_active_hand())

/obj/item/weapon/reagent_containers/food/snacks/pie/nofruitpie/AltClick(mob/user)
	pick_leaf()

/obj/item/weapon/reagent_containers/food/snacks/pie/nofruitpie/attackby(obj/item/weapon/W, mob/user)
	pick_leaf()

/obj/item/weapon/reagent_containers/food/snacks/pie/nofruitpie/proc/randomize()
	switching = 1
	mouse_opacity = 2
	spawn()
		while(switching)
			current_path = available_snacks[counter]
			var/obj/item/weapon/reagent_containers/food/snacks/S = current_path
			icon_state = initial(S.icon_state)
			sleep(4)
			if(counter == available_snacks.len)
				counter = 0
				available_snacks = shuffle(available_snacks)
			counter++

/obj/item/weapon/reagent_containers/food/snacks/pie/nofruitpie/proc/getnofruit(mob/user, obj/item/weapon/W = null)
	if(!switching || !current_path)
		return
	verbs -= /obj/item/weapon/reagent_containers/food/snacks/pie/nofruitpie/verb/pick_leaf
	switching = 0
	var/N = rand(1,3)
	if(get_turf(user))
		switch(N)
			if(1)
				playsound(user, 'sound/weapons/genhit1.ogg', 50, 1)
			if(2)
				playsound(user, 'sound/weapons/genhit2.ogg', 50, 1)
			if(3)
				playsound(user, 'sound/weapons/genhit3.ogg', 50, 1)
	if(W)
		user.visible_message("[user] smacks \the [src] with \the [W].","You smack \the [src] with \the [W].")
	else
		user.visible_message("[user] smacks \the [src].","You smack \the [src].")
	if(src.loc == user)
		user.drop_item(src, force_drop = 1)
		var/I = new current_path(get_turf(user))
		user.put_in_hands(I)
	else
		new current_path(get_turf(src))
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/sundayroast
	name = "Sunday roast"
	desc = "Everyday is Sunday when you orbit a sun."
	icon_state = "voxroast"
	bitesize = 3
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 20, CORNOIL = 4, GRAVY = 4)

/obj/item/weapon/reagent_containers/food/snacks/risenshiny
	name = "rise 'n' shiny"
	desc = "A biscuit: exactly what a Vox merchant or thief needs to start their day. (What's the difference?)"
	icon_state = "voxbiscuit"
	bitesize = 3
	food_flags = FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 6, GRAVY = 2)

/obj/item/weapon/reagent_containers/food/snacks/mushnslush
	name = "mush 'n' slush"
	desc = "Mushroom gravy poured thickly over more mushrooms. Rich in flavor and in pocket."
	icon_state = "voxmush"
	bitesize = 2
	filling_color = "#A5782D"
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2, GRAVY = 4)

/obj/item/weapon/reagent_containers/food/snacks/woodapplejam
	name = "woodapple jam"
	desc = "Tastes like white lightning made from pure sugar. Wham!"
	icon_state = "voxjam"
	bitesize = 2
	crumb_icon = "dribbles"
	filling_color = "#70054E"
	base_crumb_chance = 0
	reagents_to_add = list(HYPERZINE = 4, NUTRIMENT = 1)

/obj/item/weapon/reagent_containers/food/snacks/woodapplejam/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale",DRINK)

/obj/item/weapon/reagent_containers/food/snacks/pie/breadfruit
	name = "breadfruit pie"
	desc = "Tastes like chalk, but birds like it for some reason."
	icon_state = "voxpie"
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/candiedwoodapple
	name = "candied woodapple"
	desc = "The sweet juices inside the woodapple quickferment under heat, producing this party favorite."
	icon_state = "candiedwoodapple"
	bitesize = 2
	base_crumb_chance = 0
	reagents_to_add = list(SUGAR = 4, WINE = 20)

/obj/item/weapon/reagent_containers/food/snacks/voxstew
	name = "Vox stew"
	desc = "The culinary culmination of all Vox culture: throwing all their plants into the same pot."
	icon_state = "voxstew"
	bitesize = 4
	filling_color = "#89441E"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 15, IMIDAZOLINE = 5)

/obj/item/weapon/reagent_containers/food/snacks/voxstew/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale",DRINK)

/obj/item/weapon/reagent_containers/food/snacks/garlicbread
	name = "garlic bread"
	desc = "Banned in Space Transylvania."
	icon_state = "garlicbread"
	bitesize = 3
	food_flags = FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 4, HOLYWATER = 2)

/obj/item/weapon/reagent_containers/food/snacks/flammkuchen
	name = "flammkuchen"
	desc = "Also called tarte flambee, literally 'flame cake'. Ancient French and German people once tried not fighting and the result was a pie that is loaded with garlic, burned, and flat."
	icon_state = "flammkuchen"
	bitesize = 4
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	reagents_to_add = list(NUTRIMENT = 30, HOLYWATER = 10)


/obj/item/weapon/reagent_containers/food/snacks/pie/welcomepie
	name = "friendship pie"
	desc = "Offered as a gesture of Vox goodwill." //"Goodwill"
	icon_state = "welcomepie"
	bitesize = 4
	reagents_to_add = list(SACID =6, NUTRIMENT = 2)

/obj/item/weapon/reagent_containers/food/snacks/zhulongcaofan
	name = "zhu long cao fan"
	desc = "Literally meaning 'pitcher plant rice'. After carefully cleansing and steaming the pitcher plant, it is stuffed with steamed rice. The carnivorous plant is rich with minerals from fauna it has consumed."
	icon_state = "zhulongcaofan"
	bitesize = 3
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6, IRON = 6)

/obj/item/weapon/reagent_containers/food/snacks/bacon
	name = "bacon strip"
	desc = "A heavenly aroma surrounds this meat."
	icon_state = "bacon"
	bitesize = 2
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/porktenderloin
	name = "pork tenderloin"
	desc = "Delicious, gravy-covered meat that will melt-in-your-beak. Or mouth."
	icon_state = "porktenderloin"
	bitesize = 4
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10, GRAVY = 4) //Competitive with chicken buckets

/obj/item/weapon/reagent_containers/food/snacks/hoboburger
	name = "hoboburger"
	desc = "A burger which uses a sack-shaped plant as a 'bun'. Any sufficiently poor Vox is indistinguishable from a hobo."
	icon_state = "hoboburger"
	bitesize = 4
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE | FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 14) //Competitive with big bite burger

/obj/item/weapon/reagent_containers/food/snacks/sweetandsourpork
	name = "sweet and sour pork"
	desc = "Makes your insides burn with flavor! With this in your stomach, you won't want to stop moving any time soon."
	icon_state = "sweetsourpork"
	bitesize = 2
	base_crumb_chance = 0
	//3 nutriment inherited from the meat
	reagents_to_add = list(LITHIUM = 2, SYNAPTIZINE = 1) //Random movement for a short period //Stay on your feet, loads of toxins

/obj/item/weapon/reagent_containers/food/snacks/poachedaloe
	name = "poached aloe"
	desc = "Extremely oily and slippery gel contained inside aloe."
	icon_state = "poachedaloe"
	bitesize = 1
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2)

/obj/item/weapon/reagent_containers/food/snacks/vanishingstew
	name = "vapor stew"
	desc = "Most stews vanish, but this one does so before you eat it."
	icon_state = "vanishingstew"
	bitesize = 2
	crumb_icon = "dribbles"
	filling_color = "#FF9933"
	reagents_to_add = list(NUTRIMENT = 3)
	valid_utensils = UTENSILE_SPOON
