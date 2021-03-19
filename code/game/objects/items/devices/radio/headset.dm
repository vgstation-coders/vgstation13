/obj/item/device/radio/headset
	name = "radio headset"
	desc = "An updated, modular intercom that fits over the head. Takes encryption keys."
	icon_state = "headset"
	item_state = "headset"
	species_fit = list(INSECT_SHAPED)
	starting_materials = list(MAT_IRON = 75)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_PLASTIC
	subspace_transmission = 1
	canhear_range = 0 // can't hear headsets from very far away
	flags = FPRINT // No HEAR. Headsets should only work when being used explicitly.
	broadcasting = TRUE
	slot_flags = SLOT_EARS
	var/translate_binary = 0
	var/translate_hive = 0
	var/obj/item/device/encryptionkey/keyslot1 = null
	var/obj/item/device/encryptionkey/keyslot2 = null
	var/init_keyslot1_type = /obj/item/device/encryptionkey
	var/init_keyslot2_type = null
	maxf = 1489

/obj/item/device/radio/headset/New()
	if (init_keyslot1_type)
		keyslot1 = new init_keyslot1_type(src)
	if (init_keyslot2_type)
		keyslot2 = new init_keyslot2_type(src)
	return ..()

/obj/item/device/radio/headset/initialize()
	recalculateChannels()
	return ..()

/obj/item/device/radio/headset/talk_into(datum/speech/speech_orig, channel=null)
	if(!broadcasting)
		return
	return ..()

/obj/item/device/radio/headset/receive_range(freq, level)
	if(ishuman(src.loc))
		var/mob/living/carbon/human/H = src.loc
		if(H.ears == src)
			return ..(freq, level)
	return -1

/obj/item/device/radio/headset/syndicate
	origin_tech = Tc_SYNDICATE + "=3"
	syndie = 1
	init_keyslot1_type = /obj/item/device/encryptionkey/syndicate

/obj/item/device/radio/headset/revsquad
	init_keyslot2_type = /obj/item/device/encryptionkey/rev
	syndie = 1

/obj/item/device/radio/headset/revsquad/emp_act()
	return

/obj/item/device/radio/headset/syndicate/commando/initialize()
	. = ..()
	set_frequency(SYND_FREQ)

/obj/item/device/radio/headset/raider
//	origin_tech = Tc_SYNDICATE + "=3" birds dont have super sekrit spy radios like the syndies have
	init_keyslot1_type = /obj/item/device/encryptionkey/raider
	raider = 1

/obj/item/device/radio/headset/raider/pretuned/initialize() // pre tuned radio to 1215 aka raider freq
	. = ..()
	set_frequency(RAID_FREQ)

/obj/item/device/radio/headset/binary
	origin_tech = Tc_SYNDICATE + "=3"
	init_keyslot1_type = /obj/item/device/encryptionkey/binary

/obj/item/device/radio/headset/headset_sec
	name = "security radio headset"
	desc = "This is used by your elite security force. To access the security channel, use :s."
	icon_state = "sec_headset"
	item_state = "headset"
	init_keyslot2_type = /obj/item/device/encryptionkey/headset_sec

/obj/item/device/radio/headset/headset_eng
	name = "engineering radio headset"
	desc = "When the engineers wish to chat like girls. To access the engineering channel, use :e. "
	icon_state = "eng_headset"
	item_state = "headset"
	init_keyslot2_type = /obj/item/device/encryptionkey/headset_eng

/obj/item/device/radio/headset/headset_rob
	name = "robotics radio headset"
	desc = "Made specifically for the roboticists who cannot decide between departments. To access the engineering channel, use :e. For research, use :n."
	icon_state = "rob_headset"
	item_state = "headset"
	init_keyslot2_type = /obj/item/device/encryptionkey/headset_rob

/obj/item/device/radio/headset/headset_med
	name = "medical radio headset"
	desc = "A headset for the trained staff of the medbay. To access the medical channel, use :m."
	icon_state = "med_headset"
	item_state = "headset"
	init_keyslot2_type = /obj/item/device/encryptionkey/headset_med

/obj/item/device/radio/headset/headset_sci
	name = "science radio headset"
	desc = "A sciency headset. Like usual. To access the science channel, use :n."
	icon_state = "com_headset"
	item_state = "headset"
	init_keyslot2_type = /obj/item/device/encryptionkey/headset_sci

/obj/item/device/radio/headset/headset_medsci
	name = "medical research radio headset"
	desc = "A headset that is a result of the mating between medical and science. To access the medical channel, use :m. For science, use :n."
	icon_state = "med_headset"
	item_state = "headset"
	init_keyslot2_type = /obj/item/device/encryptionkey/headset_medsci

/obj/item/device/radio/headset/headset_com
	name = "command radio headset"
	desc = "A headset with a commanding channel. To access the command channel, use :c."
	icon_state = "com_headset"
	item_state = "headset"
	init_keyslot2_type = /obj/item/device/encryptionkey/headset_com

/obj/item/device/radio/headset/heads/captain
	name = "captain's headset"
	desc = "The headset of the boss. Channels are as follows: :c - command, :s - security, :e - engineering, :u - supply, :d - service, :m - medical, :n - science."
	icon_state = "com_headset"
	item_state = "headset"
	init_keyslot2_type = /obj/item/device/encryptionkey/heads/captain

/obj/item/device/radio/headset/heads/rd
	name = "Research Director's headset"
	desc = "Headset of the researching God. To access the science channel, use :n. For command, use :c."
	icon_state = "com_headset"
	item_state = "headset"
	init_keyslot2_type = /obj/item/device/encryptionkey/heads/rd

/obj/item/device/radio/headset/heads/hos
	name = "head of security's headset"
	desc = "The headset of the man who protects your worthless lifes. To access the security channel, use :s. For command, use :c."
	icon_state = "com_headset"
	item_state = "headset"
	init_keyslot2_type = /obj/item/device/encryptionkey/heads/hos

/obj/item/device/radio/headset/heads/ce
	name = "chief engineer's headset"
	desc = "The headset of the guy who is in charge of morons. To access the engineering channel, use :e. For command, use :c."
	icon_state = "com_headset"
	item_state = "headset"
	init_keyslot2_type = /obj/item/device/encryptionkey/heads/ce

/obj/item/device/radio/headset/heads/cmo
	name = "chief medical officer's headset"
	desc = "The headset of the highly trained medical chief. This one is sterilized against memetic infection. To access the medical channel, use :m. For command, use :c."
	icon_state = "com_headset"
	item_state = "headset"
	sterility = 100
	init_keyslot2_type = /obj/item/device/encryptionkey/heads/cmo

/obj/item/device/radio/headset/heads/hop
	name = "head of personnel's headset"
	desc = "The headset of the guy who will one day be captain. Channels are as follows: :u - supply, :d - service, :c - command, :s - security"
	icon_state = "com_headset"
	item_state = "headset"
	init_keyslot2_type = /obj/item/device/encryptionkey/heads/hop

/obj/item/device/radio/headset/headset_cargo
	name = "supply radio headset"
	desc = "A headset used by the QM and his slaves. To access the supply channel, use :u."
	icon_state = "cargo_headset"
	item_state = "headset"
	init_keyslot2_type = /obj/item/device/encryptionkey/headset_cargo

/obj/item/device/radio/headset/headset_mining
	name = "supply radio headset"
	desc = "A headset used by the shaft miners to be yelled at from the QM and R&D at the same time. Channels are as follows: :u - supply, :n - science"
	icon_state = "mine_headset"
	item_state = "headset"
	init_keyslot2_type = /obj/item/device/encryptionkey/headset_mining

/obj/item/device/radio/headset/headset_service
	name = "service radio headset"
	desc = "A headset used by the chef, the bartender and the botanists to plan their poisoning of the entire crew. To access the service channel, use :d."
	icon_state = "service_headset"
	item_state = "headset"
	init_keyslot2_type = /obj/item/device/encryptionkey/headset_service

/obj/item/device/radio/headset/headset_engsci
	name = "research engineering radio headset"
	desc = "A headset used to gossip about engineering to the science crew, and about science to the engineering crew. To access the engineering channel, use :e. For science, use :n."
	icon_state = "eng_headset"
	item_state = "headset"
	init_keyslot2_type = /obj/item/device/encryptionkey/headset_engsci

/obj/item/device/radio/headset/headset_servsci
	name = "research service radio headset"
	desc = "A headset used to talk to botanists and scientists. To access the science channel, use :n. For service, use :d."
	icon_state = "com_headset"
	item_state = "headset"
	init_keyslot2_type = /obj/item/device/encryptionkey/headset_servsci
	
/obj/item/device/radio/headset/headset_iaa
	name = "internal affairs radio headset"
	desc = "A headset used to communicate with security and heads of staff. To access the security channel, use :s. For command, use :c."
	icon_state = "iaa_headset"
	item_state = "headset"
	init_keyslot2_type = /obj/item/device/encryptionkey/headset_iaa

/obj/item/device/radio/headset/headset_earmuffs
	name = "headset earmuffs"
	desc = "Protective earmuffs for sound technicians that allow one to speak on radio channels."
	icon = 'icons/obj/items.dmi'
	icon_state = "headset_earmuffs"
	item_state = "earmuffs"

/obj/item/device/radio/headset/headset_earmuffs/syndie
	origin_tech = Tc_SYNDICATE + "=3"
	syndie = 1
	init_keyslot1_type = /obj/item/device/encryptionkey/syndicate

/obj/item/device/radio/headset/deathsquad
	name = "Deathsquad headset"
	desc = "A headset used by the dark side of Nanotrasen's Spec Ops. Channels are as follows: :0 - Deathsquad :c - command, :s - security, :e - engineering, :d - mining, :q - cargo, :m - medical, :n - science."
	icon_state = "deathsquad_headset"
	item_state = "headset"
	freerange = 1
	init_keyslot2_type = /obj/item/device/encryptionkey/deathsquad

/obj/item/device/radio/headset/ert
	name = "CentCom Response Team headset"
	desc = "The headset of the boss's boss. Channels are as follows: ':-' - Response Team :c - command, :s - security, :e - engineering, :d - mining, :q - cargo, :m - medical, :n - science."
	icon_state = "ert_headset"
	item_state = "headset"
	freerange = 1
	init_keyslot2_type = /obj/item/device/encryptionkey/ert

/obj/item/device/radio/headset/attackby(obj/item/weapon/W, mob/user)
//	..()
	if(hidden_uplink && hidden_uplink.active && hidden_uplink.refund(user, W))
		return
	user.set_machine(src)
	if (!( W.is_screwdriver(user) || (istype(W, /obj/item/device/encryptionkey/ ))))
		return

	if(W.is_screwdriver(user))
		if(keyslot1 || keyslot2)


			for(var/ch_name in channels)
				radio_controller.remove_object(src, radiochannels[ch_name])
				secure_radio_connections[ch_name] = null


			if(keyslot1)
				var/turf/T = get_turf(user)
				if(T)
					keyslot1.forceMove(T)
					keyslot1 = null



			if(keyslot2)
				var/turf/T = get_turf(user)
				if(T)
					keyslot2.forceMove(T)
					keyslot2 = null

			recalculateChannels()
			to_chat(user, "You pop out the encryption keys in the headset!")

		else
			to_chat(user, "This headset doesn't have any encryption keys!  How useless...")

	if(istype(W, /obj/item/device/encryptionkey/))
		if(keyslot1 && keyslot2)
			to_chat(user, "The headset can't hold another key!")
			return

		if(!keyslot1)
			if(user.drop_item(W, src))
				keyslot1 = W

		else
			if(user.drop_item(W, src))
				keyslot2 = W


		recalculateChannels()

	return

/obj/item/device/radio/headset/set_frequency(new_frequency)
	..()
	recalculateChannels()

/obj/item/device/radio/headset/proc/recalculateChannels()
	src.channels = list()
	src.translate_binary = 0
	src.translate_hive = 0
	src.syndie = 0
	src.raider = 0

	if(keyslot1)
		for(var/ch_name in keyslot1.channels)
			if(ch_name in src.channels)
				continue
			src.channels += ch_name
			src.channels[ch_name] = keyslot1.channels[ch_name]

		if(keyslot1.translate_binary)
			src.translate_binary = 1

		if(keyslot1.translate_hive)
			src.translate_hive = 1

		if(keyslot1.syndie)
			src.syndie = 1

		if(keyslot1.raider)
			src.raider = 1

	if(keyslot2)
		for(var/ch_name in keyslot2.channels)
			if(ch_name in src.channels)
				continue
			src.channels += ch_name
			src.channels[ch_name] = keyslot2.channels[ch_name]

		if(keyslot2.translate_binary)
			src.translate_binary = 1

		if(keyslot2.translate_hive)
			src.translate_hive = 1

		if(keyslot2.syndie)
			src.syndie = 1

		if(keyslot2.raider)
			src.raider = 1


	for (var/ch_name in channels)
		secure_radio_connections[ch_name] = add_radio(src, radiochannels[ch_name])

	return
