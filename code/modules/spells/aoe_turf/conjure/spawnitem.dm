var/global/list/spawnable_items = list()

proc/initialize_spawnable_items()
	for(var/I in typesof(/obj/item) - typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable) - typesof(/obj/item/borg) - typesof(/obj/item/tk_grab)  - typesof(/obj/item/verbs))
		var/obj/item/actual_item = I
		var/N = lowertext(initial(actual_item.name))
		spawnable_items |= N
		spawnable_items[N] = I

//These items can't be spawned through the spell; trying to do so will result in a mimic
var/global/list/unspawnable_item_types = list(/obj/item/weapon/katana/hfrequency,\
	/obj/item/weapon/reagent_containers/glass/bottle/adminordrazine,\
	/obj/item/weapon/reagent_containers/pill/adminordrazine,\
	/obj/item/device/fuse_bomb/admin,\
	/obj/item/weapon/banhammer/admin,\
	/obj/item/weapon/gun/energy/laser/admin,\
	/obj/item/toy/gooncode) + typesof(/obj/item/weapon/gun/energy/pulse_rifle)

/spell/aoe_turf/conjure/conjure_item
	name = "Conjure Item"
	desc = "This spell conjures an item into existence."

	cast_sound = 'sound/items/welder.ogg'
	hud_state = "wiz_tech_old"

/spell/aoe_turf/conjure/conjure_item/New()
	if(!spawnable_items.len)
		initialize_spawnable_items()

	..()

/spell/aoe_turf/conjure/conjure_item/cast(list/targets, mob/user)
	var/item_to_spawn = input(user, "Which item would you like to conjure?", "Conjure Item") as text
	item_to_spawn = lowertext(item_to_spawn)

	var/obj/item/path_of_item = spawnable_items[item_to_spawn]
	if(path_of_item)
		if(unspawnable_item_types.Find(path_of_item)) //If the item we're trying to create is forbidden
			summon_type = list(/mob/living/simple_animal/hostile/mimic/crate/item) //Create a mimic that looks just like it. Also it's berserk
			newVars = list("appearance" = initial(path_of_item.appearance), "size" = initial(path_of_item.w_class), "angry" = 2, name = "[initial(path_of_item.name)] mimic")
		else
			if(!initial(path_of_item.icon) || !initial(path_of_item.icon_state)) //No invisible items thanks
				user << "<span class='sinister'>Conjuration failed.</span>"
				return

			summon_type = list(path_of_item)
			newVars = list()

		user << "<span class='sinister'>You successfully conjure \a [item_to_spawn]."
	else
		user << "<span class='sinister'>You know of no [item_to_spawn].</span>"
		return

	..()
