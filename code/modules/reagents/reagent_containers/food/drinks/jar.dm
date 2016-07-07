

///jar

/obj/item/weapon/reagent_containers/food/drinks/jar
	name = "empty jar"
	desc = "A jar. You're not sure what it's supposed to hold."
	icon_state = "jar"
	item_state = "beaker"
	starting_materials = list(MAT_GLASS = 500)
	melt_temperature = MELTPOINT_GLASS
	w_type=RECYK_GLASS
	New()
		..()
		reagents.add_reagent(SLIMEJELLY, 50)

	on_reagent_change()
		if (reagents.reagent_list.len > 0)
			switch(reagents.get_master_reagent_id())
				if("slime")
					icon_state = "jar_slime"
					name = "slime jam"
					desc = "A jar of slime jam. Delicious!"
				else
					icon_state ="jar_what"
					name = "jar of something"
					desc = "You can't really tell what this is."
		else
			icon_state = "jar"
			name = "empty jar"
			desc = "A jar. You're not sure what it's supposed to hold."
			return
