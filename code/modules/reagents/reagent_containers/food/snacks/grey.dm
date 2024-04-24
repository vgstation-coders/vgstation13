//You have now entered the ayy food zone

/obj/item/weapon/zambiscuit_package
	name = "Zam Biscuit Package"
	desc = "A package of Zam biscuits, popular fare for hungry grey laborers. They go perfectly with a cup of Earl's Grey tea. "
	icon = 'icons/obj/food_container.dmi'
	icon_state = "zambiscuitbox"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/boxes_and_storage.dmi', "right_hand" = 'icons/mob/in-hand/right/boxes_and_storage.dmi')
	item_state = "zambiscuitbox"
	w_class = W_CLASS_SMALL

/obj/item/weapon/zambiscuit_package/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You start to tear open the biscuit package's seal.</span>")
	playsound(src, 'sound/items/poster_ripped.ogg', 100, 1)
	if(do_after(user, src, 2 SECONDS))
		qdel(src)
		var/obj/item/weapon/storage/fancy/zam_biscuits/new_zam = new /obj/item/weapon/storage/fancy/zam_biscuits
		user.put_in_hands(new_zam)

/obj/item/weapon/storage/fancy/zam_biscuits
	icon = 'icons/obj/food_container.dmi'
	icon_state = "zambiscuitbox3"
	icon_type = "zambiscuit"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/boxes_and_storage.dmi', "right_hand" = 'icons/mob/in-hand/right/boxes_and_storage.dmi')
	item_state = "zambiscuitbox"
	name = "Zam Biscuit Package"
	desc = "A package of Zam biscuits, popular fare for hungry grey laborers. They go perfectly with a cup of Earl's Grey tea. "
	storage_slots = 3
	can_only_hold = list("/obj/item/weapon/reagent_containers/food/snacks/zambiscuit","/obj/item/weapon/reagent_containers/food/snacks/zambiscuit_radical")

	w_class = W_CLASS_SMALL

/obj/item/weapon/storage/fancy/zam_biscuits/empty
	empty = 1
	icon_state = "zambiscuitbox0"

/obj/item/weapon/storage/fancy/zam_biscuits/New()
	..()
	if(empty)
		update_icon() //Make it look actually empty
		return
	for(var/i = 1; i <= storage_slots; i++)
		new /obj/item/weapon/reagent_containers/food/snacks/zambiscuit(src)
	return

/obj/item/weapon/reagent_containers/food/snacks/zamdinnerclassic
	name = "Classic Steak and Nettles"
	icon_state	= "box_tvdinnerclassic"
	desc = "An old Zam dinner box! This one still has the mascot on it. The instructions say to microwave before eating."
	food_flags = FOOD_MEAT
	w_class = W_CLASS_MEDIUM
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 7, SACID = 4)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/greytvdinnerclassic
	name = "Classic Steak and Nettles"
	desc = "The original Zam steak and nettles. They don't make it like they used to..."
	trash = /obj/item/trash/used_tray
	icon_state = "tvdinner_1"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 11, DOCTORSDELIGHT = 5, SACID = 4)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner1
	name = "Zam Steak and Nettles"
	desc = "The Zam research division still doesn't know where the steak's grill marks come from."
	trash = /obj/item/trash/used_tray
	icon_state = "tvdinner_1"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	wrapped = 0
	reagents_to_add = list(NUTRIMENT = 18, SACID = 8)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner1/wrapped
	name = "Zam Steak and Nettles"
	icon_state	= "box_tvdinner1"
	desc = "A packaged acidic ready-to-eat meal from the grey food company Zam Snax."
	w_class = W_CLASS_MEDIUM
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner1/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner1/proc/Unwrap(mob/user)
	desc = "The Zam research division still doesn't know where the steak's grill marks come from."
	food_flags = FOOD_MEAT
	trash = /obj/item/trash/used_tray
	icon_state = "tvdinner_1"
	to_chat(user, "<span class='notice'>You tear the packaging open and hear a nice hiss.") // Couldn't resist
	base_crumb_chance = 0
	wrapped = 0

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner2
	name = "Zam Mothership Stew"
	icon_state	= "tvdinner_2"
	desc = "This packaged version isn't quite as scrumptious as home cooking on the mothership, but it's palatable."
	trash = /obj/item/trash/used_tray
	base_crumb_chance = 0
	wrapped = 0
	reagents_to_add = list(NUTRIMENT = 15, SACID = 7)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner2/wrapped
	name = "Zam Mothership Stew"
	icon_state	= "box_tvdinner2"
	desc = "A packaged acidic ready-to-eat meal from the grey food company Zam Snax."
	w_class = W_CLASS_MEDIUM
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner2/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner2/proc/Unwrap(mob/user)
	desc = "This packaged version isn't quite as scrumptious as home cooking on the mothership, but it's palatable."
	trash = /obj/item/trash/used_tray
	icon_state = "tvdinner_2"
	to_chat(user, "<span class='notice'>You tear the packaging open and hear a little hiss.")
	base_crumb_chance = 0
	wrapped = 0

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner3
	name = "Zam Spider Slider Delight"
	icon_state	= "tvdinner_3"
	desc = "Despite extensive processing, there's definitely at least one spider hair still in it."
	trash = /obj/item/trash/used_tray
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	wrapped = 0
	reagents_to_add = list(NUTRIMENT = 12, SACID = 6)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner3/wrapped
	name = "Zam Spider Slider Delight"
	icon_state	= "box_tvdinner3"
	desc = "A packaged acidic ready-to-eat meal from the grey food company Zam Snax."
	w_class = W_CLASS_MEDIUM
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner3/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/greytvdinner3/proc/Unwrap(mob/user)
	desc = "Despite extensive processing, there's definitely at least one spider hair still in it."
	food_flags = FOOD_MEAT
	trash = /obj/item/trash/used_tray
	icon_state = "tvdinner_3"
	to_chat(user, "<span class='notice'>You tear the packaging open.") // No hiss...
	base_crumb_chance = 0
	wrapped = 0

/obj/item/weapon/reagent_containers/food/snacks/greygreens
	name = "Grey Greens"
	desc = "A dish beloved by greys since first contact, acidic vegetables seasoned with soy sauce."
	trash = /obj/item/trash/used_tray/type2
	icon_state = "greygreens"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6, SOYSAUCE = 10)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/stuffedpitcher
	name = "Stuffed Pitcher"
	desc = "A delicious grey alternative to a stuffed pepper. Very acidic."
	trash = /obj/item/trash/used_tray/type2
	icon_state = "stuffedpitcher"
	food_flags = FOOD_ANIMAL
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 8)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/nymphsperil
	name = "Nymph's Peril"
	desc = "A diona nymph steamed in sulphuric acid then stuffed with fried rice. Ruthlessly delicious!"
	trash = /obj/item/trash/used_tray/type2
	icon_state = "yahireatsbugs"
	food_flags = FOOD_MEAT
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10, SACID = 5)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/zambiscuit
	name = "Zam Biscuit"
	desc = "A sweet biscuit with an exquisite blend of chocolate and acid flavors. The recipe is a mothership secret."
	icon_state = "zambiscuit"
	food_flags = FOOD_SWEET | FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 3, HYRONALIN = 3, COCO = 2, SUGAR = 2, SACID = 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/zambiscuit_butter
	name = "Zam Buttery Biscuit"
	desc = "Butter and acid blend together to make a divine biscuit flavor. Administrator Zam's favorite!"
	icon_state = "zambiscuit_buttery"
	food_flags = FOOD_ANIMAL | FOOD_SWEET | FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 4, HYRONALIN = 3, LIQUIDBUTTER = 2, SUGAR = 2, SACID = 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/zambiscuit_radical
	name = "Zam Radical Biscuit"
	desc = "This Zam biscuit is oddly warm to the touch and glows faintly. It's probably not safe for consumption..." // Despite the warning, I'm sure someone will eat it.
	icon_state = "zambiscuit_radical"
	food_flags = FOOD_DIPPABLE
	reagents_to_add = list(NUTRIMENT = 3, MUTAGEN = 4, URANIUM = 3, SACID = 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/zam_notraisins
	name = "Zam NotRaisins"
	desc = "Dried blecher berries! A minimally processed bitter treat from the mothership's hydroponics labs." // Hopefully one day blecher berries will be a real thing in the code.
	trash = /obj/item/trash/zam_notraisins
	icon_state = "zam_notraisins"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 6)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese
	name = "Zam Moon Cheese"
	desc = "It gives off an artificial and bitter smell, but tastes much like a normal piece of sharp cheddar."
	food_flags = FOOD_ANIMAL
	icon_state = "zam_mooncheese"
	wrapped = 0
	bitesize = 3
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 3, MOONROCKS = 2)

/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese/wrapped
	name = "Zam Moon Cheese"
	desc = "Unfortunately the moon is not made of cheese, but this tasty snack is!"
	icon_state = "zam_mooncheese_wrapped"
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese/proc/Unwrap(mob/user)
	desc = "It gives off an artificial and bitter smell, but tastes much like a normal piece of sharp cheddar."
	food_flags = FOOD_ANIMAL
	icon_state = "zam_mooncheese"
	to_chat(user, "<span class='notice'>You peel the wrapping off the cheese.")
	wrapped = 0

/obj/item/weapon/reagent_containers/food/snacks/zam_spiderslider
	name = "Zam Spider Slider"
	desc = "A moderately processed acidic spider slider. Nutriment dense, despite its tiny size."
	food_flags = FOOD_MEAT
	icon_state = "zam_spiderslider"
	wrapped = 0
	bitesize = 3
	reagents_to_add = list(NUTRIMENT = 5, SACID = 3)

/obj/item/weapon/reagent_containers/food/snacks/zam_spiderslider/wrapped
	name = "Zam Spider Slider"
	desc = "A self-heating acidic slider for grey laborers on salaries too humble to afford the full meal."
	icon_state = "zam_spiderslider_wrapped"
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/zam_spiderslider/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
		spawn()
			new /obj/item/trash/zam_sliderwrapper(get_turf(src))
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/zam_spiderslider/proc/Unwrap(mob/user)
	desc = "A moderately processed acidic spider slider. Nutriment dense, despite its tiny size."
	food_flags = FOOD_MEAT
	icon_state = "zam_spiderslider"
	to_chat(user, "<span class='notice'>You tear the tab open and remove the slider from the packaging. Despite supposedly being self-heating, it's barely warm.")
	wrapped = 0

/obj/item/weapon/reagent_containers/food/snacks/mothershipbroth
	name = "Mothership Broth"
	desc = "A simple dish of mothership broth. Soothing, but not very nourishing. Could use more spice..."
	icon_state = "mothershipbroth"
	trash = /obj/item/trash/emptybowl
	food_flags = FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#B38B26"
	valid_utensils = UTENSILE_SPOON
	reagents_to_add = list(NUTRIMENT = 2, ZAMMILD = 5)
	bitesize = 2
	var/nutrimentbonus = 0

/obj/item/weapon/reagent_containers/food/snacks/mothershipbroth/New()
	if(prob(10))
		name = "Abducted Mothership Broth"
		desc = "An unidentified microwave object has abducted your broth and made it slightly more nutritious!"
		icon_state = "mothershipbroth_ufo"
		trash = /obj/item/trash/emptybowl_ufo
		reagents_to_add[NUTRIMENT] += 2+nutrimentbonus
	..()

/obj/item/weapon/reagent_containers/food/snacks/mothershipbroth/spicy
	name = "Mothership Spicy Broth"
	desc = "A simple dish of mothership broth. Soothing, but not very nourishing. At least it's spicy."
	icon_state = "mothershipbroth_spicy"
	trash = /obj/item/trash/emptybowl
	filling_color = "#D35A0D"
	reagents_to_add = list(NUTRIMENT = 3, ZAMSPICYTOXIN = 5)
	bitesize = 2
	nutrimentbonus = 1

/obj/item/weapon/reagent_containers/food/snacks/cheesybroth
	name = "Mothership Cheesy Broth"
	desc = "Traditional mothership broth with some cheese melted into it. Pairs well with a slice of gingi bread."
	icon_state = "cheesybroth"
	trash = /obj/item/trash/emptybowl
	food_flags = FOOD_ANIMAL | FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#FFEB3B"
	valid_utensils = UTENSILE_SPOON
	reagents_to_add = list(NUTRIMENT = 6, ZAMMILD = 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/swimmingcarp
	name = "Swimming Carp"
	desc = "A simple soup of tender carp meat cooked in mothership broth. Soothing and nourishing, but could use a little more spice."
	icon_state = "swimmingcarp"
	trash = /obj/item/trash/emptybowl
	food_flags = FOOD_MEAT | FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#B38B26"
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	reagents_to_add = list(NUTRIMENT = 8, ZAMMILD = 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/swimmingcarp_spicy
	name = "Spicy Swimming Carp"
	desc = "A soup of tender carp meat cooked in spicy mothership broth. Soothing, nourishing, and perfectly spicy."
	icon_state = "swimmingcarp_spicy"
	trash = /obj/item/trash/emptybowl
	food_flags = FOOD_MEAT | FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#D35A0D"
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	reagents_to_add = list(NUTRIMENT = 9, ZAMSPICYTOXIN = 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/blethernoodlesoup
	name = "Blether Noodle Soup"
	desc = "A hearty grey noodle soup. Great for teaching growing greylings new words! Not to be confused with human alphabet soup."
	icon_state = "blethernoodlesoup_open"
	trash = /obj/item/weapon/reagent_containers/glass/soupcan
	food_flags = FOOD_MEAT | FOOD_LIQUID
	crumb_icon = "dribbles"
	filling_color = "#FF9700"
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	bitesize = 3
	wrapped = FALSE
	reagents_to_add = list(NUTRIMENT = 6, SACID = 10, LOCUTOGEN = 5)

/obj/item/weapon/reagent_containers/food/snacks/blethernoodlesoup/wrapped
	icon_state = "blethernoodlesoup_closed"
	wrapped = TRUE

/obj/item/weapon/reagent_containers/food/snacks/blethernoodlesoup/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/blethernoodlesoup/proc/Unwrap(mob/user)
	icon_state = "blethernoodlesoup_open"
	wrapped = FALSE
	playsound(user, 'sound/effects/can_open1.ogg', 50, 1)
	if(user)
		to_chat(user, "<span class='notice'>You pull the tab on the soup can and pop the lid open. An inviting smell wafts out.")

/obj/item/weapon/reagent_containers/food/snacks/polyppudding
	name = "Polyp Pudding"
	desc = "A thick and sweet pudding, guaranteed to remind a mothership grey of their childhood whimsy."
	icon_state = "polyppudding"
	trash = /obj/item/trash/emptybowl
	food_flags = FOOD_LIQUID | FOOD_SWEET | FOOD_ANIMAL
	crumb_icon = "dribbles"
	filling_color = "#00FFFF"
	valid_utensils = UTENSILE_FORK|UTENSILE_SPOON
	reagents_to_add = list(NUTRIMENT = 8, POLYPGELATIN = 5)
	bitesize = 3

//You have now exited the ayy food zone. Thanks for visiting.
