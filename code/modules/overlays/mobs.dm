// Human Overlay objects for the new Overlays system.

/obj/abstract/Overlays
	plane = FLOAT_PLANE

/obj/abstract/Overlays/fire_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - FIRE_LAYER)

/obj/abstract/Overlays/mutantrace_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - MUTANTRACE_LAYER)

/obj/abstract/Overlays/mutations_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - MUTATIONS_LAYER)

/obj/abstract/Overlays/damage_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - DAMAGE_LAYER)

/obj/abstract/Overlays/uniform_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - UNIFORM_LAYER)

/obj/abstract/Overlays/shoes_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - SHOES_LAYER)

/obj/abstract/Overlays/gloves_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - GLOVES_LAYER)

/obj/abstract/Overlays/ears_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - EARS_LAYER)

/obj/abstract/Overlays/suit_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - SUIT_LAYER)

/obj/abstract/Overlays/glasses_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - GLASSES_LAYER)

/obj/abstract/Overlays/belt_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - BELT_LAYER)

/obj/abstract/Overlays/suit_store_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - SUIT_STORE_LAYER)

/obj/abstract/Overlays/hair_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - HAIR_LAYER)

/obj/abstract/Overlays/glasses_over_hair_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - GLASSES_OVER_HAIR_LAYER)

/obj/abstract/Overlays/facemask_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - FACEMASK_LAYER)

/obj/abstract/Overlays/head_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - HEAD_LAYER)

/obj/abstract/Overlays/back_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - BACK_LAYER)

/obj/abstract/Overlays/id_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - ID_LAYER)

/obj/abstract/Overlays/handcuff_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - HANDCUFF_LAYER)

/obj/abstract/Overlays/legcuff_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - LEGCUFF_LAYER)

/obj/abstract/Overlays/hand_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - HAND_LAYER)

/obj/abstract/Overlays/tail_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - TAIL_LAYER)

/obj/abstract/Overlays/targeted_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - TARGETED_LAYER)



//Human Overlays Object variables

/mob/living/carbon/human
	var/list/obj/abstract/Overlays/obj_overlays[TOTAL_LAYERS]
	/*
	var/obj/abstract/Overlays/fire_layer/fire_layer = new
	var/obj/abstract/Overlays/mutantrace_layer/mutantrace_layer = new
	var/obj/abstract/Overlays/mutations_layer/mutations_layer = new
	var/obj/abstract/Overlays/damage_layer/damage_layer = new
	var/obj/abstract/Overlays/uniform_layer/uniform_layer = new
	var/obj/abstract/Overlays/id_layer/id_layer = new
	var/obj/abstract/Overlays/shoes_layer/shoes_layer = new
	var/obj/abstract/Overlays/gloves_layer/gloves_layer = new
	var/obj/abstract/Overlays/ears_layer/ears_layer = new
	var/obj/abstract/Overlays/suit_layer/suit_layer = new
	var/obj/abstract/Overlays/glasses_layer/glasses_layer = new
	var/obj/abstract/Overlays/belt_layer/belt_layer = new
	var/obj/abstract/Overlays/suit_store_layer/suit_store_layer = new
	var/obj/abstract/Overlays/back_layer/back_layer = new
	var/obj/abstract/Overlays/hair_layer/hair_layer = new
	var/obj/abstract/Overlays/glasses_over_hair_layer/glasses_over_hair_layer = new
	var/obj/abstract/Overlays/facemask_layer/facemask_layer = new
	var/obj/abstract/Overlays/head_layer/head_layer = new
	var/obj/abstract/Overlays/handcuff_layer/handcuff_layer = new
	var/obj/abstract/Overlays/legcuff_layer/legcuff_layer = new
	var/obj/abstract/Overlays/l_hand_layer/l_hand_layer = new
	var/obj/abstract/Overlays/r_hand_layer/r_hand_layer = new
	var/obj/abstract/Overlays/tail_layer/tail_layer = new
	var/obj/abstract/Overlays/targeted_layer/targeted_layer = new
	*/
