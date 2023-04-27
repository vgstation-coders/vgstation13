/area/mining_bar
	name = "Armok's Bar and Grill"
	icon_state = "bar"

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
	acceptable_recipe_reagents = list(PLASMA,RADIUM)
