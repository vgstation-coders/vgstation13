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
	/obj/item/weapon/melee/energy/axe,\
	/obj/item/weapon/gun/energy/laser/admin,\
	/obj/item/toy/gooncode) + typesof(/obj/item/weapon/gun/energy/pulse_rifle)

//FULL LIST:
//High-frequency blade, adminordrazine, admin fusebombs, admin banhammers (oh god), energy axes, infinite laser guns, gooncode, pulse rifles

/spell/aoe_turf/conjure/conjure_item
	name = "Conjure Item"
	desc = "This spell conjures an item into existence."

	charge_max = 10 //1 second, why not

	cast_sound = 'sound/items/welder.ogg'
	hud_state = "wiz_tech_old"

/spell/aoe_turf/conjure/conjure_item/New()
	if(!spawnable_items.len)
		initialize_spawnable_items() //Initialize the list with the item name -> item type associations

	..()

/spell/aoe_turf/conjure/conjure_item/cast(list/targets, mob/user)
	var/item_to_spawn = input(user, "Which item would you like to conjure?", "Conjure Item") as text
	item_to_spawn = lowertext(item_to_spawn)

	var/obj/item/path_of_item = spawnable_items[item_to_spawn]
	if(path_of_item)
		if(unspawnable_item_types.Find(path_of_item)) //If the item we're trying to create is forbidden
			summon_type = list(/mob/living/simple_animal/hostile/mimic/crate/item) //Create a mimic that looks just like it. Also it's berserk
			newVars = list("appearance" = initial(path_of_item.appearance), "size" = initial(path_of_item.w_class))
		else
			if(!initial(path_of_item.icon) || !initial(path_of_item.icon_state)) //No invisible items thanks
				user << "<span class='warning'>Conjuration failed.</span>"
				return

			summon_type = list(path_of_item)
			newVars = list()

		user << "<span class='notice'>You successfully conjure \a [item_to_spawn]."
	else
		user << "<span class='warning'>You know of no [item_to_spawn].</span>"
		return

	targets = list(get_turf(user)) //Without this, the item would spawn wherever the caster was standing when casting this spell!
	user.attack_log += "\[[time_stamp()]\] <span style=\"color:blue\">Used the \"[src.name]\" spell to create \a [item_to_spawn] ([path_of_item])</span>"
	message_admins("<span class='notice'>[key_name(user)] has used the \"[src.name]\" spell to create \a [item_to_spawn] ([path_of_item])</span>")

	return ..()

/spell/aoe_turf/conjure/conjure_item/genie
	var/times_used = 0

/spell/aoe_turf/conjure/conjure_item/genie/cast(list/targets, mob/user)
	if(times_used >= 3)
		user << "<span class='sinister'>You have lost your ability to conjure items.</span>"
		return

	if(..())
		times_used++
		switch(times_used)
			if(1)
				user << "<span class='sinister'>You may only use this ability twice now, before you lose your ability to conjure items!</span>"
			if(2)
				user << "<span class='sinister'>You may only use this ability once now, before you lose your ability to conjure items!</span>"
			if(3)
				user << "<span class='sinister'>You have lost your ability to conjure items.</span>"

		return 1
