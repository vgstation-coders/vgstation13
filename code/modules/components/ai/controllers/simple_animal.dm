/datum/component/controller/simple_animal
	var/disable_automove_on_busy = TRUE

/datum/component/controller/simple_animal/initialize()
	parent.register_event(/event/comp_ai_cmd_can_attack, src, nameof(src::cmd_can_attack()))
	return ..()

/datum/component/controller/simple_animal/Destroy()
	parent.unregister_event(/event/comp_ai_cmd_can_attack, src, nameof(src::cmd_can_attack()))
	..()

/datum/component/controller/simple_animal/proc/cmd_can_attack(target)
	var/mob/living/simple_animal/SA = parent
	return SA.CanAttack(target)

/datum/component/controller/simple_animal/cmd_set_busy(yes)
	..()
	if(disable_automove_on_busy)
		var/mob/living/simple_animal/SA = parent
		SA.stop_automated_movement = yes
