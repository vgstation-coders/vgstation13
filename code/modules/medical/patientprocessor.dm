/obj/machinery/medical/patient_processor
	name = "patient processor"
	desc = "A device that uses advanced AutoDoc technology to heal patients."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"
	density = 1
	anchored = 1
	var/input_dir = 1
	var/output_dir = 2

/obj/machinery/medical/patient_processor/process()
	if((!output_dir || !input_dir) || output_dir == input_dir)
		return
	var/input = get_step(src, input_dir)
	var/output = get_step(src, output_dir)
	var/mob/living/M = locate(/mob/living, input)
	if(M)
		M.rejuvenate(animation = TRUE)
		M.forceMove(output)
		return
	//TODO: generate bodies for patients who have been reduced to brains or heads
