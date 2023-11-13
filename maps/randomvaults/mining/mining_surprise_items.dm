/area/mining_bar
	name = "Armok's Bar and Grill"
	icon_state = "bar"
	holomap_draw_override = HOLOMAP_DRAW_FULL

/area/mining_surprise
	name = "mining surprise"
	icon_state = "mine"
	holomap_draw_override = HOLOMAP_DRAW_FULL

/mob/living/simple_animal/robot/NPC
	flags = HEAR_ALWAYS | PROXMOVE //For hearer events
	icon = 'icons/mob/robots.dmi'

/mob/living/simple_animal/robot/NPC/New()
	..()
	initialize_NPC_components()

/mob/living/simple_animal/robot/NPC/proc/initialize_NPC_components()
	add_component(/datum/component/controller/movement/astar)

/mob/living/simple_animal/robot/NPC/dusky
	name = "Dusky"
	desc = "A little rusted at the creases, but this barbot is still happy to serve so long as the generator is running"
	icon_state = "kodiak-service"

/mob/living/simple_animal/robot/NPC/dusky/initialize_NPC_components()
	..()
	var/datum/component/ai/target_finder/simple_view/SV = add_component(/datum/component/ai/target_finder/simple_view)
	SV.range = 3
	var/datum/component/ai/conversation/auto/C = add_component(/datum/component/ai/conversation/auto)
	C.messages = list("I hear the weather on some of them planets ain't too nice to be caught out in. Especially them 'Gas Giants'.",
				"Still's on the fritz again. Sorry if you're tasting pulp or ashes in your liquor.",
				"I wonder if you can brew Plasma. Ought to try it if yonder miners bring in enough for a happy hour.",
				"You ever hear about those 'Goliaths'? Apparently their hide's as hard as plasteel!",
				"I should get a poker table...",
				"You ever try glowshroom rum? I've been informed it's \[WARNING: PRODUCT RECALL - 'Glowshroom Rum' - Unsafe for human consumption\]",
				"You'd think more people would show up to a bar in the middle of nowhere.",
				"The time is [worldtime2text()], anyone interested in a liquid lunch?")
	C.speech_delay = 25 SECONDS
	C.next_speech = world.time+C.speech_delay

	add_component(/datum/component/ai/hearing/say_response/dusky_hi)
	add_component(/datum/component/ai/hearing/say_response/dusky_who)
	add_component(/datum/component/ai/hearing/say_response/dusky_when)
	add_component(/datum/component/ai/hearing/say_response/time)
	var/datum/component/ai/area_territorial/say/AT = add_component(/datum/component/ai/area_territorial/say)
	AT.SetArea(get_area(src))
	AT.enter_args = list("Welcome to Armok's Bar and Grill. Put your plasma on the counter and bring up a seat.",
				"Welcome to Armok's Bar and Grill. Have a nice stay!",
				"Welcome to Armok's Bar and Grill. Don't drag the roid dirt in on them boots, leave em at the door.")
	AT.exit_args = list("Seeya, space dorf","Happy trails.","Anytime, feller.")
	var/datum/component/ai/hearing/order/bardrinks/select_reagents/dusky/BD = add_component(/datum/component/ai/hearing/order/bardrinks/select_reagents/dusky)
	BD.baseprice = rand(1,5) * 5

/mob/living/simple_animal/robot/NPC/dusky/examine(mob/user)
	..()
	var/datum/component/ai/hearing/order/bardrinks/select_reagents/dusky/BD = get_component(/datum/component/ai/hearing/order/bardrinks/select_reagents/dusky)
	if(BD)
		to_chat(user,"Current items in order: [counted_english_list(BD.items2deliver)]<br>Total credits due: [BD.currentprice] credit\s")

/datum/component/ai/hearing/say_response/dusky_hi
	required_messages = list("hello","hi","greetings","howdy")
	hear_args = list("Howdy!","Good to see ya, friend!","Back atcha, feller!")

/datum/component/ai/hearing/say_response/dusky_who
	required_messages = list("who are you","whos this","whats your name")
	hear_args = list("The name's Dusky, service brand bot, built to serve you fellers the finest plasm- I mean, ethanol based beverages!")

/datum/component/ai/hearing/say_response/dusky_when
	required_messages = list("how long have you been out here","when were you made","how old are you")

/datum/component/ai/hearing/say_response/dusky_when/initialize()
	if(..())
		hear_args = list("My production serial seems to be dated to roughly [rand(2300,2399)], ain't seen a customer in about [rand(12,120)] years.")
		return TRUE

/datum/component/ai/hearing/order/bardrinks/select_reagents/dusky
	notfoundmessages = list("Sorry pal, I don't think I recognise that kinda thing.",
							"Don't think we got a recipe for that back in storage, gotta try again.",
							"I don't know what kinda crazy stuff they're serving on yer planet but we dont have that, try somethin' else.")
	freemessages = list("For you, on the house, fella!",
						"I s'pose I could fix up a free servin' for ya, just cus I like ya and all.",
						"Y'know, today I'm feelin extra generous, so ya get this one free!")
	toomuchmessages = list("Easy pal, I can only hold so many glasses in my ol' compartments. Try gettin' your stuff first and then orderin' again.",
							"Look, I ain't made to carry the world on my shoulders here, get your stuff before orderin' again.",
							"Sorry, inventory's full, come get yer stuff first.")
	pricemessages = list("That'll be <PRICE> credits for one servin'.",
						"<PRICE> credits for today's amount.",
						"That's <PRICE> credits up front.")
	priceleftmessages = list("Still need about <PRICE> left.",
							"Just <PRICE> credits more for this batch.",
							"Now it just needs about <PRICE> credits.")
	servedmessages = list("<ITEMLIST> served n' poured fresh!",
						"<ITEMLIST> straight from the presses!",
						"<ITEMLIST> on the table, drink it cool!")
	ordermake_emotes = list("begins brewing its drinks...",
						"starts pouring juices into a glass...",
						"is pulping some fluids...")
	acceptable_recipe_reagents = list(RADIUM)
	var/lastwrongitemtime

/datum/component/ai/hearing/order/bardrinks/select_reagents/dusky/process()
	..()
	if(!items2deliver.len && isliving(parent))
		var/mob/living/M=parent
		if(!M.isDead())
			var/amount = 0
			var/meatfound = FALSE
			var/plantfound = FALSE
			var/list/sheets = list()
			var/list/containers = list()
			var/turf/checkloc = get_step(M,M.dir)
			for(var/obj/item/I in checkloc)
				if(istype(I,/obj/item/stack/sheet/mineral/plasma))
					var/obj/item/stack/sheet/mineral/plasma/P = I
					amount += P.amount
					sheets += P
				else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/meat/plasmaman))
					var/obj/item/weapon/reagent_containers/food/snacks/meat/plasmaman/PM = I
					amount += 5
					sheets += PM
					meatfound = TRUE
				else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/grown/plasmacabbage))
					var/obj/item/weapon/reagent_containers/food/snacks/grown/plasmacabbage/PC = I
					amount += PC.potency/2
					sheets += PC
					plantfound = TRUE
				else if(istype(I,/obj/item/weapon/reagent_containers))
					var/obj/item/weapon/reagent_containers/RC = I
					amount += RC.reagents.get_reagent_amount(PLASMA)
					containers += RC
				if(amount >= 50)
					break
			if(amount)
				if(meatfound)
					M.say(pick("I see you brought yerself some meaty plasma this time. Not the biggest fan but it'll have to do. Shame it means I can't label these drinks vegan anymore...",
							"Plasma meat's no specialty of mine but it does make a drink fine eitherhow. Let's see what I can brew up...",
							"Meat ain't the cleanest source of plasma in these parts of the roid but I guess plasma is plasma. Let's get some drinks out of it..."))
				else if(plantfound)
					M.say(pick("Dang, I didn't know you could turn plants into plasma makin' factories! I guess those stations yonder do have ways of makin drink products out of anythin'...",
							"A cabbage with flakes of plasma on it? Now ain't that the strangest thing I done seen. Hope it's juicy for a good few rounds...",
							"A plant with the texture and feel of a smooth sheet of plasma, I ain't seen nothin' like it! And it looks ripe n' juicy for some good recipes too..."))
				else
					M.say(pick("Well how about that, you found some plasma for me to fix up. Let's see if I can make somethin' for ya...",
							"Aw, my favorite, I love brewin' with plasma. I think I'll make something here with it...",
							"You found me some plasma? Well thank ya, here's a little something..."))
				playsound(M.loc, pick('sound/items/polaroid1.ogg','sound/items/polaroid2.ogg'), 70, 1)
				for(var/obj/O in sheets)
					qdel(O)
				for(var/obj/O2 in containers)
					O2.reagents.del_reagent(PLASMA)
				for(var/i in 1 to round(clamp(amount/10,1,5)))
					// i could write something that finds every bar drink that has plasma in its recipe but let's face it,
					// it's just this stuff and it's less expensive to look for these
					items2deliver += pick(/datum/reagent/ethanol/drink/toxins_special,
										/datum/reagent/ethanol/drink/boysenberry_blizzard,
										/datum/reagent/drink/tea/plasmatea)
				spawn_items()
				if(!(PLASMA in acceptable_recipe_reagents))
					acceptable_recipe_reagents += PLASMA
					M.say("I think I could get used to brewin' this now today. Be sure to try the [pick("Toxins Special","Boysenberry Blizzard","Plasma Pekoe")]!")
					// again, no initial with lists here...
					whitelist_items = list(/datum/reagent/ethanol/drink,/datum/reagent/drink,/obj/item/weapon/reagent_containers/food/drinks)
					build_whitelist()
					baseprice /= 2 // happy hour
			else if(world.time > lastwrongitemtime + 5 SECONDS)
				lastwrongitemtime = world.time
				for(var/atom/movable/O in checkloc)
					if(O.anchored)
						continue
					if(is_type_in_list(O,list(/obj/item/weapon/reagent_containers/glass/beaker/large/plasma,/obj/item/weapon/pickaxe/plasmacutter)))
						if(!(PLASMA in acceptable_recipe_reagents))
							qdel(O)
							acceptable_recipe_reagents += PLASMA
							M.say("It ain't no sheet but I guess it helps. Be sure to try the [pick("Toxins Special","Boysenberry Blizzard","Plasma Pekoe")]!")
							// again, no initial with lists here...
							whitelist_items = list(/datum/reagent/ethanol/drink,/datum/reagent/drink,/obj/item/weapon/reagent_containers/food/drinks)
							build_whitelist() // no happy hour for this
						else
							M.say(pick("I appreciate the gesture but I already got myself one of these things. Now with sheets I can get you some drinks for nothin'!",
									"I already got myself one of these, but now I need some ol' plasma to actually get you some drinks this time.",
									"I ain't particular to stockin' up on these when I got a workin' one just fine, so bring some actual plasma for free drinks."))
						return
					if(istype(O,/obj/item/stack/ore/plasma))
						M.say(pick("This ore form stuff is no good, gotta refine it with some heat before I can go brewin' with it.",
								"The ore won't cut it son. It's gotta be that real refined stuff.",
								"Ore stuff ain't any use to me, send it to a furnace and get those rock impurities out so it's not mixed in yer drinks."))
						return
					if(istype(O,/obj/item/stack/tile/mineral/plasma))
						M.say(pick("Tiles are too compressed to go brewin' plasma with, and I'd much rather use wood for floors.",
								"If I were to believe these were plasma sheets I'd tell you these are an awful lot too square n' flat to be.",
								"Tiles are too small, compressed n' thin to be any use for brewin', try gettin a bunch of em back into sheets first before you offer 'em to me."))
					if(istype(O,/obj/item/weapon/coin/plasma))
						M.say(pick("A coin, really son? This ain't useful for brewin' and I only pay in cash.",
								"I don't know if you got them wires crossed with the idea of payin' and givin' plasma, but you can't do both at once, and not with no coins.",
								"Coins are a lil' too hard to crack for me with brewin, and not much use as payment either, unlike cash."))
						return
					if(istype(O,/obj/item/stack/sheet/plasteel))
						M.say(pick("Well, you gone and smelted some plasma alright, but you got too much of that there metal in it to be any use to me.",
								"Nah son, I'm lookin fer PLASMA, not PLASTEEL, maybe you need to clean out these ears boy.",
								"Nah, this is plasteel and useless to me, and I like my walls more wooden 'round these parts anyways."))
						return
					if(is_type_in_list(O,list(/obj/item/stack/sheet/glass/plasmaglass,
											/obj/item/stack/sheet/glass/plasmarglass,
											/obj/item/weapon/shard/plasma,
											/obj/item/stack/glass_tile/rglass/plasma,
											/obj/item/weapon/stock_parts/console_screen/reinforced/plasma)))
						// not bothered to write plasma glass tile lines
						M.say(pick("Well, you gone and smelted some plasma alright, but you got too much of that there glass in it to be any use to me.",
								"This plasma could use a lil' less sand in it to me, even if it's all hardened and crystallized.",
								"Plasma ain't much good to me in glass form, unless it's window fixin' I need."))
						return
					if(istype(O,/obj/item/weapon/gun/energy/plasma))
						M.say(pick("Sorry, I ain't no arms dealer, even if the stuff fired from 'em is plasma derived.",
								"This gun might be plasma tech n' all but I'd rather you be keepin' all arms off the premises here.",
								"I don't know if this some sort of thematic duel challenge you're pointin' at me with here but I ain't takin' it."))
						return
					if(istype(O,/obj/item/weapon/table_parts/glass/plasma))
						M.say(pick("Thanks for the offer, but this place is fine for decor, and it ain't much use for brewin' like this.",
								"I don't even know what yer thinkin' offerin' plasma to me like this, it's just gettin' absurd at this point.",
								"Plasma certainly ain't much use for brewin' in table form more than anythin' else would be."))
						return
					if(isplasmaman(O))
						var/mob/living/carbon/human/H = O
						if(H.isDead())
							M.say(pick("Nah I don't take plasma off no bodies, even if they're cadaver types.",
									"I ain't seein' no organ donor card on this, 'sides even if there was, I ain't the kinda guy to just take plasma off 'em'.",
									"I think I'm just a bit too respectful of the dead to go pickin' plasma from their flesh."))
						else
							M.say(pick("I don't think I wanna harvest plasma right off yer friend here, I ain't that gruesome.",
									"Who do you think I am? I ain't no crazed organ harvestin' blood sucker, I got standards here.",
									"I ain't pickin plasma outta the scabs of your buddy here, go lookin' in the mines for some."))
						return
					if(istype(O,/obj/item/weapon/tank))
						var/obj/item/weapon/tank/T = O
						if(T.air_contents[GAS_PLASMA])
							M.say(pick("Plasma ain't much good to me as a gas. Besides, I don't got much equipment on me for safely gettin' it outta that tank.",
									"That ain't the kind of way I like to be offered plasma, so don't you even think about openin' that in here or there'll be trouble.",
									"Plasma ain't a very stable or safe substance as a gas and definitely not if it were let outta that tank, so I ain't touchin that."))
							return
				var/datum/gas_mixture/current_air = checkloc.return_air()
				if(current_air[GAS_PLASMA])
					M.say(pick("Dangit when I said get some plasma, I meant in solid form! Now how's this place gonna get customers that ain't purple boney men!",
							"Did you let GASEOUS plasma get all over my bar? I asked ya for solid plasma and you let it get dispersin' everywhere like this!",
							"Aw heck no, you didn't just let that plasma out as gas right? Solid stuff I can work with, but when you're gettin' it in the air like this it's no good for nobody."))
