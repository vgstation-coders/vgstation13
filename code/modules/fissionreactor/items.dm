/*
in this file:
items for the fission reactor which don't have another place to be.

includes:
	fuel rod (item)
'*/


/obj/item/weapon/fuelrod
	name="fuel rod"
	desc="holds various reagents for use in nuclear reactions."
	icon='icons/obj/fissionreactor/items.dmi'
	icon_state="i_fuelrod_empty"
	var/datum/fission_fuel/fueldata=null
	var/units_of_storage=150
	

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
	name="small fuel rod"
	desc="a smaller fuel rod, for lower-power applications."
	units_of_storage=50
	


