/datum/design/hookshot
	name = "Hookshot"
	desc = "A very recent design, we're still far from finding out its full potential."
	id = "hookshot"
	req_tech = list(Tc_MATERIALS = 2, Tc_ENGINEERING = 5, Tc_MAGNETS = 2, Tc_NANOTRASEN = 1)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 75000, MAT_DIAMOND = 500)//20 sheets of iron, 1/4 sheet of diamond.
	category = "Nanotrasen"
	build_path = /obj/item/weapon/gun/hookshot

/datum/design/ricochet
	name = "Ricochet Rifle"
	desc = "Here's a tip, get yourself an ablative armor before you start firing this one randomly."
	id = "ricochet"
	req_tech = list(Tc_MATERIALS = 3, Tc_POWERSTORAGE = 3, Tc_COMBAT = 3, Tc_NANOTRASEN = 1)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5000, MAT_GLASS = 1000, MAT_URANIUM = 1000)
	category = "Nanotrasen"
	build_path = /obj/item/weapon/gun/energy/ricochet
	locked = 1
	req_lock_access = list(access_armory)

/datum/design/mami
	name = "Machine-Man Interface"
	desc = "A synthetic brain interface intended to give silicon-based minds control of organic tissue. It's semi-organic, so store it in a cool, dry place."
	id = "mami"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_BIOTECH = 4, Tc_NANOTRASEN = 1)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 12000, MAT_GLASS = 52500, MAT_GOLD = 24000, MAT_SILVER = 12000, MAT_PLASTIC = 2000) //yes it's expensive
	category = "Nanotrasen"
	build_path = /obj/item/organ/brain/mami

/datum/design/gravitywell
	name = "Gravity Well Gun"
	desc = "After years of studying the Singularity, our engineers have come up with a way to produce a similar graviational anomaly that automatically decays after a bit less than a minute. Use with extreme caution!"
	id = "gravitywell"
	req_tech = list(Tc_MATERIALS = 7, Tc_BLUESPACE = 5, Tc_MAGNETS = 5, Tc_NANOTRASEN = 1)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 10000, MAT_GLASS = 37500, MAT_DIAMOND = 6000, MAT_SILVER = 10000, MAT_URANIUM = 26000)//5 sheets of gold, 10 sheets of glass, 3 sheets of diamonds, 5 sheets of silver, 13 sheets of uranium
	category = "Nanotrasen"
	build_path = /obj/item/weapon/gun/gravitywell
	locked = 1
	req_lock_access = list(access_rd)
