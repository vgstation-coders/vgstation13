/obj/item/device/encryptionkey/
	name = "Standard Encryption Key"
	desc = "An encryption key for a radio headset.  Has no special codes in it.  WHY DOES IT EXIST?  ASK NANOTRASEN."
	icon = 'icons/obj/radio.dmi'
	icon_state = "cypherkey"
	item_state = ""
	w_class = W_CLASS_TINY
	var/translate_binary = 0
	var/translate_hive = 0
	var/station_secured = FALSE
	var/list/channels = list()
	var/list/secured_channels = list()

/obj/item/device/encryptionkey/attackby(obj/item/weapon/W as obj, mob/user as mob)

/obj/item/device/encryptionkey/syndicate // Decrypts syndie comms
	icon_state = "cypherkey"
	channels = list("Syndicate" = 1)
	origin_tech = Tc_SYNDICATE + "=3"
	secured_channels = list("Syndicate")

/obj/item/device/encryptionkey/raider // Decrypts raider comms
	icon_state = "cypherkey"
	channels = list("Raider" = 1)
	//origin_tech = Tc_SYNDICATE + "=3"
	secured_channels = list("Raider")

/obj/item/device/encryptionkey/binary
	icon_state = "cypherkey"
	translate_binary = 1
	origin_tech = Tc_SYNDICATE + "=3"

/obj/item/device/encryptionkey/headset_sec
	name = "Security Radio Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "sec_cypherkey"
	channels = list("Security" = 1)
	secured_channels = list("Security")

/obj/item/device/encryptionkey/headset_eng
	name = "Engineering Radio Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "eng_cypherkey"
	channels = list("Engineering" = 1)

/obj/item/device/encryptionkey/headset_rob
	name = "Robotics Radio Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "rob_cypherkey"
	channels = list("Engineering" = 1, "Science" = 1)

/obj/item/device/encryptionkey/headset_med
	name = "Medical Radio Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "med_cypherkey"
	channels = list("Medical" = 1)

/obj/item/device/encryptionkey/headset_sci
	name = "Science Radio Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "sci_cypherkey"
	channels = list("Science" = 1)

/obj/item/device/encryptionkey/headset_medsci
	name = "Medical Research Radio Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "medsci_cypherkey"
	channels = list("Medical" = 1, "Science" = 1)

/obj/item/device/encryptionkey/headset_com
	name = "Command Radio Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "com_cypherkey"
	channels = list("Command" = 1)
	secured_channels = list("Command")

/obj/item/device/encryptionkey/heads/captain
	name = "Captain's Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "cap_cypherkey"
	channels = list("Command" = 1, "Security" = 1, "Engineering" = 0, "Science" = 0, "Medical" = 0, "Supply" = 0, "Service" = 0)
	secured_channels = list("Command", "Security")

/obj/item/device/encryptionkey/syndicate/hacked
	name = "Standard Encryption Key"
	desc = "An encryption key for a radio headset.  Has no special codes in it. Looks more sophisticated than usual."
	channels = list("Command" = 1, "Security" = 1, "Engineering" = 1, "Science" = 1, "Medical" = 1, "Supply" = 1, "Service" = 1)
	secured_channels = list("Command", "Security")

/obj/item/device/encryptionkey/syndicate/hacked/full
	channels = list("Command" = 1, "Security" = 1, "Engineering" = 1, "Science" = 1, "Medical" = 1, "Supply" = 1, "Service" = 1, "Deathsquad" = 1, "Response Team" = 1)
	secured_channels = list("Command", "Security", "Response Team")

/obj/item/device/encryptionkey/heads/rd
	name = "Research Director's Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "rd_cypherkey"
	channels = list("Science" = 1, "Command" = 1)
	secured_channels = list("Command")

/obj/item/device/encryptionkey/heads/hos
	name = "Head of Security's Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "hos_cypherkey"
	channels = list("Security" = 1, "Command" = 1)
	secured_channels = list("Security", "Command")

/obj/item/device/encryptionkey/heads/ce
	name = "Chief Engineer's Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "ce_cypherkey"
	channels = list("Engineering" = 1, "Command" = 1)
	secured_channels = list("Command")

/obj/item/device/encryptionkey/heads/cmo
	name = "Chief Medical Officer's Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "cmo_cypherkey"
	channels = list("Medical" = 1, "Command" = 1)
	secured_channels = list("Command")

/obj/item/device/encryptionkey/heads/hop
	name = "Head of Personnel's Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "hop_cypherkey"
	channels = list("Supply" = 1, "Service" = 1, "Command" = 1, "Security" = 0)
	secured_channels = list("Security", "Command")

/obj/item/device/encryptionkey/headset_cargo
	name = "Supply Radio Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "cargo_cypherkey"
	channels = list("Supply" = 1)

/obj/item/device/encryptionkey/headset_mining
	name = "Mining Radio Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "mine_cypherkey"
	channels = list("Supply" = 1, "Science" = 1)

/obj/item/device/encryptionkey/headset_service
	name = "Service Radio Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "service_cypherkey"
	channels = list("Service" = 1)

/obj/item/device/encryptionkey/headset_engsci
	name = "Research Engineering Radio Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "engsci_cypherkey"
	channels = list("Science" = 1, "Engineering" = 1)

/obj/item/device/encryptionkey/headset_servsci
	name = "Research Botany Radio Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "servsci_cypherkey"
	channels = list("Science" = 1, "Service" = 1)

/obj/item/device/encryptionkey/headset_serveng
	name = "Sound Technician Radio Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "serveng_cypherkey"
	channels = list("Engineering" = 1, "Service" = 1)

/obj/item/device/encryptionkey/deathsquad
	name = "Deathsquad Radio Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "deathsquad_cypherkey"
	channels = list("Deathsquad" = 1, "Science" = 1, "Command" = 1, "Medical" = 1, "Engineering" = 1, "Security" = 1, "Mining" = 1, "Cargo" = 1,)

/obj/item/device/encryptionkey/ert
	name = "Nanotrasen ERT Radio Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "ert_cypherkey"
	channels = list("Response Team" = 1, "Science" = 1, "Command" = 1, "Medical" = 1, "Engineering" = 1, "Security" = 1, "Mining" = 1, "Cargo" = 1,)

/obj/item/device/encryptionkey/ai
	name = "AI Encryption Key"
	desc = "An encryption key for a radio headset.  Contains cypherkeys."
	icon_state = "cap_cypherkey"
	channels = list("AI Private" = 1, "Command" = 1, "Security" = 1, "Engineering" = 0, "Science" = 0, "Medical" = 0, "Supply" = 0, "Service" = 0)
