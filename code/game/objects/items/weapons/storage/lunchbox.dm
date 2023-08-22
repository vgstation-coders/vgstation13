// -----------------------------
//          LUNCH FOOD LISTS (GENERAL)
// -----------------------------
/obj/item/weapon/storage/lunchbox/nt/proc/pickfood()
	var/entree = pick(list(/obj/item/weapon/reagent_containers/food/snacks/sandwich,
								/obj/item/weapon/reagent_containers/food/snacks/grilledcheese,
								/obj/item/weapon/reagent_containers/food/snacks/jellysandwich,
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

	new entree(src)

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

	new snack(src)

	var/sweet = pick(list(/obj/item/weapon/reagent_containers/food/snacks/donut,
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

	new sweet(src)

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
/obj/item/weapon/storage/lunchbox/syndie/proc/pickfood_syndie()
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

	new entree_syndie(src)

	var/snack_syndie = pick(list(/obj/item/weapon/reagent_containers/food/snacks/cheesyfries/punnet,
                                /obj/item/weapon/reagent_containers/food/snacks/chips/cookable/nuclear,
								/obj/item/weapon/reagent_containers/food/snacks/donkpocket,
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

	new snack_syndie(src)

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

	new sweet_syndie(src)

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
/obj/item/weapon/storage/lunchbox/zam/proc/pickfood_zam()
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

	new entree_zam(src)

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
/obj/item/weapon/storage/lunchbox/trader/proc/pickfood_trader()
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

	new sweet_trader_trader(src)

	new /obj/item/weapon/reagent_containers/food/drinks/thermos/full(src)
	new /obj/item/weapon/reagent_containers/food/condiment/gravy(src)
	new /obj/item/weapon/kitchen/utensil/spork(src)

// -----------------------------
//          LUNCHBOXES
// -----------------------------

// Generic lunchbox: Can be built from a metal sheet
/obj/item/weapon/storage/lunchbox
	name = "lunchbox"
	desc = "A little metal lunchbox. This one has no decorations or logos."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "lunchbox_plain"
	item_state = "toolbox_grey"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/toolbox_ihl.dmi', "right_hand" = 'icons/mob/in-hand/right/toolbox_ihr.dmi')
	storage_slots = 7; //the number of food items it can carry.
	fits_max_w_class = 2
	max_combined_w_class = 14
	w_class = W_CLASS_MEDIUM
	siemens_coefficient = 1
	force = 5
	hitsound = list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
	attack_verb = list("batters", "bashes")
	throwforce = 3
	starting_materials = list(MAT_IRON = 3750) // Exactly one sheet of metal
	w_type = RECYK_METAL
	can_only_hold = list("/obj/item/weapon/reagent_containers/food/snacks","/obj/item/weapon/reagent_containers/food/drinks","/obj/item/weapon/reagent_containers/food/condiment","/obj/item/weapon/kitchen/utensil","/obj/item/voucher")

	allow_quick_gather = TRUE
	allow_quick_empty = TRUE
	use_to_pickup = TRUE

	var/has_lunch = FALSE

// Nanotrasen themed lunchbox (sprite from Bay)
/obj/item/weapon/storage/lunchbox/nt
	name = "Nanotrasen lunchbox"
	desc = "A little metal lunchbox. This one has the Nanotrasen logo printed on the side."
	icon_state = "lunchbox_nt"
	item_state = "toolbox_lightblue"

/obj/item/weapon/storage/lunchbox/nt/New()
	..()
	if(has_lunch == TRUE)
		pickfood()

/obj/item/weapon/storage/lunchbox/nt/pre_filled
	has_lunch = TRUE

// Syndicate themed lunchbox
/obj/item/weapon/storage/lunchbox/syndie
	name = "Syndicate lunchbox"
	desc = "A little metal lunchbox. This one is bright red and looks suspiciously robust."
	icon_state = "lunchbox_syndie"
	item_state = "toolbox_red"
	force = 10
	throwforce = 6

/obj/item/weapon/storage/lunchbox/syndie/pre_filled
	has_lunch = TRUE

/obj/item/weapon/storage/lunchbox/syndie/New()
	..()
	if(has_lunch == TRUE)
		pickfood_syndie()

// Getmore themed lunchbox
/obj/item/weapon/storage/lunchbox/nt/getmore
	name = "Getmore lunchbox"
	desc = "A little metal lunchbox. This one has the Getmore Chocolate Corp logo printed on the side."
	icon_state = "lunchbox_getmore"
	item_state = "toolbox_blue"

/obj/item/weapon/storage/lunchbox/nt/getmore/pre_filled
	has_lunch = TRUE

// Discount Dan themed lunchbox
/obj/item/weapon/storage/lunchbox/discount
	name = "Discount lunchbox"
	desc = "A little cardboard lunchbox. This one has the Discount Dan logo printed on the side. It looks very flimsy, and has a musty smell even when empty."
	icon_state = "lunchbox_discount"
	item_state = "toolbox_purple"
	force = 2
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

/obj/item/weapon/storage/lunchbox/zam
	name = "Zam lunchbox"
	desc = "A little metal lunchbox. This one has the Zam mascot printed on the side."
	icon_state = "lunchbox_zam"
	item_state = "toolbox_lightgrey"

/obj/item/weapon/storage/lunchbox/zam/dissolvable()
	return FALSE

/obj/item/weapon/storage/lunchbox/zam/New()
	..()
	if(has_lunch == TRUE)
		pickfood_zam()

/obj/item/weapon/storage/lunchbox/zam/pre_filled
	has_lunch = TRUE

/obj/item/weapon/storage/lunchbox/trader
	name = "worn lunchbox"
	desc = "A well-used metal lunchbox. Whatever decorations or logos it might have had have long faded away."
	icon_state = "lunchbox_trader"
	item_state = "toolbox_brown"

/obj/item/weapon/storage/lunchbox/trader/New()
	..()
	if(has_lunch == TRUE)
		pickfood_trader()

/obj/item/weapon/storage/lunchbox/trader/pre_filled
	has_lunch = TRUE
