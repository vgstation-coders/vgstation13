/area/mining_bar
	name = "Armok's Bar and Grill"
	icon_state = "bar"

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
	add_component(/datum/component/ai/target_finder/simple_view)
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
	var/datum/component/ai/area_territorial/AT = add_component(/datum/component/ai/area_territorial)
	AT.SetArea(get_area(src))
	INVOKE_EVENT(src, /event/comp_ai_cmd_specific_say, "to_say" = "Welcome to Armoks Bar and Grill. Put your plasma on the counter and bring up a seat.")