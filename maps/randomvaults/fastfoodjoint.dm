/datum/map_element/vault/fastfoodjoint
	name = "Fast food joint"
	file_path = "maps/randomvaults/fastfoodjoint.dmm"

/mob/living/simple_animal/robot/NPC/fastfood
	name = "restaurant service bot"
	desc = "Serves food asked for by a customer."
	icon_state = "kodiak-service"

/mob/living/simple_animal/robot/NPC/fastfood/initialize_NPC_components()
	..()
	add_component(/datum/component/ai/hearing/order/foodndrinks)
	add_component(/datum/component/ai/target_finder/payment)
