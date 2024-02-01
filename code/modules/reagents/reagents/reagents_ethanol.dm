//Alcoholic drinks, not to be confused with non-alcoholic stuff.

//ALCOHOL WOO
/datum/reagent/ethanol
	name = "Ethanol" //Parent class for all alcoholic reagents.
	id = ETHANOL
	description = "A well-known alcohol with a variety of applications."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 0 //So alcohol can fill you up! If they want to.
	color = "#404030" //RGB: 64, 64, 48
	custom_metabolism = FOOD_METABOLISM
	density = 0.79
	specheatcap = 2.46
	var/dizzy_adj = 3
	var/slurr_adj = 3
	var/confused_adj = 2
	var/slur_start = 65 //Amount absorbed after which mob starts slurring
	var/confused_start = 130 //Amount absorbed after which mob starts confusing directions
	var/blur_start = 260 //Amount absorbed after which mob starts getting blurred vision
	var/pass_out = 450 //Amount absorbed after which mob starts passing out
	var/common_tick = 1 //Needed to add all ethanol subtype's ticks

/datum/reagent/ethanol/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	//Sobering multiplier
	//Sober block makes it more difficult to get drunk
	var/sober_str =! (M_SOBER in M.mutations) ? 1 : 2

	tick /= sober_str

	//Make all the ethanol-based beverages work together
	common_tick = 0

	if(holder.reagent_list) //Sanity
		for(var/datum/reagent/ethanol/A in holder.reagent_list)
			if(isnum(A.tick))
				common_tick += A.tick

	M.dizziness += dizzy_adj
	if(common_tick >= slur_start && tick < pass_out)
		if(!M.slurring)
			M.slurring = 1
		M.slurring += slurr_adj/sober_str
	if(common_tick >= confused_start && prob(33))
		if(!M.confused)
			M.confused = 1
		M.confused = max(M.confused+(confused_adj/sober_str), 0)
	if(common_tick >= blur_start)
		M.eye_blurry = max(M.eye_blurry, 10/sober_str)
		M.drowsyness  = max(M.drowsyness, 0)
	if(common_tick >= pass_out)
		M.paralysis = max(M.paralysis, 20/sober_str)
		M.drowsyness  = max(M.drowsyness, 30/sober_str)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
			if(!L)
				H.adjustToxLoss(5)
			else if(istype(L))
				L.take_damage(0.05, 0.5)
			H.adjustToxLoss(0.5)

/datum/reagent/ethanol/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	if(istype(O, /obj/item/weapon/paper))
		var/obj/item/weapon/paper/paperaffected = O
		if(paperaffected.info || paperaffected.stamps)
			paperaffected.clearpaper()
			O.visible_message("<span class='warning'>The solution melts away \the [O]'s ink.</span>")

	if(istype(O, /obj/item/weapon/book))
		if(volume >= 5)
			var/obj/item/weapon/book/affectedbook = O
			if(affectedbook.dat)
				affectedbook.dat = null
				O.visible_message("<span class='warning'>The solution melts away \the [O]'s ink.</span>")

//It's really much more stronger than other drinks
/datum/reagent/ethanol/beer
	name = "Beer"
	id = BEER
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "beerglass"
	glass_desc = "A cold pint of pale lager."

/datum/reagent/ethanol/beer/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.jitteriness = max(M.jitteriness - 3, 0)

/datum/reagent/ethanol/beer/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_nutrientlevel(1)
	T.add_waterlevel(1)

/datum/reagent/ethanol/whiskey
	name = "Whiskey"
	id = WHISKEY
	description = "A superb and well-aged single-malt whiskey. Damn."
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 4
	pass_out = 225
	glass_icon_state = "whiskeyglass"
	glass_desc = "The silky, smokey whiskey goodness inside the glass makes the drink look very classy."

/datum/reagent/ethanol/specialwhiskey
	name = "Special Blend Whiskey"
	id = SPECIALWHISKEY
	description = "Just when you thought regular station whiskey was good..."
	color = "#664300" //rgb: 102, 67, 0
	slur_start = 30
	pass_out = 225

/datum/reagent/ethanol/gin
	name = "Gin"
	id = GIN
	description = "It's gin. In space. I say, good sir."
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 3
	pass_out = 260
	glass_icon_state = "ginvodkaglass"
	glass_desc = "A crystal clear glass of Griffeater gin."

/datum/reagent/ethanol/absinthe
	name = "Absinthe"
	id = ABSINTHE
	description = "Watch out that the Green Fairy doesn't get you!"
	color = "#33EE00" //rgb: lots, ??, ??
	dizzy_adj = 5
	slur_start = 25
	confused_start = 100
	pass_out = 175
	glass_icon_state = "absintheglass"
	glass_desc = "One sip of this and you just know you're gonna have a good time."

//Copy paste from LSD... shoot me
/datum/reagent/ethanol/absinthe/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.hallucination += 5

/datum/reagent/ethanol/bwine
	name = "Berry Wine"
	id = BWINE
	description = "Sweet berry wine!"
	color = "#C760A2" //rgb: 199, 96, 162
	dizzy_adj = 2
	slur_start = 65
	confused_start = 145
	glass_icon_state = "bwineglass"
	glass_desc = "A particular favorite of doctors."

/datum/reagent/ethanol/wwine
	name = "White Wine"
	id = WWINE
	description = "A premium alcoholic beverage made from fermented green grape juice."
	color = "#C6C693" //rgb: 198, 198, 147
	dizzy_adj = 2
	slur_start = 65
	confused_start = 145
	glass_icon_state = "wwineglass"
	glass_desc = "A drink enjoyed by intellectuals and middle-aged female alcoholics alike."

/datum/reagent/ethanol/plumphwine
	name = "Plump Helmet Wine"
	id = PLUMPHWINE
	description = "A very peculiar wine made from fermented plump helmet mushrooms. Popular among asteroid dwellers."
	color = "#800080" //rgb: 128, 0, 128
	dizzy_adj = 3 //dorf wine is a bit stronger than regular stuff
	slur_start = 60
	confused_start = 135

/datum/reagent/ethanol/pwine
	name = "Poison Wine"
	id = PWINE
	description = "Is this even wine? Toxic, hallucinogenic, foul-tasting... Why would you drink this?"
	color = "#000000" //rgb: 0, 0, 0
	dizzy_adj = 1
	slur_start = 1
	confused_start = 1
	glass_name = "glass of Vintage 2018 Special Reserve"
	glass_icon_state = "pwineglass"

/datum/reagent/ethanol/pwine/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.druggy = max(M.druggy, 50)
	switch(tick)
		if(1 to 25)
			if(!M.stuttering)
				M.stuttering = 1
			M.Dizzy(1)
			M.hallucination = max(M.hallucination, 3)
			if(prob(1))
				M.emote(pick("twitch", "giggle"))
		if(25 to 75)
			if(!M.stuttering)
				M.stuttering = 1
			M.hallucination = max(M.hallucination, 10)
			M.Jitter(2)
			M.Dizzy(2)
			M.druggy = max(M.druggy, 45)
			if(prob(5))
				M.emote(pick("twitch", "giggle"))
		if(75 to 150)
			if(!M.stuttering)
				M.stuttering = 1
			M.hallucination = max(M.hallucination, 60)
			M.Jitter(4)
			M.Dizzy(4)
			M.druggy = max(M.druggy, 60)
			if(prob(10))
				M.emote(pick("twitch", "giggle"))
			if(prob(30))
				M.adjustToxLoss(2)
		if(150 to 300)
			if(!M.stuttering)
				M.stuttering = 1
			M.hallucination = max(M.hallucination, 60)
			M.Jitter(4)
			M.Dizzy(4)
			M.druggy = max(M.druggy, 60)
			if(prob(10))
				M.emote(pick("twitch", "giggle"))
			if(prob(30))
				M.adjustToxLoss(2)
			if(prob(5))
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					var/datum/organ/internal/heart/L = H.internal_organs_by_name["heart"]
					if(L && istype(L))
						L.take_damage(5, 0)
		if(300 to INFINITY)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/datum/organ/internal/heart/L = H.internal_organs_by_name["heart"]
				if(L && istype(L))
					L.take_damage(100, 0)

/datum/reagent/ethanol/karmotrine
	name = "Karmotrine"
	id = KARMOTRINE
	description = "A thick, light blue liquid extracted from strange plants."
	color = "#66ffff" //rgb(102, 255, 255)
	blur_start = 40 //Blur very early

/datum/reagent/ethanol/smokyroom
	name = "Smoky Room"
	id = SMOKYROOM
	description = "It was the kind of cool, black night that clung to you like something real... a black, tangible fabric of smoke, deceit, and murder. I had finished working my way through the fat cigars for the day - or at least told myself that to feel the sense of accomplishment for another night wasted on little more than chasing cheating dames and abusive husbands. It was enough to drive a man to drink... and it did. I sauntered into the cantina and wordlessly nodded to the barman. He knew my poison. I was a regular, after all. By the time the night was over, there would be another empty bottle and a case no closer to being cracked. Then I saw her, like a mirage across a desert, or a striken starlet on stage across a smoky room."
	color = "#664300"
	glass_icon_state = "smokyroom"
	glass_name = "\improper Smoky Room"

/datum/reagent/ethanol/smokyroom/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(prob(4)) //Small chance per tick to some noir stuff and gain NOIRBLOCK if we don't have it.
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!(M_NOIR in H.mutations))
				H.mutations += M_NOIR
				H.dna.SetSEState(NOIRBLOCK,1)
				genemutcheck(H, NOIRBLOCK, null, MUTCHK_FORCED)

		M.say(pick("The station corridors were heartless and cold, like the fickle 'love' of some hysterical dame.",
			"The lights, the smoke, the grime... the station itself seemed alive that day. Was it the pulse that made me think so? Or just all the blood?",
			"I caressed my .44 magnum. Ever since Jimmy bit it against the Two Bit Gang, the gun and its six rounds were the only partner I could trust. Never a single jam to trap me in another.",
			"The whole reason I took the case to begin with was trouble, in the shape of a pinup blonde with shanks that'd make you dizzy. Wouldn't give her name, said she was related to the captain. I doubt she was even on the manifest.",
			"According to the boys in the lab, the perp took a sander to the tooth profiles, but did a sloppy job. Lab report came in early this morning. Guess my vacation is on pause.",
			"The blacktop was baking that day, and the broads working 19th and Main were wearing even less than usual.",
			"The young dame was the pride and joy of the station. Little did she know that looks can breed envy... or worse.",
			"The new case reeked of the same bad blood as that now half-forgotten case of the turncoat chef. A recipe for murder.",
			"I dragged myself out of my drink-addled torpor and called to the shadowy figure at my door - come in - because if I didn't take a new case I'd be through my bottle by noon.",
			"Nursing my scotch, I turned my gaze upward and spotted trouble in the form of a bruiser with brass knuckles across the smoke-filled nightclub's cabaret.",
			"I didn't even know who she was. Just stumbled across a girl and four toughs. Took her home and the mayor named me a hero.",
			"She was a flapper and a swinger, but she was also in some hot water. Told me she'd make it worth my while if I could get her out of it. I told her that I wanted payment in cold hard simoleons.",
			"What he did just didn't compare. He killed an innocent person. What drives a man to kill in cold blood? I didn't want to hang around and find out.",
			"I breathed in the smoke of the underground speakeasy like a fish breathes water. The brass at the precinct couldn't understand: I was in my element.",
			"I put enough holes in the man to drop a goliath, but he kept coming. Some kind of blood-fueled hatred. The adrenaline of a dying man can snap bones in one last moment of spite. I can still see the anger in those dying eyes.",
			"Charlie's SPS sang its monotone dirge somewhere deep in the tunnels. I'd told him to watch his back, but the blood of rookies flows hot and fast. I took a long swig of scotch and lit a cigarette. Another good man lost.",
			"The scene was a mess. Three bodies, or what was left of them, the floor covered in blood and strange markings. I thought the shift couldn't possibly get any worse. A flash of blood red on pitch black in the corner of my eye proved me wrong.",
			"The martini was as dry as the barkeep's humor. How do I always find myself in this run-down hovel, I wondered as I lost myself in the drink.",
			"The coroner looked up from his papers and nodded at me. The mutilated body was none other than my damsel in distress. I cursed under my breath. Who would pay me now?"))

/datum/reagent/ethanol/rags_to_riches
	name = "Rags to Riches"
	id = RAGSTORICHES
	description = "The Spaceman Dream, incarnated as a cocktail."
	color = "#664300"
	dupeable = FALSE
	glass_icon_state = "ragstoriches"
	glass_name = "\improper Rags to Riches"

/datum/reagent/ethanol/rags_to_riches/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(!M.loc || prob(70))
		return
	playsound(M, pick('sound/items/polaroid1.ogg','sound/items/polaroid2.ogg'), 50, 1)
	dispense_cash(rand(5,15),get_turf(M))

/datum/reagent/ethanol/bad_touch
	name = "Bad Touch"
	id = BAD_TOUCH
	description = "On the scale of bad touches, somewhere between 'fondled by clown' and 'brushed by supermatter shard'."
	color = "#664300"
	glass_icon_state = "bad_touch"
	glass_name = "\improper Bad Touch"

/datum/reagent/ethanol/bad_touch/on_mob_life(var/mob/living/M) //Hallucinate and take hallucination damage.
	if(..())
		return 1
	M.hallucination = max(M.hallucination, 10)
	M.halloss += 5

/datum/reagent/ethanol/electric_sheep
	name = "Electric Sheep"
	id = ELECTRIC_SHEEP
	description = "Silicons dream of this."
	color = "#664300"
	custom_metabolism = 1
	glass_icon_state = "electric_sheep"
	glass_name = "\improper Electric Sheep"

/datum/reagent/ethanol/electric_sheep/on_mob_life(var/mob/living/M) //If it's human, shoot sparks every tick! If MoMMI, cause alcohol effects.
	if(..())
		return 1
	if(ishuman(M))
		spark(M, 5, FALSE)

/datum/reagent/ethanol/electric_sheep/reaction_mob(var/mob/living/M)
	if(isrobot(M))
		M.Jitter(20)
		M.Dizzy(20)
		M.druggy = max(M.druggy, 60)

/datum/reagent/ethanol/suicide
	name = "Suicide"
	id = SUICIDE
	description = "It's only tolerable because of the added alcohol."
	color = "#664300"
	custom_metabolism = 2
	glass_icon_state = "suicide"
	glass_name = "\improper Suicide"

/datum/reagent/ethanol/suicide/on_mob_life(var/mob/living/M)  //Instant vomit. Every tick.
	if(..())
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.vomit(0,1)

/datum/reagent/ethanol/metabuddy
	name = "Metabuddy"
	id = METABUDDY
	description = "Ban when?"
	color = "#664300"
	var/global/list/datum/mind/metaclub = list()
	glass_icon_state = "metabuddy"
	glass_name = "\improper Metabuddy"
	glass_desc = "The glass is etched with the name of a very deserving spaceman. There's a special note etched in the bottom..."

/datum/reagent/ethanol/metabuddy/on_mob_life(var/mob/living/L)
	if(..())
		return 1
	var/datum/mind/LM = L.mind
	if(!metaclub.Find(LM) && LM)
		metaclub += LM
		var/datum/mind/new_buddy = LM
		for(var/datum/mind/M in metaclub) //Update metaclub icons
			if(M.current.client && new_buddy.current && new_buddy.current.client)
				var/imageloc = new_buddy.current
				var/imagelocB = M.current
				if(istype(M.current.loc,/obj/mecha))
					imageloc = M.current.loc
					imagelocB = M.current.loc
				var/image/I = image('icons/mob/HUD.dmi', loc = imageloc, icon_state = "metaclub")
				I.plane = ANTAG_HUD_PLANE
				M.current.client.images += I
				var/image/J = image('icons/mob/HUD.dmi', loc = imagelocB, icon_state = "metaclub")
				J.plane = ANTAG_HUD_PLANE
				new_buddy.current.client.images += J

/datum/reagent/ethanol/waifu
	name = "Waifu"
	id = WAIFU
	description = "Don't drink more than one waifu if you value your laifu."
	color = "#D0206F"
	glass_icon_state = "waifu"
	glass_name = "\improper Waifu"

/datum/reagent/ethanol/waifu/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(holder.has_reagent(TOMBOY))
		return
	else
		if(M.gender == MALE)
			M.setGender(FEMALE)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!M.is_wearing_item(/obj/item/clothing/under/schoolgirl))
				var/turf/T = get_turf(H)
				T.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/effects/rejuvenate.ogg',anim_plane = MOB_PLANE)
				H.visible_message("<span class='warning'>[H] dons her magical girl outfit in a burst of light!</span>")
				var/obj/item/clothing/under/schoolgirl/S = new /obj/item/clothing/under/schoolgirl(get_turf(H))
				if(H.w_uniform)
					H.u_equip(H.w_uniform, 1)
				H.equip_to_slot(S, slot_w_uniform)
				holder.remove_reagent(WAIFU,4) //Generating clothes costs extra reagent
		M.regenerate_icons()

/datum/reagent/ethanol/husbando
	name = "Husbando"
	id = HUSBANDO
	description = "You talkin' shit about my husbando?"
	color = "#2043D0"
	glass_icon_state = "husbando"
	glass_name = "\improper Husbando"

/datum/reagent/ethanol/husbando/on_mob_life(var/mob/living/M) //it's copypasted from waifu
	if(..())
		return 1
	if(holder.has_reagent(TOMBOY))
		return
	else
		if(M.gender == FEMALE)
			M.setGender(MALE)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!M.is_wearing_item(/obj/item/clothing/under/callum))
				var/turf/T = get_turf(H)
				T.turf_animation('icons/effects/96x96.dmi',"manexplode",-32,0,MOB_LAYER+1,'sound/items/poster_ripped.ogg',anim_plane = MOB_PLANE)
				H.visible_message("<span class='warning'>[H] reveals his true outfit in a vortex of ripped clothes!</span>")
				var/obj/item/clothing/under/callum/C = new /obj/item/clothing/under/callum(get_turf(H))
				if(H.w_uniform)
					H.u_equip(H.w_uniform, 1)
				H.equip_to_slot(C, slot_w_uniform)
				holder.remove_reagent(HUSBANDO,4)
		M.regenerate_icons()

/datum/reagent/ethanol/tomboy
	name = "Tomboy"
	id = TOMBOY
	description = "Best girl."
	color = "#20D03B"
	glass_icon_state = "tomboy"
	glass_name = "\improper Tomboy"

/datum/reagent/ethanol/tomboy/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(M.gender == MALE)
		M.setGender(FEMALE)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!M.is_wearing_item(/obj/item/clothing/under/callum))
			var/turf/T = get_turf(H)
			T.turf_animation('icons/effects/96x96.dmi',"manexplode",-32,0,MOB_LAYER+1,'sound/items/poster_ripped.ogg',anim_plane = MOB_PLANE)
			H.visible_message("<span class='warning'>[H] reveals her true outfit in a vortex of ripped clothes!</span>")
			var/obj/item/clothing/under/callum/C = new /obj/item/clothing/under/callum(get_turf(H))
			if(H.w_uniform)
				H.u_equip(H.w_uniform, 1)
			H.equip_to_slot(C, slot_w_uniform)
			holder.remove_reagent(TOMBOY,4)
	M.regenerate_icons()

/datum/reagent/ethanol/scientists_serendipity
	name = "Scientist's Serendipity"
	id = SCIENTISTS_SERENDIPITY
	description = "Go ahead and blow the research budget on drinking this." //Can deconstruct a glass with this for loadsoftech
	color = "#664300"
	custom_metabolism = 0.01
	dupeable = FALSE

/datum/reagent/ethanol/scientists_serendipity/when_drinkingglass_master_reagent(var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/D)
	if(volume < 10)
		glass_icon_state = "scientists_surprise"
		glass_name = "\improper Scientist's Surprise"
		glass_desc = "There is as yet insufficient data for a meaningful answer."
		D.origin_tech = ""

	else if(volume < 50)
		glass_icon_state = "scientists_serendipity"
		glass_name = "\improper Scientist's Serendipity"
		glass_desc = "Knock back a cold glass of R&D."
		D.origin_tech = "materials=7;engineering=3;plasmatech=2;powerstorage=4;bluespace=6;combat=3;magnets=6;programming=3"

	else
		glass_icon_state = "scientists_serendipity"
		glass_name = "\improper Scientist's Sapience"
		glass_desc = "Why research what has already been catalogued?"
		D.origin_tech = "materials=10;engineering=5;plasmatech=4;powerstorage=5;bluespace=10;biotech=5;combat=6;magnets=6;programming=5;illegal=1;nanotrasen=1;syndicate=2" //Maxes everything but Illegal and Anomaly

/datum/reagent/ethanol/beepskyclassic
	name = "Beepsky Classic"
	id = BEEPSKY_CLASSIC
	description = "Some believe that the more modern Beepsky Smash was introduced to make this drink more popular."
	color = "#664300" //rgb: 102, 67, 0
	custom_metabolism = 2 //Ten times the normal rate.
	glass_icon_state = "beepsky_classic"
	name = "\improper Beepsky Classic"

/datum/reagent/ethanol/beepskyclassic/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.job in list("Security Officer", "Head of Security", "Detective", "Warden"))
			playsound(H, 'sound/voice/halt.ogg', 100, 1, 0)
		else
			H.Knockdown(10)
			H.Stun(10)
			playsound(H, 'sound/weapons/Egloves.ogg', 100, 1, -1)

/datum/reagent/ethanol/spiders
	name = "Spiders"
	id = SPIDERS
	description = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA."
	color = "#666666" //rgb(102, 102, 102)
	custom_metabolism = 0.01 //Spiders really 'hang around'
	glass_icon_state = "spiders"
	name = "\improper This glass is full of spiders"
	glass_desc = "Seriously, dude, don't touch it."

/datum/reagent/ethanol/spiders/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.take_organ_damage(REM, 0) //Drinking a glass of live spiders is bad for you.
	if(holder.get_reagent_amount(SPIDERS)>=4) //The main reason we need to have a minimum cost rather than just high custom metabolism is so that someone can't give themselves an IV of spiders for "fun"
		new /mob/living/simple_animal/hostile/giant_spider/spiderling(get_turf(M))
		holder.remove_reagent(SPIDERS,4)
		M.emote("scream", , , 1)
		M.visible_message("<span class='warning'>[M] recoils as a spider emerges from \his mouth!</span>")

/datum/reagent/ethanol/weedeater
	name = "Weed Eater"
	id = WEED_EATER
	description = "The vegetarian equivalant of a snake eater."
	color = "#009933" //rgb(0, 153, 51)
	glass_icon_state = "weed_eater"
	glass_name = "\improper Weed Eater"

/datum/reagent/ethanol/weedeater/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	var/spell = /spell/targeted/genetic/eat_weed
	if(!(locate(spell) in M.spell_list))
		to_chat(M, "<span class='notice'>You feel hungry like the diona.</span>")
		M.add_spell(spell)

/datum/reagent/ethanol/magicadeluxe
	name = "Magica Deluxe"
	id = MAGICADELUXE
	description = "Makes you feel enchanted until the aftertaste hits you."
	color = "#009933" //rgb(0, 153, 51)
	glass_icon_state = "magicadeluxe"
	glass_name = "magica deluxe"

/datum/reagent/ethanol/magicadeluxe/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(M.spell_list.len)
		return //one per customer, magicians need not apply
	var/list/fake_spells = list()
	var/list/choices = getAllWizSpells()
	for(var/i=5; i > 0; i--)
		var/spell/passive/fakespell = new /spell/passive
		var/name_modifier = pick("Efficient ","Efficient ","Free ", "Instant ")
		fakespell.spell_flags = STATALLOWED
		var/spell/readyup = pick_n_take(choices)
		var/spell/fromwhichwetake = new readyup
		fakespell.name = fromwhichwetake.name
		fakespell.desc = fromwhichwetake.desc
		fakespell.hud_state = fromwhichwetake.hud_state
		fakespell.invocation = "MAH'JIK"
		fakespell.invocation_type = SpI_SHOUT
		fakespell.charge_type = Sp_CHARGES
		fakespell.charge_counter = 0
		fakespell.charge_max = 1
		if(prob(20))
			fakespell.name = name_modifier + fakespell.name
		fake_spells += fakespell
	if(!M.spell_list.len) //just to be sure
		to_chat(M, "<span class='notice'>You feel magical!</span>")
		playsound(M,'sound/effects/summon_guns.ogg', 50, 1)
		for (var/spell/majik in fake_spells)
			M.add_spell(majik)

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/spell/thisisdumb = new /spell/targeted/equip_item/robesummon
			H.add_spell(thisisdumb)
			thisisdumb.charge_type = Sp_CHARGES
			thisisdumb.charge_counter = 1
			thisisdumb.charge_max = 1
			H.cast_spell(thisisdumb,list(H))
		holder.remove_reagent(MAGICADELUXE,5)

/datum/reagent/ethanol/drink/gravsingulo
	name = "Gravitational Singulo"
	id = GRAVSINGULO
	description = "A true gravitational anomaly."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113
	custom_metabolism = 1 // A bit faster to prevent easy singuloosing
	dizzy_adj = 15
	slurr_adj = 15
	glass_icon_state = "gravsingulo"
	glass_name = "\improper Gravitational Singulo"
	glass_desc = "The destructive, murderous Lord Singuloth, patron saint of Bargineering, now in grape flavor!"

/datum/reagent/ethanol/drink/gravsingulo/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	switch(tick)
		if(0 to 65)
			if(prob(5))
				to_chat(M,"<span class='notice'>You feel [pick("dense", "heavy", "attractive")].</span>")
		if(65 to 130)
			if(prob(5))
				to_chat(M,"<span class='notice'>You feel [pick("like the world revolves around you", "like your own centre of gravity", "others drawn to you")].</span>")
		if(130 to 250)
			if(prob(5))
				to_chat(M,"<span class='warning'>You feel [pick("like your insides are being pulled in", "torn apart", "sucked in")]!</span>")
			M.adjustBruteLoss(1)
		if(250 to INFINITY)
			M.visible_message("<span class='alert'>[M]'s entire mass collapses inwards, leaving a singularity behind!</span>","<span class='alert'>Your entire mass collapses inwards, leaving a singularity behind!</span>")
			var/turf/T = get_turf(M)
			//Can only make a singulo if active mind, otherwise a singulo toy
			if(M.mind)
				var/obj/machinery/singularity/S = new (T)
				S.consume(M)
			else
				new /obj/item/toy/spinningtoy(T)
				M.gib()
	//Will pull items in a range based on time in system
	for(var/atom/X in orange((tick+30)/50, M))
		if(X.type == /atom/movable/lighting_overlay)//since there's one on every turf
			continue
		X.singularity_pull(M, tick/50, tick/50)

/datum/reagent/drink/tea/gravsingularitea
	name = "Gravitational Singularitea"
	id = GRAVSINGULARITEA
	description = "Spirally!"
	custom_metabolism = 1 // A bit faster to prevent easy singuloosing
	mug_icon_state = "gravsingularitea"
	mug_name = "\improper Gravitational Singularitea"
	mug_desc = "The destructive, murderous Lord Singuloth, patron saint of Bargineering, now in herbal flavour!"

/datum/reagent/drink/tea/gravsingularitea/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	switch(tick)
		if(0 to 65)
			if(prob(5))
				to_chat(M,"<span class='notice'>You feel [pick("dense", "heavy", "attractive")].</span>")
		if(65 to 130)
			if(prob(5))
				to_chat(M,"<span class='notice'>You feel [pick("like the world revolves around you", "like your own centre of gravity", "others drawn to you")].</span>")
		if(130 to 250)
			if(prob(5))
				to_chat(M,"<span class='warning'>You feel [pick("like your insides are being pulled in", "torn apart", "sucked in")]!</span>")
			M.adjustBruteLoss(1)
		if(250 to INFINITY)
			M.visible_message("<span class='alert'>[M]'s entire mass collapses inwards, leaving a singularity behind!</span>","<span class='alert'>Your entire mass collapses inwards, leaving a singularity behind!</span>")
			var/turf/T = get_turf(M)
			//Can only make a singulo if active mind, otherwise a singulo toy
			if(M.mind)
				var/obj/machinery/singularity/S = new (T)
				S.consume(M)
			else
				new /obj/item/toy/spinningtoy(T)
				M.gib()
	//Will pull items in a range based on time in system
	for(var/atom/X in orange((tick+30)/50, M))
		if(X.type == /atom/movable/lighting_overlay)//since there's one on every turf
			continue
		X.singularity_pull(M, tick/50, tick/50)

/datum/reagent/ethanol/drink
	id = EXPLICITLY_INVALID_REAGENT_ID
	pass_out = 250

/datum/reagent/ethanol/drink/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.dizziness += 5

/datum/reagent/ethanol/drink/rum
	name = "Rum"
	id = RUM
	description = "Popular with the sailors. Not very popular with anyone else."
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "rumglass"
	glass_desc = "Now you want to pray for a pirate suit, don't you?"

/datum/reagent/ethanol/drink/vodka
	name = "Vodka"
	id = VODKA
	description = "The drink and fuel of choice of Russians galaxywide."
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "ginvodkaglass"
	glass_desc = "The glass contain wodka. Xynta."

/datum/reagent/ethanol/drink/sake
	name = "Sake"
	id = SAKE
	description = "Anime's favorite drink."
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "sakeglass"
	glass_desc = "A glass of sake."

/datum/reagent/ethanol/drink/sake/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.mind.GetRole(NINJA))
			M.nutrition += nutriment_factor //double of nothing is still... nothing. Change in future PR.
			if(M.getOxyLoss() && prob(50))
				M.adjustOxyLoss(-2)
			if(M.getBruteLoss() && prob(60))
				M.heal_organ_damage(2, 0)
			if(M.getFireLoss() && prob(50))
				M.heal_organ_damage(0, 2)
			if(M.getToxLoss() && prob(50))
				M.adjustToxLoss(-2)
			if(M.dizziness != 0)
				M.dizziness = max(0, M.dizziness - 15)
			if(M.confused != 0)
				M.remove_confused(5)

/datum/reagent/ethanol/drink/glasgow
	name = "Glasgow Deadrum"
	id = GLASGOW
	description = "Makes you feel like you had one hell of a party."
	color = "#662D1D" //rgb: 101, 44, 29
	slur_start = 1
	confused_start = 1

/datum/reagent/ethanol/drink/tequila
	name = "Tequila"
	id = TEQUILA
	description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty, hombre?"
	color = "#A8B0B7" //rgb: 168, 176, 183
	glass_icon_state = "tequilaglass"
	glass_desc = "Now all that's missing is the weird colored shades!"

/datum/reagent/ethanol/drink/vermouth
	name = "Vermouth"
	id = VERMOUTH
	description = "You suddenly feel a craving for a martini..."
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "vermouthglass"
	glass_desc = "You wonder why you're even drinking this straight."

/datum/reagent/ethanol/drink/wine
	name = "Wine"
	id = WINE
	description = "A premium alcoholic beverage made from fermented grape juice."
	color = "#7E4043" //rgb: 126, 64, 67
	dizzy_adj = 2
	slur_start = 65
	confused_start = 145
	glass_icon_state = "wineglass"
	glass_desc = "A drink enjoyed by intellectuals and middle-aged female alcoholics alike."

/datum/reagent/ethanol/drink/cognac
	name = "Cognac"
	id = COGNAC
	description = "A sweet and strongly alcoholic drink, twice distilled and left to mature for several years. Classy as fornication."
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 4
	confused_start = 115
	glass_icon_state = "cognacglass"
	glass_desc = "You feel aristocratic just holding this."

/datum/reagent/ethanol/drink/hooch
	name = "Hooch"
	id = HOOCH
	description = "A suspiciously viscous off-brown liquid that reeks of fuel. Do you really want to drink that?"
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 6
	slurr_adj = 5
	slur_start = 35
	confused_start = 90
	pass_out = 250
	glass_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."

/datum/reagent/ethanol/drink/triplesec
	name = "Triple Sec"
	id = TRIPLESEC
	description = "Clear, dry, tastes like oranges. A necessity in any bartender's shelves."
	color = "#D1D1D1" //rgb: 209, 209, 209
	glass_icon_state = "triplesecglass"
	glass_desc = "Triple Sec, a clear orange liquor with a syrupy texture. Maybe mix it with something, you weirdo."

/datum/reagent/ethanol/drink/schnapps
	name = "Schnapps"
	id = SCHNAPPS
	description = "Tastes like all the fruits in the galaxy."
	color = "#FFAC38" //rgb: 255, 172, 56
	glass_icon_state = "schnappsglass"
	glass_desc = "A glass of indescernibly fruity schnapps."

/datum/reagent/ethanol/drink/bitters
	name = "Bitters"
	id = BITTERS
	description = "Dark, bitter alcohol. Who in their right mind drinks this straight?"
	color = "#361412" //rgb: 54, 20, 18
	glass_icon_state = "bittersglass"
	glass_desc = "A glass of dark and, well, bitter, bitters."

/datum/reagent/ethanol/drink/champagne
	name = "Champagne"
	id = CHAMPAGNE
	description = "Often found sprayed all over sports victors or at New Years parties."
	color = "#FAD6A5" //rgb: 250, 214, 165
	glass_icon_state = "champagneglass"
	glass_desc = "A fancy, bubbly glass of sparkling yellow champagne!"

/datum/reagent/ethanol/drink/bluecuracao
	name = "Blue Curacao"
	id = BLUECURACAO
	description = "Essentially a sweeter, bluer form of Triple Sec."
	color = "#3AD1F0" //rgb: 58, 209, 240
	glass_icon_state = "curacaoglass"
	glass_desc = "Why's it blue if it tastes like an orange?"

/datum/reagent/ethanol/drink/ale
	name = "Ale"
	id = ALE
	description = "A dark alcoholic beverage made from malted barley and yeast."
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "aleglass"
	glass_desc = "A cold pint of delicious ale."

/datum/reagent/ethanol/drink/thirteenloko
	name = "Thirteen Loko"
	id = THIRTEENLOKO
	description = "A potent mixture of caffeine and alcohol."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#102000" //rgb: 16, 32, 0
	glass_icon_state = "thirteen_loko_glass"
	glass_desc = "This is a glass of Thirteen Loko. It appears to be of the highest quality. The drink, not the glass."

/datum/reagent/ethanol/drink/thirteenloko/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.drowsyness = max(0, M.drowsyness - 7)
	M.Jitter(1)

/datum/reagent/ethanol/drink/pinklady
	name = "Pink Lady"
	id = PINKLADY
	description = "A pink alcoholic beverage made primarily from gin."
	color = "#ff6a8f"
	glass_icon_state = "pinklady"
	glass_desc = "A delightful blush-pink cocktail, garnished with a cherry and the rind of a lemon."

/////////////////////////////////////////////////////////////////Cocktail Entities//////////////////////////////////////////////

/datum/reagent/ethanol/drink/bilk
	name = "Bilk"
	id = BILK
	description = "This appears to be beer mixed with milk. Disgusting."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#AA9988" //rgb: 170, 153, 136
	density = 0.89
	specheatcap = 2.46
	glass_desc = "A brew of milk and beer. For alcoholics who fear osteoporosis."

/datum/reagent/ethanol/drink/atomicbomb
	name = "Atomic Bomb"
	id = ATOMICBOMB
	description = "Nuclear proliferation never tasted so good."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#666300" //rgb: 102, 99, 0
	glass_icon_state = "atomicbombglass"
	glass_name = "\improper Atomic Bomb"
	glass_desc = "NanoTrasen does not take legal responsibility for your actions after imbibing."

/datum/reagent/ethanol/drink/threemileisland
	name = "Three Mile Island Iced Tea"
	id = THREEMILEISLAND
	description = "Made for a woman. Strong enough for a man."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#666340" //rgb: 102, 99, 64
	glass_icon_state = "threemileislandglass"
	glass_name = "\improper Three Mile Island Iced Tea"
	glass_desc = "A glass of this is sure to prevent a meltdown. Or cause one."

/datum/reagent/ethanol/drink/goldschlager
	name = "Goldschlager"
	id = GOLDSCHLAGER
	description = "100 proof cinnamon schnapps with small gold flakes mixed in."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	density = 2.72
	specheatcap = 0.32
	glass_icon_state = "goldschlagerglass"
	glass_desc = "A schnapps with tiny flakes of gold floating in it."

/datum/reagent/ethanol/drink/patron
	name = "Patron"
	id = PATRON
	description = "Tequila with small flakes of silver in it."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#585840" //rgb: 88, 88, 64
	density = 1.84
	specheatcap = 0.59
	glass_icon_state = "patronglass"
	glass_desc = "Drinking Patron in the bar, with all the subpar ladies."

/datum/reagent/ethanol/drink/gintonic
	name = "Gin and Tonic"
	id = GINTONIC
	description = "An all time classic, mild cocktail."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "gintonicglass"
	glass_desc = "A mild but still great cocktail. Drink up, like a true Englishman."

/datum/reagent/ethanol/drink/cuba_libre
	name = "Cuba Libre"
	id = CUBALIBRE
	description = "Rum, mixed with cola. Viva la revolution."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#3E1B00" //rgb: 62, 27, 0
	glass_icon_state = "cubalibreglass"
	glass_name = "\improper Cuba Libre"
	glass_desc = "A classic mix of rum and cola. Viva la revolution."

/datum/reagent/ethanol/drink/whiskey_cola
	name = "Whiskey Cola"
	id = WHISKEYCOLA
	description = "Whiskey, mixed with cola. Surprisingly refreshing."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#3E1B00" //rgb: 62, 27, 0
	glass_icon_state = "whiskeycolaglass"
	glass_desc = "An innocent-looking mixture of cola and whiskey. Delicious."

/datum/reagent/ethanol/drink/martini
	name = "Classic Martini"
	id = MARTINI
	description = "Vermouth with gin. Not quite how 007 enjoyed it, but still delicious."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "martiniglass"
	glass_desc = "Shaken, not stirred."

/datum/reagent/ethanol/drink/vodkamartini
	name = "Vodka Martini"
	id = VODKAMARTINI
	description = "Vodka with gin. Not quite how 007 enjoyed it, but still delicious."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "martiniglass"
	glass_desc = "A bastardisation of the classic martini. Still great."

/datum/reagent/ethanol/drink/sakemartini
	name = "Sake Martini"
	id = SAKEMARTINI
	description = "A martini mixed with sake instead of vermouth. Has a fruity, oriental flavor."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "martiniglass"
	glass_desc = "An oriental spin on the martini, mixed with sake instead of vermouth."

/datum/reagent/ethanol/drink/white_russian
	name = "White Russian"
	id = WHITERUSSIAN
	description = "That's just, like, your opinion, man..."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A68340" //rgb: 166, 131, 64
	glass_icon_state = "whiterussianglass"
	glass_name = "\improper White Russian"
	glass_desc = "A very nice looking drink. But that's just, like, your opinion, man."

/datum/reagent/ethanol/drink/screwdrivercocktail
	name = "Screwdriver"
	id = SCREWDRIVERCOCKTAIL
	description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A68310" //rgb: 166, 131, 16
	glass_icon_state = "screwdriverglass"
	glass_name = "\improper Screwdriver"
	glass_desc = "A simple, yet superb mixture of vodka and orange juice. Just the thing for the tired engineer."

/datum/reagent/ethanol/drink/booger
	name = "Booger"
	id = BOOGER
	description = "Ewww..."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A68310" //rgb: 166, 131, 16
	glass_icon_state = "booger"
	glass_name = "\improper Booger"
	glass_desc = "The color reminds you of something that came out of the clown's nose."

/datum/reagent/ethanol/drink/bloody_mary
	name = "Bloody Mary"
	id = BLOODYMARY
	description = "A strange yet pleasant mixture made of vodka, tomato and lime juice. Or at least you think the red stuff is tomato juice."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "bloodymaryglass"
	glass_name = "\improper Bloody Mary"
	glass_desc = "Tomato juice, mixed with vodka and a lil' bit of lime. Tastes like liquid murder."

/datum/reagent/ethanol/drink/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = GARGLEBLASTER
	description = "Whoah, this stuff looks volatile!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "gargleblasterglass"
	glass_name = "\improper Pan-Galactic Gargle Blaster"
	glass_desc = "Does... does this mean that Arthur and Ford are on the station? Oh joy."

/datum/reagent/ethanol/drink/brave_bull
	name = "Brave Bull"
	id = BRAVEBULL
	description = "A mixture of tequila and coffee liqueur."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "bravebullglass"
	glass_name = "\improper Brave Bull"
	glass_desc = "Tequila and coffee liqueur. Kicks like a bull."

/datum/reagent/ethanol/drink/tequila_sunrise
	name = "Tequila Sunrise"
	id = TEQUILASUNRISE
	description = "Tequila and orange juice. Much like a Screwdriver, only Mexican."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "tequilasunriseglass"
	glass_name = "\improper Tequila Sunrise"
	glass_desc = "Oh great, now you feel nostalgic about sunrises back on Terra..."

/datum/reagent/ethanol/drink/toxins_special
	name = "Toxins Special"
	id = TOXINSSPECIAL
	description = "This thing is FLAMING! CALL THE DAMN SHUTTLE!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "toxinsspecialglass"
	glass_name = "\improper Toxins Special"
	glass_desc = "Whoah, this thing is on FIRE!"

/datum/reagent/ethanol/drink/beepsky_smash
	name = "Beepsky Smash"
	id = BEEPSKYSMASH
	description = "This drink is the law."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "beepskysmashglass"
	glass_name = "\improper Beepsky Smash"
	glass_desc = "Heavy, hot and strong. Best enjoyed with your hands behind your back."

/datum/reagent/ethanol/drink/irish_cream
	name = "Irish Cream"
	id = IRISHCREAM
	description = "Whiskey-imbued cream. What else could you expect from the Irish."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "irishcreamglass"
	glass_desc = "It's cream, mixed with whiskey. What else would you expect from the Irish?"

/datum/reagent/ethanol/drink/manly_dorf
	name = "The Manly Dorf"
	id = MANLYDORF
	description = "A dwarfy concoction made from ale and beer. Intended for stout dwarves only."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "manlydorfglass"
	glass_name = "The Manly Dorf"
	glass_desc = "A dwarfy concoction made from ale and beer. Intended for stout dwarves only."

/datum/reagent/ethanol/drink/longislandicedtea
	name = "Long Island Iced Tea"
	id = LONGISLANDICEDTEA
	description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "longislandicedteaglass"
	glass_name = "\improper Long Island Iced Tea"

/datum/reagent/ethanol/drink/mudslide
	name = "Mudslide"
	id = MUDSLIDE
	description = "Like a milkshake, but for irresponsible adults."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#b6ac94" //rgb: 182, 172, 148
	glass_icon_state = "mudslide"
	glass_name = "\improper Mudslide"

/datum/reagent/ethanol/drink/sacrificial_mary
	name = "Sacrificial Mary"
	id = SACRIFICIAL_MARY
	description = "Fresh Altar-To-Table taste in every sip."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#bd1c1e" //rgb: 189, 28, 30
	glass_icon_state = "sacrificialmary"
	glass_name = "\improper Sacrificial Mary"

/datum/reagent/ethanol/drink/boysenberry_blizzard
	name = "Boysenberry Blizzard"
	id = BOYSENBERRY_BLIZZARD
	description = "Don't stick your tongue out for these snowflakes!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#aa4cbd" //rgb: 170, 76, 189
	glass_icon_state = "boysenberryblizzard"
	glass_name = "\improper Boysenberry Blizzard"

/datum/reagent/ethanol/drink/moonshine
	name = "Moonshine"
	id = MOONSHINE
	description = "You've really hit rock bottom now... your liver packed its bags and left last night."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/drink/midnightkiss
	name = "Midnight Kiss"
	id = MIDNIGHTKISS
	description = "Vodka mixed with Blue Curacao and topped with champagne. Bubbly!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#82f0ff" //rgb: 130, 240, 255
	glass_icon_state = "midnightkiss"
	glass_name = "\improper Midnight Kiss"

/datum/reagent/ethanol/drink/cosmopolitan
	name = "Cosmopolitan"
	id = COSMOPOLITAN
	description = "A Cosmopolitan, the poster child of fruity cocktails."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#d64054" //rgb: 214, 64, 84
	glass_icon_state = "cosmopolitan"
	glass_name = "cosmopolitan"

/datum/reagent/ethanol/drink/corpsereviver
	name = "Corpse Reviver No. 2"
	id = CORPSEREVIVER
	description = "Hair of the dog taken to one of its most logical extremes."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFFFFF" //rgb: 255, 255, 255
	glass_icon_state = "corpsereviver"
	glass_name = "\improper Corpse Reviver No. 2"

/datum/reagent/ethanol/drink/bluelagoon
	name = "Blue Lagoon"
	id = BLUELAGOON
	description = "Goes best with swim trunks, a sea breeze, and a nice big beach."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#82f0ff" //rgb: 130, 240, 255
	glass_icon_state = "bluelagoon"
	glass_name = "\improper Blue Lagoon"

/datum/reagent/ethanol/drink/sexonthebeach
	name = "Sex On The Beach"
	id = SEXONTHEBEACH
	description = "Did you hear a bear just now?"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#fca668" //rgb: 252, 166, 104
	glass_icon_state = "sexonthebeach"
	glass_desc = "\improper Sex On The Beach"

/datum/reagent/ethanol/drink/americano
	name = "Americano"
	id = AMERICANO
	description = "Expensive soda water - the best way to improve a poor drink."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#872d12" //rgb: 135, 45, 18
	glass_icon_state = "americano"
	glass_name = "americano"

/datum/reagent/ethanol/drink/betweenthesheets
	name = "Between The Sheets"
	id = BETWEENTHESHEETS
	description = "This is basically just a sidecar with rum in it."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#f0d695" //rgb: 240, 214, 149
	glass_icon_state = "betweenthesheets"
	glass_name = "\improper Between The Sheets"

/datum/reagent/ethanol/drink/sidecar
	name = "Sidecar"
	id = SIDECAR
	description = "For those who still want a fruity cocktail, without the effeminate connotations of a Cosmo."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#99593c" //rgb: 153, 89, 60
	glass_icon_state = "sidecar"
	glass_name = "sidecar"

/datum/reagent/ethanol/drink/champagnecocktail
	name = "Champagne Cocktail"
	id = CHAMPAGNECOCKTAIL
	description = "Champagne, bitters, and cognac, garnished with a cherry. Very classy."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#fcdf95" //rgb: 252, 223, 149
	glass_icon_state = "champagnecocktail"
	glass_name = "Champagne cocktail"

/datum/reagent/ethanol/drink/espressomartini
	name = "Espresso Martini"
	id = ESPRESSOMARTINI
	description = "Two of any self respecting substance abuser's fixes in one drink!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#120705" //rgb: 18, 7, 5
	glass_icon_state = "espressomartini"
	glass_name = "espresso martini"

/datum/reagent/ethanol/drink/kamikaze
	name = "Kamikaze"
	id = KAMIKAZE
	description = "Banzai!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFFFFF" //rgb: 255, 255, 255
	glass_icon_state = "kamikaze"
	glass_name = "kamikaze"

/datum/reagent/ethanol/drink/mojito
	name = "Mojito"
	id = MOJITO
	description = "A giant pain in the ass to make on the best of days."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#c3f08d" //rgb: 195, 240, 141
	glass_icon_state = "mojito"
	glass_name = "mojito"

/datum/reagent/ethanol/drink/whiskeytonic
	name = "Whiskey Tonic"
	id = WHISKEYTONIC
	description = "Quinine makes everything taste better."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#fff9cf" //rgb: 255, 249, 207
	glass_icon_state = "whiskeytonic"
	glass_name = "\improper Whiskey Tonic"

/datum/reagent/ethanol/drink/moscowmule
	name = "Moscow Mule"
	id = MOSCOWMULE
	description = "Wait a minute, this isn't ginger beer..."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6e573f" //rgb: 110, 87, 63
	glass_icon_state = "moscowmule"
	glass_name = "\improper Moscow Mule"

/datum/reagent/ethanol/drink/cinnamonwhisky
	name = "Cinnamon Whisky"
	id = CINNAMONWHISKY
	description = "Cinnamon whisky. Feel the burn."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#f29224" //rgb: 242, 146, 36
	glass_icon_state = "fireballglass"
	glass_desc = "Red-hot cinnamon whisky in a shot glass."

/datum/reagent/ethanol/drink/c4cocktail
	name = "C-4 Cocktail"
	id = C4COCKTAIL
	description = "Kahlua and Cinnamon Whisky, a burning explosion of flavor - tastes like pain. And cinnamon."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#1f0802" //31, 8, 2
	glass_icon_state = "c4cocktail"
	glass_name = "\improper C-4 Cocktail"
	glass_desc = "Kahlua and Cinnamon Whisky, a burning explosion of cinnamon flavor."

/datum/reagent/ethanol/drink/dragonsblood
	name = "Dragon's Blood"
	id = DRAGONSBLOOD
	description = "Burning hot and bright red, just like the mythical namesake."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#b01522" //176, 21, 34
	glass_icon_state = "dragonsblood"
	glass_name = "\improper Dragon's Blood"
	flammable = 1
	light_color = "#540303"

/datum/reagent/ethanol/drink/dragonspit
	name = "Dragon's Spit"
	id = DRAGONSSPIT
	description = "The simplest idea possible; take something hot, and make it hotter."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#f29224" // 242, 146, 36
	glass_icon_state = "dragonsspit"
	glass_name = "\improper Dragon's Spit"
	light_color = "#ff7003"
	flammable = 1

/datum/reagent/ethanol/drink/firecider
	name = "Fire Cider"
	id = FIREBALLCIDER
	description = "Apples, alcohol, and cinnamon, a match made in heaven."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#f29224" // 242, 146, 36
	glass_icon_state = "fireballcider"
	glass_name = "\improper Fireball Cider"
	glass_desc = "A toasty hot glass of apple cider and cinnamon whisky - makes you feel warm and fuzzy inside."

/datum/reagent/ethanol/drink/cinnamontoastcocktail
	name = "Cinnamon Toast"
	id = CINNAMONTOASTCOCKTAIL
	description = "Rum, cream, and cinnamon whisky. Tastes a little like the milk you get out of a sugary cereal."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#f29224" // 242, 146, 36
	glass_icon_state = "cinnamontoastcocktail"
	glass_name = "\improper Cinnamon Toast Cocktail"
	glass_desc = "Kind of like drinking left-over cereal milk, but for people with a drinking problem."

/datum/reagent/ethanol/drink/manhattanfireball
	name = "Manhattan Fireball"
	id = MANHATTANFIREBALL
	description = "A timeless classic made with a burning hot twist."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#f29224" // 242, 146, 36
	glass_icon_state = "manhattanfireball"
	glass_name = "\improper Manhattan Fireball"
	light_color = "#540303"
	flammable = 1

/datum/reagent/ethanol/drink/fireballcola
	name = "Fireball Cola"
	id = FIREBALLCOLA
	description = "Like a Whiskey Cola, but with added painful burning sensation."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#f20224" //242, 146, 36
	glass_icon_state = "fireballcola"
	glass_name = "\improper Fireball Cola"
	glass_desc = "Cinnamon whisky and cola - like a regular whiskey cola, but with more burning."

/datum/reagent/ethanol/drink/firerita
	name = "Fire-rita"
	id = FIRERITA
	description = "Triple sec, Cinnamon Whisky, and Tequila, eugh. Less a cocktail more than throwing whatever's on the shelf in a glass."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#f0133c" //rgb: 240, 19, 60
	glass_icon_state = "firerita"
	glass_name = "firerita"
	glass_desc = "Looks pretty, offends a sane person's taste buds. Then again, anyone who orders this probably lacks one of those two traits."

/datum/reagent/ethanol/drink/magica
	name = "Magica"
	id = MAGICA
	description = "A bitter mix with a burning aftertaste."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#774F1B"
	glass_icon_state = "magica"
	glass_name = "magica"
	glass_desc = "Bitter, with an annoying aftertaste of spice. Supposedly inspired by wearers of bath robes."

/datum/reagent/ethanol/drink/b52
	name = "B-52"
	id = B52
	description = "Coffee, irish cream, and cognac. You will get bombed."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "b52glass"
	glass_name = "\improper B-52"
	light_color = "#000080"
	flammable = 1

/datum/reagent/ethanol/drink/irishcoffee
	name = "Irish Coffee"
	id = IRISHCOFFEE
	description = "Coffee served with irish cream. Regular cream just isn't the same."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "irishcoffeeglass"

/datum/reagent/ethanol/drink/margarita
	name = "Margarita"
	id = MARGARITA
	description = "On the rocks with salt on the rim. Arriba!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "margaritaglass"

/datum/reagent/ethanol/drink/black_russian
	name = "Black Russian"
	id = BLACKRUSSIAN
	description = "For the lactose-intolerant. Still as classy as a White Russian."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#360000" //rgb: 54, 0, 0
	glass_icon_state = "blackrussianglass"
	glass_name = "\improper Black Russian"
	glass_desc = "For the lactose-intolerant. Still as classy as a White Russian."

/datum/reagent/ethanol/drink/manhattan
	name = "Manhattan"
	id = MANHATTAN
	description = "The Detective's undercover drink of choice. He never could stomach gin..."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "manhattanglass"
	glass_name = "\improper Manhattan"

/datum/reagent/ethanol/drink/manhattan_proj
	name = "Manhattan Project"
	id = MANHATTAN_PROJ
	description = "A scientist's drink of choice, for thinking about how to blow up the station."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "proj_manhattanglass"
	glass_name = "\improper Manhattan Project"

/datum/reagent/ethanol/drink/whiskeysoda
	name = "Whiskey Soda"
	id = WHISKEYSODA
	description = "Ultimate refreshment."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "whiskeysodaglass2"

/datum/reagent/ethanol/drink/antifreeze
	name = "Anti-Freeze"
	id = ANTIFREEZE
	description = "The ultimate refreshment."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "antifreeze"
	glass_name = "\improper Anti-freeze"

/datum/reagent/ethanol/drink/barefoot
	name = "Barefoot"
	id = BAREFOOT
	description = "Barefoot and pregnant"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "b&p"
	glass_name = "\improper Barefoot"

/datum/reagent/ethanol/drink/snowwhite
	name = "Snow White"
	id = SNOWWHITE
	description = "Pale lager mixed with lemon-lime soda. Refreshing and sweet."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "snowwhite"
	glass_name = "\improper Snow White"

/datum/reagent/ethanol/drink/demonsblood
	name = "Demon's Blood"
	id = DEMONSBLOOD
	description = "AHHHH!!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 10
	slurr_adj = 10
	glass_icon_state = "demonsblood"
	glass_name = "\improper Demon's Blood"
	glass_desc = "Just looking at this thing makes the hair on the back of your neck stand up."

/datum/reagent/ethanol/drink/vodkatonic
	name = "Vodka and Tonic"
	id = VODKATONIC
	description = "For when a gin and tonic isn't Russian enough."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 4
	slurr_adj = 3
	glass_icon_state = "vodkatonicglass"
	glass_desc = "For when a gin and tonic isn't Russian enough."

/datum/reagent/ethanol/drink/ginfizz
	name = "Gin Fizz"
	id = GINFIZZ
	description = "Refreshingly lemony, deliciously dry."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 4
	slurr_adj = 3
	glass_icon_state = "ginfizzglass"
	glass_name = "\improper Gin Fizz"

/datum/reagent/ethanol/drink/bahama_mama
	name = "Bahama Mama"
	id = BAHAMA_MAMA
	description = "Tropical cocktail."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "bahama_mama"
	glass_name = "\improper Bahama Mama"
	glass_desc = "A delicious tropical cocktail."

/datum/reagent/ethanol/drink/pinacolada
	name = "Pina Colada"
	id = PINACOLADA
	description = "Sans pineapple."
	reagent_state = REAGENT_STATE_LIQUID
	color = "F2F5BF" //rgb: 242, 245, 191
	glass_icon_state = "pinacolada"
	glass_name = "\improper Pina Colada"
	glass_desc = "If you like this and getting caught in the rain, come with me and escape."

/datum/reagent/ethanol/drink/singulo
	name = "Singulo"
	id = SINGULO
	description = "A gravitational anomaly."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113
	dizzy_adj = 15
	slurr_adj = 15
	glass_icon_state = "singulo"
	glass_name = "\improper Singulo"
	glass_desc = "IT'S LOOSE!"

/datum/reagent/ethanol/drink/sangria
	name = "Sangria"
	id = SANGRIA
	description = "So tasty you won't believe it's alcohol."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#53181A" //rgb: 83, 24, 26
	dizzy_adj = 2
	slur_start = 65
	confused_start = 145
	glass_icon_state = "sangria"
	glass_name = "\improper Sangria"

/datum/reagent/ethanol/drink/sbiten
	name = "Sbiten"
	id = SBITEN
	description = "A spicy vodka."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "sbitenglass"
	glass_desc = "A spicy mix of vodka and spice. Very hot."

/datum/reagent/ethanol/drink/sbiten/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(M.bodytemperature < 360)
		M.bodytemperature = min(360, M.bodytemperature + 50) //310 is the normal bodytemp. 310.055

/datum/reagent/ethanol/drink/devilskiss
	name = "Devil's Kiss"
	id = DEVILSKISS
	description = "Creepy time!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A68310" //rgb: 166, 131, 16
	glass_icon_state = "devilskiss"
	glass_name = "\improper Devil's Kiss"

/datum/reagent/ethanol/drink/red_mead
	name = "Red Mead"
	id = RED_MEAD
	description = "A crimson beverage consumed by space vikings. The coloration is from berries... you hope."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "red_meadglass"

/datum/reagent/ethanol/drink/mead
	name = "Mead"
	id = MEAD
	description = "A beverage consumed by space vikings on their long raids and rowdy festivities."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "meadglass"

/datum/reagent/ethanol/drink/iced_beer
	name = "Iced Beer"
	id = ICED_BEER
	description = "A beer so frosty the air around it freezes."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "iced_beerglass"

/datum/reagent/ethanol/drink/iced_beer/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(M.bodytemperature < T0C+33)
		M.bodytemperature = min(T0C+33, M.bodytemperature - 4) //310 is the normal bodytemp. 310.055

/datum/reagent/ethanol/drink/grog
	name = "Grog"
	id = GROG
	description = "Watered down rum. NanoTrasen approves!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "grogglass"
	glass_desc = "The favorite of pirates everywhere."

/datum/reagent/ethanol/drink/evoluator
	name = "Evoluator"
	id = EVOLUATOR
	description = "Blobs that come into contact with oxygen really do evoluate."
	reagent_state = REAGENT_STATE_LIQUID
	color = BLOB_MEAT
	glass_icon_state = "evoluatorglass"
	glass_desc = "Blob evoluated with oxigen. Prickly!"

/datum/reagent/ethanol/drink/blob_beer
	name = "Blob beer"
	id = BLOBBEER
	description = "Enzymes in the blob, when under heat, entered a state of rapid fermentation. The result was this beverage."
	reagent_state = REAGENT_STATE_LIQUID
	color = BLOB_MEAT
	glass_icon_state = "blobbeerglass"
	glass_desc = "Acidic beer with a grand foam head. Subtle hints of apple."

/datum/reagent/ethanol/drink/liberator
	name = "Liberator"
	id = LIBERATOR
	description = "Fruit juice and liquors balancing the blob's overwhelming taste."
	reagent_state = REAGENT_STATE_LIQUID
	color = DEFAULT_BLOOD
	glass_icon_state = "liberatorglass"
	glass_desc = "Fruity and strong, for when you need a quick recharge."

/datum/reagent/ethanol/drink/spore
	name = "Spore"
	id = SPORE
	description = "The special properties of karmotrine combined with blobanine create a disgusting but interesting drink."
	reagent_state = REAGENT_STATE_LIQUID
	color = BLOB_MEAT
	custom_metabolism = 0.1
	glass_icon_state = "sporeglass"
	glass_desc = "A tasteless drink with an almost unbearable aftertaste."

/datum/reagent/ethanol/drink/spore/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	for(var/spell/S in M.spell_list)
		if (istype(S, /spell/aoe_turf/conjure/spore))
			return
	var/spell/aoe_turf/conjure/spore/summon_spore = new()
	summon_spore.charge_counter = 0 // Spell starts on cooldown
	summon_spore.process()
	M.add_spell(summon_spore)

/datum/reagent/ethanol/drink/spore/on_removal(var/amount)
	if (!iscarbon(src.holder.my_atom) || (max(0, src.volume - amount) >= 1))
		return TRUE

	var/mob/living/carbon/M = holder.my_atom
	for(var/spell/aoe_turf/conjure/spore/S in M.spell_list)
		M.remove_spell(S)
	return TRUE

/datum/reagent/ethanol/drink/aloe
	name = "Aloe"
	id = ALOE
	description = "Watermelon juice and irish cream. Contains no actual aloe."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "aloe"
	glass_name = "\improper Aloe"

/datum/reagent/ethanol/drink/andalusia
	name = "Andalusia"
	id = ANDALUSIA
	description = "Rum, whiskey, and lemon juice."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "andalusia"
	glass_name = "\improper Andalusia"
	glass_desc = "A strong cocktail named after a historical Terran land."

/datum/reagent/ethanol/drink/alliescocktail
	name = "Allies Cocktail"
	id = ALLIESCOCKTAIL
	description = "English gin, French vermouth, and Russian vodka."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "alliescocktail"
	glass_name = "\improper Allies Cocktail"
	glass_desc = "A cocktail of spirits from three historical Terran nations, symbolizing their alliance in a great war."

/datum/reagent/ethanol/drink/acid_spit
	name = "Acid Spit"
	id = ACIDSPIT
	description = "Wine and sulphuric acid. You hope the wine has neutralized the acid."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#365000" //rgb: 54, 80, 0
	glass_icon_state = "acidspitglass"
	glass_name = "\improper Acid Spit"
	glass_desc = "Bites like a xeno queen."

/datum/reagent/ethanol/drink/amasec
	name = "Amasec"
	id = AMASEC
	description = "The official drink of the Imperium."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "amasecglass"
	glass_name = "\improper Amasec"
	glass_desc = "A grim and dark drink that knows only war."

/datum/reagent/ethanol/drink/amasec/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.AdjustStunned(4)

/datum/reagent/ethanol/drink/neurotoxin
	name = "Neurotoxin"
	id = NEUROTOXIN
	description = "A strong neurotoxin that puts the subject into a death-like state."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E2E61" //rgb: 46, 46, 97
	glass_icon_state = "neurotoxinglass"
	glass_name = "\improper Neurotoxin"
	glass_desc = "Guaranteed to knock you silly."

/datum/reagent/ethanol/drink/neurotoxin/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.adjustOxyLoss(1)
	M.SetKnockdown(max(M.knockdown, 15))
	M.SetStunned(max(M.stunned, 15))
	M.silent = max(M.silent, 15)

/datum/reagent/ethanol/drink/changelingsting
	name = "Changeling Sting"
	id = CHANGELINGSTING
	description = "Milder than the name suggests. Not that you've ever been stung."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113
	glass_icon_state = "changelingsting"
	glass_name = "\improper Changeling Sting"
	glass_desc = "Stings, but not deadly."

/datum/reagent/ethanol/drink/changelingsting/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.dizziness += 5

/datum/reagent/ethanol/drink/changelingsting/stab
	name = "Changeling Stab"
	id = CHANGELINGSTAB
	description = "A bit less mild than the sting. Not that you've ever been stabbed either, surely."
	glass_name = "\improper Changeling Stab"
	glass_desc = "Stabs, but metaphorically."

/datum/reagent/ethanol/drink/changelingsting/stab/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(tick <= 1) // The stab itself
		M.SetKnockdown(max(M.knockdown,2))

/datum/reagent/ethanol/drink/erikasurprise
	name = "Erika Surprise"
	id = ERIKASURPRISE
	description = "The surprise is, it's green!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113
	glass_icon_state = "erikasurprise"
	glass_name = "\improper Erika Surprise"

/datum/reagent/ethanol/drink/irishcarbomb
	name = "Irish Car Bomb"
	id = IRISHCARBOMB
	description = "A troubling mixture of irish cream and ale."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113
	glass_icon_state = "irishcarbomb"
	glass_name = "\improper Irish Car Bomb"
	glass_desc = "Something about this drink troubles you."

/datum/reagent/ethanol/drink/irishcarbomb/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.dizziness += 5

/datum/reagent/ethanol/drink/syndicatebomb
	name = "Syndicate Bomb"
	id = SYNDICATEBOMB
	description = "Whiskey cola and beer. Figuratively explosive."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113
	glass_icon_state = "syndicatebomb"
	glass_name = "\improper Syndicate Bomb"
	glass_desc = "Somebody set up us the bomb!"
	glass_isGlass = 0

/datum/reagent/ethanol/drink/driestmartini
	name = "Driest Martini"
	id = DRIESTMARTINI
	description = "Only for the experienced. You think you see sand floating in the glass."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#2E6671" //rgb: 46, 102, 113
	glass_icon_state = "driestmartiniglass"
	glass_name = "\improper Driest Martini"

/datum/reagent/ethanol/drink/driestmartini/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.dizziness += 10
	if(tick >= 55 && tick < 115)
		M.stuttering += 10
	else if(tick >= 115 && prob(33))
		M.confused = max(M.confused + 15, 15)

/datum/reagent/ethanol/drink/danswhiskey
	name = "Discount Dan's 'Malt' Whiskey"
	id = DANS_WHISKEY
	description = "It looks like whiskey... kinda."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 181, 199, 158
	glass_icon_state = "dans_whiskey"
	glass_name = "\improper Discount Dan's 'Malt' Whiskey"
	glass_desc = "The cheapest path to liver failure."

/datum/reagent/ethanol/drink/danswhiskey/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		switch(volume)
			if(1 to 15)
				if(prob(5))
					to_chat(H,"<span class='warning'>Your stomach grumbles and you feel a little nauseous.</span>")
					H.adjustToxLoss(0.5)
				H.adjustToxLoss(0.1)
			if(15 to 25)
				if(prob(10))
					to_chat(H,"<span class='warning'>Something in your abdomen definitely doesn't feel right.</span>")
					H.adjustToxLoss(1)
				if(prob(5))
					H.adjustToxLoss(2)
					H.vomit()
				H.adjustToxLoss(0.2)
			if(25 to INFINITY)
				if(prob(10))
					H.custom_pain("You feel a horrible throbbing pain in your stomach!",1)
					var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
					if(istype(L))
						L.take_damage(1, 1)
					H.adjustToxLoss(2)
				if(prob(5))
					H.vomit()
					H.adjustToxLoss(3)
				H.adjustToxLoss(0.3)

/datum/reagent/ethanol/drink/pintpointer
	name = "Pintpointer"
	id = PINTPOINTER
	description = "A little help finding the bartender."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/drink/pintpointer/when_drinkingglass_master_reagent(var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/D)
	var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/pintpointer/P = new (get_turf(D))
	var/datum/reagents/glassreagents = D.reagents

	if(glassreagents.last_ckey_transferred_to_this)
		for(var/client/C in clients)
			if(C.ckey == glassreagents.last_ckey_transferred_to_this)
				var/mob/M = C.mob
				P.creator = M
	glassreagents.trans_to(P, glassreagents.total_volume)
	spawn(1)
		qdel(D)

/datum/reagent/ethanol/drink/monstermash
	name = "Monster Mash"
	id = MONSTERMASH
	description = "It'll be gone in a flash!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#b97309"
	glass_icon_state = "monster_mash"
	glass_name = "\improper Monster Mash"
	glass_desc = "Will get you graveyard smashed."

/datum/reagent/ethanol/drink/monstermash/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(isskellington(H) || isskelevox(H) || islich(H) || H.is_wearing_item(/obj/item/clothing/under/skelesuit))
			doTheMash(H)
		if(H.is_wearing_item(/obj/item/clothing/head/franken_bolt) || istype(H, /mob/living/carbon/human/frankenstein))
			joltOfMyElectrodes(H)
		if(H.is_wearing_item(/obj/item/clothing/mask/vamp_fangs) || H.is_wearing_item(/obj/item/clothing/suit/storage/draculacoat) || isvampire(H))
			draculaAndHisSon(H)

/datum/reagent/ethanol/drink/monstermash/proc/doTheMash(mob/living/carbon/human/H)
	playsound(H, 'sound/effects/rattling_bones.ogg', 100, 1)
	if(prob(15))
		H.emote("spin")
		H.visible_message("<span class='good'>[H] does the mash!</span>")
		if(prob(25))
			spawn(1 SECONDS)
				H.emote("spin")
				H.visible_message("<span class='good'>[H] does the monster mash!</span>")

/datum/reagent/ethanol/drink/monstermash/proc/joltOfMyElectrodes(mob/living/carbon/human/H)
	for(var/turf/simulated/T in orange(1, H))
		if(prob(volume))
			spark(T, 1)

/datum/reagent/ethanol/drink/monstermash/proc/draculaAndHisSon(mob/living/carbon/human/H)
	if(prob(15))
		var/mob/living/simple_animal/dracson/dSon = new /mob/living/simple_animal/dracson(H.loc)
		try_move_adjacent(dSon)
		spawn(5 SECONDS)
			dSon.death()

/datum/reagent/ethanol/drink/eggnog
	name = "Eggnog"
	id = EGGNOG
	description = "Milk, cream and egg."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#F0DFD1" //rgb: 240, 223, 209
	glass_icon_state = "eggnog"
	glass_name = "\improper eggnog"
	glass_desc = "Celebrate the holidays with practically liquid custard. Something is missing though."

/datum/reagent/ethanol/drink/festive_eggnog
	name = "Festive Eggnog"
	id = FESTIVE_EGGNOG
	description = "Eggnog, complete with booze and a dusting of cinnamon."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#F0DFD1" //rgb: 240, 223, 209
	glass_icon_state = "festive_eggnog"
	glass_name = "\improper festive eggnog"
	glass_desc = "Eggnog, complete with booze and a dusting of cinnamon for that winter warmth."

/datum/reagent/ethanol/drink/mimosa
	name = "Mimosa"
	id = MIMOSA
	description = "Champagne and orange juice."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFCA24" //rgb: 255, 202, 36
	glass_icon_state = "mimosa"
	glass_name = "\improper mimosa"
	glass_desc = "Tangy and light. Perfect for brunch."

/datum/reagent/ethanol/drink/lemondrop
	name = "Lemon Drop"
	id = LEMONDROP
	description = "Vodka, lemon juice, and triple sec."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFF353" //rgb: 255, 243, 83
	glass_icon_state = "lemondrop"
	glass_name = "\improper lemon drop"
	glass_desc = "A strong and sour drink, served with a sugar coated rim."

/datum/reagent/ethanol/drink/greyvodka
	name = "Greyshirt Vodka"
	id = GREYVODKA
	description = "Made presumably from whatever scrapings you can get out of maintenance. Don't think, just drink."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#DEF7F5"
	alpha = 64
	glass_icon_state = "ginvodkaglass"
	glass_desc = "A questionable concoction of ingredients found within maintenance. Tastes just like you'd expect."

/datum/reagent/ethanol/drink/greyvodka/on_mob_life(var/mob/living/carbon/human/H)
	if(..())
		return 1
	H.radiation = max(H.radiation - 5 * REM, 0)
	H.rad_tick = max(H.rad_tick - 3 * REM, 0)
