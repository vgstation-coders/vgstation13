/*
in this file:
items for the fission reactor which don't have another place to be.

includes:
	fuel rod (item)
'*/


/obj/item/weapon/fuelrod
	name="fuel rod"
	icon='icons/obj/fissionreactor/items.dmi'
	icon_state="i_fuelrod_empty"
	var/datum/fission_fuel/fueldata=null
	

/obj/item/weapon/fuelrod/New()
	fueldata = new /datum/fission_fuel
	..()
	

/obj/item/weapon/fuelrod/update_icon()
	..()
	icon_state="i_fuelrod_empty"
	if(!fueldata)
		return
	if(fueldata.fuel.total_volume>0)
		icon_state="i_fuelrod[fueldata.life>0 ? "" : "_depleted"]"





