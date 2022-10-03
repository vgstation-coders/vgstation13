//Hockey pads, neck guards, particularly well-stained handkerchiefs go here
/obj/item/clothing/accessory/armor_shard
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 0, rad = 0)
	autoignition_temperature = AUTOIGNITION_PROTECTIVE

/obj/item/clothing/accessory/armor_shard/can_attach_to(obj/item/clothing/C)
	. = ..()
	for(var/obj/item/clothing/accessory in C.accessories)
		if(accessory.type == type)
			return 0

/obj/item/clothing/accessory/armor_shard/shoulder
	name = "shoulder pads"
	desc = "Has clips to attach to a jumpsuit. Makes you feel like you're playing a fantasy MMO."
	icon_state = "shoulder_guard"
	body_parts_covered = ARMS

/obj/item/clothing/accessory/armor_shard/knee
	name = "knee pads"
	desc = "Has clips to attach to a jumpsuit. Now you can safely play hockey."
	icon_state = "knee_guard"
	body_parts_covered = LEGS

/obj/item/clothing/accessory/armor_shard/neck
	name = "neck guard"
	desc = "Has clips to attach to a jumpsuit. For when you want to protect your pretty face."
	icon_state = "neck_guard"
	body_parts_covered = FACE

/obj/item/clothing/accessory/armoredvestshoulderstrap
	name = "pair of reinforced shoulder straps"
	desc = "Wraps around armored vests. For when you're going on an action-packed trip to Neo Detroit."
	icon_state = "shoulder_straps"
	body_parts_covered = UPPER_TORSO
	armor = list(melee = 1, bullet = 1, laser = 1, energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/accessory/armoredvestshoulderstrap/can_attach_to(obj/item/clothing/C)
	. = ..()
	for(var/obj/item/clothing/accessory in C.accessories)
		if(accessory.type == type)
			return 0
	return istype(C, /obj/item/clothing/suit/armor/vest)
