/* You attempt to make water by mixing the ingredients for Hydroperoxyl, but you get a big, whopping sum of nothing!
/datum/chemical_reaction/water //Keeping this commented out for posterity.
	name = "Water"
	id = "water"
	required_reagents = list("oxygen" = 2, "hydrogen" = 1) //And there goes the atmosphere, thanks greenhouse gases!
	results = list("water"=1)
*/

/datum/chemical_reaction/water
	name = "Water"
	id = "water"
	required_reagents = list("hydrogen" = 2, "oxygen" = 1)
	results = list("water"=1)

/datum/chemical_reaction/sodiumchloride
	name = "Sodium Chloride"
	id = "sodiumchloride"
	required_reagents = list("sodium" = 1, "chlorine" = 1)
	results = list("sodiumchloride" = 2)

/datum/chemical_reaction/plasmasolidification
	name = "Solid Plasma"
	id = "solidplasma"
	required_reagents = list("iron" = 5, "frostoil" = 5, "plasma" = 20)

/datum/chemical_reaction/plasmasolidification/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/stack/sheet/mineral/plasma(location)
	return

/datum/chemical_reaction/plastication
	name = "Plastic"
	id = "solidplastic"
	required_reagents = list("pacid" = 10, "plasticide" = 20)

/datum/chemical_reaction/plastication/on_reaction(var/datum/reagents/holder)
	new /obj/item/stack/sheet/mineral/plastic(get_turf(holder.my_atom),10)
	return

