/vgcomp_output
	var/datum/vgcomponent/vgc
	var/target

/vgcomp_output/New(var/datum/vgcomponent/vgc, var/target = "main")
	src.vgc = vgc
	src.target = target
