/vgc_output_queue_item
	var/datum/vgcomponent/source
	var/datum/vgcomponent/target
	var/target_proc
	var/signal

/vgc_output_queue_item/New(var/datum/vgcomponent/source, var/datum/vgcomponent/target, var/target_proc, var/signal)
	src.source = source
	src.target = target
	src.target_proc = target_proc
	src.signal = signal

/vgc_output_queue_item/proc/fire()
	call(target, target_proc)(signal)
