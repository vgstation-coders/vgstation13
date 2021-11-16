/area/mining_bar
	name = "Armok's Bar and Grill"
	icon_state = "bar"

/mob/living/silicon/robot/NPC
	flags = HEAR_ALWAYS | PROXMOVE //For hearer events

/mob/living/silicon/robot/NPC/updatename()
	return

/mob/living/silicon/robot/NPC/New()
	..()
	initialize_NPC_components()

/mob/living/silicon/robot/NPC/proc/initialize_NPC_components()
	add_component(/datum/component/controller/movement/astar)

/mob/living/silicon/robot/NPC/dusky
	name = "Dusky"
	desc = "A little rusted at the creases, but this barbot is still happy to serve so long as the generator is running"
	icon_state = "kodiak-service"

/mob/living/silicon/robot/NPC/dusky/initialize_NPC_components()
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

	add_component(/datum/component/ai/hearing/say_response/dusky_who)
	add_component(/datum/component/ai/hearing/say_response/dusky_when)
	add_component(/datum/component/ai/hearing/say_response/time)
	var/datum/component/ai/area_territorial/AT = add_component(/datum/component/ai/area_territorial)
	AT.SetArea(get_area(src))
	AT.enter_signal = /event/comp_ai_cmd_specific_say
	AT.enter_args = list("Welcome to Armok's Bar and Grill. Put your plasma on the counter and bring up a seat.")
	AT.exit_signal = /event/comp_ai_cmd_specific_say
	AT.exit_args = list("Seeya, space dorf","Happy trails.","Anytime, feller.")

/datum/component/ai/hearing/say_response/dusky_who
	required_messages = list("Who are you?","Who's this?","What's your name?")
	hear_args = list("The name's Dusky, service brand bot, built to serve you fellers the finest plasm- I mean, ethanol based beverages!")

/datum/component/ai/hearing/say_response/dusky_when
	required_messages = list("How long have you been out here?","When were you made?","How old are you?")
	hear_args = list("My production serial seems to be dated to roughly 2301, ain't seen a customer in about 126 years.")