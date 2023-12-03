/spell/aoe_turf/conjure/magical_wardrobe
	name = "Magical Wardrobe"
	desc = "Conjure a magical wardrobe that acts as an anchor, allowing you to quickly teleport inside it. Upon creation it will come stocked with clothing proportional to its durability."
	user_type = USER_TYPE_WIZARD
	specialization = SSUTILITY
	abbreviation = "MW"
	hud_state = "wardrobe_main"
	charge_max = 300 SECONDS
	cooldown_min = 150 SECONDS
	spell_flags = NEEDSCLOTHES | Z2NOCAST
	invocation_type = SpI_SHOUT
	invocation = "NAR'NI'AH"
	summon_type = list(/obj/structure/closet/magical_wardrobe)
	price = 0.75 * Sp_BASE_PRICE
	spell_levels = list(Sp_SPEED = 0, Sp_POWER = 0, Sp_MOVE = 0, Sp_AMOUNT = 0)
	level_max = list(Sp_TOTAL = 8, Sp_SPEED = 3, Sp_POWER = 1, Sp_MOVE = 1, Sp_AMOUNT = 4)

	var/obj/structure/closet/magical_wardrobe/magicCloset = null
	var/spell/targeted/magical_wardrobe_recall/mWRecall = null
	var/spell/magical_wardrobe_summon/mWSummon = null
	var/wardrobeHealth = 100

/spell/aoe_turf/conjure/magical_wardrobe/on_added(mob/user)
	mWRecall = new /spell/targeted/magical_wardrobe_recall
	mWRecall.mCloset = magicCloset
	if(user.mind)
		if(!user.mind.wizard_spells)
			user.mind.wizard_spells = list()
		user.mind.wizard_spells += mWRecall
	user.add_spell(mWRecall)

/spell/aoe_turf/conjure/magical_wardrobe/on_removed(mob/user)
	for(var/spell/targeted/magical_wardrobe_recall/mgr in user.spell_list)
		user.remove_spell(mgr)


/spell/aoe_turf/conjure/magical_wardrobe/apply_upgrade(upgrade_type)
	switch(upgrade_type)
		if(Sp_SPEED)
			wardrobeHealth += 25
			return quicken_spell()
		if(Sp_POWER)
			wardrobeHealth += 25
			spell_levels[Sp_POWER]++
			return "You no longer suffer backlash when your wardrobe is destroyed."
		if(Sp_MOVE)
			if(isliving(usr))	//Spellcode
				spell_levels[Sp_MOVE]++
				var/mob/living/user = usr
				wardrobeHealth += 25
				mWSummon = new /spell/magical_wardrobe_summon
				mWSummon.mCloset = magicCloset
				if(user.mind)
					if(!user.mind.wizard_spells)
						user.mind.wizard_spells = list()
					user.mind.wizard_spells += mWSummon
				user.add_spell(mWSummon)
				return "You may now summon your wardrobe to you."
		if(Sp_AMOUNT)
			wardrobeHealth += 50
			spell_levels[Sp_AMOUNT]++
			return "Your wardrobe is both sturdier and more fashionable."	//This exists because it took 5 seconds and might be good for a gimmick. No one should buy this.

/spell/aoe_turf/conjure/magical_wardrobe/get_upgrade_price(upgrade_type)
	switch(upgrade_type)
		if(Sp_SPEED)
			return 5
		if(Sp_POWER)
			return 10
		if(Sp_MOVE)
			return 5
		if(Sp_AMOUNT)
			return 10

/spell/aoe_turf/conjure/magical_wardrobe/get_upgrade_info(upgrade_type, level)
	if(upgrade_type == Sp_SPEED)
		if(spell_levels[Sp_SPEED] >= level_max[Sp_SPEED])
			return "The spell can't be made any quicker than this!"
		var/formula = round((initial_charge_max - cooldown_min)/level_max[Sp_SPEED])
		return "Decreases the cooldown on summoning a new wardrobe by [formula/10]. Does not affect the recall or summon spells. Also increases its durability."
	if(upgrade_type == Sp_MOVE)
		if(spell_levels[Sp_MOVE] >= level_max[Sp_MOVE])
			return "You can already summon the wardrobe to your location!"
		return "Allows you to summon your wardrobe to your location. Also increases its durability."
	if(upgrade_type == Sp_POWER)
		if(spell_levels[Sp_POWER] >= level_max[Sp_POWER])
			return "You are already immune to the magical backlash of your wardrobe getting destroyed!"
		return "Prevents magical backlash from affecting you when your wardrobe is destroyed. Also increases its durability."
	if(upgrade_type == Sp_AMOUNT)
		if(spell_levels[Sp_AMOUNT] >= level_max[Sp_AMOUNT])
			return "You have already made the wardrobe as durable as it can be through this upgrade! You may try buying a different upgrade."
		return "Significantly increases durability. Only wizards completely devoted to fashion should choose this."
	return ..()

/spell/aoe_turf/conjure/magical_wardrobe/cast(list/targets, mob/user)
	if(magicCloset)
		magicCloset.forceMove(user.loc)
		magicCloset.wardrobeSetup()
		if(spell_levels[Sp_POWER])
			magicCloset.backlash = FALSE
	else
		..()

/spell/aoe_turf/conjure/magical_wardrobe/on_creation(obj/structure/closet/magical_wardrobe/MW, mob/user)
	magicCloset = MW
	magicCloset.theWiz = user
	magicCloset.mWOrigin = src
	magicCloset.wardrobeSetup()
	if(spell_levels[Sp_POWER])
		magicCloset.backlash = FALSE
	if(mWRecall)
		mWRecall.mCloset = magicCloset
	if(mWSummon)
		mWSummon.mCloset = magicCloset

/spell/aoe_turf/conjure/magical_wardrobe/proc/clearClosets()
	magicCloset = null
	if(mWRecall)
		mWRecall.mCloset = null
	if(mWSummon)
		mWSummon.mCloset = null


/spell/targeted/magical_wardrobe_recall
	name = "Wardrobe Recall"
	desc = "Teleport back to your magical wardrobe, assuming it still exists."
	abbreviation = "WR"
	hud_state = "wardrobe_recall"
	charge_max = 150
	spell_flags = Z2NOCAST | INCLUDEUSER 	//Creating a wardrobe needs clothes, using it doesn't
	range = SELFCAST
	var/obj/structure/closet/magical_wardrobe/mCloset = null

/spell/targeted/magical_wardrobe_recall/cast(list/targets, mob/user)
	if(!mCloset)
		to_chat(user, "<span class='warning'>You don't have a wardrobe to recall to!</span>")
	else
		do_teleport(user, mCloset, 0)
		mCloset.wardrobeToggle()

/spell/magical_wardrobe_summon
	name = "Wardrobe Summon"
	desc = "Teleport your magical wardrobe back to you, assuming it still exists."
	abbreviation = "WS"
	hud_state = "wardrobe_summon"
	charge_max = 150
	spell_flags = Z2NOCAST
	var/obj/structure/closet/magical_wardrobe/mCloset = null

/spell/magical_wardrobe_summon/choose_targets(mob/user = usr)
	return list(user)

/spell/magical_wardrobe_summon/cast(list/targets, mob/user)
	if(mCloset)
		do_teleport(mCloset, user, 0)
		mCloset.wardrobeToggle()
	else
		to_chat(user, "<span class='warning'>You don't have a wardrobe to summon!</span>")


/obj/structure/closet/magical_wardrobe
	name = "mysterious wardrobe"
	desc = "Smells like wizard robes and beard freshener."
	icon_state = "wizcabinet_closed"
	icon_closed = "wizcabinet_closed"
	icon_opened = "wizcabinet_open"
	health = 100
	var/spell/aoe_turf/conjure/magical_wardrobe/mWOrigin = null
	var/mob/living/carbon/human/theWiz = null
	var/backlash = TRUE

/obj/structure/closet/magical_wardrobe/canweld()
	return 0	//Just not in for messing with the overlay location right now

/obj/structure/closet/magical_wardrobe/Destroy()
	mWOrigin.clearClosets()
	if(backlash)
		to_chat(theWiz, "<span class='warning'>Your wardrobe has been destroyed! The magics linking you to it create a horrible feedback!</span>")
		theWiz.Silent(2)
		theWiz.Knockdown(2)
		theWiz.confused += 4
	else
		to_chat(theWiz, "<span class='warning'>Your wardrobe has been destroyed! You feel a small tinge of pain from the feedback.</span>")
	..()

/obj/structure/closet/magical_wardrobe/proc/wardrobeToggle()
	if(!opened)
		open()
	close()

/obj/structure/closet/magical_wardrobe/proc/wardrobeSetup()
	health = mWOrigin.wardrobeHealth
	wizardDressUp()
	wardrobeToggle()

/obj/structure/closet/magical_wardrobe/proc/wizardDressUp()
	var/static/list/wizFashion = list(	//Potion shops are last season, wizard thrift shops are hip
		/obj/item/clothing/suit/chickensuit,
		/obj/item/clothing/head/chicken,
		/obj/item/clothing/under/gladiator,
		/obj/item/clothing/head/helmet/gladiator,
		/obj/item/clothing/under/schoolgirl,
		/obj/item/clothing/head/kitty,
		/obj/item/clothing/under/blackskirt,
		/obj/item/clothing/head/rabbitears,
		/obj/item/clothing/suit/wcoat,
		/obj/item/clothing/under/suit_jacket,
		/obj/item/clothing/head/that,
		/obj/item/clothing/head/cueball,
		/obj/item/clothing/under/kilt,
		/obj/item/clothing/head/beret,
		/obj/item/clothing/glasses/monocle,
		/obj/item/clothing/mask/fakemoustache,
		/obj/item/clothing/under/owl,
		/obj/item/clothing/mask/gas/owl_mask,
		/obj/item/clothing/suit/pirate,
		/obj/item/clothing/head/pirate,
		/obj/item/clothing/glasses/eyepatch,
		/obj/item/clothing/under/sundress,
		/obj/item/clothing/head/witchwig,
		/obj/item/clothing/under/sexyclown,
		/obj/item/clothing/under/sexymime,
		/obj/item/clothing/under/chameleon,
		/obj/item/clothing/under/pj/red,
		/obj/item/clothing/under/pj/blue,
		/obj/item/clothing/under/captain_fly,
		/obj/item/clothing/under/waiter,
		/obj/item/clothing/under/rainbow,
		/obj/item/clothing/under/darkholme,
		/obj/item/clothing/under/contortionist,
		/obj/item/clothing/under/greaser,
		/obj/item/clothing/under/keyholesweater,
		/obj/item/clothing/under/casualhoodie,
		/obj/item/clothing/under/rottensuit,
		/obj/item/clothing/under/elf,
		/obj/item/clothing/under/newclothes,
		/obj/item/clothing/under/skelesuit,
		/obj/item/clothing/head/helmet/dredd,
		/obj/item/clothing/head/helmet/rune,
		/obj/item/clothing/suit/armor/rune,
		/obj/item/clothing/suit/apron,
		/obj/item/clothing/head/beret/centcom/captain,
		/obj/item/clothing/suit/wizrobe,
		/obj/item/clothing/head/wizard,
		/obj/item/clothing/shoes/sandal,
		/obj/item/clothing/head/hairflower,
		/obj/item/clothing/head/powdered_wig,
		/obj/item/clothing/head/hasturhood,
		/obj/item/clothing/head/nursehat,
		/obj/item/clothing/head/spaceninjafake,
		/obj/item/clothing/head/cardborg,
		/obj/item/clothing/head/beaverhat,
		/obj/item/clothing/head/fedora,
		/obj/item/clothing/head/fez,
		/obj/item/clothing/head/bearpelt,
		/obj/item/clothing/head/bearpelt/real,
		/obj/item/clothing/head/xenos,
		/obj/item/clothing/head/batman,
		/obj/item/clothing/head/lordadmiralhat,
		/obj/item/clothing/head/jesterhat,
		/obj/item/clothing/head/cowboy,
		/obj/item/clothing/head/festive,
		/obj/item/clothing/head/pajamahat/red,
		/obj/item/clothing/head/pajamahat/blue,
		/obj/item/clothing/head/party_hat,
		/obj/item/clothing/head/snake,
		/obj/item/clothing/head/elfhat,
		/obj/item/clothing/head/rice_hat,
		/obj/item/clothing/head/pharaoh,
	)
	var/styleAmount = round(health/50, 1)	//2 base, 1 per 2 spell upgrades
	for(var/i in 1 to styleAmount)
		var/thrift = pick(wizFashion)
		new thrift(src)
