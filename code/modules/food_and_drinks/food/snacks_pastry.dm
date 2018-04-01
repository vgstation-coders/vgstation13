//Pastry is a food that is made from dough which is made from wheat or rye flour.
//This file contains pastries that don't fit any existing categories.
////////////////////////////////////////////DONUTS////////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/donut
	name = "donut"
	desc = "Goes great with robust coffee."
	icon_state = "donut1"
	bitesize = 5
	bonus_reagents = list("sugar" = 1)
	list_reagents = list("nutriment" = 3, "sugar" = 2)
	var/extra_reagent = null
	filling_color = "#D2691E"
	tastes = list("donut" = 1)
	foodtype = JUNKFOOD | GRAIN | FRIED | SUGAR

/obj/item/reagent_containers/food/snacks/donut/Initialize()
	. = ..()
	if(prob(30))
		icon_state = "donut2"
		name = "frosted donut"
		reagents.add_reagent("sprinkles", 2)
		bonus_reagents = list("sprinkles" = 2, "sugar" = 1)
		filling_color = "#FF69B4"


/obj/item/reagent_containers/food/snacks/donut/checkLiked(fraction, mob/M)	//Sec officers always love donuts
	if(last_check_time + 50 < world.time)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.mind && H.mind.assigned_role == "Security Officer" && !H.has_trait(TRAIT_AGEUSIA))
				to_chat(H,"<span class='notice'>I love this taste!</span>")
				H.adjust_disgust(-5 + -2.5 * fraction)
				GET_COMPONENT_FROM(mood, /datum/component/mood, H)
				if(mood)
					mood.add_event("fav_food", /datum/mood_event/favorite_food)
				last_check_time = world.time
				return
	..()

/obj/item/reagent_containers/food/snacks/donut/chaos
	name = "chaos donut"
	desc = "Like life, it never quite tastes the same."
	bitesize = 10
	tastes = list("donut" = 3, "chaos" = 1)

/obj/item/reagent_containers/food/snacks/donut/chaos/Initialize()
	. = ..()
	extra_reagent = pick("nutriment", "capsaicin", "frostoil", "krokodil", "plasma", "cocoa", "slimejelly", "banana", "berryjuice", "omnizine")
	reagents.add_reagent("[extra_reagent]", 3)
	bonus_reagents = list("[extra_reagent]" = 3, "sugar" = 1)
	if(prob(30))
		icon_state = "donut2"
		name = "frosted chaos donut"
		reagents.add_reagent("sprinkles", 2)
		bonus_reagents = list("sprinkles" = 2, "[extra_reagent]" = 3, "sugar" = 1)
		filling_color = "#FF69B4"

/obj/item/reagent_containers/food/snacks/donut/jelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	bonus_reagents = list("sugar" = 1, "vitamin" = 1)
	extra_reagent = "berryjuice"
	tastes = list("jelly" = 1, "donut" = 3)
	foodtype = JUNKFOOD | GRAIN | FRIED | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/donut/jelly/Initialize()
	. = ..()
	if(extra_reagent)
		reagents.add_reagent("[extra_reagent]", 3)
	if(prob(30))
		icon_state = "jdonut2"
		name = "frosted jelly Donut"
		reagents.add_reagent("sprinkles", 2)
		bonus_reagents = list("sprinkles" = 2, "sugar" = 1)
		filling_color = "#FF69B4"

/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	extra_reagent = "slimejelly"
	foodtype = JUNKFOOD | GRAIN | FRIED | TOXIC | SUGAR

/obj/item/reagent_containers/food/snacks/donut/jelly/cherryjelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	extra_reagent = "cherryjelly"
	foodtype = JUNKFOOD | GRAIN | FRIED | FRUIT

////////////////////////////////////////////MUFFINS////////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/muffin
	name = "muffin"
	desc = "A delicious and spongy little cake."
	icon_state = "muffin"
	bonus_reagents = list("vitamin" = 1)
	list_reagents = list("nutriment" = 6)
	filling_color = "#F4A460"
	tastes = list("muffin" = 1)
	foodtype = GRAIN | SUGAR

/obj/item/reagent_containers/food/snacks/muffin/berry
	name = "berry muffin"
	icon_state = "berrymuffin"
	desc = "A delicious and spongy little cake, with berries."
	tastes = list("muffin" = 3, "berry" = 1)
	foodtype = GRAIN | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/muffin/booberry
	name = "booberry muffin"
	icon_state = "berrymuffin"
	alpha = 125
	desc = "My stomach is a graveyard! No living being can quench my bloodthirst!"
	tastes = list("muffin" = 3, "spookiness" = 1)
	foodtype = GRAIN | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	bonus_reagents = list("vitamin" = 1)
	list_reagents = list("nutriment" = 5)
	filling_color = "#FFE4E1"
	tastes = list("custard" = 1)
	foodtype = GRAIN | MEAT | VEGETABLES

////////////////////////////////////////////WAFFLES////////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Mmm, waffles."
	icon_state = "waffles"
	trash = /obj/item/trash/waffles
	bonus_reagents = list("vitamin" = 1)
	list_reagents = list("nutriment" = 8, "vitamin" = 1)
	filling_color = "#D2691E"
	tastes = list("waffles" = 1)
	foodtype = GRAIN | SUGAR

/obj/item/reagent_containers/food/snacks/soylentgreen
	name = "\improper Soylent Green"
	desc = "Not made of people. Honest." //Totally people.
	icon_state = "soylent_green"
	trash = /obj/item/trash/waffles
	bonus_reagents = list("vitamin" = 1)
	list_reagents = list("nutriment" = 10, "vitamin" = 1)
	filling_color = "#9ACD32"
	tastes = list("waffles" = 7, "people" = 1)
	foodtype = GRAIN | GROSS | MEAT

/obj/item/reagent_containers/food/snacks/soylenviridians
	name = "\improper Soylent Virdians"
	desc = "Not made of people. Honest." //Actually honest for once.
	icon_state = "soylent_yellow"
	trash = /obj/item/trash/waffles
	bonus_reagents = list("vitamin" = 1)
	list_reagents = list("nutriment" = 10, "vitamin" = 1)
	filling_color = "#9ACD32"
	tastes = list("waffles" = 7, "the colour green" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/rofflewaffles
	name = "roffle waffles"
	desc = "Waffles from Roffle. Co."
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles
	bitesize = 4
	bonus_reagents = list("vitamin" = 2)
	list_reagents = list("nutriment" = 8, "mushroomhallucinogen" = 2, "vitamin" = 2)
	filling_color = "#00BFFF"
	tastes = list("waffle" = 1, "mushrooms" = 1)
	foodtype = GRAIN | VEGETABLES | TOXIC | SUGAR

////////////////////////////////////////////OTHER////////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/cookie
	name = "cookie"
	desc = "COOKIE!!!"
	icon_state = "COOKIE!!!"
	bitesize = 1
	bonus_reagents = list("nutriment" = 1)
	list_reagents = list("nutriment" = 1)
	filling_color = "#F0E68C"
	tastes = list("cookie" = 1)
	foodtype = GRAIN | SUGAR

/obj/item/reagent_containers/food/snacks/donkpocket
	name = "\improper Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	list_reagents = list("nutriment" = 4)
	cooked_type = /obj/item/reagent_containers/food/snacks/donkpocket/warm
	filling_color = "#CD853F"
	tastes = list("meat" = 2, "dough" = 2, "laziness" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/donkpocket/warm
	name = "warm Donk-pocket"
	desc = "The heated food of choice for the seasoned traitor."
	bonus_reagents = list("omnizine" = 3)
	list_reagents = list("nutriment" = 4, "omnizine" = 3)
	tastes = list("meat" = 2, "dough" = 2, "laziness" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/dankpocket
	name = "\improper Dank-pocket"
	desc = "The food of choice for the seasoned botanist."
	icon_state = "dankpocket"
	list_reagents = list("lipolicide" = 3, "space_drugs" = 3, "nutriment" = 4)
	filling_color = "#00FF00"
	tastes = list("meat" = 2, "dough" = 2)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/fortunecookie
	name = "fortune cookie"
	desc = "A true prophecy in each cookie!"
	icon_state = "fortune_cookie"
	bonus_reagents = list("nutriment" = 2)
	list_reagents = list("nutriment" = 3)
	filling_color = "#F4A460"
	tastes = list("cookie" = 1)
	foodtype = GRAIN | SUGAR

/obj/item/reagent_containers/food/snacks/poppypretzel
	name = "poppy pretzel"
	desc = "It's all twisted up!"
	icon_state = "poppypretzel"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 2)
	list_reagents = list("nutriment" = 5)
	filling_color = "#F0E68C"
	tastes = list("pretzel" = 1)
	foodtype = GRAIN | SUGAR

/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit
	name = "plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet, and well-minced dwarven wheat flour."
	icon_state = "phelmbiscuit"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 1)
	list_reagents = list("nutriment" = 5)
	filling_color = "#F0E68C"
	tastes = list("mushroom" = 1, "biscuit" = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit/Initialize()
	var/fey = prob(10)
	if(fey)
		name = "exceptional plump helmet biscuit"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump helmet biscuit!"
		bonus_reagents = list("omnizine" = 5, "nutriment" = 1, "vitamin" = 1)
	. = ..()
	if(fey)
		reagents.add_reagent("omnizine", 5)

/obj/item/reagent_containers/food/snacks/cracker
	name = "cracker"
	desc = "It's a salted cracker."
	icon_state = "cracker"
	bitesize = 1
	bonus_reagents = list("nutriment" = 1)
	list_reagents = list("nutriment" = 1)
	filling_color = "#F0E68C"
	tastes = list("cracker" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	desc = "Fresh footlong ready to go down on."
	icon_state = "hotdog"
	bitesize = 3
	bonus_reagents = list("nutriment" = 1, "vitamin" = 3)
	list_reagents = list("nutriment" = 6, "ketchup" = 3, "vitamin" = 3)
	filling_color = "#8B0000"
	tastes = list("bun" = 3, "meat" = 2)
	foodtype = GRAIN | MEAT | VEGETABLES

/obj/item/reagent_containers/food/snacks/meatbun
	name = "meat bun"
	desc = "Has the potential to not be Dog."
	icon_state = "meatbun"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 2)
	list_reagents = list("nutriment" = 6, "vitamin" = 2)
	filling_color = "#8B0000"
	tastes = list("bun" = 3, "meat" = 2)
	foodtype = GRAIN | MEAT | VEGETABLES

/obj/item/reagent_containers/food/snacks/khachapuri
	name = "khachapuri"
	desc = "Bread with egg and cheese?"
	icon_state = "khachapuri"
	list_reagents = list("nutriment" = 12, "vitamin" = 2)
	filling_color = "#FFFF4D"
	tastes = list("bread" = 1, "egg" = 1, "cheese" = 1)
	foodtype = GRAIN | MEAT | DAIRY


/obj/item/reagent_containers/food/snacks/sugarcookie
	name = "sugar cookie"
	desc = "Just like your little sister used to make."
	icon_state = "sugarcookie"
	bonus_reagents = list("nutriment" = 1, "sugar" = 3)
	list_reagents = list("nutriment" = 3, "sugar" = 3)
	filling_color = "#CD853F"
	tastes = list("sweetness" = 1)
	foodtype = GRAIN | JUNKFOOD | SUGAR

/obj/item/reagent_containers/food/snacks/chococornet
	name = "chocolate cornet"
	desc = "Which side's the head, the fat end or the thin end?"
	icon_state = "chococornet"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 1)
	list_reagents = list("nutriment" = 5, "vitamin" = 1)
	filling_color = "#FFE4C4"
	tastes = list("biscuit" = 3, "chocolate" = 1)
	foodtype = GRAIN | JUNKFOOD

/obj/item/reagent_containers/food/snacks/oatmealcookie
	name = "oatmeal cookie"
	desc = "The best of both cookie and oat."
	icon_state = "oatmealcookie"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 1)
	list_reagents = list("nutriment" = 5, "vitamin" = 1)
	filling_color = "#D2691E"
	tastes = list("cookie" = 2, "oat" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/raisincookie
	name = "raisin cookie"
	desc = "Why would you put raisins on a cookie?"
	icon_state = "raisincookie"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 1)
	list_reagents = list("nutriment" = 5, "vitamin" = 1)
	filling_color = "#F0E68C"
	tastes = list("cookie" = 1, "raisins" = 1)
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/cherrycupcake
	name = "cherry cupcake"
	desc = "A sweet cupcake with cherry bits."
	icon_state = "cherrycupcake"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 1)
	list_reagents = list("nutriment" = 5, "vitamin" = 1)
	filling_color = "#F0E68C"
	tastes = list("cake" = 3, "cherry" = 1)
	foodtype = GRAIN | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/bluecherrycupcake
	name = "blue cherry cupcake"
	desc = "Blue cherries inside a delicious cupcake."
	icon_state = "bluecherrycupcake"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 3)
	list_reagents = list("nutriment" = 5, "vitamin" = 1)
	filling_color = "#F0E68C"
	tastes = list("cake" = 3, "blue cherry" = 1)
	foodtype = GRAIN | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/honeybun
	name = "honey bun"
	desc = "A sticky pastry bun glazed with honey."
	icon_state = "honeybun"
	bonus_reagents = list("nutriment" = 1, "honey" = 1)
	list_reagents = list("nutriment" = 5, "honey" = 5)
	filling_color = "#F2CE91"
	tastes = list("pastry" = 1, "sweetness" = 1)
	foodtype = GRAIN

#define PANCAKE_MAX_STACK 10

/obj/item/reagent_containers/food/snacks/pancakes
	name = "pancake"
	desc = "A fluffy pancake. The softer, superior relative of the waffle."
	icon_state = "pancakes_1"
	item_state = "pancakes"
	bonus_reagents = list("vitamin" = 1)
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	filling_color = "#D2691E"
	tastes = list("pancakes" = 1)
	foodtype = GRAIN | SUGAR

/obj/item/reagent_containers/food/snacks/pancakes/blueberry
	name = "blueberry pancake"
	desc = "A fluffy and delicious blueberry pancake."
	icon_state = "bbpancakes_1"
	item_state = "bbpancakes"
	bonus_reagents = list("vitamin" = 2)
	list_reagents = list("nutriment" = 6, "vitamin" = 3)
	tastes = list("pancakes" = 1, "blueberries" = 1)

/obj/item/reagent_containers/food/snacks/pancakes/chocolatechip
	name = "chocolate chip pancake"
	desc = "A fluffy and delicious chocolate chip pancake."
	icon_state = "ccpancakes_1"
	item_state = "ccpancakes"
	bonus_reagents = list("vitamin" = 2)
	list_reagents = list("nutriment" = 6, "vitamin" = 3)
	tastes = list("pancakes" = 1, "chocolate" = 1)

/obj/item/reagent_containers/food/snacks/pancakes/Initialize()
	. = ..()
	update_icon()

/obj/item/reagent_containers/food/snacks/pancakes/update_icon()
	if(contents.len)
		name = "stack of pancakes"
	else
		name = initial(name)
	if(contents.len < LAZYLEN(our_overlays))
		cut_overlay(our_overlays[our_overlays.len])

/obj/item/reagent_containers/food/snacks/pancakes/examine(mob/user)
	var/ingredients_listed = ""
	var/pancakeCount = contents.len
	switch(pancakeCount)
		if(0)
			desc = initial(desc)
		if(1 to 2)
			desc = "A stack of fluffy pancakes."
		if(3 to 6)
			desc = "A fat stack of fluffy pancakes!"
		if(7 to 9)
			desc = "A grand tower of fluffy, delicious pancakes!"
		if(PANCAKE_MAX_STACK to INFINITY)
			desc = "A massive towering spire of fluffy, delicious pancakes. It looks like it could tumble over!"
	var/originalBites = bitecount
	if (pancakeCount)
		var/obj/item/reagent_containers/food/snacks/S = contents[pancakeCount]
		bitecount = S.bitecount
	..()
	if (pancakeCount)
		for(var/obj/item/reagent_containers/food/snacks/pancakes/ING in contents)
			ingredients_listed += "[ING.name], "
		to_chat(user, "It contains [contents.len?"[ingredients_listed]":"no ingredient, "]on top of a [initial(name)].")
	bitecount = originalBites

/obj/item/reagent_containers/food/snacks/pancakes/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/reagent_containers/food/snacks/pancakes/))
		var/obj/item/reagent_containers/food/snacks/pancakes/P = I
		if((contents.len >= PANCAKE_MAX_STACK) || ((P.contents.len + contents.len) > PANCAKE_MAX_STACK) || (reagents.total_volume >= volume))
			to_chat(user, "<span class='warning'>You can't add that many pancakes to [src]!</span>")
		else
			if(!user.transferItemToLoc(I, src))
				return
			to_chat(user, "<span class='notice'>You add the [I] to the [name].</span>")
			P.name = initial(P.name)
			contents += P
			update_overlays(P)
			if (P.contents.len)
				for(var/V in P.contents)
					P = V
					P.name = initial(P.name)
					contents += P
					update_overlays(P)
			P = I
			clearlist(P.contents)
		return
	else if(contents.len)
		var/obj/O = contents[contents.len]
		return O.attackby(I, user, params)
	..()

/obj/item/reagent_containers/food/snacks/pancakes/update_overlays(obj/item/reagent_containers/food/snacks/P)
	var/mutable_appearance/pancake = mutable_appearance(icon, "[P.item_state]_[rand(1,3)]")
	pancake.pixel_x = rand(-1,1)
	pancake.pixel_y = 3 * contents.len - 1
	add_overlay(pancake)
	update_icon()

/obj/item/reagent_containers/food/snacks/pancakes/attack(mob/M, mob/user, def_zone, stacked = TRUE)
	if(user.a_intent == INTENT_HARM || !contents.len || !stacked)
		return ..()
	var/obj/item/O = contents[contents.len]
	. = O.attack(M, user, def_zone, FALSE)
	update_icon()

#undef PANCAKE_MAX_STACK
