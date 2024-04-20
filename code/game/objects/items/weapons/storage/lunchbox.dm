// -----------------------------
//          LUNCH FOOD LISTS (GENERAL)
// -----------------------------
/obj/item/weapon/storage/lunchbox/plastic/nt/proc/pickfood()
	var/entree = pick(list(/obj/item/weapon/reagent_containers/food/snacks/sandwich,
								/obj/item/weapon/reagent_containers/food/snacks/grilledcheese,
								/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/cherry,
								/obj/item/weapon/reagent_containers/food/snacks/pbj,
                                /obj/item/weapon/reagent_containers/food/snacks/meatbreadslice,
								/obj/item/weapon/reagent_containers/food/snacks/monkeyburger,
                               	/obj/item/weapon/reagent_containers/food/snacks/fishburger,
								/obj/item/weapon/reagent_containers/food/snacks/chickenburger,
								/obj/item/weapon/reagent_containers/food/snacks/veggieburger,
								/obj/item/weapon/reagent_containers/food/snacks/hotdog,
                                /obj/item/weapon/reagent_containers/food/snacks/margheritaslice,
                                /obj/item/weapon/reagent_containers/food/snacks/meatpizzaslice,
                                /obj/item/weapon/reagent_containers/food/snacks/mushroompizzaslice,
                                /obj/item/weapon/reagent_containers/food/snacks/vegetablepizzaslice,
                                /obj/item/weapon/reagent_containers/food/snacks/hotchili,
								/obj/item/weapon/reagent_containers/food/snacks/meatballsoup,
								/obj/item/weapon/reagent_containers/food/snacks/vegetablesoup,
								/obj/item/weapon/reagent_containers/food/snacks/tomatosoup,
								/obj/item/weapon/reagent_containers/food/snacks/mushroomsoup,
								/obj/item/weapon/reagent_containers/food/snacks/beetsoup,
								/obj/item/weapon/reagent_containers/food/snacks/threebeanburrito,
								/obj/item/weapon/reagent_containers/food/snacks/enchiladas,
								/obj/item/weapon/reagent_containers/food/snacks/fishtacosupreme,
								/obj/item/weapon/reagent_containers/food/snacks/potatosalad,
								/obj/item/weapon/reagent_containers/food/snacks/herbsalad))

	var/obj/item/weapon/reagent_containers/food/snacks/E = new entree(src)
	if(E.is_empty())
		E.reagents.add_reagent(NUTRIMENT, 6)

	var/snack = pick(list(/obj/item/weapon/reagent_containers/food/snacks/fries/cone,
                                /obj/item/weapon/reagent_containers/food/snacks/sosjerky,
								/obj/item/weapon/reagent_containers/food/snacks/donkpocket,
								/obj/item/weapon/reagent_containers/food/snacks/breadslice,
								/obj/item/weapon/reagent_containers/food/snacks/creamcheesebreadslice,
                                /obj/item/weapon/reagent_containers/food/snacks/no_raisin,
                                /obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers,
                                /obj/item/weapon/reagent_containers/food/snacks/poppypretzel,
                                /obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit,
								/obj/item/weapon/reagent_containers/food/snacks/chips,
								/obj/item/weapon/reagent_containers/food/snacks/chips/cookable,
								/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/vinegar,
								/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/cheddar,
								/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/hot,
								/obj/item/weapon/reagent_containers/food/snacks/fruitsalad))

	var/obj/item/weapon/reagent_containers/food/snacks/S = new snack(src)
	if(S.is_empty())
		S.reagents.add_reagent(NUTRIMENT, 3)

	var/sweet = pick(list(/obj/item/weapon/reagent_containers/food/snacks/donut/normal,
								/obj/item/weapon/reagent_containers/food/snacks/donut/jelly,
								/obj/item/weapon/reagent_containers/food/snacks/candiedapple,
								/obj/item/weapon/reagent_containers/food/snacks/applecakeslice,
								/obj/item/weapon/reagent_containers/food/snacks/carrotcakeslice,
								/obj/item/weapon/reagent_containers/food/snacks/cheesecakeslice,
								/obj/item/weapon/reagent_containers/food/snacks/orangecakeslice,
								/obj/item/weapon/reagent_containers/food/snacks/limecakeslice,
								/obj/item/weapon/reagent_containers/food/snacks/lemoncakeslice,
								/obj/item/weapon/reagent_containers/food/snacks/chocolatecakeslice,
								/obj/item/weapon/reagent_containers/food/snacks/pumpkinpieslice,
								/obj/item/weapon/reagent_containers/food/snacks/cookie,
								/obj/item/weapon/reagent_containers/food/snacks/cookie/holiday,
								/obj/item/weapon/reagent_containers/food/snacks/fortunecookie,
								/obj/item/weapon/reagent_containers/food/snacks/sugarcookie,
								/obj/item/weapon/reagent_containers/food/snacks/caramelcookie,
								/obj/item/weapon/reagent_containers/food/snacks/bananabreadslice,
								/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
								/obj/item/weapon/reagent_containers/food/snacks/ricepudding))

	var/obj/item/weapon/reagent_containers/food/snacks/D = new sweet(src)
	if(D.is_empty())
		D.reagents.add_reagent(NUTRIMENT, 3)

	var/drink = pick(list(/obj/item/weapon/reagent_containers/food/drinks/coffee,
                                /obj/item/weapon/reagent_containers/food/drinks/latte,
                                /obj/item/weapon/reagent_containers/food/drinks/cappuccino,
                                /obj/item/weapon/reagent_containers/food/drinks/espresso,
                                /obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola,
                                /obj/item/weapon/reagent_containers/food/drinks/soda_cans/tonic,
                                /obj/item/weapon/reagent_containers/food/drinks/soda_cans/sodawater,
								/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lemon_lime,
								/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_up,
								/obj/item/weapon/reagent_containers/food/drinks/soda_cans/starkist,
								/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_mountain_wind,
								/obj/item/weapon/reagent_containers/food/drinks/soda_cans/dr_gibb,
								/obj/item/weapon/reagent_containers/food/drinks/beer,
								/obj/item/weapon/reagent_containers/food/drinks/plastic/water/small))

	new drink(src)

	var/condiment = pick(list(/obj/item/weapon/reagent_containers/food/condiment/small/hotsauce,
									/obj/item/weapon/reagent_containers/food/condiment/small/vinegar,
									/obj/item/weapon/reagent_containers/food/condiment/small/soysauce,
									/obj/item/weapon/reagent_containers/food/condiment/small/mayo,
									/obj/item/weapon/reagent_containers/food/condiment/small/ketchup))

	new condiment(src)

	new /obj/item/weapon/kitchen/utensil/spork/plastic(src)

// -----------------------------
//          LUNCH FOOD LISTS (SYNDICATE)
// -----------------------------
/obj/item/weapon/storage/lunchbox/metal/syndie/proc/pickfood_syndie()
	var/entree_syndie = pick(list(/obj/item/weapon/reagent_containers/food/snacks/toastedsandwich,
                                /obj/item/weapon/reagent_containers/food/snacks/notasandwich,
								/obj/item/weapon/reagent_containers/food/snacks/grilledcheese,
								/obj/item/weapon/reagent_containers/food/snacks/bigbiteburger,
								/obj/item/weapon/reagent_containers/food/snacks/bearburger,
								/obj/item/weapon/reagent_containers/food/snacks/avocadoburger,
                               	/obj/item/weapon/reagent_containers/food/snacks/fishburger,
								/obj/item/weapon/reagent_containers/food/snacks/chickenburger,
								/obj/item/weapon/reagent_containers/food/snacks/veggieburger,
								/obj/item/weapon/reagent_containers/food/snacks/cubancarp,
								/obj/item/weapon/reagent_containers/food/snacks/fishandchips,
								/obj/item/weapon/reagent_containers/food/snacks/turkeyslice,
								/obj/item/weapon/reagent_containers/food/snacks/pie/meatpie,
                                /obj/item/weapon/reagent_containers/food/snacks/spesslaw,
								/obj/item/weapon/reagent_containers/food/snacks/lasagna,
								/obj/item/weapon/reagent_containers/food/snacks/threebeanburrito,
								/obj/item/weapon/reagent_containers/food/snacks/enchiladas,
								/obj/item/weapon/reagent_containers/food/snacks/fishtacosupreme,
								/obj/item/weapon/reagent_containers/food/snacks/dionaroast,
								/obj/item/weapon/reagent_containers/food/snacks/salmonavocado,
								/obj/item/weapon/reagent_containers/food/snacks/aesirsalad,
								/obj/item/weapon/reagent_containers/food/snacks/validsalad,
								/obj/item/weapon/reagent_containers/food/snacks/chickensalad,
								/obj/item/weapon/reagent_containers/food/snacks/monkeykabob,
								/obj/item/weapon/reagent_containers/food/snacks/curry,
								/obj/item/weapon/reagent_containers/food/snacks/curry/vindaloo,
								/obj/item/weapon/reagent_containers/food/snacks/curry/crab,
								/obj/item/weapon/reagent_containers/food/snacks/curry/lemon))

	var/obj/item/weapon/reagent_containers/food/snacks/E = new entree_syndie(src)
	if(E.is_empty())
		E.reagents.add_reagent(NUTRIMENT, 9)

	var/snack_syndie = pick(list(/obj/item/weapon/reagent_containers/food/snacks/cheesyfries/punnet,
                                /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/nuclear,
								/obj/item/weapon/reagent_containers/food/snacks/donkpocket/self_heating,
								/obj/item/weapon/reagent_containers/food/snacks/meatbreadslice,
								/obj/item/weapon/reagent_containers/food/snacks/creamcheesebreadslice,
								/obj/item/weapon/reagent_containers/food/snacks/twobread,
                                /obj/item/weapon/reagent_containers/food/snacks/hotchili,
								/obj/item/weapon/reagent_containers/food/snacks/meatballsoup,
								/obj/item/weapon/reagent_containers/food/snacks/vegetablesoup,
								/obj/item/weapon/reagent_containers/food/snacks/tomatosoup,
								/obj/item/weapon/reagent_containers/food/snacks/mushroomsoup,
								/obj/item/weapon/reagent_containers/food/snacks/catfishgumbo,
								/obj/item/weapon/reagent_containers/food/snacks/beetsoup,
                                /obj/item/weapon/reagent_containers/food/snacks/pie/plump_pie,
								/obj/item/weapon/reagent_containers/food/snacks/fishfingers,
								/obj/item/weapon/reagent_containers/food/snacks/fruitsalad,
								/obj/item/weapon/reagent_containers/food/snacks/herbsalad,
								/obj/item/weapon/reagent_containers/food/snacks/potatosalad,
								/obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato,
								/obj/item/weapon/reagent_containers/food/snacks/baguette,
								/obj/item/weapon/reagent_containers/food/snacks/crab_sticks,
								/obj/item/weapon/reagent_containers/food/snacks/eggplantparm,
								/obj/item/weapon/reagent_containers/food/snacks/risotto))

	var/obj/item/weapon/reagent_containers/food/snacks/S = new snack_syndie(src)
	if(S.is_empty())
		S.reagents.add_reagent(NUTRIMENT, 5)

	var/sweet_syndie = pick(list(/obj/item/weapon/reagent_containers/food/snacks/cinnamonroll,
								/obj/item/weapon/reagent_containers/food/snacks/jectie,
								/obj/item/weapon/reagent_containers/food/snacks/flan,
								/obj/item/weapon/reagent_containers/food/snacks/honeyflan,
								/obj/item/weapon/reagent_containers/food/snacks/syndicake,
								/obj/item/weapon/reagent_containers/food/snacks/appletart,
								/obj/item/weapon/reagent_containers/food/snacks/eclair,
								/obj/item/weapon/reagent_containers/food/snacks/sweetroll,
								/obj/item/weapon/reagent_containers/food/snacks/cookiebowl,
								/obj/item/weapon/reagent_containers/food/snacks/chococherrycakeslice,
								/obj/item/weapon/reagent_containers/food/snacks/pie/clovercreampie,
								/obj/item/weapon/reagent_containers/food/snacks/pie/cherrypie,
								/obj/item/weapon/reagent_containers/food/snacks/pie/applepie,
								/obj/item/weapon/reagent_containers/food/snacks/pie,
								/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
								/obj/item/weapon/reagent_containers/food/snacks/muffin/berry,
								/obj/item/weapon/reagent_containers/food/snacks/sugarcookie,
								/obj/item/weapon/reagent_containers/food/snacks/caramelcookie,
								/obj/item/weapon/reagent_containers/food/snacks/cookie,
								/obj/item/weapon/reagent_containers/food/snacks/cookie/holiday,
								/obj/item/weapon/reagent_containers/food/snacks/ricepudding))

	var/obj/item/weapon/reagent_containers/food/snacks/D = new sweet_syndie(src)
	if(D.is_empty())
		D.reagents.add_reagent(NUTRIMENT, 5)

	var/drink_syndie = pick(list(/obj/item/weapon/reagent_containers/food/drinks/soda_cans/nuka,
								/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lifeline_white,
								/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lifeline_red,
								/obj/item/weapon/reagent_containers/food/drinks/soda_cans/roentgen_energy,
                                /obj/item/weapon/reagent_containers/food/drinks/soda_cans/sportdrink,
                                /obj/item/weapon/reagent_containers/food/drinks/soda_cans/gunka_cola,
                                /obj/item/weapon/reagent_containers/food/drinks/soda_cans/cannedcoffee,
								/obj/item/weapon/reagent_containers/food/drinks/plastic/water,
								/obj/item/weapon/reagent_containers/food/drinks/thermos/full,
								/obj/item/weapon/reagent_containers/food/drinks/soda_cans/strongebow))

	new drink_syndie(src)

	var/condiment_syndie = pick(list(/obj/item/weapon/reagent_containers/food/condiment/hotsauce,
									/obj/item/weapon/reagent_containers/food/condiment/coldsauce,
									/obj/item/weapon/reagent_containers/food/condiment/ketchup,
									/obj/item/weapon/reagent_containers/food/condiment/mustard,
									/obj/item/weapon/reagent_containers/food/condiment/relish,
									/obj/item/weapon/reagent_containers/food/condiment/honey,
									/obj/item/weapon/reagent_containers/food/condiment/saltshaker,
									/obj/item/weapon/reagent_containers/food/condiment/peppermill,
									/obj/item/weapon/reagent_containers/food/condiment/vinegar,
									/obj/item/weapon/reagent_containers/food/condiment/soysauce))

	new condiment_syndie(src)

	new /obj/item/weapon/kitchen/utensil/spork(src)

// -----------------------------
//          LUNCH FOOD LISTS (DISCOUNT)
// -----------------------------
/obj/item/weapon/storage/lunchbox/discount/proc/pickfood_discount()
	var/entree_discount = pick(list(/obj/item/weapon/reagent_containers/food/snacks/discountburrito,
								/obj/item/weapon/reagent_containers/food/snacks/discountburger,
								/obj/item/weapon/reagent_containers/food/snacks/pie/discount,
								/obj/item/weapon/reagent_containers/food/snacks/meat/animal/dan,
								/obj/item/weapon/reagent_containers/food/snacks/sausage/dan))

	new entree_discount(src)

	var/snack_discount = pick(list(/obj/item/weapon/reagent_containers/food/snacks/dangles,
                                /obj/item/weapon/reagent_containers/food/snacks/danitos,
								/obj/item/weapon/reagent_containers/food/drinks/discount_ramen,
								/obj/item/weapon/reagent_containers/food/snacks/meat/animal/dan))

	new snack_discount(src)

	var/sweet_discount = pick(list(/obj/item/weapon/reagent_containers/food/snacks/discountchocolate,
								/obj/item/weapon/reagent_containers/food/snacks/cheap_raisins))

	new sweet_discount(src)

	var/drink_discount = pick(list(/obj/item/weapon/reagent_containers/food/drinks/groans,
                                /obj/item/weapon/reagent_containers/food/drinks/filk,
                                /obj/item/weapon/reagent_containers/food/drinks/soda_cans/grifeo,
                                /obj/item/weapon/reagent_containers/food/drinks/soda_cans/mannsdrink,
                                /obj/item/weapon/reagent_containers/food/drinks/soda_cans/sportdrink))

	new drink_discount(src)

	new /obj/item/weapon/reagent_containers/food/condiment/small/discount(src)

	if(prob(50))
		new /obj/item/weapon/kitchen/utensil/spork/plastic(src) // You may or may not get a utensil when buying lunch from Dan

// -----------------------------
//          LUNCH FOOD LISTS (ZAM)
// -----------------------------
/obj/item/weapon/storage/lunchbox/metal/zam/proc/pickfood_zam()
	var/entree_zam = pick(list(/obj/item/weapon/reagent_containers/food/snacks/polypburger,
								/obj/item/weapon/reagent_containers/food/snacks/xenoburger,
								/obj/item/weapon/reagent_containers/food/snacks/blethernoodlesoup/wrapped,
								/obj/item/weapon/reagent_containers/food/snacks/cheesybroth,
								/obj/item/weapon/reagent_containers/food/snacks/swimmingcarp,
								/obj/item/weapon/reagent_containers/food/snacks/swimmingcarp_spicy,
								/obj/item/weapon/reagent_containers/food/snacks/greygreens,
								/obj/item/weapon/reagent_containers/food/snacks/stuffedpitcher,
								/obj/item/weapon/reagent_containers/food/snacks/nymphsperil,
								/obj/item/weapon/reagent_containers/food/snacks/dionaroast,
								/obj/item/weapon/reagent_containers/food/snacks/xenomeatbreadslice,
								/obj/item/weapon/reagent_containers/food/snacks/spidermeatbreadslice,
								/obj/item/weapon/reagent_containers/food/snacks/pie/xemeatpie,
								/obj/item/weapon/reagent_containers/food/snacks/spidereggsham))

	var/obj/item/weapon/reagent_containers/food/snacks/E = new entree_zam(src)
	if(E.is_empty())
		E.reagents.add_reagent(NUTRIMENT, 6)

	var/snack_zam = pick(list(/obj/item/weapon/reagent_containers/food/snacks/zam_spiderslider/wrapped,
                                /obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese/wrapped,
								/obj/item/weapon/reagent_containers/food/snacks/zamitos,
								/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/xeno))

	new snack_zam(src)

	var/sweet_zam = pick(list(/obj/item/weapon/reagent_containers/food/snacks/polyppudding,
								/obj/item/weapon/reagent_containers/food/snacks/zam_notraisins,
								/obj/item/weapon/reagent_containers/food/snacks/zambiscuit))

	new sweet_zam(src)

	var/drink_zam = pick(list(/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_sulphuricsplash,
                                /obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_formicfizz,
                                /obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_trustytea,
                                /obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_tannicthunder))

	new drink_zam(src)

	var/condiment_zam = pick(list(/obj/item/weapon/reagent_containers/food/condiment/small/zamspices,
                                /obj/item/weapon/reagent_containers/food/condiment/small/zammild,
                                /obj/item/weapon/reagent_containers/food/condiment/small/zamspicytoxin))

	new condiment_zam(src)

	new /obj/item/weapon/kitchen/utensil/spork/plastic/teflon(src)

// -----------------------------
//          LUNCH FOOD LISTS (TRADER)
// -----------------------------
/obj/item/weapon/storage/lunchbox/metal/trader/proc/pickfood_trader()
	var/entree_trader = pick(list(/obj/item/weapon/reagent_containers/food/snacks/hoboburger,
								/obj/item/weapon/reagent_containers/food/snacks/bacon,
								/obj/item/weapon/reagent_containers/food/snacks/zhulongcaofan,
								/obj/item/weapon/reagent_containers/food/snacks/pie/breadfruit,
								/obj/item/weapon/reagent_containers/food/snacks/porktenderloin,
								/obj/item/weapon/reagent_containers/food/snacks/pie/meatpie))

	new entree_trader(src)

	var/snack_trader = pick(list(/obj/item/weapon/reagent_containers/food/snacks/garlicbread,
                                /obj/item/weapon/reagent_containers/food/snacks/poachedaloe,
								/obj/item/weapon/reagent_containers/food/snacks/mushnslush,
								/obj/item/weapon/reagent_containers/food/snacks/vanishingstew,
								/obj/item/weapon/reagent_containers/food/snacks/risenshiny,
								/obj/item/weapon/reagent_containers/food/snacks/poutine))

	new snack_trader(src)

	var/sweet_trader = pick(list(/obj/item/weapon/reagent_containers/food/snacks/candiedwoodapple,
								/obj/item/weapon/reagent_containers/food/snacks/fortunecookie,
								/obj/item/weapon/reagent_containers/food/snacks/chococoin/wrapped))

	new sweet_trader(src)

	new /obj/item/weapon/reagent_containers/food/drinks/thermos/full(src)
	new /obj/item/weapon/reagent_containers/food/condiment/gravy(src)
	new /obj/item/weapon/kitchen/utensil/spork(src)

// -----------------------------
//          LUNCHBOXES
// -----------------------------

// Generic lunchbox
/obj/item/weapon/storage/lunchbox
	name = "lunchbox"
	icon = 'icons/obj/kitchen.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/toolbox_ihl.dmi', "right_hand" = 'icons/mob/in-hand/right/toolbox_ihr.dmi')
	storage_slots = 7; //the number of food items it can carry.
	fits_max_w_class = 2
	max_combined_w_class = 14
	w_class = W_CLASS_MEDIUM

	allow_quick_gather = TRUE
	allow_quick_empty = TRUE
	use_to_pickup = TRUE

	var/has_lunch = FALSE

/obj/item/weapon/storage/lunchbox/return_air()//prevents hot food from getting cold while in it.
	return

// -----------------------------
//          CARDBOARD LUNCHBOXES
// -----------------------------

// Discount Dan themed lunchbox
/obj/item/weapon/storage/lunchbox/discount
	name = "Discount lunchbox"
	desc = "A little cardboard lunchbox. This one has the Discount Dan logo printed on the side. It looks very flimsy, and has a musty smell even when empty."
	icon_state = "lunchbox_discount"
	item_state = "toolbox_purple"
	force = 1
	hitsound = 'sound/weapons/tap.ogg'
	attack_verb = list("taps", "smacks")
	throwforce = 1
	starting_materials = list(MAT_CARDBOARD = 3750)
	w_type = RECYK_MISC

/obj/item/weapon/storage/lunchbox/discount/pre_filled
	has_lunch = TRUE

/obj/item/weapon/storage/lunchbox/discount/New()
	..()
	if(has_lunch == TRUE)
		pickfood_discount()

// -----------------------------
//          PLASTIC LUNCHBOXES (From plain to subtypes)
// -----------------------------

// Plain lunchbox: Can be built from a plastic sheet
/obj/item/weapon/storage/lunchbox/plastic
	desc = "A little plastic lunchbox. This one has no decorations or logos."
	icon_state = "lunchbox_plastic"
	item_state = "toolbox_white"
	force = 2
	hitsound = 'sound/weapons/tap.ogg'
	attack_verb = list("taps", "smacks")
	throwforce = 2
	starting_materials = list(MAT_PLASTIC = 3750) // Exactly one sheet of plastic
	w_type = RECYK_PLASTIC

// Nanotrasen themed lunchbox (sprite from Bay)
/obj/item/weapon/storage/lunchbox/plastic/nt
	name = "Nanotrasen lunchbox"
	desc = "A little plastic lunchbox. This one has the Nanotrasen logo printed on the side."
	icon_state = "lunchbox_nt"
	item_state = "toolbox_lightblue"

/obj/item/weapon/storage/lunchbox/plastic/nt/New()
	..()
	if(has_lunch == TRUE)
		pickfood()

/obj/item/weapon/storage/lunchbox/plastic/nt/pre_filled
	has_lunch = TRUE

// Getmore themed lunchbox
/obj/item/weapon/storage/lunchbox/plastic/nt/getmore
	name = "Getmore lunchbox"
	desc = "A little plastic lunchbox. This one has the Getmore Chocolate Corp logo printed on the side."
	icon_state = "lunchbox_getmore"
	item_state = "toolbox_blue"

/obj/item/weapon/storage/lunchbox/plastic/nt/getmore/pre_filled
	has_lunch = TRUE

// Randomized collectable lunchboxes
/obj/item/weapon/storage/lunchbox/plastic/nt/random
	name = "Collectible lunchbox"
	desc = "A plastic lunchbox with a unique design!"
	icon_state = "lunchbox_random"

/obj/item/weapon/storage/lunchbox/plastic/nt/random/New()
	..()
	if(has_lunch == TRUE)
		pickfood()
	switch(rand(1,18))
		if(1)
			name = "Ian lunchbox"
			desc = "A little plastic lunchbox. This one has a portrait of Ian on the side."
			icon_state = "lunchbox_ian"
			item_state = "toolbox_orange"
		if(2)
			name = "Shard lunchbox"
			desc = "A little plastic lunchbox. This one has a supermatter shard on the side, and a red line across a hand reaching out to touch it."
			icon_state = "lunchbox_shard"
			item_state = "toolbox_lightblue2"
		if(3)
			name = "AI lunchbox"
			desc = "A little plastic lunchbox. This one has a design on the side depicting a station's AI."
			icon_state = "lunchbox_ai"
			item_state = "toolbox_grey"
		if(4)
			name = "Beepsky lunchbox"
			desc = "A little plastic lunchbox. This one has a picture of Beepsky on the side, and bright red letters spelling out 'LAW'."
			icon_state = "lunchbox_beepksky"
			item_state = "toolbox_red"
		if(5)
			name = "Carp lunchbox"
			desc = "A little plastic lunchbox. This one has a picture of a space carp on the side."
			icon_state = "lunchbox_carp"
			item_state = "toolbox_purple"
		if(6)
			name = "MoMMI lunchbox"
			desc = "A little plastic lunchbox. This one has a design depicting a MoMMI on the side."
			icon_state = "lunchbox_mommi"
			item_state = "toolbox_grey"
		if(7)
			name = "Durand lunchbox"
			desc = "A little plastic lunchbox. This one has a scene of a Durand swinging its fist depicted on the side."
			icon_state = "lunchbox_durand"
			item_state = "toolbox_orange"
		if(8)
			name = "Glubb lunchbox"
			desc = "A little plastic lunchbox. This one depicts a hand wearing an insulated glove on the side, with electrical currents deflecting off it."
			icon_state = "lunchbox_glubb"
			item_state = "toolbox_yellow"
		if(9)
			name = "Medbay lunchbox"
			desc = "A little plastic lunchbox. This one has a first aid cross and a picture of a cryo tube decorating the side."
			icon_state = "lunchbox_medbay"
			item_state = "toolbox_lightblue2"
		if(10)
			name = "Goliath lunchbox"
			desc = "A little plastic lunchbox. This one has a portrait of a goliath's many eyes decorating the side."
			icon_state = "lunchbox_goliath"
			item_state = "toolbox_brown"
		if(11)
			name = "Plasmaman lunchbox"
			desc = "A little plastic lunchbox. This one depicts a plasmaman's face on the side."
			icon_state = "lunchbox_plasmaman"
			item_state = "toolbox_grey"
		if(12)
			name = "Cuban lunchbox"
			desc = "A little plastic lunchbox. This one depicts a hat over a set of sunglasses on the side, with water in the background."
			icon_state = "lunchbox_cuban"
			item_state = "toolbox_yellow"
		if(13)
			name = "Jannie lunchbox"
			desc = "A little plastic lunchbox. This one has a picture of a wet floor sign and a pair of galoshes decorating the side."
			icon_state = "lunchbox_jannie"
			item_state = "toolbox_grey"
		if(14)
			name = "Pinup lunchbox"
			desc = "A little plastic lunchbox. This one has a picture of Amy decorating the side, the nymphomaniac urban legend of Nanotrasen space stations."
			icon_state = "lunchbox_pinup"
			item_state = "toolbox_lightblue"
		if(15)
			name = "Ablative lunchbox"
			desc = "A little plastic lunchbox. This one is has a decorative design similar to an ablative vest on the side."
			icon_state = "lunchbox_ablative"
			item_state = "toolbox_lightblue2"
		if(16)
			name = "Nuclear lunchbox"
			desc = "A little plastic lunchbox. This one has a design on the side that looks similar to a nuclear fission device."
			icon_state = "lunchbox_nuke"
			item_state = "toolbox_brown"
		if(17)
			name = "ERT lunchbox"
			desc = "A little plastic lunchbox. This one has a scene decorating the side that depicts four ERT members striking action poses."
			icon_state = "lunchbox_ert"
			item_state = "toolbox_lightblue"
		if(18)
			name = "Shuttle lunchbox"
			desc = "A little plastic lunchbox. This one is decorated to look like a little escape shuttle."
			icon_state = "lunchbox_shuttle"
			item_state = "toolbox_lightblue2"

/obj/item/weapon/storage/lunchbox/plastic/nt/random/bullet_act(var/obj/item/projectile/P) // Ablative lunchboxes protect lunch from lasers!
	if(icon_state == "lunchbox_ablative")
		if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam) || istype(P, /obj/item/projectile/forcebolt) || istype(P, /obj/item/projectile/change))
			visible_message("<span class='danger'>The [P.name] gets reflected by the [src]!</span>")

			if(!istype(P, /obj/item/projectile/beam)) //beam has its own rebound-call-logic
				P.reflected = 1
				P.rebound(src)

			return PROJECTILE_COLLISION_REBOUND // complete projectile permutation

	return (..(P))

/obj/item/weapon/storage/lunchbox/plastic/nt/random/pre_filled
	has_lunch = TRUE

// Honky lunchbox!
/obj/item/weapon/storage/lunchbox/plastic/clown
	name = "Clown lunchbox"
	desc = "A little plastic lunchbox. This one has a clown mask design decorating the side."
	icon_state = "lunchbox_clown"
	item_state = "toolbox_red2"
	attack_verb = list("HONKS")
	hitsound = 'sound/items/bikehorn.ogg'

/obj/item/weapon/storage/lunchbox/plastic/clown/Crossed(atom/movable/O) // Can very briefly slip people
	if(..())
		return 1
	if(iscarbon(O))
		var/mob/living/carbon/C = O
		C.Slip(2, 2, slipped_on = src)

// ...
/obj/item/weapon/storage/lunchbox/plastic/mime
	name = "Mime lunchbox"
	desc = "A little plastic lunchbox. This one has a mime mask design decorating the side."
	icon_state = "lunchbox_mime"
	item_state = "toolbox_black"
	hitsound = null // ...

// -----------------------------
//          METAL LUNCHBOXES (From plain to subtypes)
// -----------------------------

// Plain lunchbox: Can be built from a metal sheet
/obj/item/weapon/storage/lunchbox/metal
	desc = "A little metal lunchbox. This one has no decorations or logos."
	icon_state = "lunchbox_metal"
	item_state = "toolbox_grey"
	force = 5
	hitsound = list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
	attack_verb = list("batters", "bashes")
	throwforce = 3
	starting_materials = list(MAT_IRON = 3750) // Exactly one sheet of metal
	w_type = RECYK_METAL

// Syndicate themed lunchbox
/obj/item/weapon/storage/lunchbox/metal/syndie
	name = "Syndicate lunchbox"
	desc = "A little metal lunchbox. This one is bright red and looks suspiciously robust."
	icon_state = "lunchbox_syndie"
	item_state = "toolbox_red"
	force = 10
	throwforce = 6

/obj/item/weapon/storage/lunchbox/metal/syndie/pre_filled
	has_lunch = TRUE

/obj/item/weapon/storage/lunchbox/metal/syndie/New()
	..()
	if(has_lunch == TRUE)
		pickfood_syndie()

// Zam themed lunchbox
/obj/item/weapon/storage/lunchbox/metal/zam
	name = "Zam lunchbox"
	desc = "A little metal lunchbox. This one has the Zam mascot printed on the side."
	icon_state = "lunchbox_zam"
	item_state = "toolbox_lightgrey"

/obj/item/weapon/storage/lunchbox/metal/zam/dissolvable()
	return FALSE

/obj/item/weapon/storage/lunchbox/metal/zam/New()
	..()
	if(has_lunch == TRUE)
		pickfood_zam()

/obj/item/weapon/storage/lunchbox/metal/zam/pre_filled
	has_lunch = TRUE

// Trader lunchbox
/obj/item/weapon/storage/lunchbox/metal/trader
	name = "worn lunchbox"
	desc = "A well-used metal lunchbox. Whatever decorations or logos it might have had have long since faded away."
	icon_state = "lunchbox_trader"
	item_state = "toolbox_brown"

/obj/item/weapon/storage/lunchbox/metal/trader/New()
	..()
	if(has_lunch == TRUE)
		pickfood_trader()

/obj/item/weapon/storage/lunchbox/metal/trader/pre_filled
	has_lunch = TRUE
