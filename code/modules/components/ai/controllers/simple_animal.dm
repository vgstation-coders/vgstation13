/datum/component/controller/simple_animal
	var/disable_automove_on_busy=1

/datum/component/controller/simple_animal/setBusy(var/yes)
	..(yes)
	if(disable_automove_on_busy)
		var/mob/living/simple_animal/SA = holder
		SA.stop_automated_movement = yes
