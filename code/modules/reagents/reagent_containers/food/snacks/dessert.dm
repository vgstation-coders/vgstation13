
/obj/item/weapon/reagent_containers/food/snacks/candy
	name = "candy"
	desc = "Nougat love it or hate it."
	icon_state = "candy"
	trash = /obj/item/trash/candy
	food_flags = FOOD_SWEET
	filling_color = "#603000"
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 1, SUGAR = 3)

/obj/item/weapon/reagent_containers/food/snacks/candy/donor
	name = "Donor Candy"
	desc = "A little treat for blood donors."
	trash = /obj/item/trash/candy
	food_flags = FOOD_SWEET
	bitesize = 5
	reagents_to_add = list(NUTRIMENT = 10, SUGAR = 3)

/obj/item/weapon/reagent_containers/food/snacks/candy_corn
	name = "candy corn"
	desc = "It's a handful of candy corn. Can be stored in a detective's hat."
	icon_state = "candy_corn"
	base_crumb_chance = 0
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 4, SUGAR = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy_cane
	name = "candy cane"
	desc = "It's a classic striped candy cane."
	icon = 'icons/obj/food_seasonal.dmi'
	icon_state = "candycane"
	base_crumb_chance = 0
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 4, SUGAR = 2)

/obj/item/weapon/reagent_containers/food/snacks/cookie
	name = "cookie"
	desc = "COOKIE!!!"
	icon_state = "COOKIE!!!"
	base_crumb_chance = 20
	food_flags = FOOD_DIPPABLE
	bitesize = 1
	reagents_to_add = list(NUTRIMENT = 4)

/obj/item/weapon/reagent_containers/food/snacks/multispawner/holidaycookie
	name = "Seasonal Cookies"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/cookie/holiday
	reagents_to_add = list(NUTRIMENT = 3, SUGAR = 6)

/obj/item/weapon/reagent_containers/food/snacks/cookie/holiday
	name = "seasonal cookie"
	desc = "Charming holiday sugar cookies, just like Mom used to make."
	icon = 'icons/obj/food_seasonal.dmi'
	base_crumb_chance = 5
	food_flags = FOOD_SWEET | FOOD_DIPPABLE

/obj/item/weapon/reagent_containers/food/snacks/cookie/holiday/New()
	..()

	var/NM = time2text(world.realtime,"Month")
	var/cookiecutter

	switch(NM)
		if("February")
			cookiecutter = pick( list("heart","jamheart","frostingheartpink","frostingheartwhite","frostingheartred") )
		if("December")
			cookiecutter = pick( list("stocking","tree","snowman","mitt","angel","deer") )
		if("October")
			cookiecutter = pick( list("spider","cat","pumpkin","bat","ghost","hat","frank") )
		else
			cookiecutter = pick( list("spider","cat","pumpkin","bat","ghost","hat","frank","stocking","tree","snowman","mitt","angel","deer","heart","jamheart","frostingheartpink","frostingheartwhite","frostingheartred") )
	icon_state = "[cookiecutter]"

/obj/item/weapon/reagent_containers/food/snacks/multispawner/candyheart
	name = "Candy Hearts"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/candyheart
	reagents_to_add = list(NUTRIMENT = 6, SUGAR = 15)

/obj/item/weapon/reagent_containers/food/snacks/candyheart
	name = "candy heart"
	icon = 'icons/obj/food.dmi'

/obj/item/weapon/reagent_containers/food/snacks/candyheart/New()
	..()

	var/heartphrase = pick( list("SO FINE","B TRU","U ROCK","HELLO","SOUL MATE","ME + U","2 CUTE","SWEET LUV","IM URS","XOXO","B MINE","LUV BUG","I &lt;3 U","PDA ME","U LEAVE ME BREATHLESS") )

	var/heartcolor = pick( list("p","b","w","y","g") )

	icon_state = "conversationheart_[heartcolor]"
	desc = "Chalky sugar in the form of a heart.<br/>This one says, <span class='valentines'>\"[heartphrase]\"</span>."

/obj/item/weapon/reagent_containers/food/snacks/chocostrawberry
	name = "chocolate strawberry"
	desc = "A fresh strawberry dipped in melted chocolate."
	icon_state = "chocostrawberry"
	food_flags = FOOD_SWEET
	bitesize = 10
	reagents_to_add = list(NUTRIMENT = 5, SUGAR = 5, COCO = 5)

/obj/item/weapon/reagent_containers/food/snacks/gingerbread_man
	name = "gingerbread man"
	desc = "A holiday treat made with sugar and love."
	icon = 'icons/obj/food_seasonal.dmi'
	icon_state = "gingerbread"
	food_flags = FOOD_DIPPABLE
	base_crumb_chance = 20
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 3, SUGAR = 4)

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar
	name = "chocolate bar"
	desc = "Such, sweet, fattening food."
	icon_state = "chocolatebarunwrapped"
	wrapped = 0
	bitesize = 2
	food_flags = FOOD_SWEET
	base_crumb_chance = 5
	reagents_to_add = list(NUTRIMENT = 5, SUGAR = 5, COCO = 5)

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/proc/Unwrap(mob/user)
		icon_state = "chocolatebarunwrapped"
		desc = "It won't make you all sticky."
		to_chat(user, "<span class='notice'>You remove the foil.</span>")
		wrapped = 0


/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped
	desc = "It's wrapped in some foil."
	icon_state = "chocolatebar"
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped/valentine
	name = "Valentine's Day chocolate bar"
	desc = "Made (or bought) with love!"
	icon_state = "valentinebar"
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped/valentine/New()
	..()
	if(Holiday != VALENTINES_DAY)
		new /obj/item/weapon/reagent_containers/food/snacks/badrecipe(get_turf(src))
		qdel(src)
		return FALSE
	return TRUE

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped/valentine/syndicate
	desc = "Bought (or made) with love!"
	reagents_to_add = list(NUTRIMENT = 5, SUGAR = 5, COCO = 5, BICARODYNE = 3)

/obj/item/weapon/reagent_containers/food/snacks/chocolateegg
	name = "chocolate egg"
	desc = "Such, sweet, fattening food."
	icon_state = "chocolateegg"
	food_flags = FOOD_SWEET | FOOD_ANIMAL //eggs are used
	base_crumb_chance = 3
	bitesize = 2
	reagents_to_add = list(NUTRIMENT = 3, SUGAR = 2, COCO = 2)

/obj/item/weapon/reagent_containers/food/snacks/donut
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_DIPPABLE //eggs are used
	var/soggy = 0
	var/frosts = FALSE
	base_crumb_chance = 30

//Called in drinks.dm attackby

/obj/item/weapon/reagent_containers/food/snacks/donut/New()
	if(frosts && prob(30))
		frost()
	..()

/obj/item/weapon/reagent_containers/food/snacks/donut/proc/dip(var/obj/item/weapon/reagent_containers/R, mob/user)
	var/probability = 15*soggy
	to_chat(user, "<span class='notice'>You dip \the [src] into \the [R]</span>")
	if(prob(probability))
		to_chat(user, "<span class='danger'>\The [src] breaks off into \the [R]!</span>")
		src.reagents.trans_to(R,reagents.maximum_volume)
		qdel(src)
		return
	R.reagents.trans_to(src, rand(3,12))
	if(!soggy)
		name = "soggy [name]"
	soggy += 1

/obj/item/weapon/reagent_containers/food/snacks/donut/proc/frost()
	icon_state = "donut2"
	name = "frosted [initial(name)]"
	reagents_to_add[SPRINKLES] += 2

/obj/item/weapon/reagent_containers/food/snacks/donut/normal
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
	bitesize = 3
	reagents_to_add = list(NUTRIMENT = 3, SPRINKLES = 1)
	frosts = TRUE

/obj/item/weapon/reagent_containers/food/snacks/donut/chaos
	name = "Chaos Donut"
	desc = "Like life, it never quite tastes the same."
	icon_state = "donut1"
	reagents_to_add = list(NUTRIMENT = 2, SPRINKLES = 1)
	bitesize = 10
	frosts = TRUE

/obj/item/weapon/reagent_containers/food/snacks/donut/chaos/New()
	switch(rand(1,10))
		if(1)
			reagents_to_add = list(NUTRIMENT = 5, SPRINKLES = 3)
		if(2)
			reagents_to_add += list(CAPSAICIN = 3)
		if(3)
			reagents_to_add += list(FROSTOIL = 3)
		if(4)
			reagents_to_add = list(NUTRIMENT = 2, SPRINKLES = 6)
		if(5)
			reagents_to_add += list(PLASMA = 3)
		if(6)
			reagents_to_add += list(COCO = 3)
		if(7)
			reagents_to_add += list(SLIMEJELLY = 3)
		if(8)
			reagents_to_add += list(BANANA = 3)
		if(9)
			reagents_to_add += list(BERRYJUICE = 3)
		if(10)
			reagents_to_add += list(TRICORDRAZINE = 3)
	..()

/obj/item/weapon/reagent_containers/food/snacks/donut/jelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	bitesize = 5
	reagents_to_add = list(NUTRIMENT = 3, SPRINKLES = 1, BERRYJUICE = 5)
	frosts = TRUE

/obj/item/weapon/reagent_containers/food/snacks/donut/jelly/frost()
	..()
	icon_state = "jdonut2"

/obj/item/weapon/reagent_containers/food/snacks/donut/jelly/slime
	reagents_to_add = list(NUTRIMENT = 3, SPRINKLES = 1, SLIMEJELLY = 5)

/obj/item/weapon/reagent_containers/food/snacks/donut/jelly/cherry
	reagents_to_add = list(NUTRIMENT = 3, SPRINKLES = 1, CHERRYJELLY = 5)

/obj/item/weapon/reagent_containers/food/snacks/donutiron //not a subtype of donuts to avoid inheritance
	name = "ironman donut"
	icon_state = "irondonut"
	desc = "An ironman donut will keep you cool when things heat up."
	bitesize = 3
	reagents_to_add = list(NUTRIMENT = 6, LEPORAZINE = 6, IRON = 6)

/obj/item/weapon/reagent_containers/food/snacks/bagel
	name = "bagel"
	desc = "You can almost imagine the center is a black hole."
	icon_state = "bagel"
	food_flags = FOOD_ANIMAL | FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 3)

/obj/item/weapon/reagent_containers/food/snacks/muffin
	name = "muffin"
	desc = "A delicious and spongy little cake."
	icon_state = "muffin"
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE | FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/muffin/berry
	name = "berry muffin"
	icon_state = "berrymuffin"
	desc = "A delicious and spongy little cake, with berries."

/obj/item/weapon/reagent_containers/food/snacks/muffin/booberry
	name = "booberry muffin"
	icon_state = "booberrymuffin"
	desc = "My stomach is a graveyard! No living being can quench my bloodthirst!"

/obj/item/weapon/reagent_containers/food/snacks/muffin/dindumuffin
	name = "Dindu Muffin"
	desc = "This muffin didn't do anything."
	icon_state = "dindumuffins"

/obj/item/weapon/reagent_containers/food/snacks/oldempirebar
	name = "Old Empire Bar"
	icon_state = "old_empire_bar"
	desc = "You can see a villager from a long lost old empire on the wrap."
	trash = /obj/item/trash/oldempirebar
	base_crumb_chance = 30
	valid_utensils = 0
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/oldempirebar/set_reagents_to_add()
	reagents_to_add = list(NUTRIMENT = rand(2,6), ROGAN = 6)

/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie
	name = "space twinkie"
	icon_state = "space_twinkie"
	desc = "Guaranteed to survive longer than you will."
	valid_utensils = 0
	food_flags = FOOD_DIPPABLE
	reagents_to_add = list(SUGAR = 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff
	name = "Spacy Liberty Duff"
	desc = "Jello gelatin, from Alfred Hubbard's cookbook"
	icon_state = "spacylibertyduff"
	trash = /obj/item/trash/snack_bowl
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	random_filling_colors = list("#FFB2AE","#FFB2E4","#EDB2FB","#BBB2FB","#B2D3FB","#B2FFF8","#BDF6B7","#D9E37F","#FBD365")
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6, PSILOCYBIN = 6)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/amanitajelly
	name = "Amanita Jelly"
	desc = "Looks curiously toxic."
	icon_state = "amanitajelly"
	trash = /obj/item/trash/snack_bowl
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6, AMATOXIN = 6, PSILOCYBIN = 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/jectie
	name = "jectie"
	desc = "<font color='red'><B>The jectie has failed!</B></font color>"
	icon_state = "jectie_red"
	base_crumb_chance = 0
	reagents_to_add = list(REDTEA = 9, NUTRIMENT = 3)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/jectie/New()
	if(prob(40)) //approximate solo antag winrate
		icon_state = "jectie_green"
		desc = "<font color='green'><B>The jectie was successful!</B></font color>"
		reagents_to_add = list(GREENTEA = 18, NUTRIMENT = 6)
	..()

/obj/item/weapon/reagent_containers/food/snacks/candiedapple
	name = "Candied Apple"
	desc = "An apple coated in sugary sweetness."
	icon_state = "candiedapple"
	food_flags = FOOD_SWEET
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/caramelapple
	name = "Caramel Apple"
	desc = "An apple coated in caramel goodness."
	icon_state = "caramelapple"
	food_flags = FOOD_SWEET
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 3, CARAMEL = 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/appletart
	name = "golden apple streusel tart"
	desc = "A tasty dessert that won't make it through a metal detector."
	icon_state = "gappletart"
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8, GOLD = 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sugarcookie
	name = "sugar cookie"
	desc = "Just like your little sister used to make."
	icon_state = "sugarcookie"
	food_flags = FOOD_SWEET | FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 2, SUGAR = 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/caramelcookie
	name = "caramel cookie"
	desc = "Just like your little sister used to make."
	icon_state = "caramelcookie"
	food_flags = FOOD_SWEET | FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 2, CARAMEL = 5)
	bitesize = 2

////////////////////////////////ICE CREAM///////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/icecream
	name = "ice cream"
	desc = "Delicious ice cream."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_cone"
	food_flags = FOOD_SWEET
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 1, SUGAR = 1)
	bitesize = 1
	var/image/filling

/obj/item/weapon/reagent_containers/food/snacks/icecream/New()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/food/snacks/icecream/update_icon()
	extra_food_overlay.overlays -= filling
	filling = image('icons/obj/kitchen.dmi', src, "icecream_color")
	filling.icon += mix_color_from_reagents(reagents.reagent_list)
	extra_food_overlay.overlays += filling
	..()

/obj/item/weapon/reagent_containers/food/snacks/icecream/icecreamcone
	name = "ice cream cone"
	desc = "Delicious ice cream."
	icon_state = "icecream_cone"
	volume = 500
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 3, SUGAR = 7, ICE = list("volume" = 2,"temp" = T0C))
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/icecream/icecreamcup
	name = "chocolate ice cream cone"
	desc = "Delicious ice cream."
	icon_state = "icecream_cup"
	volume = 500
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 5, SUGAR = 9, ICE = list("volume" = 2,"temp" = T0C))
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/muffin/bluespace
	name = "Bluespace-berry Muffin"
	desc = "Just like a normal blueberry muffin, except with completely unnecessary floaty things!"
	icon_state = "bluespace"
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE

/obj/item/weapon/reagent_containers/food/snacks/yellowcake
	name = "Yellowcake"
	desc = "For Fat Men."
	icon_state = "yellowcake"
	food_flags = FOOD_SWEET | FOOD_ANIMAL //egg
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 40, RADIUM = 10, URANIUM = 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/yellowcupcake
	name = "Yellowcupcake"
	desc = "For Little Boys."
	icon_state = "yellowcupcake"
	food_flags = FOOD_SWEET | FOOD_ANIMAL
	reagents_to_add = list(NUTRIMENT = 15, RADIUM = 5, URANIUM = 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cookiebowl
	name = "Bowl of cookies"
	desc = "A bowl full of small cookies."
	icon_state = "cookiebowl"
	trash = /obj/item/trash/snack_bowl
	reagents_to_add = list(NUTRIMENT = 5, SUGAR = 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/higashikata
	name = "Higashikata Special"
	desc = "9 layer parfait, very expensive."
	icon_state = "higashikata"
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10, SUGAR = 10, ICE = list("volume" = 10,"temp" = T0C), WATERMELONJUICE = 5)
	bitesize = 3
	crumb_icon = "dribbles"
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/sundae
	name = "Sundae"
	desc = "A colorful ice cream treat."
	icon_state = "sundae"
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE //milk
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 5, SUGAR = 5, ICE = list("volume" = 5,"temp" = T0C))
	bitesize = 3
	crumb_icon = "dribbles"
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/avocadomilkshake
	name = "avocado milkshake"
	desc = "Strange, but good."
	icon_state = "avocadomilkshake"
	food_flags = FOOD_LIQUID | FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE //milk
	trash = /obj/item/weapon/reagent_containers/food/drinks/drinkingglass
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10, SUGAR = 5, ICE = list("volume" = 5,"temp" = T0C))
	bitesize = 4
	crumb_icon = "dribbles"
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/cinnamonroll
	name = "cinnamon roll"
	desc = "Sweet and spicy!"
	icon_state = "cinnamon_roll"
	food_flags = FOOD_SWEET | FOOD_ANIMAL | FOOD_LACTOSE
	plate_offset_y = 1
	reagents_to_add = list(NUTRIMENT = 3, CINNAMON = 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sundaeramen
	name = "Sundae Ramen"
	desc = "This is... sundae (?) flavored (?) ramen (?). You just don't know."
	icon_state = "sundaeramen"
	food_flags = FOOD_SWEET
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10, DISCOUNT = 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sweetsundaeramen
	name = "Sweet Sundae Ramen"
	desc = "A delicious ramen recipe that can soothe the soul of a savage spaceman."
	icon_state = "sweetsundaeramen"
	food_flags = FOOD_SWEET | FOOD_ANIMAL //uses puddi in recipe
	base_crumb_chance = 0
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/sweetsundaeramen/set_reagents_to_add()
	desc = initial(desc)
	reagents.clear_reagents()
	while(reagents.total_volume<70)
		switch(rand(1,10))
			if(1)
				desc += " It has peppermint flavoring! But just a few drops."
				reagents.add_reagent(ZOMBIEPOWDER, 10)
			if(2)
				desc += " This may not be everyone's cup of tea, but it's great, I promise."
				reagents.add_reagent(OXYCODONE, 10)
			if(3)
				desc += " This has the cook's favorite ingredient -- and a lot of it!"
				reagents.add_reagent(MINDBREAKER, 10)
			if(4)
				desc += " It has TONS of flavor!"
				reagents.add_reagent(MINTTOXIN, 10)
			if(5)
				desc += " The recipe for this thing got lost somewhere..."
				reagents.add_reagent(NUTRIMENT, 10)
			if(6)
				desc += " It has extra sweetness and a little bit of crumble!"
				reagents.add_reagent(TRICORDRAZINE, 10)
			if(7)
				desc += " It may be thick, but the noodles slip around easily."
				reagents.add_reagent(NUTRIMENT, 10)
			if(8)
				desc += " It has a nice crunch!"
				reagents.add_reagent(NUTRIMENT, 10)
			if(9)
				desc += " Yummy, but with all the sweets, your chest starts to hurt."
				reagents.add_reagent(NUTRIMENT, 10)
			if(10)
				desc += " Just a dollop of garnishes."
				reagents.add_reagent(NUTRIMENT, 10)

/obj/item/weapon/reagent_containers/food/snacks/chocofrog
	name = "chocolate frog"
	desc = "An exotic snack originating from the Space Wizard Federation. Very slippery!"
	icon = 'icons/obj/wiz_cards.dmi'
	icon_state = "frog"
	flags = PROXMOVE
	food_flags = FOOD_SWEET
	base_crumb_chance = 0
	var/jump_cd
	reagents_to_add = list(NUTRIMENT = 2, HYPERZINE = 1)

/obj/item/weapon/reagent_containers/food/snacks/chocofrog/HasProximity(atom/movable/AM as mob|obj)
	if(!jump_cd && isliving(AM))
		jump()
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/chocofrog/proc/jump()
	if(!istype(src.loc,/turf))
		return
	jump_cd=1
	spawn(50)
		jump_cd=0

	var/list/escape_paths=list()

	for(var/turf/T in view(7,src))
		escape_paths |= T

	var/turf/T = pick(escape_paths)
	src.throw_at(T, 10, 2)
	return 1

/obj/item/weapon/reagent_containers/food/snacks/chocofrog/pickup(mob/living/user as mob)
	var/mob/living/carbon/human/H = user
	if(!H)
		return 1

	spawn(0)
		if((clumsy_check(H)) || prob(25))
			if(H.drop_item())
				user.visible_message("<span class='warning'>[src] escapes from [H]'s hands!</span>","<span class='warning'>[src] escapes from your grasp!</span>")

				jump()
	return 1

/obj/item/weapon/reagent_containers/food/snacks/sweet
	name = "\improper Sweet"
	desc = "Comes in many different and unique flavours! One of the flagship products of the Getmore Chocolate Corp. Not suitable for children aged 0-3. Do not consume around open flames or expose to radiation. Flavors may not match the description. Expiration date: 2921."
	food_flags = FOOD_SWEET
	base_crumb_chance = 0
	icon = 'icons/obj/candymachine.dmi'
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/sweet/New()
	if(!islist(reagents_to_add))
		reagents_to_add = list()
	var/list/possible_reagents=list(NUTRIMENT=5, SUGAR=10, CORNOIL=5, BANANA=15, LIQUIDBUTTER=5, NUTRIMENT=10, CARAMEL=10, LEMONJUICE=10, APPLEJUICE=10, WATERMELONJUICE=10, GRAPEJUICE=10, ORANGEJUICE=10, TOMATOJUICE=10, LIMEJUICE=10, CARROTJUICE=10, BERRYJUICE=10, GGRAPEJUICE=10, POTATO=10, PLUMPHJUICE=10, COCO=10, SPRINKLES=10, NUTRIMENT=20)
	var/list/flavors = list("\improper strawberry","\improper lime","\improper blueberry","\improper banana","\improper grape","\improper lemonade","\improper bubblegum","\improper raspberry","\improper orange","\improper liquorice","\improper apple","\improper cranberry")
	var/reagent=pick(possible_reagents)
	reagents_to_add[reagent] = possible_reagents[reagent]
	..()
	var/variety = rand(1,flavors.len) //MORE SWEETS MAYBE IF YOU SPRITE IT
	icon_state = "sweet[variety]"
	name = "[flavors[variety]] sweet"

/obj/item/weapon/reagent_containers/food/snacks/sweet/strange
	desc = "Something about this sweet doesn't seem right."

/obj/item/weapon/reagent_containers/food/snacks/sweet/strange/New()
	if(!islist(reagents_to_add))
		reagents_to_add = list()
	var/list/possible_reagents=list(ZOMBIEPOWDER=5, MINDBREAKER=5, PACID=5, HYPERZINE=5, CHLORALHYDRATE=5, TRICORDRAZINE=5, DOCTORSDELIGHT=5, MUTATIONTOXIN=5, MERCURY=5, ANTI_TOXIN=5, SPACE_DRUGS=5, HOLYWATER=5,  RYETALYN=5, CRYPTOBIOLIN=5, DEXALINP=5, HAMSERUM=1,
	LEXORIN=5, GRAVY=5, DETCOFFEE=5, AMUTATIONTOXIN=5, GYRO=5, SILENCER= 5, URANIUM=5, WATER=5, DIABEETUSOL =5, SACID=5, LITHIUM=5, CHILLWAX=5, OXYCODONE=5, VOMIT=5, BLEACH=5, HEARTBREAKER=5, NANITES=5, CORNOIL=5, NOVAFLOUR=5, DEGENERATECALCIUM = 5, COLORFUL_REAGENT = 5, LIQUIDBUTTER = 5)
	var/reagent=pick(possible_reagents)
	reagents_to_add[reagent] = possible_reagents[reagent]
	..()

/obj/item/weapon/reagent_containers/food/snacks/lollipop
	name = "lollipop"
	desc = "Suck on this!"
	icon_state = "lollipop_stick"
	item_state = "lollipop_stick"
	food_flags = FOOD_SWEET
	icon = 'icons/obj/candymachine.dmi'
	bitesize = 5
	slot_flags = SLOT_MASK //No, really, suck on this.
	goes_in_mouth = TRUE
	attack_verb = list("taps", "pokes")
	eatverb = "crunch"
	valid_utensils = 0
	trash = /obj/item/trash/lollipopstick
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	var/candyness = 161 //how long this thing will last
	reagents_to_add = list(NUTRIMENT=2, SUGAR=8)
	volume = 20 //not a lotta room for poison
	base_crumb_chance = 0

/obj/item/weapon/reagent_containers/food/snacks/lollipop/New()
	..()
	eatverb = pick("bite","crunch","chomp")
	var/list/random_color_list = list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700")
	var/image/colorpop = image('icons/obj/candymachine.dmi', icon_state = "lollipop_head")
	colorpop.color = pick(random_color_list)
	extra_food_overlay.overlays += colorpop
	overlays += colorpop
	filling_color = colorpop.color

/obj/item/weapon/reagent_containers/food/snacks/lollipop/consume()
	..()
	candyness -= bitesize*10 //taking a bite out reduces how long it'll last

/obj/item/weapon/reagent_containers/food/snacks/lollipop/proc/updateconsuming(var/consuming)
	if(consuming)
		processing_objects.Add(src)
	else
		processing_objects.Remove(src)

/obj/item/weapon/reagent_containers/food/snacks/lollipop/process()
	var/mob/living/carbon/human/H = get_holder_of_type(src,/mob/living/carbon/human)
	if(!H) //we ended up outside our human somehow
		updateconsuming(FALSE)
		return
	if(H.isDead()) //human isn't really consuming it
		return
	if(H.is_wearing_item(src,slot_wear_mask))
		candyness--
	if(candyness <= 0)
		to_chat(H, "<span class='notice'>You finish \the [src].</span>")
		var/atom/new_stick = new /obj/item/trash/lollipopstick(loc)
		transfer_fingerprints_to(new_stick)
		qdel(src)
		H.equip_to_slot(new_stick, slot_wear_mask, 1)
	else
		if(candyness%10 == 0) //every 10 ticks, ~15 times
			reagents.trans_to(H, 1, log_transfer = FALSE, whodunnit = null)
		if(candyness%50 == 0) //every 50 ticks, so ~3 times
			bitecount++ //we're arguably eating it

/obj/item/weapon/reagent_containers/food/snacks/lollipop/equipped(mob/living/carbon/human/H, equipped_slot)
	if(!H.isDead())
		updateconsuming(equipped_slot == slot_wear_mask)

/obj/item/weapon/reagent_containers/food/snacks/lollipop/medipop
	name = "medipop"
	reagents_to_add = list(NUTRIMENT=2, SUGAR=8, TRICORDRAZINE=10)

/obj/item/weapon/reagent_containers/food/snacks/lollipop/lollicheap
	name = "cheap medipop"
	reagents_to_add = list(NUTRIMENT=2, SUGAR=8, PICCOLYN=1, TRICORDRAZINE = 1)

/obj/item/weapon/reagent_containers/food/snacks/chococoin
	name = "\improper Choco-Coin"
	desc = "A thin wafer of milky, chocolatey, melt-in-your-mouth goodness. That alone is already worth a hoard."
	food_flags = FOOD_SWEET
	icon_state = "chococoin_unwrapped"
	bitesize = 4
	reagents_to_add = list(NUTRIMENT = 2, SUGAR = 2, COCO = 3)

/obj/item/weapon/reagent_containers/food/snacks/chococoin/wrapped
	desc = "Still covered in golden foil wrapper."
	icon_state = "chococoin_wrapped"
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/chococoin/New()
	..()
	add_component(/datum/component/coinflip)

/obj/item/weapon/reagent_containers/food/snacks/chococoin/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/chococoin/proc/Unwrap(mob/user)
	icon_state = "chococoin_unwrapped"
	desc = "A thin wafer of milky, chocolatey, melt-in-your-mouth goodness. That alone is already worth a hoard."
	to_chat(user, "<span class='notice'>You remove the golden foil from \the [src].</span>")
	wrapped = 0

/obj/item/weapon/reagent_containers/food/snacks/chococoin/is_screwdriver(var/mob/user)
	return user.a_intent == I_HURT

/obj/item/trash/lollipopstick
	name = "lollipop stick"
	desc = "A small plastic stick."
	icon = 'icons/obj/candymachine.dmi'
	icon_state = "lollipop_stick"
	w_class = W_CLASS_TINY
	slot_flags = SLOT_MASK
	goes_in_mouth = TRUE
	throwforce = 1
	w_type = RECYK_PLASTIC
	starting_materials = list(MAT_PLASTIC = 100)
	species_fit = list(INSECT_SHAPED)

/obj/item/weapon/reagent_containers/food/snacks/eclair
	name = "\improper eclair"
	desc = "Plus doux que ses lèvres."
	icon_state = "eclair"
	bitesize = 5
	reagents_to_add = list(NUTRIMENT = 3, CREAM = 2)

/obj/item/weapon/reagent_containers/food/snacks/eclair/big
	name = "massive eclair"
	desc = "Plus fort que ses hanches."
	icon_state = "big_eclair"
	bitesize = 30
	w_class = 5
	reagents_to_add = list(NUTRIMENT = 27, CREAM = 18)

/obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje
	name = "IJzerkoekje"
	desc = "Bevat geen ijzer."
	icon_state = "ijzerkoekje"
	food_flags = FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 5, IRON = 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/multispawner/ijzerkoekjes
	name = "ijzerkoekjes"
	child_type = /obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje
	child_volume = 10
	reagents_to_add = list(NUTRIMENT = 30, IRON = 30) //spawns 6

/obj/item/weapon/reagent_containers/food/snacks/gelatin
	name = "gelatin"
	desc = "Made from real teeth!"
	icon_state = "gelatin"
	bitesize = 1
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 1, WATER = 9)

/obj/item/weapon/reagent_containers/food/snacks/yogurt
	name = "yogurt"
	desc = "Who knew bacteria could be so helpful?"
	icon_state = "yoghurt"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2, SUGAR = 2, MILK = 2)
	crumb_icon = "dribbles"
	valid_utensils = UTENSILE_SPOON

/obj/item/weapon/reagent_containers/food/snacks/pannacotta
	name = "panna cotta"
	desc = "Among the most fashionable of fine desserts. A dish fit for a captain."
	icon_state = "pannacotta"
	bitesize = 2
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10, OXYCODONE = 2)

/obj/item/weapon/reagent_containers/food/snacks/hauntedjam
	name = "haunted jam"
	desc = "I woke up one morning to find that the entire city had been covered in a three-foot layer of man-eating jam."
	icon_state = "ghostjam"
	bitesize = 2
	base_crumb_chance = 0
	filling_color = "#D60000"
	reagents_to_add = list(HELL_RAMEN = 8) //This should be enough to at least seriously wound, if not kill, someone.

/obj/item/weapon/reagent_containers/food/snacks/hauntedjam/spook(mob/dead/observer/O)
	if(!..()) //Check that they can spook
		return
	visible_message("<span class='warning'>\The [src] rattles maliciously!</span>")
	if(loc.Adjacent(get_turf(O))) //Two reasons. First, prevent distance spooking. Second, don't move through border objects (windows)
		Move(get_turf(O))

/obj/item/weapon/reagent_containers/food/snacks/croissant
	name = "croissant"
	desc = "True French cuisine."
	icon_state = "croissant"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE | FOOD_DIPPABLE
	base_crumb_chance = 40 // Croissants are literal crumb-making machines
	reagents_to_add = list(NUTRIMENT = 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mapleleaf
	name = "maple leaf"
	desc = "A large maple leaf."
	icon_state = "mapleleaf"
	base_crumb_chance = 0
	reagents_to_add = list(MAPLESYRUP = 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candiedpear
	name = "candied pear"
	desc = "A pear covered with caramel. Quite sugary."
	icon_state = "candiedpear"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/PAIcookie
	name = "cookie"
	desc = "Oh god, it's self-replicating!"
	icon = 'icons/obj/food2.dmi'
	food_flags = FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 5)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/PAIcookie/New()
	..()
	icon_state = "paicookie[pick(1,2,3)]"

/obj/item/weapon/reagent_containers/food/snacks/mint
	name = "mint"
	desc = "It is only wafer thin."
	icon_state = "mint"
	base_crumb_chance = 0
	var/safeforfat = FALSE
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mint/set_reagents_to_add()
	if(!safeforfat)
		reagents_to_add = list(MINTTOXIN = 1)
	else
		reagents_to_add = list(MINTESSENCE = 2)

//the syndie version for muh tators
/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint
	name = "mint candy"

/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/nano
	desc = "It's not just a mint!"
	icon_state = "nanomint"

/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/syndie
	desc = "Made with care, love, and the blood of Nanotrasen executives kept in eternal torment."
	icon_state = "syndiemint"

/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/discount
	desc = "Yeah, I wouldn't eat these if I were yo- Wait, you're still recording?"
	icon_state = "discountmint"

/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/homemade
	desc = "Made with love with the finest maintenance gunk I could find, trust me. I promise there's only trace amounts of bleach."
	icon_state = "homemademint"

//The candy version for the vendors
/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/nano/safe
	safeforfat = TRUE

/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/syndie/safe
	safeforfat = TRUE

/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/discount/safe
	safeforfat = TRUE

/obj/item/weapon/reagent_containers/food/snacks/mint/syndiemint/homemade/safe
	safeforfat = TRUE
