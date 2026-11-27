//hunters have the most poison and move the fastest, so they can find prey
// THEY CAN ALSO OPEN DOORS OH GOD
/mob/living/simple_animal/hostile/giant_spider/hunter
	desc = "Furry and black, it makes you shudder to look at it. This one has sparkling purple eyes."
	icon_state = "hunter"
	icon_living = "hunter"
	icon_dead = "hunter_dead"
	maxHealth = 120 // Was 60
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 20
	poison_per_bite = 5
	wanted_objects = list(
		/obj/machinery/bot,          // Beepsky and friends
		/obj/machinery/light,        // Bust out lights
	)
	idle_vision_range = 7
	search_objects = 1 // Consider objects when searching.  Set to 0 when attacked
	wander = 1
	ranged = 0
	minimum_distance = 1
	speed = 2

/mob/living/simple_animal/hostile/giant_spider/hunter/dead
	iscorpse = 1
	health = 0

// WIP: the hunter runs the idle combat tree. It keeps the base spider's poison
// bite (through attack_target's legacy bridge) and its object targeting
// (search_objects/wanted_objects now feed target_source/enemies).
/mob/living/simple_animal/hostile/giant_spider/hunter/New()
	..()
	if(iscorpse)
		return
	stop_automated_movement = TRUE
	wander = 0
	var/datum/ai_controller/controller = new(src)
	controller.behavior_nodes = list(bt_idle_hostile_tree())
	controller.initialize_behavior_tree()

