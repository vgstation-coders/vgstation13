/obj/structure/closet/secure_closet/vault
	name = "vault locker"
	desc = "For when you absolutely need to keep something safe."
	icon = 'icons/obj/closet.dmi'
	icon_state = "vault1"
	density = 1
	opened = 0
	large = 1
	locked = 1
	anchored = 1 //immovable
	icon_closed = "vault"
	icon_locked = "vault1"
	icon_opened = "vaultopen"
	icon_broken = "vaultbroken"
	icon_off = "vaultoff"
	wall_mounted = 0 //never solid (You can always pass over it)
	health = 20000

/obj/structure/closet/secure_closet/vault/ex_act(var/severity) //bomb-proof
	var/list/bombs = search_contents_for(/obj/item/device/transfer_valve)
	if(!isemptylist(bombs))
		..(severity)
	return

/obj/structure/closet/secure_closet/vault/emp_act(severity) //EMP-proof
	for(var/obj/O in src)
		O.emp_act(severity)
	..()

/obj/structure/closet/secure_closet/vault/armory
	name = "\improper Armory vault locker"
	req_access = list(access_armory)

/obj/structure/closet/secure_closet/vault/armory/lawgiver
/obj/structure/closet/secure_closet/vault/armory/lawgiver/New()
	..()
	new /obj/item/weapon/storage/lockbox/lawgiver(src)

/obj/structure/closet/secure_closet/vault/vault
	req_access = list(access_heads_vault)

/obj/structure/closet/secure_closet/vault/centcomm
	name = "\improper Centcomm vault locker"
	req_access = list(access_cent_general)

/obj/structure/closet/secure_closet/vault/syndicate
	name = "\improper Syndicate vault locker"
	req_access = list(access_syndicate)

/obj/structure/closet/secure_closet/vault/ert
	name = "\improper ERT vault locker"
	req_access = list(access_cent_ert)