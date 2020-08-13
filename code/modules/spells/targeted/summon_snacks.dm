#define SUMMON_SNACKS_FILLING 1
#define SUMMON_SNACKS_DISCOUNT 2
#define SUMMON_SNACKS_HORRIBLE 3
#define SUMMON_SNACKS_PUB 4

/spell/targeted/summon_snacks //can mean aoe for mobs (limited/unlimited number) or one target mob
	name = "Summon Snacks"
	desc = "Summon up a snack and beverage for your victim. They'll drop whatever they're holding at the time. Snacks cannot be dropped and must be eaten. The move upgrade allows you to change what's on the menu, yum!"
	spell_flags = SELECTABLE | INCLUDEUSER | WAIT_FOR_CLICK | NEEDSCLOTHES
	abbreviation = "SS"
	hud_state = "wiz_snack"
	user_type = USER_TYPE_WIZARD
	specialization = SSUTILITY
	user_type = USER_TYPE_WIZARD
	school = "conjuration"
	invocation = "OR'DER UHP"
	invocation_type = SpI_SHOUT
	message = "<span class='sinister'>Suddenly your hands are full of snacks!<span>"
	charge_max = 300
	cooldown_min = 150
	selection_type = "range"
	range = 7
	compatible_mobs = list(/mob/living/carbon)
	spell_levels = list(Sp_SPEED = 0, Sp_POWER = 0, Sp_AMOUNT = 0, Sp_MOVE = 0)
	level_max = list(Sp_TOTAL = 13, Sp_SPEED = 3, Sp_POWER = 1, Sp_AMOUNT = 5, Sp_MOVE = 4)
	var/menuType = SUMMON_SNACKS_FILLING

/spell/targeted/summon_snacks/cast(var/list/targets, mob/user)
	..()
	for(var/mob/living/carbon/target in targets)
		target.drop_hands(force_drop = 1)
		if(target.find_empty_hand_index())
			var/obj/item/weapon/reagent_containers/food/snacks/summoned/summoned_snack/S = new /obj/item/weapon/reagent_containers/food/snacks/summoned/summoned_snack(target.loc)
			var/obj/item/weapon/reagent_containers/food/snacks/summoned/summoned_drink/D = new /obj/item/weapon/reagent_containers/food/snacks/summoned/summoned_drink(target.loc)
			S.spellInherit(menuType, spell_levels[Sp_AMOUNT], spell_levels[Sp_POWER])
			S.menuOrder(menuType)
			D.spellInherit(menuType, spell_levels[Sp_AMOUNT], spell_levels[Sp_POWER])
			D.menuOrder(menuType)
			target.put_in_hands(S)
			target.put_in_hands(D)

/spell/targeted/summon_snacks/on_added(mob/user)
	name = "Summon Filling Snacks"

/spell/targeted/summon_snacks/apply_upgrade(upgrade_type)
	switch(upgrade_type)
		if(Sp_SPEED)
			return quicken_spell()
		if(Sp_POWER)
			spell_levels[Sp_POWER]++
			return "Your snacks are now extremely unhealthy."
		if(Sp_AMOUNT)
			spell_levels[Sp_AMOUNT]++
			return "Your snacks are now a little bigger"
		if(Sp_MOVE)
			spell_levels[Sp_MOVE]++
			if(spell_levels[Sp_MOVE] == 1)
				name = "Summon Discount Snacks"
				invocation = "DA'N THUH MA'N"
				menuType = SUMMON_SNACKS_DISCOUNT
				return "Your snacks are now sponsored by Discount Dan."
			if(spell_levels[Sp_MOVE] == 2)
				name = "Summon Horrible Snacks"
				invocation = "AB'OM'INATION"
				menuType = SUMMON_SNACKS_HORRIBLE
				return "Your snacks are now horrible."
			if(spell_levels[Sp_MOVE] == 3)
				name = "Summon Pub Snacks"
				invocation = "PE'ANO AS'BEN DRYNCAN"
				menuType = SUMMON_SNACKS_PUB
				return "Your snacks are now pub fare."
			if(spell_levels[Sp_MOVE] == 4)
				name = "Summon Filling Snacks"
				invocation = "OR'DER UHP"
				menuType = SUMMON_SNACKS_FILLING
				spell_levels[Sp_MOVE] = 0		//So you can cycle between them
				return "Your snacks are now hearty."

/spell/targeted/summon_snacks/get_upgrade_price(upgrade_type)
	switch(upgrade_type)
		if(Sp_SPEED)
			return 10
		if(Sp_POWER)
			return 25
		if(Sp_MOVE)
			return 0
		if(Sp_AMOUNT)
			return 1

/spell/targeted/summon_snacks/get_upgrade_info(upgrade_type)
	switch(upgrade_type)
		if(Sp_SPEED)
			return "Lowers the cooldown of the spell."
		if(Sp_POWER)
			return "Your snacks will now contain a small amount of diabeetusol. Full of flavor and calories!"
		if(Sp_AMOUNT)
			return "Increases how many bites it takes to finish eating."
		if(Sp_MOVE)
			return "Changes the type of snack and drink. Resets at max level to allow cycling through the menu. Level 0: Filling, Level 1: Discount, Level 2: Horrible, Level 3: Pub."

/obj/item/weapon/reagent_containers/food/snacks/summoned
	name = "wizard snack"
	desc = "Magically delicious."
	icon_state = "spellburger"
	cant_drop = 1

/obj/item/weapon/reagent_containers/food/snacks/summoned/proc/spellInherit(var/menu, var/biteS, var/diabeetus)
	switch(menu)
		if(SUMMON_SNACKS_FILLING)
			reagents.add_reagent(NUTRIMENT, 8)
		if(SUMMON_SNACKS_DISCOUNT)
			reagents.add_reagent(NUTRIMENT, 1)
			reagents.add_reagent(DISCOUNT, 3)
			reagents.add_reagent(BEFF, 1)
			reagents.add_reagent(CHEMICAL_WASTE, 1)
		if(SUMMON_SNACKS_HORRIBLE)
			reagents.add_reagent(NUTRIMENT, 1)
			reagents.add_reagent(TOXIN, 1)
			reagents.add_reagent(SUGAR, 2)
		if(SUMMON_SNACKS_PUB)
			reagents.add_reagent(NUTRIMENT, 2)
			reagents.add_reagent(BEER, 4)
	bitesize = 6 - biteS
	if(diabeetus)
		reagents.add_reagent(DIABEETUSOL, 1)

/obj/item/weapon/reagent_containers/food/snacks/summoned/proc/menuOrder(var/onMenu)
	return

/obj/item/weapon/reagent_containers/food/snacks/summoned/summoned_snack/menuOrder(onMenu)
	switch(onMenu)
		if(SUMMON_SNACKS_FILLING)
			icon_state = "sandwich"
			name = "Summoned sandwich"
		if(SUMMON_SNACKS_DISCOUNT)
			icon_state = "goburger"
			name = "Summoned Dan Burger"
		if(SUMMON_SNACKS_HORRIBLE)
			icon_state = "COOKIE!!!"	//I hate you, mysterious icon namer
			name = "Summoned Chocolate Chip Cookie"
		if(SUMMON_SNACKS_PUB)
			icon_state = "fries"
			name = "Summoned Fries"

/obj/item/weapon/reagent_containers/food/snacks/summoned/summoned_drink
	icon = 'icons/obj/drinks.dmi'
	icon_state = "groans"

/obj/item/weapon/reagent_containers/food/snacks/summoned/summoned_drink/menuOrder(onMenu)
	switch(onMenu)
		if(SUMMON_SNACKS_FILLING)
			icon_state = "tomatosoup"
			name = "Summoned Tomato Soup"
		if(SUMMON_SNACKS_DISCOUNT)
			icon_state = "filk"
			name = "Summoned Filk"
		if(SUMMON_SNACKS_HORRIBLE)
			icon_state = "orangejuice"
			name = "Summoned Orange Juice"
		if(SUMMON_SNACKS_PUB)
			icon_state = "beer"
			name = "Summoned Beer"
