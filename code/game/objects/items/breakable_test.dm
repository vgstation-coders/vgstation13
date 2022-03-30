/////////////////////
//Breakability testing items
/obj/item/device/flashlight/test
	name = "breakable flashlight"
	desc = "This flashlight looks particularly flimsy."
	breakable_flags = BREAKABLE_ALL
	health = 30
	maxHealth = 30
	damaged_examine_text = "It has gone bad."
	breaks_text = "crumbles apart"
	take_hit_text = "cracking"
	breaks_sound = 'sound/misc/balloon_pop.ogg'
	breakable_fragments = list(/obj/item/weapon/shard, /obj/item/weapon/reagent_containers/food/snacks/hotdog)
	fragment_amounts = list(2,1) //Will break into 2 shards, 1 hotdog.
	damaged_sound = 'sound/effects/grillehit.ogg'
	glanced_sound = 'sound/items/trayhit1.ogg'

/obj/item/weapon/kitchen/utensil/knife/large/test
	name = "breakable knife"
	desc = "This knife looks like it could break under pressure."
	breakable_flags = BREAKABLE_ALL
	health = 30
	maxHealth = 30
	damaged_examine_text = "It's seen better days."
	breaks_text = "splinters into little bits"
	take_hit_text = list("denting","cracking")
	breaks_sound = 'sound/items/trayhit1.ogg'
	breakable_fragments = list(/obj/item/weapon/shard, /obj/item/weapon/kitchen/utensil/knife/large/test)

/obj/item/weapon/kitchen/utensil/knife/large/test/weak
	name = "flimsy breakable knife"
	desc = "This flimsy knife looks like it could fall apart at any time."
	breakable_flags = BREAKABLE_ALL
	health = 0.1
	maxHealth = 1
	damaged_examine_text = "It's seen much better days."
	damage_armor = BREAKARMOR_NOARMOR
	damage_resist = 0
	take_hit_text = "chipping"
	take_hit_text2 = "chips"
	breaks_text = "falls apart into dust"
	breakable_fragments = list(/obj/item/weapon/shard, /obj/item/weapon/kitchen/utensil/knife/large/test/weak)

/obj/item/weapon/pen/fountain/test
	name = "breakable fountain pen"
	desc = "This pen looks really weak."
	breakable_flags = BREAKABLE_ALL
	health = 10
	maxHealth = 10
	damaged_examine_text = "It's seen much better days."
	damage_armor = 0
	damage_resist = 0
	breaks_text = "falls apart into dust"
	density = 1
	breakable_fragments = list(/obj/item/weapon/pen/fountain/test, /obj/item/weapon/kitchen/utensil/knife/)
	fragment_amounts = list(1,3)

/obj/item/weapon/pen/fountain/test/strong
	name = "invincible fountain pen"
	desc = "This pen looks really, really tough."
	breakable_flags = BREAKABLE_ALL
	health = 10
	maxHealth = 10
	damaged_examine_text = "Somehow it has a crack in it..."
	damage_armor = BREAKARMOR_INVINCIBLE
	damage_resist = 0
	density = 1
	breaks_text = "implodes"
	breakable_fragments = list(/obj/item/weapon/reagent_containers/food/snacks/hotdog)

/obj/item/weapon/reagent_containers/glass/jar/erlenmeyer/test
	name = "huge breakable flask"
	desc = "A huge flask that could break at any time, under the right conditions."
	breakable_flags = BREAKABLE_ALL
	health = 1
	maxHealth = 1
	damaged_examine_text = "It has a big crack down the side."
	damage_armor = BREAKARMOR_NOARMOR
	damage_resist = 0
	density = 1
	breaks_text = "shatters"

/obj/item/weapon/reagent_containers/glass/jar/erlenmeyer/test/New()
	..()
	reagents.add_reagent(PACID, 250)
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/test
	name = "breakable beaker"
	desc = "A breakable beaker. Can hold up to 50 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	item_state = "beaker"
	breakable_flags = BREAKABLE_ALL
	maxHealth = 20
	damaged_examine_text = "It has a big crack down the side."
	damage_armor = BREAKARMOR_NOARMOR
	damage_resist = 0
	breaks_text = "shatters"
	take_hit_text = list("cracking","chipping")
	take_hit_text2 = list("cracks","chips")
	glances_text = list("glances","bounces")
	starting_materials = list(MAT_GLASS = 500)
	origin_tech = Tc_MATERIALS + "=1"
	layer = ABOVE_OBJ_LAYER //So it always gets layered above pills and bottles

/obj/item/weapon/reagent_containers/glass/jar/erlenmeyer/test/New()
	..()
	reagents.add_reagent(PACID, 50)
	update_icon()

/obj/item/weapon/storage/box/survival/test
	name = "breakable survival box"
	desc = "A box that holds survival equipment, but is also somewhat fragile."
	icon_state = "box_emergency"
	item_state = "box_emergency"
	breakable_flags = BREAKABLE_ALL
	health = 10
	maxHealth = 10
	density = 1
	damaged_examine_text = "It's all banged up."
	damage_armor = BREAKARMOR_NOARMOR
	damage_resist = 0
	breaks_text = "blows apart"
	items_to_spawn = list(
		/obj/item/weapon/reagent_containers/food/snacks/hotdog,
		/obj/item/weapon/reagent_containers/food/snacks/hotdog,
		/obj/item/weapon/reagent_containers/food/snacks/hotdog,
	)
/////////////////////
