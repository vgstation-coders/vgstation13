// First consumer of the WIP behavior tree port: a hostile simple animal whose
// decision layer is a behavior tree controller instead of the legacy hostile AI.
//
// This mob is intentionally not placed on any map. It exists to prove the
// controller/tree/behavior path with a real simple animal while the existing
// mobs are migrated.

/mob/living/simple_animal/hostile/bt_guard
	name = "behaviour tree guard"
	desc = "A test guard driven by the WIP behavior tree controller."
	icon = 'icons/mob/animal.dmi'
	icon_state = "carp"
	icon_living = "carp"
	icon_dead = "carp_dead"
	maxHealth = 50
	health = 50
	melee_damage_lower = 5
	melee_damage_upper = 10
	attack_sound = 'sound/weapons/bite.ogg'
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	attack_same = 1
	wander = 0
	stop_automated_movement = TRUE

/mob/living/simple_animal/hostile/bt_guard/New()
	..()
	stop_automated_movement = TRUE
	wander = 0

	var/datum/ai_controller/controller = new(src)
	// Playground for the WIP tree: fight, flee when badly hurt and chat in the
	// background. The parallel keeps chatter from blocking the decision branch.
	controller.behavior_nodes = list(
		list(
			BT_DESC_TYPE = /datum/bt_node/composite/parallel,
			BT_DESC_CHILDREN = list(
				bt_fleeing_hostile_tree(0.3, 2),
				list(
					BT_DESC_TYPE = /datum/bt_node/ai_behavior/speak_line,
					lines = list("Halt!", "Stop right there!", "You shall not pass!"),
					speak_chance = 2,
					cooldown = 8 SECONDS,
				),
			),
		),
	)
	controller.initialize_behavior_tree()

// The behavior tree owns target acquisition; keep the legacy hostile AI idle.
/mob/living/simple_animal/hostile/bt_guard/FindTarget()
	return null
