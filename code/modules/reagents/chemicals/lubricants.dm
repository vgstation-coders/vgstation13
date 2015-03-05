/datum/reagent/lube
	name = "Space Lube"
	id = "lube"
	description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
	reagent_state = LIQUID
	color = "#009CA8" // rgb: 0, 156, 168
	overdose_threshold = REAGENTS_OVERDOSE

/datum/reagent/lube/reaction_turf(var/turf/simulated/T, var/volume)
	if (!istype(T)) return
	src = null
	if(volume >= 1)
		if(T.wet >= 2) return
		T.wet = 2
		spawn(800)
			if (!istype(T)) return
			T.wet = 0
			if(T.wet_overlay)
				T.overlays -= T.wet_overlay
				T.wet_overlay = null
			return