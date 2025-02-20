/*
in this file:
items for the fission reactor which don't have another place to be.

includes:
	fuel rod (item)
'*/


/obj/item/weapon/fuelrod
	name="fuel reservoir"
	desc="Holds various reagents for use in nuclear reactions."
	icon='icons/obj/fissionreactor/items.dmi'
	icon_state="i_fuelrod_empty"
	var/datum/fission_fuel/fueldata=null
	var/units_of_storage=90
	

/obj/item/weapon/fuelrod/New()
	fueldata = new /datum/fission_fuel(units_of_storage)
	..()
	

/obj/item/weapon/fuelrod/update_icon()
	..()
	icon_state="i_fuelrod_empty"
	if(!fueldata)
		return
	if(fueldata.fuel.total_volume>0)
		icon_state="i_fuelrod[fueldata.life>0 ? "" : "_depleted"]"


/obj/item/weapon/fuelrod/small
	name="small fuel reservoir"
	desc="A small container for lower-power applications."
	icon_state="i_fuelrod_s_empty"
	units_of_storage=30
	
/obj/item/weapon/fuelrod/small/update_icon()
	..()
	icon_state="i_fuelrod_s_empty"
	if(!fueldata)
		return
	if(fueldata.fuel.total_volume>0)
		icon_state="i_fuelrod_s[fueldata.life>0 ? "" : "_depleted"]"	

/obj/item/weapon/fuelrod/large
	name="large fuel reservoir"
	icon_state="i_fuelrod_l_empty"
	desc="A very large container, for high-power or complex mixes. Use with caution."
	units_of_storage=210	

/obj/item/weapon/fuelrod/large/update_icon()
	..()
	icon_state="i_fuelrod_l_empty"
	if(!fueldata)
		return
	if(fueldata.fuel.total_volume>0)
		icon_state="i_fuelrod_l[fueldata.life>0 ? "" : "_depleted"]"
