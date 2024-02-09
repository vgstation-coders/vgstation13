#define ALERT_AMOUNT_ONLY 1
#define ALERT_ALL_REAGENTS 2

///////////////////////////////////////////////////////////////////////////////////
/datum/chemical_reaction
	var/name = null
	var/id = null
	var/result = null
	var/list/required_reagents = new/list()
	var/list/required_catalysts = new/list()

	//Both of these variables are mostly going to be used with slime cores - but if you want to, you can use them for other things
	var/atom/required_container = null //The container required for the reaction to happen

	var/result_amount = 0
	var/secondary = 0 //Set to nonzero if secondary reaction
	var/list/secondary_results = list() //Additional reagents produced by the reaction
	var/is_cold_recipe = 0
	var/required_temp = 0
	var/react_discretely = FALSE //Handle_reactions() won't find the maximum number of times the chemicals can react. Use only if it shouldn't react more than once at a time.
	var/reaction_temp_change = 0 //How much to change the temperature of the result chemical after the reaction
	var/alert_admins = 0 //1 to alert admins with name and amount, 2 to alert with name and amount of all reagents
	var/quiet = 0

	var/data = null


/datum/chemical_reaction/proc/log_reaction(var/datum/reagents/holder, var/amt)
	var/datum/log_controller/I = investigations[I_CHEMS]
	var/atom/A = holder.my_atom
	var/turf/T = get_turf(holder.my_atom)
	var/mob/M = get_holder_of_type(A, /mob) //if held by a mob (not necessarily true)

	var/obj/machinery/O = get_holder_of_type(A, /obj/machinery) //rather than showing "in a large beaker" let's show the name of the machine if it's inside one
	if(istype(O))
		A = O

	var/investigate_text = "<small>[time_stamp()] \ref[A] ([formatJumpTo(T)])</small> || "

	if(result)
		investigate_text += "[amt]u of [result] have been created"
	else
		investigate_text += "\A [name] reaction ([amt]u total combined) has taken place"

	if(M)
		investigate_text += " in \a [A], carried by [M.real_name] ([M.key])<br />"
	else
		investigate_text += " in \a [A], last touched by [(A.fingerprintslast ? A.fingerprintslast : "N/A (Last user processed: [usr ? usr.ckey : "N/A"])")]<br />"

	I.write(investigate_text)

	if(alert_admins)
		var/admin_text = "[name] reaction [alert_admins == 2 ? "([holder.get_reagent_ids(1)])" : "([amt]u total combined)"] at [formatJumpTo(T)]"
		if(M)
			admin_text += " in \a [A] (<A HREF='?_src_=vars;Vars=\ref[A]'>VV</A>), carried by [M.real_name] ([M.key]) (<A HREF='?_src_=holder;adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>)"
		else
			admin_text += " in \a [A] (<A HREF='?_src_=vars;Vars=\ref[A]'>VV</A>), last touched by [(A.fingerprintslast ? A.fingerprintslast : "N/A (Last user processed: [usr.ckey])")]"
		message_admins(admin_text, 0, 1)
	return investigate_text

/datum/chemical_reaction/proc/on_reaction(var/datum/reagents/holder, var/created_volume)
	return

//Add conditions here for whether a reaction will happen when reactions happen. Defaults to 1
/datum/chemical_reaction/proc/required_condition_check(var/datum/reagents/holder)
	return 1

//I recommend you set the result amount to the total volume of all components.
/datum/chemical_reaction/explosion_potassium
	name = "Water Potassium Explosion"
	id = "explosion_potassium"
	result = null
	required_reagents = list(POTASSIUM = 1, WATER = 1)
	result_amount = 2
	alert_admins = ALERT_AMOUNT_ONLY
	secondary = 1

/datum/chemical_reaction/explosion_potassium/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/datum/effect/system/reagents_explosion/e = new()
	e.set_up(min(round (created_volume/10, 1), 15), holder.my_atom, 0, 0)
	e.holder_damage(holder.my_atom)
	if(isliving(holder.my_atom))
		e.amount *= 0.5
		var/mob/living/L = holder.my_atom
		if(L.stat != DEAD)
			e.amount *= 0.5
	e.start()
	holder.clear_reagents()
	holder.add_reagent(POTASSIUM_HYDROXIDE, created_volume)

/datum/chemical_reaction/explosion_potassium/holy
	id = "holy_explosion_potassium"
	required_reagents = list(POTASSIUM = 1, HOLYWATER = 1)
	result_amount = 2.4

/datum/chemical_reaction/explosion_potassium/holy/on_reaction(var/datum/reagents/holder, var/created_volume)
	set waitfor = FALSE //makes sleep() work like spawn()
	playsound(holder.my_atom, 'sound/misc/holyhandgrenade.ogg', 100, 0)
	sleep(2 SECONDS) //wait for the song to finish
	..() //boom

/datum/chemical_reaction/soap //Potassium Hydroxide is used in making liquid soap not bar soap but that will not stop me
	name = "Soap"
	id = "soap"
	result = null
	required_reagents = list(POTASSIUM_HYDROXIDE = 20, NUTRIMENT = 5)
	required_temp = T0C + 50
	result_amount = 1

/datum/chemical_reaction/soap/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i=1 to created_volume)
		new /obj/item/weapon/soap(location)

/datum/chemical_reaction/creatine
	name = "Creatine"
	id = CREATINE
	result = CREATINE
	required_reagents = list(NUTRIMENT = 1, BICARIDINES = 1, HYPERZINES = 1, MUTAGENS = 1)
	result_amount = 2

/datum/chemical_reaction/discount
	name = "Discount Dan's Special Sauce"
	id = DISCOUNT
	result = DISCOUNT
	required_reagents = list(IRRADIATEDBEANS = 1, TOXICWASTE = 1, REFRIEDBEANS = 1, MUTATEDBEANS = 1, BEFF = 1, HORSEMEAT = 1, CORNSYRUP = 1, \
							 MOONROCKS = 1, OFFCOLORCHEESE = 1, BONEMARROW = 1, GREENRAMEN = 1, GLOWINGRAMEN = 1, DEEPFRIEDRAMEN = 1)
	result_amount = 13

/datum/chemical_reaction/peptobismol
	name = "Peptobismol"
	id = PEPTOBISMOL
	result = PEPTOBISMOL
	required_reagents = list(ANTI_TOXINS = 1, DISCOUNT = 1)
	result_amount = 2

/datum/chemical_reaction/emp_pulse
	name = "EMP Pulse"
	id = "emp_pulse"
	result = null
	required_reagents = list(URANIUM = 1, IRON = 1) // Yes, laugh, it's the best recipe I could think of that makes a little bit of sense
	result_amount = 2

/datum/chemical_reaction/emp_pulse/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	//100 created volume = 4 heavy range & 7 light range. A few tiles smaller than traitor EMP grandes.
	//200 created volume = 8 heavy range & 14 light range. 4 tiles larger than traitor EMP grenades.
	empulse(location, round(created_volume / 24), round(created_volume / 14), 1)
	holder.clear_reagents()

/datum/chemical_reaction/silicate
	name = "Silicate"
	id = SILICATE
	result = SILICATE
	required_reagents = list(ALUMINUM = 1, SILICON = 1, OXYGEN = 1)
	result_amount = 9

/datum/chemical_reaction/phalanximine
	name = "Phalanximine"
	id = PHALANXIMINE
	result = PHALANXIMINE
	required_reagents = list(HYRONALIN = 1, ETHANOL = 1, MUTAGEN = 1)
	result_amount = 3

/datum/chemical_reaction/stoxin
	name = "Sleep Toxin"
	id = STOXIN
	result = STOXIN
	required_reagents = list(CHLORALHYDRATE = 1, SUGARS = 4)
	result_amount = 5

/datum/chemical_reaction/sterilizine
	name = "Sterilizine"
	id = STERILIZINE
	result = STERILIZINE
	required_reagents = list(ETHANOL = 1, ANTI_TOXINS = 1, CHLORINE = 1)
	result_amount = 3

/datum/chemical_reaction/inaprovaline
	name = "Inaprovaline"
	id = INAPROVALINE
	result = INAPROVALINE
	required_reagents = list(OXYGEN = 1, CARBON = 1, SUGARS = 1)
	result_amount = 3

/datum/chemical_reaction/anti_toxin
	name = "Dylovene"
	id = ANTI_TOXIN
	result = ANTI_TOXIN
	required_reagents = list(SILICON = 1, POTASSIUM = 1, NITROGEN = 1)
	result_amount = 3

/datum/chemical_reaction/mutagen
	name = "Unstable mutagen"
	id = MUTAGEN
	result = MUTAGEN
	required_reagents = list(RADIUM = 1, PHOSPHORUS = 1, CHLORINE = 1)
	result_amount = 3

/datum/chemical_reaction/tramadol
	name = "Tramadol"
	id = TRAMADOL
	result = TRAMADOL
	required_reagents = list(INAPROVALINE = 1, ETHANOL = 1, OXYGEN = 1)
	result_amount = 3

/datum/chemical_reaction/oxycodone
	name = "Oxycodone"
	id = OXYCODONE
	result = OXYCODONE
	required_reagents = list(ETHANOL = 1, TRAMADOL = 1, PLASMA = 1)
	result_amount = 3

///datum/chemical_reaction/cyanide
//	name = "Cyanide"
//	id = CYANIDE
//	result = CYANIDE
//	required_reagents = list(HYDROGEN = 1, CARBON = 1, NITROGEN = 1)
//	result_amount = 1

/* You attempt to make water by mixing the ingredients for Hydroperoxyl, but you get a big, whopping sum of nothing!
/datum/chemical_reaction/water //Keeping this commented out for posterity.
	name = "Water"
	id = WATER
	result = null //I can't believe it's not water!
	required_reagents = list(OXYGEN = 2, HYDROGEN = 1) //And there goes the atmosphere, thanks greenhouse gases!
	result_amount = 1
*/

/datum/chemical_reaction/water
	name = "Water"
	id = WATER
	result = WATER
	required_reagents = list(HYDROGEN = 2, OXYGEN = 1)
	result_amount = 1

/datum/chemical_reaction/sacid
	name = "Sulphuric Acid"
	id = SACID
	result = SACID
	required_reagents = list(SULFUR = 1, OXYGEN = 3, WATER = 1)
	result_amount = 1

/datum/chemical_reaction/thermite
	name = "Thermite"
	id = THERMITE
	result = THERMITE
	required_reagents = list(ALUMINUM = 1, IRON = 1, OXYGEN = 1)
	result_amount = 3

/datum/chemical_reaction/lexorin
	name = "Lexorin"
	id = LEXORIN
	result = LEXORIN
	required_reagents = list(PLASMA = 1, AMMONIA = 1)
	result_amount = 3

/datum/chemical_reaction/space_drugs
	name = "Space Drugs"
	id = SPACE_DRUGS
	result = SPACE_DRUGS
	required_reagents = list(MERCURY = 1, SUGARS = 1, LITHIUM = 1)
	result_amount = 3

/datum/chemical_reaction/lube
	name = "Space Lube"
	id = LUBE
	result = LUBE
	required_reagents = list(WATER = 1, SILICON = 1, OXYGEN = 1)
	result_amount = 4

/datum/chemical_reaction/sodium_polyacrylate
	name = "Sodium Polyacrylate"
	id = SODIUM_POLYACRYLATE
	result = SODIUM_POLYACRYLATE
	required_reagents = list(CARBON = 3, SODIUM = 1, WATER = 2)
	result_amount = 8

/datum/chemical_reaction/spoly_absorb_water
	name = "Absorb Water"
	id = "absorbwater"
	result = CHEMICAL_WASTE
	required_reagents = list(SODIUM_POLYACRYLATE = 0.3, WATER = 1)
	result_amount = 0.3

/datum/chemical_reaction/spoly_absorb_lube
	name = "Absorb Lube"
	id = "absorblube"
	result = CHEMICAL_WASTE
	required_reagents = list(SODIUM_POLYACRYLATE = 0.3, LUBE = 1)
	result_amount = 0.3

/datum/chemical_reaction/sludge
	name = "Sludge"
	id = CHEMICAL_WASTE
	result = CHEMICAL_WASTE
	required_reagents = list(LUBE = 1)
	result_amount = 0.2
	required_temp = 3500
	react_discretely = TRUE
	reaction_temp_change = -3500

/datum/chemical_reaction/degrease
	name = "Degrease"
	id = "degrease"
	result = null
	required_reagents = list(CHEMICAL_WASTE = 1, ETHANOL = 1) //Turns out it really WAS an engine degreaser
	result_amount = 0

/datum/chemical_reaction/pacid
	name = "Polytrinic acid"
	id = PACID
	result = PACID
	required_reagents = list(SACIDS = 1, CHLORINE = 1, POTASSIUM = 1)
	result_amount = 3

/datum/chemical_reaction/synaptizine
	name = "Synaptizine"
	id = SYNAPTIZINE
	result = SYNAPTIZINE
	required_reagents = list(SUGARS = 1, LITHIUM = 1, WATER = 1)
	result_amount = 3

/datum/chemical_reaction/hyronalin
	name = "Hyronalin"
	id = HYRONALIN
	result = HYRONALIN
	required_reagents = list(RADIUM = 1, ANTI_TOXINS = 1)
	result_amount = 2

/datum/chemical_reaction/arithrazine
	name = "Arithrazine"
	id = ARITHRAZINE
	result = ARITHRAZINE
	required_reagents = list(HYRONALIN = 1, HYDROGEN = 1)
	result_amount = 2

/datum/chemical_reaction/impedrezene
	name = "Impedrezene"
	id = IMPEDREZENE
	result = IMPEDREZENE
	required_reagents = list(MERCURY = 1, OXYGEN = 1, SUGARS = 1)
	result_amount = 2

/datum/chemical_reaction/kelotane
	name = "Kelotane"
	id = KELOTANE
	result = KELOTANE
	required_reagents = list(SILICON = 1, CARBON = 1)
	result_amount = 2

/datum/chemical_reaction/blisterol
	name = "Blisterol"
	id = BLISTEROL
	result = BLISTEROL
	required_reagents = list(ALUMINUM = 1, COPPER = 1, FUEL = 2)
	result_amount = 3

/datum/chemical_reaction/virus_food
	name = "Virus Food"
	id = VIRUSFOOD
	result = VIRUSFOOD
	required_reagents = list(WATER = 5, MILK = 5)
	result_amount = 15

/datum/chemical_reaction/leporazine
	name = "Leporazine"
	id = LEPORAZINE
	result = LEPORAZINE
	required_reagents = list(SILICON = 1, COPPER = 1)
	required_catalysts = list(PLASMA = 5)
	result_amount = 2

/datum/chemical_reaction/cryptobiolin
	name = "Cryptobiolin"
	id = CRYPTOBIOLIN
	result = CRYPTOBIOLIN
	required_reagents = list(POTASSIUM = 1, OXYGEN = 1, SUGARS = 1)
	result_amount = 3

/datum/chemical_reaction/tricordrazine
	name = "Tricordrazine"
	id = TRICORDRAZINE
	result = TRICORDRAZINE
	required_reagents = list(INAPROVALINE = 1, ANTI_TOXINS = 1)
	result_amount = 2

/datum/chemical_reaction/simpolinol
	name = "Simpolinol"
	id = SIMPOLINOL
	result = SIMPOLINOL
	required_reagents = list(METHYLIN = 20, SILVER = 20)
	result_amount = 40

/datum/chemical_reaction/simpolinol2
	name = "Simpolinol"
	id = "simpolinol_alternate"
	result = SIMPOLINOL
	required_reagents = list(VAPORSALT = 1)
	required_container = /obj/item/weapon/reagent_containers/food/drinks/soda_cans
	result_amount = 1

/datum/chemical_reaction/alkysine
	name = "Alkysine"
	id = ALKYSINE
	result = ALKYSINE
	required_reagents = list(CHLORINE = 1, NITROGEN = 1, ANTI_TOXINS = 1)
	result_amount = 2

/datum/chemical_reaction/alkycosine
	name = "Alkycosine"
	id = ALKYCOSINE
	result = ALKYCOSINE
	required_reagents = list(ALKYSINE = 1, BLEACH = 1, ANTI_TOXINS = 1)
	required_temp = T0C + 40
	result_amount = 4

/datum/chemical_reaction/dexalin
	name = "Dexalin"
	id = DEXALIN
	result = DEXALIN
	required_reagents = list(OXYGEN = 2)
	required_catalysts = list(PLASMA = 5)
	result_amount = 1

/datum/chemical_reaction/dermaline
	name = "Dermaline"
	id = DERMALINE
	result = DERMALINE
	required_reagents = list(OXYGEN = 1, PHOSPHORUS = 1, KELOTANES = 1)
	result_amount = 3

/datum/chemical_reaction/dexalinp
	name = "Dexalin Plus"
	id = DEXALINP
	result = DEXALINP
	required_reagents = list(DEXALINS = 1, CARBON = 1, IRON = 1)
	result_amount = 3

/datum/chemical_reaction/bicaridine
	name = "Bicaridine"
	id = BICARIDINE
	result = BICARIDINE
	required_reagents = list(INAPROVALINE = 1, CARBON = 1)
	result_amount = 2

/datum/chemical_reaction/synthocarisol
	name = "Synthocarisol"
	id = SYNTHOCARISOL
	result = SYNTHOCARISOL
	required_reagents = list(BICARIDINES = 1, INAPROVALINE = 1)
	required_temp = T0C + 77
	result_amount = 2

/datum/chemical_reaction/hyperzine
	name = "Hyperzine"
	id = HYPERZINE
	result = HYPERZINE
	required_reagents = list(SUGARS = 1, PHOSPHORUS = 1, SULFUR = 1)
	result_amount = 3

/datum/chemical_reaction/PCP
	name = "Liquid PCP"
	id = LIQUIDPCP
	result = LIQUIDPCP
	required_reagents = list(HYPERZINES = 5, MINDBREAKER = 5)
	required_temp = T0C + 200
	result_amount = 5

/datum/chemical_reaction/ryetalyn
	name = "Ryetalyn"
	id = RYETALYN
	result = RYETALYN
	required_reagents = list(ARITHRAZINE = 1, CARBON = 1)
	result_amount = 2

/datum/chemical_reaction/cryoxadone
	name = "Cryoxadone"
	id = CRYOXADONE
	result = CRYOXADONE
	required_reagents = list(DEXALINS = 1, WATER = 1, OXYGEN = 1)
	result_amount = 3

/datum/chemical_reaction/clonexadone
	name = "Clonexadone"
	id = CLONEXADONE
	result = CLONEXADONE
	required_reagents = list(CRYOXADONE = 1, SODIUM = 1)
	required_catalysts = list(PLASMA = 5)
	result_amount = 2

/datum/chemical_reaction/spaceacillin
	name = "Spaceacillin"
	id = SPACEACILLIN
	result = SPACEACILLIN
	required_reagents = list(CRYPTOBIOLINS = 1, INAPROVALINE = 1)
	result_amount = 2

/datum/chemical_reaction/nanofloxacin
	name = "Nanofloxacin"
	id = NANOFLOXACIN
	result = NANOFLOXACIN
	required_reagents = list(NANOBOTS = 1, SPACEACILLIN = 5, FLUORINE = 5)
	result_amount = 2.5

/datum/chemical_reaction/vaccine
	name = "Vaccine"
	id = VACCINE
	result = VACCINE
	required_reagents = list(ALUMINUM = 1, SUGARS = 1, WATER = 1)
	result_amount = 3
	data = list(
		"antigen" = list(),
		)

/datum/chemical_reaction/imidazoline
	name = IMIDAZOLINE
	id = IMIDAZOLINE
	result = IMIDAZOLINE
	required_reagents = list(CARBON = 1, HYDROGEN = 1, ANTI_TOXINS = 1)
	result_amount = 2

/datum/chemical_reaction/inacusiate
	name = INACUSIATE
	id = INACUSIATE
	result = INACUSIATE
	required_reagents = list(WATER = 1, CARBON = 1, ANTI_TOXINS = 1)
	result_amount = 3

/datum/chemical_reaction/ethylredoxrazine
	name = "Ethylredoxrazine"
	id = ETHYLREDOXRAZINE
	result = ETHYLREDOXRAZINE
	required_reagents = list(OXYGEN = 1, ANTI_TOXINS = 1, CARBON = 1)
	result_amount = 3

/datum/chemical_reaction/ethanoloxidation
	name = "ethanoloxidation"	//Kind of a placeholder in case someone ever changes it so that chemicals
	id = "ethanoloxidation"		//react in the body. Also it would be silly if it didn't exist.
	result = WATER
	required_reagents = list(ETHYLREDOXRAZINE = 1, ETHANOL = 1)
	result_amount = 2

/datum/chemical_reaction/glycerol
	name = "Glycerol"
	id = GLYCEROL
	result = GLYCEROL
	required_reagents = list(CORNOIL = 3, SACIDS = 1)
	result_amount = 1

/datum/chemical_reaction/nitroglycerin
	name = "Nitroglycerin Explosion"
	id = NITROGLYCERIN
	result = NITROGLYCERIN
	required_reagents = list(GLYCEROL = 1, PACIDS = 1, SACIDS = 1)
	result_amount = 2
	alert_admins = ALERT_AMOUNT_ONLY

/datum/chemical_reaction/nitroglycerin/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/datum/effect/system/reagents_explosion/e = new()
	e.set_up(round (created_volume/2, 1), holder.my_atom, 0, 0)
	e.holder_damage(holder.my_atom)
	if(isliving(holder.my_atom))
		e.amount *= 0.5
		var/mob/living/L = holder.my_atom
		if(L.stat!=DEAD)
			e.amount *= 0.5
	e.start()
	holder.clear_reagents()

/datum/chemical_reaction/trinitrine
	name = "Trinitrine"
	id = TRINITRINE
	result = TRINITRINE
	required_reagents = list(GLYCEROL = 1, SACIDS = 1, WATER = 3)
	required_catalysts = list(NITROGEN = 5)
	result_amount = 5

/datum/chemical_reaction/fuelbomb
	name = "Fuel bomb"
	id = FUELBOMB
	result = null
	required_reagents = list(FUEL = 1)
	required_temp = AUTOIGNITION_WELDERFUEL
	result_amount = 1
	var/fire_temp = AUTOIGNITION_WELDERFUEL
	var/power = 0

/datum/chemical_reaction/fuelbomb/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(holder.my_atom.is_open_container() || ismob(holder.my_atom))
		if(!is_in_airtight_object(holder.my_atom)) //Don't pop while ventcrawling.
			var/turf/location = get_turf(holder.my_atom.loc)

			for(var/turf/simulated/floor/target_tile in range(0,location))
				spawn(0)
					target_tile.hotspot_expose(fire_temp, created_volume, surfaces = 1)

		for(var/reagent in required_reagents)
			holder.del_reagent(reagent)
	else
		var/datum/effect/system/reagents_explosion/e = new()
		if(created_volume > 500)
			e.set_up(15, holder.my_atom, 0, 0, null, 1+power, 2+(power*2), 4+(power*2))
		else if(created_volume > 100)
			e.set_up(9, holder.my_atom, 0, 0, null, 0+power, 1+power, 3+power)
		else
			e.set_up(9, holder.my_atom, 0, 0, null, -1+power, 1, 2+power)
		e.holder_damage(holder.my_atom)
		if(isliving(holder.my_atom))
			e.amount *= 0.5
			var/mob/living/L = holder.my_atom
			if(L.stat!=DEAD)
				e.amount *= 0.5
		e.start()
		holder.clear_reagents()


/datum/chemical_reaction/fuelbomb/plasma
	name = "Plasma bomb"
	id = PLASMABOMB
	required_reagents = list(PLASMA = 1)
	required_temp = AUTOIGNITION_WELDERFUEL
	fire_temp = AUTOIGNITION_WELDERFUEL
	power = 1

/datum/chemical_reaction/fuelbomb/anfo
	name = "AN/FO bomb"
	id = ANFOBOMB
	required_reagents = list(AMMONIUMNITRATE = 16, FUEL = 1)  // rough approximation of the 94%-6% mix
	required_temp = AUTOIGNITION_WELDERFUEL-1 // just for priority and to stop recipe conflicts
	result_amount = 17
	fire_temp = AUTOIGNITION_WELDERFUEL
	power = 1

/datum/chemical_reaction/sodiumchloride
	name = "Sodium Chloride"
	id = SODIUMCHLORIDE
	result = SODIUMCHLORIDE
	required_reagents = list(SODIUM = 1, CHLORINE = 1)
	result_amount = 2

/datum/chemical_reaction/holysalts
	name = "Holy Salts"
	id = HOLYSALTS
	result = HOLYSALTS
	required_reagents = list(SODIUMCHLORIDE = 1)
	required_catalysts = list(HOLYWATER = 5)
	result_amount = 1

/datum/chemical_reaction/occult_blood_test
	name = "Occult Blood Test"
	id = "occult_blood_test"
	required_reagents = list(HOLYSALTS = 5)
	required_catalysts = list(BLOOD = 5)
	result = SODIUMCHLORIDE
	result_amount = 5
	quiet = TRUE

/datum/chemical_reaction/occult_blood_test/on_reaction(var/datum/reagents/holder, var/created_volume)
	for(var/datum/reagent/blood/B in holder.reagent_list)
		var/turf/T = get_turf(holder.my_atom)
		if ("occult" in B.data)
			var/datum/mind/M = B.data["occult"]
			if (M && M.current && iscultist(M.current) && !M.current.isDead()) // checking that the source cultist is alive and still a cultist
				T.visible_message("<span class='notice'>[bicon(holder.my_atom)] The salts violently react with the blood and flames lick the air above the [holder.my_atom].</span>")
				var/red_flames = 0
				var/orange_flames = 0
				var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
				for (var/datum/role/R in cult.members)
					var/mob/L = R.antag.current
					if (isliving(L) && !L.isDead())
						var/turf/U = get_turf(L)
						if ((T.z == U.z) && !isshade(L))
							red_flames++//human or construct on the current Z level
						else
							orange_flames++//either a shade or on another Z level
				if (red_flames)
					T.visible_message("<span class='notice'>You count <font color='red'><b>[(red_flames > 1) ? "[red_flames] distinct" : "a single"]</b></font> bright red flame[(red_flames > 1) ? "s":""].</span>")
				if (orange_flames)
					T.visible_message("<span class='notice'>[red_flames ? "As well as" : "You count"] <font color='orange'><b>[(orange_flames > 1) ? "[orange_flames] distinct" : "a single"]</b></font> dim orange flame[(orange_flames > 1) ? "s":""].</span>")
				playsound(T, 'sound/effects/bubbles.ogg', 80, 1)
				T.hotspot_expose(500 * red_flames + 100 * orange_flames, 10)
				holder.remove_reagent(BLOOD, 5)
				return

		T.visible_message("<span class='notice'>[bicon(holder.my_atom)] The salts dissolve into the blood without so much as a reaction.</span>")
		return

/datum/chemical_reaction/ethylcyanoacrylate
	name = "Ethyl Cyanoacrylate"
	id = ETHYLCYANOACRYLATE
	result = ETHYLCYANOACRYLATE
	required_reagents = list(ETHANOL = 1, NITROGEN = 1, CARBON = 1)
	result_amount = 1

/datum/chemical_reaction/glue
	name = "Glue"
	id = GLUE
	result = GLUE
	required_reagents = list(ETHYLCYANOACRYLATE = 1, SILICON = 1)
	result_amount = 1

/datum/chemical_reaction/flash_powder
	name = "Flash powder"
	id = "flash_powder"
	result = null
	required_reagents = list(ALUMINUM = 1, POTASSIUM = 1, SULFUR = 1)
	result_amount = 1

/datum/chemical_reaction/flash_powder/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(!is_in_airtight_object(holder.my_atom)) //Don't pop while ventcrawling.
		var/location = get_turf(holder.my_atom)
		spark(location, 2)
		if(created_volume >= 20)
			holder.my_atom.flashbangprime(FALSE)
		else
			playsound(src, 'sound/effects/phasein.ogg', 25, 1)

			for(var/mob/living/M in viewers(get_turf(holder.my_atom), null))
				if(M.blinded)
					continue
				var/eye_safety = 0
				if(iscarbon(M))
					eye_safety = M.eyecheck()

				if(get_dist(M, location) <= 3)
					if(eye_safety < 1)
						M.flash_eyes(visual = 1)
						M.Knockdown(15)
						M.Stun(15)
				else if(get_dist(M, location) <= 5)
					if(eye_safety < 1)
						M.flash_eyes(visual = 1)
						M.Stun(5)

/datum/chemical_reaction/napalm
	name = "Napalm"
	id = "napalm"
	result = null
	required_reagents = list(ALUMINUM = 1, PLASMA = 1, SACIDS = 1 )
	result_amount = 1

/datum/chemical_reaction/napalm/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(!is_in_airtight_object(holder.my_atom)) //Don't pop while ventcrawling.
		var/turf/location = get_turf(holder.my_atom.loc)

		for(var/turf/simulated/floor/target_tile in range(0,location))
			var/datum/gas_mixture/napalm = new()
			napalm.adjust_gas(GAS_VOLATILE, created_volume, FALSE)
			napalm.temperature = 400+T0C
			napalm.update_values()
			target_tile.assume_air(napalm)
			spawn(0)
				target_tile.hotspot_expose(700, 400, surfaces = 1)

	holder.del_reagent("napalm")

/datum/chemical_reaction/chemsmoke
	name = "Chemsmoke"
	id = "chemsmoke"
	result = null
	required_reagents = list(POTASSIUM = 1, SUGARS = 1, PHOSPHORUS = 1)
	result_amount = null
	secondary = 1
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/chemsmoke/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(!is_in_airtight_object(holder.my_atom)) //Don't pop while ventcrawling.
		var/location = get_turf(holder.my_atom)
		var/datum/effect/system/smoke_spread/chem/S = new /datum/effect/system/smoke_spread/chem
		S.attach(location)
		S.set_up(holder, 10, 0, location)
		playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
		spawn(0)
			S.start()
			sleep(10)
			S.start()
	holder.clear_reagents()

/datum/chemical_reaction/chemsmoke/bleach
	name = "Bleach Fumes"
	id = "bleachfumes"
	result = CHLORAMINE
	required_reagents = list(BLEACH = 1, AMMONIA = 1)
	result_amount = 2

/datum/chemical_reaction/chemsmoke/bleach/on_reaction(var/datum/reagents/holder, var/created_volume) //I hate to copypasta this to change one argument but it appears I have little choice
	holder.isolate_reagent(CHLORAMINE)
	if(!is_in_airtight_object(holder.my_atom)) //Don't pop while ventcrawling.
		var/location = get_turf(holder.my_atom)
		var/datum/effect/system/smoke_spread/chem/S = new /datum/effect/system/smoke_spread/chem
		S.attach(location)
		S.set_up(holder, 5, 0, location)
		playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
		spawn(0)
			S.start()
			sleep(10)
			S.start()
	holder.clear_reagents()

/datum/chemical_reaction/chloralhydrate
	name = "Chloral Hydrate"
	id = CHLORALHYDRATE
	result = CHLORALHYDRATE
	required_reagents = list(ETHANOL = 1, CHLORINE = 3, WATER = 1)
	result_amount = 1

/datum/chemical_reaction/suxameth
	name = "Suxameth"
	id = SUX
	result = SUX
	required_reagents = list(TOXINS = 1, CHLORINE = 1)
	result_amount = 2

/datum/chemical_reaction/zombiepowder
	name = "Zombie Powder"
	id = ZOMBIEPOWDER
	result = ZOMBIEPOWDER
	required_reagents = list(CARPOTOXIN = 5, STOXINS = 5, COPPER = 5)
	result_amount = 2

/datum/chemical_reaction/rezadone
	name = "Rezadone"
	id = REZADONE
	result = REZADONE
	required_reagents = list(CARPOTOXIN = 1, CRYPTOBIOLINS = 1, COPPER = 1)
	result_amount = 3

/datum/chemical_reaction/mindbreaker
	name = "Mindbreaker Toxin"
	id = MINDBREAKER
	result = MINDBREAKER
	required_reagents = list(SILICON = 1, HYDROGEN = 1, ANTI_TOXINS = 1)
	result_amount = 5

/datum/chemical_reaction/heartbreaker
	name = "Heartbreaker Toxin"
	id = HEARTBREAKER
	result = HEARTBREAKER
	required_reagents = list(MINDBREAKER = 1, DEXALINS = 1)
	required_temp = T0C + 37
	result_amount = 5

/datum/chemical_reaction/lipozine
	name = "Lipozine"
	id = LIPOZINE
	result = LIPOZINE
	required_reagents = list(SODIUMCHLORIDE = 1, ETHANOL = 1, RADIUM = 1)
	result_amount = 3

/datum/chemical_reaction/dietine
	name = "Dietine"
	id = DIETINE
	result = DIETINE
	required_reagents = list(SODIUMCHLORIDE = 1, COFFEE = 3, LITHIUM = 1, FUEL = 1)
	result_amount = 1

/datum/chemical_reaction/gatormix
	name = "Gator Mix"
	id = GATORMIX
	result = GATORMIX
	required_reagents = list(NUTRIMENT = 1, COFFEE = 1, COLA = 1, EGG_YOLK = 1, FUEL = 1)
	result_amount = 5

/datum/chemical_reaction/carp_pheromones
	name = "Carp Pheromones"
	id = CARPPHEROMONES
	result = CARPPHEROMONES
	required_reagents = list(CARPOTOXIN = 1, LEPORAZINE = 1, CARBON = 1)
	result_amount = 3

/datum/chemical_reaction/vaporize
	name = "Vaporize"
	id = "vaporize"
	result_amount = 104
	result = null

/datum/chemical_reaction/vaporize/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/turf/T = get_turf(holder.my_atom)
	if(!T)
		return
	var/datum/gas_mixture/G = new
	G.temperature = T20C
	disperse(T,G,created_volume)

/datum/chemical_reaction/vaporize/proc/disperse(turf/T,datum/gas_mixture/G,var/vol)
	T.assume_air(G)

/datum/chemical_reaction/vaporize/oxygen
	name = "Vaporize Oxygen"
	id = "vaporizeoxygen"
	required_reagents = list(VAPORSALT = 1, OXYGEN = 1)

/datum/chemical_reaction/vaporize/oxygen/disperse(turf/T,datum/gas_mixture/G,var/vol)
	G.adjust_gas(GAS_OXYGEN, vol)
	..()

/datum/chemical_reaction/vaporize/nitrogen
	name = "Vaporize Nitrogen"
	id = "vaporizenitrogen"
	required_reagents = list(VAPORSALT = 1, NITROGEN = 1)

/datum/chemical_reaction/vaporize/nitrogen/disperse(turf/T,datum/gas_mixture/G,var/vol)
	G.adjust_gas(GAS_NITROGEN, vol)
	..()

/datum/chemical_reaction/vaporize/plasma
	name = "Vaporize Plasma"
	id = "vaporizeplasma"
	result_amount = 10 //Let's not go overboard with the plasma, alright?
	required_reagents = list(VAPORSALT = 1, PLASMA = 1)

/datum/chemical_reaction/vaporize/plasma/disperse(turf/T,datum/gas_mixture/G,var/vol)
	G.adjust_gas(GAS_PLASMA, vol)
	..()

/datum/chemical_reaction/solidification
	name = "Solid Metal"
	id = "metalsolid"
	result = null
	required_reagents = list(SILICATE = 10, FROSTOIL = 10, IRON = 20)
	result_amount = 1 //amount of sheets created per the above reagents ^

/datum/chemical_reaction/solidification/proc/product_to_spawn()
	return /obj/item/stack/sheet/metal

/datum/chemical_reaction/solidification/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	var/to_spawn = product_to_spawn()
	new to_spawn(location, created_volume)

/datum/chemical_reaction/solidification/plasma
	name = "Solid Plasma"
	id = "solidplasma"
	result = null
	required_reagents = list(SILICATE = 10, FROSTOIL = 10, PLASMA = 20)
	result_amount = 1

/datum/chemical_reaction/solidification/plasma/product_to_spawn()
	return /obj/item/stack/sheet/mineral/plasma

/datum/chemical_reaction/solidification/silver
	name = "Solid Silver"
	id = "solidsilver"
	result = null
	required_reagents = list(SILICATE = 10, FROSTOIL = 10, SILVER = 20)
	result_amount = 1

/datum/chemical_reaction/solidification/silver/product_to_spawn()
	return /obj/item/stack/sheet/mineral/silver

/datum/chemical_reaction/solidification/gold
	name = "Solid Gold"
	id = "solidgold"
	result = null
	required_reagents = list(SILICATE = 10, FROSTOIL = 10, GOLD = 20)
	result_amount = 1

/datum/chemical_reaction/solidification/gold/product_to_spawn()
	return /obj/item/stack/sheet/mineral/gold

/datum/chemical_reaction/solidification/uranium
	name = "Solid Uranium"
	id = "soliduranium"
	result = null
	required_reagents = list(SILICATE = 10, FROSTOIL = 10, URANIUM = 20)
	result_amount = 1

/datum/chemical_reaction/solidification/uranium/product_to_spawn()
	return /obj/item/stack/sheet/mineral/uranium

/datum/chemical_reaction/solidification/diamond
	name = "Solid Diamond"
	id = "soliddiamond"
	result = null
	required_reagents = list(SILICATE = 10, FROSTOIL = 10, DIAMONDDUST = 20)
	result_amount = 1

/datum/chemical_reaction/solidification/diamond/product_to_spawn()
	return /obj/item/stack/sheet/mineral/diamond

/datum/chemical_reaction/solidification/clown
	name = "Solid Bananium"
	id = "solidbananium"
	result = null
	required_reagents = list(SILICATE = 10, FROSTOIL = 10, BANANA = 20)
	required_catalysts = list(PHAZON = 1)
	result_amount = 1

/datum/chemical_reaction/solidification/clown/product_to_spawn()
	return /obj/item/stack/sheet/mineral/clown

/datum/chemical_reaction/solidification/phazon
	name = "Solid Phazon"
	id = "solidphazon"
	result = null
	required_reagents = list(SILICATE = 10, FROSTOIL = 10, PHAZON = 1)
	required_catalysts = list(MUTAGEN = 5)
	result_amount = 1

/datum/chemical_reaction/solidification/phazon/product_to_spawn()
	return /obj/item/stack/sheet/mineral/phazon

/datum/chemical_reaction/solidification/glass
	name = "Solid Glass"
	id = "solidglass"
	result = null
	required_reagents = list(SILICATE = 20, CAPSAICIN = 10) //You melt the silicate to make glass
	result_amount = 1 //amount of sheets created per the above reagents

/datum/chemical_reaction/solidification/glass/product_to_spawn()
	return /obj/item/stack/sheet/glass/glass

/datum/chemical_reaction/solidification/plasmaglass
	name = "Solid Plasma Glass"
	id = "solidplasmaglass"
	result = null
	required_reagents = list(SILICATE = 20, CONDENSEDCAPSAICIN = 10, PLASMA = 20) //You need even stronger heat to make plasmaglass
	result_amount = 1 //amount of sheets created per the above reagents

/datum/chemical_reaction/solidification/plasmaglass/product_to_spawn()
	return /obj/item/stack/sheet/glass/plasmaglass

/datum/chemical_reaction/solidification/plasteel
	name = "Solid Plasteel"
	id = "solidplasteel"
	result = null
	required_reagents = list(SODIUMSILICATE = 5, FROSTOIL = 5, PLASMA = 10, IRON = 10)
	result_amount = 1

/datum/chemical_reaction/solidification/plasteel/product_to_spawn()
	return /obj/item/stack/sheet/plasteel

/datum/chemical_reaction/solidification/plastic
	name = "Plastic"
	id = "solidplastic"
	result = null
	required_reagents = list(PLASTICIDE = 20, PACIDS = 10)
	result_amount = 10

/datum/chemical_reaction/solidification/plastic/product_to_spawn()
	return /obj/item/stack/sheet/mineral/plastic

/datum/chemical_reaction/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = CONDENSEDCAPSAICIN
	result = CONDENSEDCAPSAICIN
	required_reagents = list(CAPSAICIN = 1, ETHANOL = 5)
	result_amount = 5

/datum/chemical_reaction/methylin
	name = "Methylin"
	id = METHYLIN
	result = METHYLIN
	required_reagents = list(HYDROGEN = 1, CHLORINE = 1, ETHANOL = 1)
	required_catalysts = list(FLUORINE = 5)
	result_amount = 1

/datum/chemical_reaction/mannitol
	name = "Mannitol"
	id = MANNITOL
	result = MANNITOL
	required_reagents = list(DISCOUNT = 1, ICE = 1, BEFF = 1)
	result_amount = 2

/datum/chemical_reaction/piccolyn
	name = "Piccolyn"
	id = PICCOLYN
	result = PICCOLYN
	required_reagents = list(COPPER = 1, TUNGSTEN = 1, FLUORINE = 1)
	result_amount = 1

/datum/chemical_reaction/explosion_bicarodyne
	name = "Explosion"
	id = "explosion_bicarodyne"
	result = null
	required_reagents = list(BICARODYNE = 1, PARACETAMOL = 1)
	result_amount = 1

/datum/chemical_reaction/explosion_bicarodyne/on_reaction(var/datum/reagents/holder, var/created_volume)
	explosion(get_turf(holder.my_atom),1,2,4)
	if(!holder.my_atom.is_open_container() || ismob(holder.my_atom))
		holder.del_reagent(BICARODYNE)
		holder.del_reagent(PARACETAMOL)
	else
		holder.clear_reagents()

/datum/chemical_reaction/more_bicarodyne
	name = "Bicarodyne"
	id = BICARODYNE
	result = BICARODYNE
	required_reagents = list(BICARIDINES = 1)
	required_catalysts = list(BICARODYNE = 1)
	result_amount = 1

/datum/chemical_reaction/more_hypozine
	name = "Hypozine"
	id = HYPOZINE
	result = HYPOZINE
	required_reagents = list(HYPERZINES = 1)
	required_catalysts = list(HYPOZINE = 1)
	result_amount = 1

/datum/chemical_reaction/nanobots
	name = "Nanobots"
	id = NANOBOTS
	result = NANOBOTS
	required_reagents = list(ALLNANITES = 1, URANIUM = 10, GOLD = 10, NUTRIMENT = 10, SILICON = 10)
	result_amount = 2

/datum/chemical_reaction/nanobots2
	name = "Nanobots2"
	id = "nanobots2"
	result = NANOBOTS
	required_reagents = list(MEDNANOBOTS = 2.5, CRYOXADONE = 2) //2.5 here since otherwise you could just dupe again with this return recipe.
	result_amount = 1

/datum/chemical_reaction/mednanobots
	name = "Medical Nanobots"
	id = MEDNANOBOTS
	result = MEDNANOBOTS
	required_reagents = list(NANOBOTS = 1, DOCTORSDELIGHT = 5)
	result_amount = 2.5

/datum/chemical_reaction/comnanobots
	name = "Combat Nanobots"
	id = COMNANOBOTS
	result = COMNANOBOTS
	required_reagents = list(NANOBOTS = 1, MUTAGEN = 5, SILICATE = 5, IRON = 10)
	result_amount = 2.5

//Surgery tools from chemicals because why not? Requires a vial to make them and consumes it as a part of making the tool.
//DO NOT COPY PASTE THESE WITHOUT SOME KIND OF CONTAINER/HOLDER CHECK BECAUSE qdel WILL DELETE ANY REAGENT CONTAINER WITHOUT IT. IE PLAYERS
/datum/chemical_reaction/fixoveinmake
	name = "FixOVein"
	id = "fixovein"
	result = null
	required_reagents = list(BICARIDINES = 10, CLONEXADONE = 10)
	result_amount = 1
	required_container = /obj/item/weapon/reagent_containers/glass/beaker/vial //safety net and a case for the "crafting" of the tool

/datum/chemical_reaction/fixoveinmake/on_reaction(var/datum/reagents/holder)
	var/location = get_turf(holder.my_atom)
	new /obj/item/tool/FixOVein(location)
	qdel(holder.my_atom)

/datum/chemical_reaction/bonegelmake
	name = "Bone Gel"
	id = "bonegel"
	result = null
	required_reagents = list(MILK = 10, CRYOXADONE = 10) //milk is good for the bones
	result_amount = 1
	required_container = /obj/item/weapon/reagent_containers/glass/beaker/vial

/datum/chemical_reaction/bonegelmake/on_reaction(var/datum/reagents/holder)
	var/location = get_turf(holder.my_atom)
	new /obj/item/tool/bonegel(location)
	qdel(holder.my_atom)

///////////////////////////////////////////////////////////////////////////////////

//Foam and foam precursor

/datum/chemical_reaction/surfactant
	name = "Foam surfactant"
	id = FLUOROSURFACTANT
	result = FLUOROSURFACTANT
	required_reagents = list(FLUORINE = 2, CARBON = 2, SACIDS = 1)
	result_amount = 5


/datum/chemical_reaction/foam
	name = "Foam"
	id = "foam"
	result = null
	required_reagents = list(FLUOROSURFACTANT = 1, WATER = 1)
	result_amount = 2

/datum/chemical_reaction/foam/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(!is_in_airtight_object(holder.my_atom)) //Don't pop while ventcrawling.
		var/location = get_turf(holder.my_atom)
		for(var/mob/M in viewers(5, location))
			to_chat(M, "<span class='warning'>The solution violently bubbles!</span>")

		location = get_turf(holder.my_atom)

		for(var/mob/M in viewers(5, location))
			to_chat(M, "<span class='warning'>The solution spews out foam!</span>")

		var/datum/effect/system/foam_spread/s = new()
		s.set_up(created_volume, location, holder, 0)
		s.start()
	holder.clear_reagents()

/datum/chemical_reaction/metalfoam
	name = "Metal Foam"
	id = "metalfoam"
	result = null
	required_reagents = list(ALUMINUM = 3, FOAMING_AGENT = 1, PACIDS = 1)
	result_amount = 5

/datum/chemical_reaction/metalfoam/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(!is_in_airtight_object(holder.my_atom)) //Don't pop while ventcrawling.
		var/location = get_turf(holder.my_atom)

		for(var/mob/M in viewers(5, location))
			to_chat(M, "<span class='warning'>The solution spews out a metallic foam!</span>")

		var/datum/effect/system/foam_spread/s = new()
		s.set_up(created_volume, location, holder, 1)
		s.start()

/datum/chemical_reaction/ironfoam
	name = "Iron Foam"
	id = "ironlfoam"
	result = null
	required_reagents = list(IRON = 3, FOAMING_AGENT = 1, PACIDS = 1)
	result_amount = 5

/datum/chemical_reaction/ironfoam/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(!is_in_airtight_object(holder.my_atom)) //Don't pop while ventcrawling.
		var/location = get_turf(holder.my_atom)

		for(var/mob/M in viewers(5, location))
			to_chat(M, "<span class='warning'>The solution spews out a metallic foam!</span>")

		var/datum/effect/system/foam_spread/s = new()
		s.set_up(created_volume, location, holder, 2)
		s.start()

/datum/chemical_reaction/foaming_agent
	name = "Foaming Agent"
	id = FOAMING_AGENT
	result = FOAMING_AGENT
	required_reagents = list(LITHIUM = 1, HYDROGEN = 1)
	result_amount = 1

//Synthesizing these three(+) chemicals is pretty complex in real life, but fuck it, it's just a game!
/datum/chemical_reaction/ammonia
	name = "Ammonia"
	id = AMMONIA
	result = AMMONIA
	required_reagents = list(HYDROGEN = 3, NITROGEN = 1)
	result_amount = 3

/datum/chemical_reaction/ammoniumnitrate
	name = "Ammonium Nitrate"
	id = AMMONIUMNITRATE
	result = AMMONIUMNITRATE
	required_reagents = list(AMMONIA = 5, CLEANER = 3, NITROGEN = 2, OXYGEN = 5)
	result_amount = 18

/datum/chemical_reaction/diethylamine
	name = "Diethylamine"
	id = DIETHYLAMINE
	result = DIETHYLAMINE
	required_reagents = list (AMMONIA = 1, ETHANOL = 1)
	result_amount = 2

/datum/chemical_reaction/space_cleaner
	name = "Space Cleaner"
	id = CLEANER
	result = CLEANER
	required_reagents = list(AMMONIA = 1, WATER = 1)
	result_amount = 2

/datum/chemical_reaction/bleach
	name = "Bleach"
	id = BLEACH
	result = BLEACH
	required_reagents = list(SODIUMCHLORIDE = 2, CLEANER = 2, OXYGEN = 1)
	result_amount = 2

/datum/chemical_reaction/acetone
	name = "Acetone"
	id = ACETONE
	result = ACETONE
	required_reagents = list(CARBON = 1, WATER = 1, HYDROGEN = 1)
	result_amount = 2

//This one isn't even close the the real life reaction but will have to do to avoid conflicts with the above reactions.
/datum/chemical_reaction/luminol
	name = "Luminol"
	id = LUMINOL
	result = LUMINOL
	required_reagents = list(CLEANER = 3, CARBON = 8)
	result_amount = 10
	//"Realistic" results.
	//result_amount = 3
	//secondary_results = list(WATER = 1, HYDROGEN = 6)

//Botany chemicals

/datum/chemical_reaction/eznutrient
	name = "E-Z-Nutrient"
	id = EZNUTRIENT
	result = EZNUTRIENT
	required_reagents = list(NITROGEN = 1, PHOSPHORUS = 1, POTASSIUM = 1)
	result_amount = 3

/datum/chemical_reaction/robustharvest
	name = "Robust Harvest"
	id = ROBUSTHARVEST
	result = ROBUSTHARVEST
	required_reagents = list(EZNUTRIENT = 1)
	required_catalysts = list(FORMIC_ACID = 1)
	result_amount = 1

/datum/chemical_reaction/left4zed
	name = "Left 4 Zed"
	id = LEFT4ZED
	result = LEFT4ZED
	required_reagents = list(EZNUTRIENT = 1)
	required_catalysts = list(RADIUM = 5)
	result_amount = 1

/datum/chemical_reaction/plantbgone
	name = "Plant-B-Gone"
	id = PLANTBGONE
	result = PLANTBGONE
	required_reagents = list(TOXINS = 1, WATER = 4)
	result_amount = 5

/datum/chemical_reaction/insecticide
	name = "Insecticide"
	id = INSECTICIDE
	result = INSECTICIDE
	required_reagents = list(TOXINS = 1, SALTWATER = 4)
	result_amount = 5

// Special Reactions for Plasma Beaker
/datum/chemical_reaction/plasmabeakerdexalin
	name = "Plasma Beaker Dexalin"
	id = DEXALIN
	result = DEXALIN
	required_reagents = list(OXYGEN = 2)
	result_amount = 1
	required_container = /obj/item/weapon/reagent_containers/glass/beaker/large/plasma

/datum/chemical_reaction/plasmabeakerleporazine
	name = "Leporazine"
	id = LEPORAZINE
	result = LEPORAZINE
	required_reagents = list(SILICON = 1, COPPER = 1)
	result_amount = 2
	required_container = /obj/item/weapon/reagent_containers/glass/beaker/large/plasma

/datum/chemical_reaction/plasmabeakerclonexadone
	name = "Clonexadone"
	id = CLONEXADONE
	result = CLONEXADONE
	required_reagents = list(CRYOXADONE = 1, SODIUM = 1)
	result_amount = 2
	required_container = /obj/item/weapon/reagent_containers/glass/beaker/large/plasma

//Special reaction for mimic meat: injecting it with 5 units of blood causes it to turn into a random food item. Makes more sense than hitting it with a fking rolling pin
/datum/chemical_reaction/mimicshift
	name = "Shapeshift"
	id = "mimic_meat_shift"
	result = null
	required_reagents = list(BLOOD = 5)
	result_amount = 1
	required_container = /obj/item/weapon/reagent_containers/food/snacks/meat/mimic

/datum/chemical_reaction/mimicshift/on_reaction(var/datum/reagents/holder)
	if(istype(holder.my_atom, /obj/item/weapon/reagent_containers/food/snacks/meat/mimic))
		var/obj/item/weapon/reagent_containers/food/snacks/meat/mimic/M = holder.my_atom
		M.shapeshift()

		if(ismob(holder.my_atom.loc))
			var/mob/mob_holder = holder.my_atom.loc
			mob_holder.drop_item(holder.my_atom) //Bandaid to work around items becoming invisible when their appearance is changed!

/////////////////////////////////////////////NEW SLIME CORE REACTIONS/////////////////////////////////////////////

//the slime_extract chem reaction parent, that will only be called when the container type is a slime extract
//Automatically deletes the extract when used up
/datum/chemical_reaction/slime_extract
	result = null
	result_amount = 1
	var/reagent //If toggled on, will make a container appear on use that contains the reagent
	var/reagent_amount
	var/container_type = /obj/item/weapon/reagent_containers/glass/bottle //The type of container, default is a bottle

/datum/chemical_reaction/slime_extract/required_condition_check(datum/reagents/holder)
	if(istype(holder.my_atom, /obj/item/slime_extract))
		var/obj/item/slime_extract/S = holder.my_atom
		if(S.Uses > 0)
			return 1
	return 0

/datum/chemical_reaction/slime_extract/on_reaction(datum/reagents/holder, created_volume)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	if(reagent && reagent_amount && container_type)
		var/obj/item/weapon/reagent_containers/B = new container_type
		B.reagents.add_reagent(reagent, reagent_amount)
		B.forceMove(get_turf(holder.my_atom))
	if(istype(holder.my_atom, /obj/item/slime_extract))
		var/obj/item/slime_extract/S = holder.my_atom
		S.Uses--
		S.update_icon()
		if(S.Uses <= 0)
			if(!istype(S.loc, /obj/item/weapon/grenade/chem_grenade) && !quiet)
				S.visible_message("<span class='notice'>[bicon(holder.my_atom)] \The [holder.my_atom]'s power is consumed in the reaction.</span>")
			qdel(S)

//Grey
/datum/chemical_reaction/slime_extract/slimespawn
	name = "Slime Spawn"
	id = "m_spawn"
	required_reagents = list(PLASMA = 5)
	required_container = /obj/item/slime_extract/grey
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slime_extract/slimespawn/on_reaction(var/datum/reagents/holder)
	if(!is_in_airtight_object(holder.my_atom)) //Don't pop while ventcrawling.
		if(istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
			holder.my_atom.visible_message("<span class='rose'>The grenade bursts open and a new baby slime emerges from it!</span>")
		else
			holder.my_atom.visible_message("<span class='rose'>Infused with plasma, the core begins to quiver and grow, and soon a new baby slime emerges from it!</span>")
		var/mob/living/carbon/slime/S = new /mob/living/carbon/slime
		S.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime_extract/slimemonkey
	name = "Slime Monkey"
	id = "m_monkey"
	required_reagents = list(BLOOD = 5)
	required_container = /obj/item/slime_extract/grey

/datum/chemical_reaction/slime_extract/slimemonkey/on_reaction(var/datum/reagents/holder)
	for(var/i = 1, i <= 3, i++)
		var /obj/item/weapon/reagent_containers/food/snacks/monkeycube/M = new /obj/item/weapon/reagent_containers/food/snacks/monkeycube
		M.forceMove(get_turf(holder.my_atom))
	..()

//Green
/datum/chemical_reaction/slime_extract/slimemutate
	name = "Mutation Toxin"
	id = MUTATIONTOXIN
	required_reagents = list(PLASMA = 5)
	required_container = /obj/item/slime_extract/green
	reagent = MUTATIONTOXIN
	reagent_amount = 1

/datum/chemical_reaction/slime_extract/slimetile
	name = "Slime tiles"
	id = "slimetile"
	required_reagents = list(IRON = 5)
	required_container = /obj/item/slime_extract/green

/datum/chemical_reaction/slime_extract/slimetile/on_reaction(var/datum/reagents/holder)
	var/obj/item/stack/tile/slime/T = new /obj/item/stack/tile/slime
	T.amount = 20
	T.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime_extract/slimeheart
	name = "slime heart"
	id = "R_heart"
	required_reagents = list(BLOOD = 5)
	required_container = /obj/item/slime_extract/green

/datum/chemical_reaction/slime_extract/slimeheart/on_reaction(var/datum/reagents/holder)
	var/obj/item/slime_heart/S = new /obj/item/slime_heart
	S.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime_extract/slimecoat
	name = "slime coat"
	id = "R_coat"
	required_reagents = list(WATER = 5)
	required_container = /obj/item/slime_extract/green

/datum/chemical_reaction/slime_extract/slimecoat/on_reaction(var/datum/reagents/holder)
	var/obj/item/clothing/suit/storage/wintercoat/slimecoat/C = new /obj/item/clothing/suit/storage/wintercoat/slimecoat
	C.forceMove(get_turf(holder.my_atom))
	..()

//Metal
/datum/chemical_reaction/slime_extract/slimemetal
	name = "Slime Metal"
	id = "m_metal"
	required_reagents = list(PLASMA = 5)
	required_container = /obj/item/slime_extract/metal

/datum/chemical_reaction/slime_extract/slimemetal/on_reaction(var/datum/reagents/holder)
	var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal(get_turf(holder.my_atom))
	M.amount = 15
	var/obj/item/stack/sheet/plasteel/P = new /obj/item/stack/sheet/plasteel
	P.amount = 5
	P.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime_extract/slimegold
	name = "Slime Gold"
	id = "m_gold"
	required_reagents = list(COPPER = 5)
	required_container = /obj/item/slime_extract/metal

/datum/chemical_reaction/slime_extract/slimegold/on_reaction(var/datum/reagents/holder)
	var/obj/item/stack/sheet/mineral/gold/G = new /obj/item/stack/sheet/mineral/gold
	G.amount = 5
	G.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime_extract/slimesilver
	name = "Slime Silver"
	id = "m_silver"
	required_reagents = list(TUNGSTEN = 5)
	required_container = /obj/item/slime_extract/metal

/datum/chemical_reaction/slime_extract/slimesilver/on_reaction(var/datum/reagents/holder)
	var/obj/item/stack/sheet/mineral/silver/S = new /obj/item/stack/sheet/mineral/silver
	S.amount = 5
	S.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime_extract/slimeuranium
	name = "Slime Uranium"
	id = "m_uranium"
	required_reagents = list(RADIUM = 5)
	required_container = /obj/item/slime_extract/metal

/datum/chemical_reaction/slime_extract/slimeuranium/on_reaction(var/datum/reagents/holder)
	var/obj/item/stack/sheet/mineral/uranium/U = new /obj/item/stack/sheet/mineral/uranium
	U.amount = 5
	U.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime_extract/slimediamond
	name = "Slime diamond"
	id = "m_diamond"
	required_reagents = list(CARBON = 5)
	required_container = /obj/item/slime_extract/metal

/datum/chemical_reaction/slime_extract/slimediamond/on_reaction(var/datum/reagents/holder)
	var/obj/item/stack/sheet/mineral/diamond/K = new /obj/item/stack/sheet/mineral/diamond
	K.amount = 2
	K.forceMove(get_turf(holder.my_atom))
	..()

//Gold
/datum/chemical_reaction/slime_extract/slimecrit
	name = "Slime Crit (Summon Monsters)"
	id = "m_tele"
	required_reagents = list(PLASMA = 5)
	required_container = /obj/item/slime_extract/gold
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slime_extract/slimecrit/on_reaction(var/datum/reagents/holder)
	if(!istype(holder.my_atom.loc, /obj/item/weapon/grenade/chem_grenade))
		holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently!</span>")
		sleep(50)

	var/list/blocked = existing_typesof(
		/mob/living/simple_animal/hostile/faithless/cult,
		/mob/living/simple_animal/hostile/scarybat/cult,
		/mob/living/simple_animal/hostile/creature/cult,
		/mob/living/simple_animal/hostile/retaliate/clown,
		/mob/living/simple_animal/hostile/mushroom,
		/mob/living/simple_animal/hostile/slime,
		/mob/living/simple_animal/hostile/mimic,
		) + boss_mobs + blacklisted_mobs//Exclusion list for things you don't want the reaction to create.

	var/list/critters = existing_typesof(/mob/living/simple_animal/hostile) - existing_typesof_list(blocked) //List of possible hostile mobs

	playsound(holder.my_atom, 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		if(O.is_blind())
			if(O.is_deaf())
				to_chat(O, "<span class='danger'>You feel a strange rumbling!</span>")
			else
				to_chat(O, "<span class='danger'>You hear a rumbling and terrifying noises!</span>")
		else if(ishuman(O))
			var/mob/living/carbon/human/H = O
			if((H.eyecheck() <= 0) && (!istype(H.glasses, /obj/item/clothing/glasses/scanner/science)))
				H.flash_eyes(visual = 1)
				to_chat(O, "<span class='danger'>A flash blinds you[O.is_deaf() ? "" : " while you start hearing terrifying noises"]!</span>")
			else
				to_chat(O, "<span class='danger'>[O.is_deaf() ? "A" : "You hear a rumbling as a"] troup of monsters phases into existence!</span>")
		else
			to_chat(O, "<span class='danger'>[O.is_deaf() ? "A" : "You hear a rumbling as a"] troup of monsters phases into existence!</span>")

	for(var/i = 1, i <= 5, i++)
		var/chosen = pick(critters)
		var/mob/living/simple_animal/hostile/C = new chosen(get_turf(holder.my_atom))
		C.faction = "slimesummon"
		if(prob(50))
			for(var/j = 1, j <= rand(1, 3), j++)
				step(C, pick(NORTH,SOUTH,EAST,WEST))
	..()

/datum/chemical_reaction/slime_extract/slimecritlesser
	name = "Slime Crit Lesser (Summon Monsters)"
	id = "m_tele3"
	required_reagents = list(BLOOD = 5)
	required_container = /obj/item/slime_extract/gold
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slime_extract/slimecritlesser/on_reaction(var/datum/reagents/holder)
	if(!istype(holder.my_atom.loc, /obj/item/weapon/grenade/chem_grenade))
		holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently !</span>")
		sleep(50)

	var/list/blocked = list(
		/mob/living/simple_animal/hostile/retaliate/clown,
		/mob/living/simple_animal/hostile/mushroom,
		/mob/living/simple_animal/hostile/faithless/cult,
		/mob/living/simple_animal/hostile/scarybat/cult,
		/mob/living/simple_animal/hostile/creature/cult,
		/mob/living/simple_animal/hostile/slime,
		) + boss_mobs + blacklisted_mobs//Exclusion list for things you don't want the reaction to create.

	var/list/critters = existing_typesof(/mob/living/simple_animal/hostile) - existing_typesof_list(blocked)//List of possible hostile mobs

	playsound(holder.my_atom, 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		if(O.is_blind())
			if(O.is_deaf())
				to_chat(O, "<span class='rose'>There's a sudden whiff of ozone in the air!</span>")
			else
				to_chat(O, "<span class='rose'>You hear an eerie crackling!</span>")
		else if(ishuman(O))
			var/mob/living/carbon/human/H = O
			if((H.eyecheck() <= 0) && (!istype(H.glasses, /obj/item/clothing/glasses/scanner/science)))
				H.flash_eyes(visual = 1)
				to_chat(O, "<span class='rose'>A flash blinds and you can feel a new presence!</span>")
			else
				to_chat(O, "<span class='rose'>[O.is_deaf() ? "A" : "You hear a crackling as a"] creature manifests before you!</span>")
		else
			to_chat(O, "<span class='rose'>[O.is_deaf() ? "A" : "You hear a crackling as a"] creature manifests before you!</span>")

	var/chosen = pick(critters)
	var/mob/living/simple_animal/hostile/C = new chosen
	C.faction = "neutral" //Uh, beepsky ignores mobs in this faction as of Redmine #147 - N3X
	C.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime_extract/slimecritweak
	name = "Slime Animation"
	id = "m_tele4"
	required_reagents = list(WATER = 5)
	required_container = /obj/item/slime_extract/gold
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slime_extract/slimecritweak/on_reaction(var/datum/reagents/holder)
	if(!istype(holder.my_atom.loc, /obj/item/weapon/grenade/chem_grenade))
		holder.my_atom.visible_message("<span class='warning'>The slime extract begins to slowly vibrate!</span>")

	var/atom/location = holder.my_atom.loc
	spawn(5 SECONDS)
		if(isturf(location))
			var/list/disguise_candidates = list()

			for(var/obj/item/I in oview(4, location))
				disguise_candidates += I

			var/atom/disguise = null

			if(disguise_candidates.len)
				disguise = pick(disguise_candidates)

			//If there are no nearby items to copy, become a completely random item!
			new/mob/living/simple_animal/hostile/mimic/crate/item(location, disguise) //Create a mimic identical to a nearby item

		else if(istype(location, /obj/item))
			new /mob/living/simple_animal/hostile/mimic/crate/item(get_turf(location), location) //Copy the item we're inside of, drop it outside the item!

		else if(ismob(location)) //Copy the mob! Owwwwwwwwwww this is going to be fun
			var/mob/M = location

			var/mimictype = /obj/item/stack/sheet/wood/bigstack
			if(ishuman(M))
				mimictype = /obj/structure/mannequin/wood
				if(isvox(M))
					mimictype = /obj/structure/mannequin/wood/vox
			else if(ismonkey(M))
				mimictype = /obj/structure/mannequin/wood/monkey
			var/mob/mimic = new /mob/living/simple_animal/hostile/mimic/crate(get_turf(location), mimictype)
			mimic.appearance = M.appearance //Because mimics copy appearances from paths, not actual existing objects.
			to_chat(M, "<span class='sinister'>You feel something thoroughly analyzing you from inside...</span>")

		else
			new /mob/living/simple_animal/hostile/mimic/crate
	..()

//Silver
/datum/chemical_reaction/slime_extract/slimebork
	name = "Slime Bork"
	id = "m_tele2"
	required_reagents = list(PLASMA = 5)
	required_container = /obj/item/slime_extract/silver

/datum/chemical_reaction/slime_extract/slimebork/on_reaction(var/datum/reagents/holder)
	var/blocked = list(
		/obj/item/weapon/reagent_containers/food/snacks,
		/obj/item/weapon/reagent_containers/food/snacks/snackbar,
		/obj/item/weapon/reagent_containers/food/snacks/grown,
		/obj/item/weapon/reagent_containers/food/snacks/deepfryholder
		)
	blocked += typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable) //Silver-slime spawned customizable food is borked

	var/list/borks = existing_typesof(/obj/item/weapon/reagent_containers/food/snacks) - blocked

	//BORK BORK BORK
	playsound(holder.my_atom, 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		if(O.is_blind())
			to_chat(O,"<span class='notice'>you think you can smell some food nearby!</span>")
		else if(ishuman(O))
			var/mob/living/carbon/human/H = O
			if((H.eyecheck() <= 0) && (!istype(H.glasses, /obj/item/clothing/glasses/scanner/science)))
				H.flash_eyes(visual = 1)
				to_chat(O, "<span class='caution'>A white light blinds you and you think you can smell some food nearby!</span>")
			else
				to_chat(O, "<span class='notice'>A bunch of snacks appears before your very eyes!</span>")
		else
			to_chat(O, "<span class='notice'>A bunch of snacks appears before your very eyes!</span>")

	for(var/i = 1, i <= 4 + rand(1,2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.forceMove(get_turf(holder.my_atom))

			if(istype(B,/obj/item/weapon/reagent_containers/food/snacks/meat/human))
				B.name = "human-meat"
			if(istype(B,/obj/item/weapon/reagent_containers/food/snacks/human))
				B.name = "human-meat burger"
			if(istype(B,/obj/item/weapon/reagent_containers/food/snacks/fortunecookie))
				var/obj/item/weapon/paper/paper = new /obj/item/weapon/paper(B)
				paper.info = pick("power to the slimes", "have a slime day", "today, you will meet a very special slime", "stay away from cold showers")
				var/obj/item/weapon/reagent_containers/food/snacks/fortunecookie/cookie = B
				cookie.trash = paper

			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH,SOUTH,EAST,WEST))
	..()

/datum/chemical_reaction/slime_extract/slimedrinks
	name = "Slime Drinks"
	id = "m_tele3"
	required_reagents = list(WATER = 5)
	required_container = /obj/item/slime_extract/silver

/datum/chemical_reaction/slime_extract/slimedrinks/on_reaction(var/datum/reagents/holder)

	var/blocked = list(
		/obj/item/weapon/reagent_containers/food/drinks,
		)
	blocked += typesof(/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable)	//Silver-slime spawned customizable food is borked
	blocked += typesof(/obj/item/weapon/reagent_containers/food/drinks/golden_cup) //Was probably never intended to spawn outside admin events

	var/list/borks = existing_typesof(/obj/item/weapon/reagent_containers/food/drinks) - blocked

	//BORK BORK BORK
	playsound(holder.my_atom, 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		if(O.is_blind())
			if(O.is_deaf())
				continue
			to_chat(O, "<span class='caution'>You think you can hear bottles rolling on the floor!</span>")
		if(ishuman(O))
			var/mob/living/carbon/human/H = O
			if((H.eyecheck() <= 0) && (!istype(H.glasses, /obj/item/clothing/glasses/scanner/science)))
				H.flash_eyes(visual = 1)
				to_chat(O, "<span class='caution'>A white light blinds you[O.is_deaf() ? "" : " and you think you can hear bottles rolling on the floor"]!</span>")
			else
				to_chat(O, "<span class='notice'>A bunch of drinks appears before you!</span>")
		else
			to_chat(O, "<span class='notice'>A bunch of drinks appears before you!</span>")

	for(var/i = 1, i <= 4 + rand(1, 2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen

		if(B)
			B.forceMove(get_turf(holder.my_atom))

			if(istype(B,/obj/item/weapon/reagent_containers/food/drinks/sillycup))
				B.reagents.add_reagent(WATER, 10)

			if(istype(B,/obj/item/weapon/reagent_containers/food/drinks/flask))
				B.reagents.add_reagent(WHISKEY, 60)

			if(istype(B,/obj/item/weapon/reagent_containers/food/drinks/shaker))
				B.reagents.add_reagent(GARGLEBLASTER, 100)

			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH,SOUTH,EAST,WEST))
	..()

/datum/chemical_reaction/slime_extract/slimematerials
	name = "Slime Materials"
	id = "m_mats"
	required_reagents = list(CARBON = 5)
	required_container = /obj/item/slime_extract/silver

/datum/chemical_reaction/slime_extract/slimematerials/on_reaction(var/datum/reagents/holder)
	var/list/paths = list(/obj/item/stack/sheet/plasteel,
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/mineral/plasma,
			/obj/item/stack/sheet/mineral/silver,
			/obj/item/stack/sheet/mineral/gold,
			/obj/item/stack/sheet/mineral/uranium)
	var/path = pick(paths)
	new path(get_turf(holder.my_atom), 5)
	path = pick(paths)
	new path(get_turf(holder.my_atom), 5)
	..()

//Blue
/datum/chemical_reaction/slime_extract/slimefrost
	name = "Slime Frost Oil"
	id = "m_frostoil"
	required_reagents = list(PLASMA = 5)
	required_container = /obj/item/slime_extract/blue
	reagent = FROSTOIL
	reagent_amount = 10

//Dark Blue
/datum/chemical_reaction/slime_extract/slimefreeze
	name = "Slime Freeze"
	id = "m_freeze"
	required_reagents = list(PLASMA = 5)
	required_container = /obj/item/slime_extract/darkblue
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slime_extract/slimefreeze/on_reaction(var/datum/reagents/holder)
	if(!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
		holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently!</span>")
		sleep(50)

	playsound(holder.my_atom, 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/living/M in range (get_turf(holder.my_atom), 7))
		M.bodytemperature -= 6
		to_chat(M, "<span class='notice'>You feel a chill!</span>")
	..()

/datum/chemical_reaction/slime_extract/slimenutrient
	name = "Slime Nutrient"
	id = "m_nutrient"
	required_reagents = list(BLOOD = 5)
	required_container = /obj/item/slime_extract/darkblue

/datum/chemical_reaction/slime_extract/slimenutrient/on_reaction(var/datum/reagents/holder)
	var/obj/item/weapon/slimenutrient/P = new /obj/item/weapon/slimenutrient
	P.forceMove(get_turf(holder.my_atom))
	..()

//Orange
/datum/chemical_reaction/slime_extract/slimecasp
	name = "Slime Capsaicin Oil"
	id = "m_capsaicinoil"
	required_reagents = list(BLOOD = 5)
	required_container = /obj/item/slime_extract/orange
	reagent = CAPSAICIN
	reagent_amount = 10

/datum/chemical_reaction/slime_extract/slimefire
	name = "Slime Napalm"
	id = "m_fire"
	required_reagents = list(PLASMA = 5)
	required_container = /obj/item/slime_extract/orange
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slime_extract/slimefire/on_reaction(var/datum/reagents/holder)
	if(!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
		holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently!</span>")
		sleep(50)

	var/turf/location = get_turf(holder.my_atom.loc)
	for(var/turf/simulated/floor/target_tile in range(0, location))

		var/datum/gas_mixture/napalm = new
		napalm.temperature = 1400
		napalm.adjust_gas(GAS_PLASMA, 25)
		target_tile.assume_air(napalm)
		spawn(0)
			target_tile.hotspot_expose(700, 400,surfaces = 1)
	..()

//Yellow
/datum/chemical_reaction/slime_extract/slimeoverload
	name = "Slime EMP"
	id = "m_emp"
	required_reagents = list(BLOOD = 5)
	required_container = /obj/item/slime_extract/yellow
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slime_extract/slimeoverload/on_reaction(var/datum/reagents/holder, var/created_volume)
	empulse(get_turf(holder.my_atom), 3, 7)
	..()

/datum/chemical_reaction/slime_extract/slimecell
	name = "Slime Powercell"
	id = "m_cell"
	required_reagents = list(PLASMA = 5)
	required_container = /obj/item/slime_extract/yellow

/datum/chemical_reaction/slime_extract/slimecell/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/obj/item/weapon/cell/slime/P = new /obj/item/weapon/cell/slime
	P.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime_extract/slimeglow
	name = "Slime Glow"
	id = "m_glow"
	required_reagents = list(WATER = 5)
	required_container = /obj/item/slime_extract/yellow

/datum/chemical_reaction/slime_extract/slimeglow/on_reaction(var/datum/reagents/holder)
	var/obj/item/device/flashlight/lamp/slime/P = new /obj/item/device/flashlight/lamp/slime
	P.forceMove(get_turf(holder.my_atom))
	..()

//Purple
/datum/chemical_reaction/slime_extract/slimepsteroid
	name = "Slime Steroid"
	id = "m_steroid"
	required_reagents = list(PLASMA = 5)
	required_container = /obj/item/slime_extract/purple

/datum/chemical_reaction/slime_extract/slimepsteroid/on_reaction(var/datum/reagents/holder)
	var/obj/item/weapon/slimesteroid/P = new /obj/item/weapon/slimesteroid
	P.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime_extract/slimejam
	name = "Slime Jam"
	id = "m_jam"
	required_reagents = list(SUGARS = 5)
	required_container = /obj/item/slime_extract/purple
	alert_admins = ALERT_ALL_REAGENTS
	reagent = SLIMEJELLY
	reagent_amount = 10

//Dark Purple
/datum/chemical_reaction/slime_extract/slimeplasma
	name = "Slime Plasma"
	id = "m_plasma"
	required_reagents = list(PLASMA = 5)
	required_container = /obj/item/slime_extract/darkpurple

/datum/chemical_reaction/slime_extract/slimeplasma/on_reaction(var/datum/reagents/holder)
	var/obj/item/stack/sheet/mineral/plasma/P = new /obj/item/stack/sheet/mineral/plasma
	P.amount = 10
	P.forceMove(get_turf(holder.my_atom))
	..()

//Red
/datum/chemical_reaction/slime_extract/slimeglycerol
	name = "Slime Glycerol"
	id = "m_glycerol"
	required_reagents = list(PLASMA = 5)
	required_container = /obj/item/slime_extract/red
	alert_admins = ALERT_ALL_REAGENTS
	reagent = GLYCEROL
	reagent_amount = 8

/datum/chemical_reaction/slime_extract/slimeres
	name = "Slime Res"
	id = "m_nutrient"
	required_reagents = list(SUGARS = 5)
	required_container = /obj/item/slime_extract/red

/datum/chemical_reaction/slime_extract/slimeres/on_reaction(var/datum/reagents/holder)
	var/obj/item/weapon/slimeres/P = new /obj/item/weapon/slimeres
	P.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime_extract/slimebloodlust
	name = "Bloodlust"
	id = "m_bloodlust"
	required_reagents = list(BLOOD = 5)
	required_container = /obj/item/slime_extract/red
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slime_extract/slimebloodlust/on_reaction(var/datum/reagents/holder)
	for(var/mob/living/carbon/slime/slime in viewers(get_turf(holder.my_atom), null))
		slime.rabid()
		holder.my_atom.visible_message("<span class='warning'>\The [slime] is driven into a frenzy!</span>")
	for(var/mob/living/simple_animal/slime/slime in viewers(get_turf(holder.my_atom), null))
		slime.rabid()
		holder.my_atom.visible_message("<span class='warning'>\The [slime] is driven into a frenzy!</span>")
	..()

//Pink
/datum/chemical_reaction/slime_extract/slimeppotion
	name = "Slime Potion"
	id = "m_potion"
	required_reagents = list(PLASMA = 5)
	required_container = /obj/item/slime_extract/pink

/datum/chemical_reaction/slime_extract/slimeppotion/on_reaction(var/datum/reagents/holder)
	var/obj/item/weapon/slimepotion/P = new /obj/item/weapon/slimepotion
	P.forceMove(get_turf(holder.my_atom))
	..()

//Black
/datum/chemical_reaction/slime_extract/slimemutate2
	name = "Advanced Mutation Toxin"
	id = "mutationtoxin2"
	required_reagents = list(PLASMA = 5)
	required_container = /obj/item/slime_extract/black
	alert_admins = ALERT_ALL_REAGENTS
	reagent = AMUTATIONTOXIN
	result_amount = 1
	reagent_amount = 1

/datum/chemical_reaction/slime_extract/slimenanobots
	name = "Slime Nanobots"
	id = "s_nanobots"
	required_reagents = list(GOLD = 5)
	required_container = /obj/item/slime_extract/black
	alert_admins = ALERT_ALL_REAGENTS
	reagent = NANOBOTS
	reagent_amount = 5

/datum/chemical_reaction/slime_extract/slimeperidaxon
	name = "Slime Peridaxon"
	id = "m_peridaxon"
	required_reagents = list(WATER = 5)
	required_container = /obj/item/slime_extract/black
	reagent = PERIDAXON
	reagent_amount = 5

/datum/chemical_reaction/slime_extract/slimesdelight
	name = "Slime Doctor's Delight"
	id = "m_doctordelight"
	required_reagents = list(SUGARS = 5)
	required_container = /obj/item/slime_extract/black
	reagent = DOCTORSDELIGHT
	reagent_amount = 10

/datum/chemical_reaction/slime_extract/slimerezadone
	name = "Slime Rezadone"
	id = "m_rezadone"
	required_reagents = list(BLOOD = 5)
	required_container = /obj/item/slime_extract/black
	reagent = REZADONE
	reagent_amount = 10

//Oil
/datum/chemical_reaction/slime_extract/slimeexplosion
	name = "Slime Explosion"
	id = "m_explosion"
	required_reagents = list(PLASMA = 5)
	required_container = /obj/item/slime_extract/oil
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slime_extract/slimeexplosion/on_reaction(var/datum/reagents/holder)
	if(!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
		holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently!</span>")
		sleep(50)
	explosion(get_turf(holder.my_atom), 1 ,3, 6)
	..()

/datum/chemical_reaction/slime_extract/slimegenocide
	name = "Slime Genocide" //Oy vey
	id = "m_genocide"
	required_reagents = list(BLOOD = 5)
	required_container = /obj/item/slime_extract/oil
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slime_extract/slimegenocide/on_reaction(var/datum/reagents/holder)
	for(var/mob/living/carbon/slime/S in viewers(get_turf(holder.my_atom), null)) //Kills slimes
		S.death(0)
	for(var/mob/living/simple_animal/slime/S in viewers(get_turf(holder.my_atom), null)) //Kills pet slimes too
		S.death(0)
	..()

//Light Pink
/datum/chemical_reaction/slime_extract/slimepotion2
	name = "Slime Potion 2"
	id = "m_potion2"
	required_container = /obj/item/slime_extract/lightpink
	required_reagents = list(PLASMA = 5)

/datum/chemical_reaction/slime_extract/slimepotion2/on_reaction(var/datum/reagents/holder)
	var/obj/item/weapon/slimepotion2/P = new /obj/item/weapon/slimepotion2
	P.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime_extract/slimeparalyze
	name = "Slime Paralyzer"
	id = "slimepara"
	required_container = /obj/item/slime_extract/lightpink
	required_reagents = list(BLOOD = 5)

/datum/chemical_reaction/slime_extract/slimeparalyze/on_reaction(var/datum/reagents/holder)
	new /obj/item/weapon/slimeparapotion(get_turf(holder.my_atom))
	..()

//Adamantine
/datum/chemical_reaction/slime_extract/slimegolem
	name = "Slime Golem"
	id = "m_golem"
	required_reagents = list(PLASMA = 5)
	required_container = /obj/item/slime_extract/adamantine

/datum/chemical_reaction/slime_extract/slimegolem/on_reaction(var/datum/reagents/holder)
	var/obj/effect/golem_rune/Z = new /obj/effect/golem_rune
	Z.forceMove(get_turf(holder.my_atom))
	Z.announce_to_ghosts()
	..()

/datum/chemical_reaction/slime_extract/slimediamond2
	name = "Slime Diamond2"
	id = "m_Diamond2"
	required_container = /obj/item/slime_extract/adamantine
	required_reagents = list(CARBON = 5)

/datum/chemical_reaction/slime_extract/slimediamond2/on_reaction(var/datum/reagents/holder)
	var/obj/item/stack/sheet/mineral/diamond/D = new /obj/item/stack/sheet/mineral/diamond
	D.amount = 5
	D.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime_extract/slimephazon
	name = "Slime Phazon"
	id = "m_Phazon"
	required_container = /obj/item/slime_extract/adamantine
	required_reagents = list(GOLD = 5)

/datum/chemical_reaction/slime_extract/slimephazon/on_reaction(var/datum/reagents/holder)
	var/obj/item/stack/sheet/mineral/phazon/P = new /obj/item/stack/sheet/mineral/phazon
	P.amount = 5
	P.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime_extract/slimeclown
	name = "Slime Clown"
	id = "m_Clown"
	required_reagents = list(SILVER = 5)
	required_container = /obj/item/slime_extract/adamantine

/datum/chemical_reaction/slime_extract/slimeclown/on_reaction(var/datum/reagents/holder)
	var/obj/item/stack/sheet/mineral/clown/C = new /obj/item/stack/sheet/mineral/clown
	C.amount = 5
	C.forceMove(get_turf(holder.my_atom))
	..()

//Bluespace
/datum/chemical_reaction/slime_extract/slimeteleport
	name = "Slime Teleport"
	id = "m_tele"
	required_reagents = list(PLASMA = 5)
	required_container = /obj/item/slime_extract/bluespace
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slime_extract/slimeteleport/on_reaction(var/datum/reagents/holder, var/created_volume)
	//Calculate new position (searches through beacons in world)
	var/obj/item/beacon/chosen
	var/list/possible = list()
	for(var/obj/item/beacon/W in beacons)
		possible += W

	if(possible.len > 0)
		chosen = pick(possible)

	if(chosen)

		//Calculate previous position for transition
		var/turf/from = get_turf(holder.my_atom) //The turf of origin we're travelling from
		var/turf/towards = get_turf(chosen)			 //The turf of origin we're travelling towards

		playsound(towards, 'sound/effects/phasein.ogg', 100, 1)

		var/list/flashers = list()
		for(var/mob/living/carbon/human/M in viewers(towards, null))
			if((M.eyecheck() <= 0) && (!istype(M.glasses, /obj/item/clothing/glasses/scanner/science)))
				M.flash_eyes(visual = 1)
				flashers += M

		var/y_distance = towards.y - from.y
		var/x_distance = towards.x - from.x
		for(var/atom/movable/A in range(4, from)) //Iterate thru list of mobs in the area
			if(istype(A, /obj/item/beacon)) //Don't teleport beacons because that's just insanely stupid
				continue
			if(A.anchored)
				continue
			if(istype(A, /obj/structure/cable))
				continue

			var/turf/newloc = locate(A.x + x_distance, A.y + y_distance, towards.z) //Calculate the new place
			if(!A.Move(newloc)) //If the atom, for some reason, can't move, force them to move! We try Move() first to invoke any movement-related checks the atom needs to perform after moving
				A.forceMove(locate(A.x + x_distance, A.y + y_distance, towards.z))

			spawn()
				if(ismob(A) && !(A in flashers)) //Don't flash if we're already doing an effect
					var/mob/M = A
					if(M.client)
						var/obj/blueeffect = new /obj(src)
						blueeffect.screen_loc = "WEST,SOUTH to EAST,NORTH"
						blueeffect.icon = 'icons/effects/effects.dmi'
						blueeffect.icon_state = "shieldsparkles"
						blueeffect.plane = HUD_PLANE
						blueeffect.layer = UNDER_HUD_LAYER
						blueeffect.mouse_opacity = 0
						M.client.screen += blueeffect
						sleep(20)
						M.client.screen -= blueeffect
						QDEL_NULL(blueeffect)
	..()

/datum/chemical_reaction/slime_extract/slimecrystal
	name = "Slime Crystal"
	id = "m_crystal"
	required_reagents = list(BLOOD = 5)
	required_container = /obj/item/slime_extract/bluespace

/datum/chemical_reaction/slime_extract/slimecrystal/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/obj/item/bluespace_crystal/BC = new(get_turf(holder.my_atom))
	BC.visible_message("<span class='notice'>\The [BC] appears out of thin air!</span>")
	..()

//Cerulean
/datum/chemical_reaction/slime_extract/slimepsteroid2
	name = "Slime Steroid 2"
	id = "m_steroid2"
	required_reagents = list(PLASMA = 5)
	required_container = /obj/item/slime_extract/cerulean

/datum/chemical_reaction/slime_extract/slimepsteroid2/on_reaction(var/datum/reagents/holder)
	var/obj/item/weapon/slimesteroid2/P = new /obj/item/weapon/slimesteroid2
	P.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime_extract/slimedupe
	name = "Slime Duplicator"
	id = "m_dupe"
	required_reagents = list(BLOOD = 5)
	required_container = /obj/item/slime_extract/cerulean

/datum/chemical_reaction/slime_extract/slimedupe/on_reaction(var/datum/reagents/holder)
	var/obj/item/weapon/slimedupe/P = new /obj/item/weapon/slimedupe
	P.forceMove(get_turf(holder.my_atom))
	..()

//Sepia
/datum/chemical_reaction/slime_extract/slimecamera
	name = "Slime Camera"
	id = "m_camera"
	required_reagents = list(PLASMA = 5)
	required_container = /obj/item/slime_extract/sepia

/datum/chemical_reaction/slime_extract/slimecamera/on_reaction(var/datum/reagents/holder)
	var/obj/item/device/camera/sepia/P = new /obj/item/device/camera/sepia
	P.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime_extract/slimefilm
	name = "Slime Film"
	id = "m_film"
	required_reagents = list(BLOOD = 5)
	required_container = /obj/item/slime_extract/sepia

/datum/chemical_reaction/slime_extract/slimefilm/on_reaction(var/datum/reagents/holder)
	var/obj/item/device/camera_film/P = new /obj/item/device/camera_film
	P.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime_extract/slimestop
	name = "Slime timestop"
	id = "s_stop"
	required_reagents = list(PHAZON = 5)
	required_container = /obj/item/slime_extract/sepia
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slime_extract/slimestop/on_reaction(var/datum/reagents/holder, var/created_volume)
	playsound(holder.my_atom, 'sound/effects/theworld3.ogg', 100, 1)
	timestop(get_turf(holder.my_atom), 25,5)
	..()

//Pyrite
/datum/chemical_reaction/slime_extract/slimepaint
	name = "Slime Paint"
	id = "s_paint"
	required_reagents = list(PLASMA = 5)
	required_container = /obj/item/slime_extract/pyrite

/datum/chemical_reaction/slime_extract/slimepaint/on_reaction(var/datum/reagents/holder)
	new /obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/random(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime_extract/slimenanopaint
	name = "Slime Nano Paint"
	id = "s_nanopaint"
	required_reagents = list(PHAZON = 5)
	required_container = /obj/item/slime_extract/pyrite

/datum/chemical_reaction/slime_extract/slimenanopaint/on_reaction(var/datum/reagents/holder)
	new /obj/item/weapon/reagent_containers/glass/metal_bucket/nanopaint/filled/vantablack(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime_extract/slimecash
	name = "Slime Cash"
	id = "m_cash"
	required_reagents = list(BLOOD = 5)
	required_container = /obj/item/slime_extract/pyrite

/datum/chemical_reaction/slime_extract/slimecash/on_reaction(var/datum/reagents/holder)
	var/obj/item/weapon/spacecash/c100/C = new /obj/item/weapon/spacecash/c100/
	C.amount = 5
	C.forceMove(get_turf(holder.my_atom))
	..()

//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////

/datum/chemical_reaction/enzyme
	name = "Universal Enzyme"
	id = ENZYME
	result = ENZYME
	required_reagents = list(SODIUMCHLORIDE = 1, NUTRIMENT = 1, BLOOD = 1)
	result_amount = 1

/datum/chemical_reaction/tofu
	name = "Tofu"
	id = "tofu"
	result = null
	required_reagents = list(SOYMILK = 10)
	required_catalysts = list(ENZYME = 5)
	result_amount = 1

/datum/chemical_reaction/tofu/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/tofu(location)

/datum/chemical_reaction/chocolate_bar
	name = "Chocolate Bar"
	id = "chocolate_bar"
	result = null
	required_reagents = list(SOYMILK = 2, COCO = 2, SUGARS = 2)
	result_amount = 1

/datum/chemical_reaction/chocolate_bar/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)

/datum/chemical_reaction/chocolate_bar2
	name = "Chocolate Bar"
	id = "chocolate_bar"
	result = null
	required_reagents = list(MILK = 2, COCO = 2, SUGARS = 2)
	result_amount = 1

/datum/chemical_reaction/chocolate_bar2/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)

/datum/chemical_reaction/hot_coco
	name = "Hot Coco"
	id = HOT_COCO
	result = HOT_COCO
	required_reagents = list(MILK = 5, COCO = 1)
	required_temp = T0C + 60
	result_amount = 5

/datum/chemical_reaction/hot_coco/subhuman
	id = HOT_COCO_SUBHUMAN
	result = HOT_COCO_SUBHUMAN
	required_reagents = list(WATER = 2, COCO = 1)
	required_temp = T0C + 80
	result_amount = 2

/*
/datum/chemical_reaction/coffee
	name = "Coffee"
	id = COFFEE
	result = COFFEE
	required_reagents = list("coffeepowder" = 1, WATER = 5)
	result_amount = 5

/datum/chemical_reaction/tea
	name = "Tea"
	id = TEA
	result = TEA
	required_reagents = list("teapowder" = 1, WATER = 5)
	result_amount = 5
*/

/datum/chemical_reaction/soysauce
	name = "Soy Sauce"
	id = SOYSAUCE
	result = SOYSAUCE
	required_reagents = list(SOYMILK = 4, SACIDS = 1)
	result_amount = 5

/datum/chemical_reaction/mustard
	name = "Mustard"
	id = MUSTARD
	result = MUSTARD
	required_reagents = list(MUSTARD_POWDER = 4, SODIUMCHLORIDE = 1, VINEGAR = 1)
	result_amount = 8

/datum/chemical_reaction/mayo
	name = "Mayonnaise"
	id = MAYO
	result = MAYO
	required_reagents = list(MUSTARD = 1, SODIUMCHLORIDE = 1, VINEGAR = 4, EGG_YOLK = 4) //there are about fifty different variants for homemade mayo, using the one that sounds best
	result_amount = 10

/datum/chemical_reaction/bluegoo
	name = "Blue Goo"
	id = BLUEGOO
	result = BLUEGOO
	required_reagents = list(ZAMSPICES = 3, LOCUTOGEN = 2)
	result_amount = 5

/datum/chemical_reaction/zammild
	name = "Zam's Mild Sauce"
	id = ZAMMILD
	result = ZAMMILD
	required_reagents = list(ZAMSPICES = 3, SACIDS = 2)
	result_amount = 5

/datum/chemical_reaction/zamspicytoxin
	name = "Zam's Spicy Sauce"
	id = ZAMSPICYTOXIN
	result = ZAMSPICYTOXIN
	required_reagents = list(ZAMMILD = 3, PACIDS = 2)
	required_catalysts = list(MUTAGEN = 5)
	result_amount = 3

/datum/chemical_reaction/vinegar
	name = "Vinegar"
	id = VINEGAR
	result = VINEGAR
	required_reagents = list(WINE = 1, WATER = 1)
	required_catalysts = list(ENZYME = 1)
	result_amount = 2

/datum/chemical_reaction/vinegar/malt
	name = "Malt Vinegar"
	id = VINEGAR
	result = VINEGAR
	required_reagents = list(ETHANOL = 1, WATER = 1)
	required_catalysts = list(ENZYME = 1)
	result_amount = 2

/datum/chemical_reaction/sprinkles
	name = "Sprinkles"
	id = SPRINKLES
	result = SPRINKLES
	required_reagents = list(SUGARS = 5, WATER = 5)
	required_catalysts = list(ENZYME = 1)
	result_amount = 5

/datum/chemical_reaction/cheesewheel
	name = "Cheesewheel"
	id = "cheesewheel"
	result = null
	required_reagents = list(MILK = 40)
	required_catalysts = list(ENZYME = 5)
	result_amount = 1

/datum/chemical_reaction/cheesewheel/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i=1 to created_volume)
		new /obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel(location)

/datum/chemical_reaction/butter
	name = "Butter"
	id = "butter"
	result = null
	required_reagents = list(CREAM = 20, SODIUMCHLORIDE = 5)
	required_catalysts = list(ENZYME = 5)
	result_amount = 1

/datum/chemical_reaction/butter/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i=1 to created_volume)
		new /obj/item/weapon/reagent_containers/food/snacks/butter(location)

/*
		=Recipe for easy pancakes=

	- Mix in a bowl:
	* 100g plain flour
	* 2 large eggs
	* 300ml milk
	* a tablespoon of melted butter
	* a teaspoon of salt
	* 3 tablespoons of sugar

	- Pre-heat and lightly grease your cooking pan at medium-high heat
	- Pour just enough of the mix to fill the pan's surface
	- Wait around 3 minutes for the first side, flip, then 1 more minute on the other side (adjust depending on how fast your pan is cooking)
	- Serve with some sugar or chocolate

*/
/datum/chemical_reaction/pancake_mix
	name = "Pancake Mix"
	id = PANCAKE
	result = PANCAKE
	required_reagents = list(FLOUR = 10, MILK = 30, LIQUIDBUTTER = 2, EGG_YOLK = 8, SODIUMCHLORIDE = 1, SUGARS = 5)
	result_amount = 56 // 1:1

//Jesus christ how horrible
/datum/chemical_reaction/cream
	name = "Cream"
	id = CREAM
	result = CREAM
	required_reagents = list(MILK = 10,SACIDS = 1)
	result_amount = 5

/datum/chemical_reaction/syntiflesh
	name = "Syntiflesh"
	id = "syntiflesh"
	result = null
	required_reagents = list(BLOOD = 5, CLONEXADONE = 1)
	result_amount = 1

/datum/chemical_reaction/syntiflesh/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i=1 to created_volume)
		new /obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh(location)

/datum/chemical_reaction/hot_ramen
	name = "Hot Ramen"
	id = HOT_RAMEN
	result = HOT_RAMEN
	required_reagents = list(WATER = 1, DRY_RAMEN = 3)
	result_amount = 3
	required_temp = 100+T0C

/datum/chemical_reaction/hell_ramen
	name = "Hell Ramen"
	id = HELL_RAMEN
	result = HELL_RAMEN
	required_reagents = list(CAPSAICIN = 1, HOT_RAMEN = 6)
	result_amount = 6

/datum/chemical_reaction/ice
	name = "Ice"
	id = ICE
	result = ICE
	required_reagents = list(WATER = 10, FROSTOIL = 1)
	result_amount = 10
	reaction_temp_change = -30

/datum/chemical_reaction/ice/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(ismob(holder.my_atom))
		var/mob/M = holder.my_atom
		M.bodytemperature -= rand(10,20)

/datum/chemical_reaction/ice2
	name = "Frozen water"
	id = ICE
	result = ICE
	required_reagents = list(WATER = 1)
	is_cold_recipe = 1
	result_amount = 1
	quiet = 1
	required_temp = T0C

/datum/chemical_reaction/ice_to_water
	name = "Melted ice"
	id = WATER
	result = WATER
	required_reagents = list(ICE = 1)
	required_temp = T20C+5
	result_amount = 1
	quiet = 1

////////////////////////////////////////// COCKTAILS //////////////////////////////////////

/datum/chemical_reaction/goldschlager
	name = "Goldschlager"
	id = GOLDSCHLAGER
	result = GOLDSCHLAGER
	required_reagents = list(VODKA = 10, GOLD = 1)
	result_amount = 10

/datum/chemical_reaction/patron
	name = "Patron"
	id = PATRON
	result = PATRON
	required_reagents = list(TEQUILA = 10, SILVER = 1)
	result_amount = 10

/datum/chemical_reaction/bilk
	name = "Bilk"
	id = BILK
	result = BILK
	required_reagents = list(MILK = 1, BEER = 1)
	result_amount = 2

/datum/chemical_reaction/icetea
	name = "Iced Tea"
	id = ICETEA
	result = ICETEA
	required_reagents = list(ICE = 1, TEA = 3)
	result_amount = 4

/datum/chemical_reaction/arnoldpalmer
	name = "Arnold Palmer"
	id = ARNOLDPALMER
	result = ARNOLDPALMER
	required_reagents = list(LEMONADE = 1, ICETEA = 1)
	result_amount = 2

/datum/chemical_reaction/icecoffee
	name = "Iced Coffee"
	id = ICECOFFEE
	result = ICECOFFEE
	required_reagents = list(ICE = 1, COFFEE = 3)
	result_amount = 4

/datum/chemical_reaction/nuka_cola
	name = "Nuka Cola"
	id = NUKA_COLA
	result = NUKA_COLA
	required_reagents = list(URANIUM = 1, COLA = 6)
	result_amount = 6

/datum/chemical_reaction/moonshine
	name = "Moonshine"
	id = MOONSHINE
	result = MOONSHINE
	required_reagents = list(CORNOIL = 10)
	required_catalysts = list(ENZYME = 5)
	result_amount = 10

/datum/chemical_reaction/cornsyrup
	name = "Corn Syrup"
	id = CORNSYRUP
	result = CORNSYRUP
	required_reagents = list(MOONSHINE = 10, SUGAR = 2)
	required_catalysts = list(ENZYME = 5)
	result_amount = 12

/datum/chemical_reaction/wine
	name = "Wine"
	id = WINE
	result = WINE
	required_reagents = list(GRAPEJUICE = 10)
	required_catalysts = list(ENZYME = 5)
	result_amount = 10

/datum/chemical_reaction/bwine
	name = "Berry Wine"
	id = BWINE
	result = BWINE
	required_reagents = list(BERRYJUICE = 10)
	required_catalysts = list(ENZYME = 5)
	result_amount = 10

/datum/chemical_reaction/wwine
	name = "White Wine"
	id = WWINE
	result = WWINE
	required_reagents = list(GGRAPEJUICE = 10)
	required_catalysts = list(ENZYME = 5)
	result_amount = 10

/datum/chemical_reaction/plumphwine
	name = "Plump Helmet Wine"
	id = PLUMPHWINE
	result = PLUMPHWINE
	required_reagents = list(PLUMPHJUICE = 10)
	required_catalysts = list(ENZYME = 5)
	result_amount = 10

/datum/chemical_reaction/sangria
	name = "Sangria"
	id = SANGRIA
	result = SANGRIA
	required_reagents = list(WINE = 2, ORANGEJUICE = 1, SODAWATER = 1)
	result_amount = 4

/datum/chemical_reaction/pinacolada
	name = "Pina Colada"
	id = PINACOLADA
	result = PINACOLADA
	required_reagents = list(RUM = 2, ICE = 1, CREAM = 1)
	result_amount = 4

/datum/chemical_reaction/spacebeer
	name = "Space Beer"
	id = BEER
	result = BEER
	required_reagents = list(FLOUR = 10)
	required_catalysts = list(ENZYME = 5)
	result_amount = 10

/datum/chemical_reaction/vodka
	name = "Vodka"
	id = VODKA
	result = VODKA
	required_reagents = list(POTATO = 10)
	required_catalysts = list(ENZYME = 5)
	result_amount = 10

/datum/chemical_reaction/greyvodka
	name = "Greyshirt Vodka"
	id = GREYVODKA
	result = GREYVODKA
	required_reagents = list(POTATO = 2, WATER = 2, ROACHSHELL = 1)
	result_amount = 5

/datum/chemical_reaction/sake
	name = "Sake"
	id = SAKE
	result = SAKE
	required_reagents = list(RICE = 10)
	required_catalysts = list(ENZYME = 5)
	result_amount = 10

/datum/chemical_reaction/kahlua
	name = "Kahlua"
	id = KAHLUA
	result = KAHLUA
	required_reagents = list(COFFEE = 5, SUGARS = 5)
	required_catalysts = list(ENZYME = 5)
	result_amount = 5

/datum/chemical_reaction/gin_tonic
	name = "Gin and Tonic"
	id = GINTONIC
	result = GINTONIC
	required_reagents = list(GIN = 2, TONIC = 1)
	result_amount = 3

/datum/chemical_reaction/cuba_libre
	name = "Cuba Libre"
	id = CUBALIBRE
	result = CUBALIBRE
	required_reagents = list(RUM = 2, COLA = 1)
	result_amount = 3

/datum/chemical_reaction/martini
	name = "Classic Martini"
	id = MARTINI
	result = MARTINI
	required_reagents = list(GIN = 2, VERMOUTH = 1)
	result_amount = 3

/datum/chemical_reaction/vodkamartini
	name = "Vodka Martini"
	id = VODKAMARTINI
	result = VODKAMARTINI
	required_reagents = list(VODKA = 2, VERMOUTH = 1)
	result_amount = 3

/datum/chemical_reaction/sakemartini
	name = "Sake Martini"
	id = SAKEMARTINI
	result = SAKEMARTINI
	required_reagents = list(SAKE = 1, GIN = 1)
	result_amount = 2

/datum/chemical_reaction/white_russian
	name = "White Russian"
	id = WHITERUSSIAN
	result = WHITERUSSIAN
	required_reagents = list(BLACKRUSSIAN = 3, CREAM = 2)
	result_amount = 5

/datum/chemical_reaction/whiskey_cola
	name = "Whiskey Cola"
	id = WHISKEYCOLA
	result = WHISKEYCOLA
	required_reagents = list(WHISKEY = 2, COLA = 1)
	result_amount = 3

/datum/chemical_reaction/screwdriver
	name = "Screwdriver"
	id = SCREWDRIVERCOCKTAIL
	result = SCREWDRIVERCOCKTAIL
	required_reagents = list(VODKA = 2, ORANGEJUICE = 1)
	result_amount = 3

/datum/chemical_reaction/bloody_mary
	name = "Bloody Mary"
	id = BLOODYMARY
	result = BLOODYMARY
	required_reagents = list(VODKA = 1, TOMATOJUICE = 2, LIMEJUICE = 1)
	result_amount = 4

/datum/chemical_reaction/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = GARGLEBLASTER
	result = GARGLEBLASTER
	required_reagents = list(VODKA = 1, GIN = 1, WHISKEY = 1, COGNAC = 1, LIMEJUICE = 1)
	result_amount = 5

/datum/chemical_reaction/brave_bull
	name = "Brave Bull"
	id = BRAVEBULL
	result = BRAVEBULL
	required_reagents = list(TEQUILA = 2, KAHLUA = 1)
	result_amount = 3

/datum/chemical_reaction/tequila_sunrise
	name = "Tequila Sunrise"
	id = TEQUILASUNRISE
	result = TEQUILASUNRISE
	required_reagents = list(TEQUILA = 2, ORANGEJUICE = 1)
	result_amount = 3

/datum/chemical_reaction/toxins_special
	name = "Toxins Special"
	id = TOXINSSPECIAL
	result = TOXINSSPECIAL
	required_reagents = list(RUM = 2, VERMOUTH = 1, PLASMA = 2)
	result_amount = 5

/datum/chemical_reaction/beepsky_smash
	name = "Beepsky Smash"
	id = BEEPSKYSMASH
	result = BEEPSKYSMASH
	required_reagents = list(LIMEJUICE = 2, WHISKEY = 2, IRON = 1)
	result_amount = 4

/datum/chemical_reaction/doctor_delight
	name = "The Doctor's Delight"
	id = DOCTORSDELIGHT
	result = DOCTORSDELIGHT
	required_reagents = list(LIMEJUICE = 1, TOMATOJUICE = 1, ORANGEJUICE = 1, CREAM = 1, TRICORDRAZINE = 1)
	result_amount = 5

/datum/chemical_reaction/doctor_delight_from_syrup
	name = "The Dector's Delight from pre-mix"
	id= "p_doctordelight"
	result = DOCTORSDELIGHT
	required_reagents = list(DSYRUP = 1, TRICORDRAZINE = 1)
	result_amount = 2

/datum/chemical_reaction/irish_cream
	name = "Irish Cream"
	id = IRISHCREAM
	result = IRISHCREAM
	required_reagents = list(WHISKEY = 2, CREAM = 1)
	result_amount = 3

/datum/chemical_reaction/manly_dorf
	name = "The Manly Dorf"
	id = MANLYDORF
	result = MANLYDORF
	required_reagents = list (BEER = 1, ALE = 2)
	result_amount = 3

/datum/chemical_reaction/hooch
	name = "Hooch"
	id = HOOCH
	result = HOOCH
	required_reagents = list (SUGARS = 1, ETHANOL = 2, FUEL = 1)
	result_amount = 3

/datum/chemical_reaction/irish_coffee
	name = "Irish Coffee"
	id = IRISHCOFFEE
	result = IRISHCOFFEE
	required_reagents = list(IRISHCREAM = 1, COFFEE = 1)
	result_amount = 2

/datum/chemical_reaction/b52
	name = "B-52"
	id = B52
	result = B52
	required_reagents = list(IRISHCARBOMB = 1, KAHLUA = 1, COGNAC = 1)
	result_amount = 3

/datum/chemical_reaction/atomicbomb
	name = "Atomic Bomb"
	id = ATOMICBOMB
	result = ATOMICBOMB
	required_reagents = list(B52 = 10, URANIUM = 1)
	result_amount = 10

/datum/chemical_reaction/margarita
	name = "Margarita"
	id = MARGARITA
	result = MARGARITA
	required_reagents = list(TEQUILA = 2, LIMEJUICE = 1)
	result_amount = 3

/datum/chemical_reaction/longislandicedtea
	name = "Long Island Iced Tea"
	id = LONGISLANDICEDTEA
	result = LONGISLANDICEDTEA
	required_reagents = list(VODKA = 1, GIN = 1, TEQUILA = 1, CUBALIBRE = 1, ICE = 1)
	result_amount = 5

/datum/chemical_reaction/threemileisland
	name = "Three Mile Island Iced Tea"
	id = THREEMILEISLAND
	result = THREEMILEISLAND
	required_reagents = list(LONGISLANDICEDTEA = 10, URANIUM = 1)
	result_amount = 10

/datum/chemical_reaction/whiskeysoda
	name = "Whiskey Soda"
	id = WHISKEYSODA
	result = WHISKEYSODA
	required_reagents = list(WHISKEY = 2, SODAWATER = 1)
	result_amount = 3

/datum/chemical_reaction/black_russian
	name = "Black Russian"
	id = BLACKRUSSIAN
	result = BLACKRUSSIAN
	required_reagents = list(VODKA = 3, KAHLUA = 2)
	result_amount = 5

/datum/chemical_reaction/manhattan
	name = "Manhattan"
	id = MANHATTAN
	result = MANHATTAN
	required_reagents = list(WHISKEY = 2, VERMOUTH = 1)
	result_amount = 3

/datum/chemical_reaction/manhattan_proj
	name = "Manhattan Project"
	id = MANHATTAN_PROJ
	result = MANHATTAN_PROJ
	required_reagents = list(MANHATTAN = 10, URANIUM = 1)
	result_amount = 10

/datum/chemical_reaction/vodka_tonic
	name = "Vodka and Tonic"
	id = VODKATONIC
	result = VODKATONIC
	required_reagents = list(VODKA = 2, TONIC = 1)
	result_amount = 3

/datum/chemical_reaction/gin_fizz
	name = "Gin Fizz"
	id = GINFIZZ
	result = GINFIZZ
	required_reagents = list(GIN = 2, SODAWATER = 1, LIMEJUICE = 1)
	result_amount = 4

/datum/chemical_reaction/bahama_mama
	name = "Bahama mama"
	id = BAHAMA_MAMA
	result = BAHAMA_MAMA
	required_reagents = list(RUM = 2, ORANGEJUICE = 2, LIMEJUICE = 1, ICE = 1)
	result_amount = 6

/datum/chemical_reaction/singulo
	name = "Singulo"
	id = SINGULO
	result = SINGULO
	required_reagents = list(VODKA = 5, RADIUM = 1, WINE = 5)
	result_amount = 10

/datum/chemical_reaction/alliescocktail
	name = "Allies Cocktail"
	id = ALLIESCOCKTAIL
	result = ALLIESCOCKTAIL
	required_reagents = list(MARTINI = 1, VODKA = 1)
	result_amount = 2

/datum/chemical_reaction/demonsblood
	name = "Demons Blood"
	id = DEMONSBLOOD
	result = DEMONSBLOOD
	required_reagents = list(RUM = 1, SPACEMOUNTAINWIND = 1, BLOOD = 1, DR_GIBB = 1)
	result_amount = 4

/datum/chemical_reaction/booger
	name = "Booger"
	id = BOOGER
	result = BOOGER
	required_reagents = list(CREAM = 1, BANANA = 1, RUM = 1, WATERMELONJUICE = 1)
	result_amount = 4

/datum/chemical_reaction/antifreeze
	name = "Anti-freeze"
	id = ANTIFREEZE
	result = ANTIFREEZE
	required_reagents = list(VODKA = 2, CREAM = 1, ICE = 1)
	result_amount = 4

/datum/chemical_reaction/barefoot
	name = "Barefoot"
	id = BAREFOOT
	result = BAREFOOT
	required_reagents = list(BERRYJUICE = 1, CREAM = 1, VERMOUTH = 1)
	result_amount = 3

/datum/chemical_reaction/dans_whiskey
	name = "Discount Dan's 'Malt' Whiskey"
	id = DANS_WHISKEY
	result = DANS_WHISKEY
	required_reagents = list(BLEACH = 1, DISCOUNT = 1)
	result_amount = 2

/datum/chemical_reaction/pintpointer
	name = "Pintpointer"
	id = PINTPOINTER
	result = PINTPOINTER
	required_reagents = list(ATOMICBOMB = 1, SYNDICATEBOMB = 1)
	result_amount = 2

/datum/chemical_reaction/mudslide
	name = "Mudslide"
	id = MUDSLIDE
	result = MUDSLIDE
	required_reagents = list(ANTIFREEZE = 1, BLACKRUSSIAN = 1, IRISHCREAM = 1)
	result_amount = 3

/datum/chemical_reaction/creamy_hot_coco
	name = "Creamy Hot Chocolate"
	id = CREAMY_HOT_COCO
	result = CREAMY_HOT_COCO
	required_reagents = list(HOT_COCO = 1, CREAM = 1)
	result_amount = 2

/datum/chemical_reaction/sacrificialmary
	name = "Sacrificial Mary"
	id = SACRIFICIAL_MARY
	result = SACRIFICIAL_MARY
	required_reagents = list(VODKA = 1, BLOOD = 2, LIMEJUICE = 1)
	result_amount = 4

/datum/chemical_reaction/boysenberryblizzard
	name = "Boysenberry Blizzard"
	id = BOYSENBERRY_BLIZZARD
	result = BOYSENBERRY_BLIZZARD
	required_reagents = list(PLASMA = 1, SNOWWHITE = 4, BERRYJUICE = 1)
	result_amount = 5

/datum/chemical_reaction/pinklady
	name = "Pink Lady"
	id = PINKLADY
	result = PINKLADY
	required_reagents = list(GIN = 3, CHERRYJELLY = 1)
	result_amount = 4

/datum/chemical_reaction/mimosa
	name = "Mimosa"
	id = MIMOSA
	result = MIMOSA
	required_reagents = list(CHAMPAGNE = 1, ORANGEJUICE = 1)
	result_amount = 2

/datum/chemical_reaction/lemondrop
	name = "Lemon Drop"
	id = LEMONDROP
	result = LEMONDROP
	required_reagents = list(LEMONJUICE = 1, TRIPLESEC = 1, VODKA = 1)
	result_amount = 3

////DRINKS THAT REQUIRED IMPROVED SPRITES BELOW:: -Agouri/////

/datum/chemical_reaction/sbiten
	name = "Sbiten"
	id = SBITEN
	result = SBITEN
	required_reagents = list(VODKA = 10, CAPSAICIN = 1)
	result_amount = 10

/datum/chemical_reaction/red_mead
	name = "Red Mead"
	id = RED_MEAD
	result = RED_MEAD
	required_reagents = list(BLOOD = 1, MEAD = 1)
	result_amount = 2

/datum/chemical_reaction/mead
	name = "Mead"
	id = MEAD
	result = MEAD
	required_reagents = list(HONEY = 1, WATER = 1)
	required_catalysts = list(ENZYME = 5)
	result_amount = 2

/datum/chemical_reaction/iced_beer
	name = "Iced Beer"
	id = ICED_BEER
	result = ICED_BEER
	required_reagents = list(BEER = 10, FROSTOIL = 1)
	result_amount = 10

/datum/chemical_reaction/iced_beer2
	name = "Iced Beer"
	id = ICED_BEER
	result = ICED_BEER
	required_reagents = list(BEER = 5, ICE = 1)
	result_amount = 6

/datum/chemical_reaction/grog
	name = "Grog"
	id = GROG
	result = GROG
	required_reagents = list(RUM = 1, WATER = 1)
	result_amount = 2

/datum/chemical_reaction/evoluator
	name = "Evoluator"
	id = EVOLUATOR
	result = EVOLUATOR
	required_reagents = list(BLOBANINE = 1, OXYGEN = 2, APPLEJUICE = 1, VERMOUTH = 1)
	result_amount = 5

/datum/chemical_reaction/blob_beer
	name = "Blob beer"
	id = BLOBBEER
	result = BLOBBEER
	required_reagents = list(BLOBANINE = 1, SUGAR = 1)
	required_temp = T0C + 60
	result_amount = 10

/datum/chemical_reaction/liberator
	name = "Liberator"
	id = LIBERATOR
	result = LIBERATOR
	required_reagents = list(BLOBANINE = 1, ORANGEJUICE = 1, TRIPLESEC = 1)
	result_amount = 6

/datum/chemical_reaction/spore
	name = "Spore"
	id = SPORE
	result = SPORE
	required_reagents = list(BLOBANINE = 1, KARMOTRINE = 1, OXYGEN = 1)
	result_amount = 3

/datum/chemical_reaction/soy_latte
	name = "Soy Latte"
	id = SOY_LATTE
	result = SOY_LATTE
	required_reagents = list(ESPRESSO = 1, SOYMILK = 1)
	result_amount = 2

/datum/chemical_reaction/cafe_latte
	name = "Latte"
	id = CAFE_LATTE
	result = CAFE_LATTE
	required_reagents = list(ESPRESSO = 1, MILK = 1)
	result_amount = 2

/datum/chemical_reaction/acidspit
	name = "Acid Spit"
	id = ACIDSPIT
	result = ACIDSPIT
	required_reagents = list(SACIDS = 1, WINE = 5)
	result_amount = 6

/datum/chemical_reaction/amasec
	name = "Amasec"
	id = AMASEC
	result = AMASEC
	required_reagents = list(IRON = 1, WINE = 5, VODKA = 5)
	result_amount = 10

/datum/chemical_reaction/changelingsting
	name = "Changeling Sting"
	id = CHANGELINGSTING
	result = CHANGELINGSTING
	required_reagents = list(SCREWDRIVERCOCKTAIL = 1, LIMEJUICE = 1, LEMONJUICE = 1)
	result_amount = 5

/datum/chemical_reaction/changelingstab
	name = "Changeling Stab"
	id = CHANGELINGSTAB
	result = CHANGELINGSTAB
	required_reagents = list(CHANGELINGSTING = 1, NOTHING = 1, KARMOTRINE = 3)
	result_amount = 5

/datum/chemical_reaction/aloe
	name = "Aloe"
	id = ALOE
	result = ALOE
	required_reagents = list(IRISHCREAM = 1, WATERMELONJUICE = 1)
	result_amount = 2

/datum/chemical_reaction/andalusia
	name = "Andalusia"
	id = ANDALUSIA
	result = ANDALUSIA
	required_reagents = list(RUM = 1, WHISKEY = 1, LEMONJUICE = 1)
	result_amount = 3

/datum/chemical_reaction/neurotoxin
	name = "Neurotoxin"
	id = NEUROTOXIN
	result = NEUROTOXIN
	required_reagents = list(GARGLEBLASTER = 1, STOXINS = 1)
	result_amount = 2

/datum/chemical_reaction/snowwhite
	name = "Snow White"
	id = SNOWWHITE
	result = SNOWWHITE
	required_reagents = list(BEER = 1, LEMON_LIME = 1)
	result_amount = 2

/datum/chemical_reaction/irishcarbomb
	name = "Irish Car Bomb"
	id = IRISHCARBOMB
	result = IRISHCARBOMB
	required_reagents = list(ALE = 1, IRISHCREAM = 1)
	result_amount = 2

/datum/chemical_reaction/syndicatebomb
	name = "Syndicate Bomb"
	id = SYNDICATEBOMB
	result = SYNDICATEBOMB
	required_reagents = list(BEER = 1, WHISKEYCOLA = 1)
	result_amount = 2

/datum/chemical_reaction/erikasurprise
	name = "Erika Surprise"
	id = ERIKASURPRISE
	result = ERIKASURPRISE
	required_reagents = list(ALE = 1, LIMEJUICE = 1, WHISKEY = 1, BANANA = 1, ICE = 1)
	result_amount = 5

/datum/chemical_reaction/devilskiss
	name = "Devils Kiss"
	id = DEVILSKISS
	result = DEVILSKISS
	required_reagents = list(BLOOD = 1, KAHLUA = 1, RUM = 1)
	result_amount = 3

/datum/chemical_reaction/hippiesdelight
	name = "Hippies Delight"
	id = HIPPIESDELIGHT
	result = HIPPIESDELIGHT
	required_reagents = list(PSILOCYBIN = 1, GARGLEBLASTER = 1)
	result_amount = 2

/datum/chemical_reaction/bananahonk
	name = "Banana Honk"
	id = BANANAHONK
	result = BANANAHONK
	required_reagents = list(BANANA = 1, CREAM = 1, SUGARS = 1)
	result_amount = 3

/datum/chemical_reaction/honkserum
	name = "Honk Serum"
	id = HONKSERUM
	result = HONKSERUM
	required_reagents = list(BANANA = 1, INACUSIATE = 1, ALKYSINE = 1)
	result_amount = 3

/datum/chemical_reaction/silencer
	name = "Silencer"
	id = SILENCER
	result = SILENCER
	required_reagents = list(NOTHING = 1, CREAM = 1, SUGARS = 1)
	result_amount = 3

/datum/chemical_reaction/driestmartini
	name = "Driest Martini"
	id = DRIESTMARTINI
	result = DRIESTMARTINI
	required_reagents = list(NOTHING = 1, GIN = 1)
	result_amount = 2

/datum/chemical_reaction/lemonade
	name = "Lemonade"
	id = LEMONADE
	result = LEMONADE
	required_reagents = list(LEMONJUICE = 1, SUGARS = 1, WATER = 1)
	result_amount = 3

/datum/chemical_reaction/kiraspecial
	name = "Kira Special"
	id = KIRASPECIAL
	result = KIRASPECIAL
	required_reagents = list(ORANGEJUICE = 1, LIMEJUICE = 1, SODAWATER = 1)
	result_amount = 2

/datum/chemical_reaction/brownstar
	name = "Brown Star"
	id = BROWNSTAR
	result = BROWNSTAR
	required_reagents = list(KAHLUA = 1, IRISHCREAM = 4)
	result_amount = 5

/datum/chemical_reaction/milkshake
	name = "Milkshake"
	id = MILKSHAKE
	result = MILKSHAKE
	required_reagents = list(CREAM = 1, ICE = 2, MILK = 2)
	result_amount = 5

/datum/chemical_reaction/rewriter
	name = "Rewriter"
	id = REWRITER
	result = REWRITER
	required_reagents = list(SPACEMOUNTAINWIND = 1, COFFEE = 1)
	result_amount = 2

/datum/chemical_reaction/moscowmule
	name = "Moscow Mule"
	id = MOSCOWMULE
	result = MOSCOWMULE
	required_reagents = list(BEER = 3, VODKA = 1, LIMEJUICE=1)
	result_amount = 5

/datum/chemical_reaction/midnightkiss
	name = "Midnight Kiss"
	id = MIDNIGHTKISS
	result = MIDNIGHTKISS
	required_reagents = list(VODKA = 1, BLUECURACAO = 1, CHAMPAGNE = 3)
	result_amount = 5

/datum/chemical_reaction/cosmopolitan
	name = "Cosmopolitan"
	id = COSMOPOLITAN
	result = COSMOPOLITAN
	required_reagents = list(BERRYJUICE = 1, KAMIKAZE = 1)
	result_amount = 2

/datum/chemical_reaction/corpsereviver
	name = "Corpse Reviver No. 2"
	id = CORPSEREVIVER
	result = CORPSEREVIVER
	required_reagents = list(GIN = 1, LEMONJUICE = 1, TRIPLESEC = 1, WINE = 1, ABSINTHE = 1)
	result_amount = 5

/datum/chemical_reaction/bluelagoon
	name = "Blue Lagoon"
	id = BLUELAGOON
	result = BLUELAGOON
	required_reagents = list(LEMON_LIME = 3, VODKA = 1, BLUECURACAO = 1)
	result_amount = 5

/datum/chemical_reaction/sexonthebeach
	name = "Sex on The Beach"
	id = SEXONTHEBEACH
	result = SEXONTHEBEACH
	required_reagents = list(SCREWDRIVERCOCKTAIL = 1, SCHNAPPS = 1, BERRYJUICE = 1)
	result_amount = 3

/datum/chemical_reaction/americano
	name = "Americano"
	id = AMERICANO
	result = AMERICANO
	required_reagents = list(SODAWATER = 1, WINE = 1, BITTERS = 1)
	result_amount = 3

/datum/chemical_reaction/sidecar
	name = "Sidecar"
	id = SIDECAR
	result = SIDECAR
	required_reagents = list(COGNAC = 1, TRIPLESEC = 1, LEMONJUICE = 1)
	result_amount = 3

/datum/chemical_reaction/betweenthesheets
	name = "Between The Sheets"
	id = BETWEENTHESHEETS
	result = BETWEENTHESHEETS
	required_reagents = list(SIDECAR = 1, RUM = 1)
	result_amount = 2

/datum/chemical_reaction/champagnecocktail
	name = "Champagne Cocktail"
	id = CHAMPAGNECOCKTAIL
	result = CHAMPAGNECOCKTAIL
	required_reagents = list(CHAMPAGNE = 2, COGNAC = 1, BITTERS = 1, SUGARS = 1)
	result_amount = 5

/datum/chemical_reaction/espressomartini
	name = "Espresso Martini"
	id = ESPRESSOMARTINI
	result = ESPRESSOMARTINI
	required_reagents = list(VODKA = 1, ESPRESSO = 1)
	result_amount = 2

/datum/chemical_reaction/kamikaze
	name = "Kamikaze"
	id = KAMIKAZE
	result = KAMIKAZE
	required_reagents = list(VODKA = 1, TRIPLESEC = 1, LIMEJUICE = 1)
	result_amount = 3

/datum/chemical_reaction/mojito
	name = "Mojito"
	id = MOJITO
	result = MOJITO
	required_reagents = list(RUM = 2, SUGARS = 1, SODAWATER = 1, LIMEJUICE = 1)
	result_amount = 5

/datum/chemical_reaction/whiskeytonic
	name = "Whiskey Tonic"
	id = WHISKEYTONIC
	result = WHISKEYTONIC
	required_reagents = list(WHISKEY = 1, TONIC = 1)
	result_amount = 2

/datum/chemical_reaction/cinnamonwhisky
	name = "Cinnamon Whisky"
	id = CINNAMONWHISKY
	result = CINNAMONWHISKY
	required_reagents = list(WHISKEY = 5, CINNAMON = 1)
	result_amount = 5

/datum/chemical_reaction/c4cocktail
	name = "C-4 Cocktail"
	id = C4COCKTAIL
	result = C4COCKTAIL
	required_reagents = list(KAHLUA = 2, CINNAMONWHISKY = 1)
	result_amount = 3

/datum/chemical_reaction/dragonsblood
	name = "Dragon's Blood"
	id = DRAGONSBLOOD
	result = DRAGONSBLOOD
	required_reagents = list(CINNAMONWHISKY = 2, BERRYJUICE = 1)
	result_amount = 3

/datum/chemical_reaction/dragonsspit
	name = "Dragon's Spit"
	id = DRAGONSSPIT
	result = DRAGONSSPIT
	required_reagents = list(CINNAMONWHISKY = 2, CAPSAICIN = 1)
	result_amount = 3

/datum/chemical_reaction/cinnamontoastcocktail
	name = "Cinnamon Toast Cocktail"
	id = CINNAMONTOASTCOCKTAIL
	result = CINNAMONTOASTCOCKTAIL
	required_reagents = list(RUM = 1, CINNAMONWHISKY = 1, CREAM = 1)
	result_amount = 3

/datum/chemical_reaction/fireballcider
	name = "Fireball Cider"
	id = FIREBALLCIDER
	result = FIREBALLCIDER
	required_reagents = list(APPLEJUICE = 2, CINNAMONWHISKY = 1)
	result_amount = 3

/datum/chemical_reaction/manhattanfireball
	name = "Manhattan Fireball"
	id = MANHATTANFIREBALL
	result = MANHATTANFIREBALL
	required_reagents = list(CINNAMONWHISKY = 2, VERMOUTH = 1)
	result_amount = 3

/datum/chemical_reaction/fireballcola
	name = "Fireball Cola"
	id = FIREBALLCOLA
	result = FIREBALLCOLA
	required_reagents = list(CINNAMONWHISKY = 2, COLA = 1)
	result_amount = 3

/datum/chemical_reaction/firerita
	name = "Fire-rita"
	id = FIRERITA
	result = FIRERITA
	required_reagents = list(CINNAMONWHISKY = 1, TRIPLESEC = 1, TEQUILA = 3)
	result_amount = 5

/datum/chemical_reaction/magica
	name = "Magica"
	id = MAGICA
	result = MAGICA
	required_reagents = list(CINNAMONWHISKY = 1, BITTERS = 1)
	result_amount = 2

/datum/chemical_reaction/magicadeluxe
	name = "Magica Deluxe"
	id = MAGICADELUXE
	result = MAGICADELUXE
	required_reagents = list(MAGICA = 1, KARMOTRINE = 1)
	result_amount = 1

//Cafe stuff!
/datum/chemical_reaction/acidtea
	name = "Earl's Grey Tea"
	id = ACIDTEA
	result = ACIDTEA
	required_reagents = list(SACIDS = 1, TEA = 1)
	result_amount = 2

/datum/chemical_reaction/chifir
	name = "Chifir"
	id = CHIFIR
	result = CHIFIR
	required_reagents = list(TEA = 5, REDTEA = 5, GREENTEA = 5)
	result_amount = 15

/datum/chemical_reaction/yinyang
	name = "Zen Tea"
	id = YINYANG
	result = YINYANG
	required_reagents = list(TEA = 5, NOTHING = 5)
	result_amount = 10

/datum/chemical_reaction/singularitea
	name = "Singularitea"
	id = SINGULARITEA
	result = SINGULARITEA
	required_reagents = list(RADIUM = 1, TEA = 5, REDTEA = 5)
	result_amount = 10

/datum/chemical_reaction/gyro
	name = "Gyro"
	id = GYRO
	result = GYRO
	required_reagents = list(GREENTEA = 5, WHISKEY = 5, IRON = 1)
	result_amount = 10

/datum/chemical_reaction/plasmatea
	name = "Plasma Pekoe"
	id = PLASMATEA
	result = PLASMATEA
	required_reagents = list(TEA = 5, PLASMA = 5)
	result_amount = 10

/datum/chemical_reaction/espresso
	name = "Espresso"
	id = ESPRESSO
	result = ESPRESSO
	required_reagents = list(COFFEE = 1, WATER = 1)
	result_amount = 2

/datum/chemical_reaction/cappuccino
	name = "Cappuccino"
	id = CAPPUCCINO
	result = CAPPUCCINO
	required_reagents = list(ESPRESSO = 1, CREAM = 1)
	result_amount = 2

/datum/chemical_reaction/tonio
	name = "Tonio"
	id = TONIO
	result = TONIO
	required_reagents = list(COFFEE = 5, LIMEJUICE = 1, TOMATOJUICE = 1, LEMONJUICE = 1, WATERMELONJUICE = 1, HONEY = 1)
	result_amount = 10

/datum/chemical_reaction/doppio
	name = "Doppio"
	id = DOPPIO
	result = DOPPIO
	required_reagents = list(COFFEE = 5, REDTEA = 5, GREENTEA = 5)
	result_amount = 10

/datum/chemical_reaction/passione
	name = "Passione"
	id = PASSIONE
	result = PASSIONE
	required_reagents = list(CAPPUCCINO = 5, GOLD = 1, HONEY =5)
	result_amount = 10

/datum/chemical_reaction/seccoffee
	name = "Wake-Up Call"
	id = SECCOFFEE
	result = SECCOFFEE
	required_reagents = list(COFFEE = 5, SPRINKLES = 1, BEEPSKYSMASH = 5)
	result_amount = 10

/datum/chemical_reaction/engicoffee
	name = "NT Standard Battery Acid"
	id = ENGICOFFEE
	result = ENGICOFFEE
	required_reagents = list(COFFEE = 5, FUEL = 1, SACID = 5)
	result_amount = 10

/datum/chemical_reaction/medcoffee
	name = "Lifeline"
	id = MEDCOFFEE
	result = MEDCOFFEE
	required_reagents = list(COFFEE = 5, DOCTORSDELIGHT = 5, BLOOD = 1)
	result_amount = 10

/datum/chemical_reaction/detcoffee
	name = "Joe"
	id = DETCOFFEE
	result = DETCOFFEE
	required_reagents = list(COFFEE = 5, WHISKEY = 5)
	result_amount = 5

/datum/chemical_reaction/etank
	name = "Recharger"
	id = ETANK
	result = ETANK
	required_reagents = list(COFFEE = 1, IRON = 1, LITHIUM = 1, FUEL = 1, ALUMINUM = 1)
	result_amount = 5

/datum/chemical_reaction/greytea
	name = "Tide"
	id = GREYTEA
	result = GREYTEA
	required_reagents = list(WATER = 5, FUEL = 5)
	result_amount = 10

/datum/chemical_reaction/citalopram
	name = "Citalopram"
	id = CITALOPRAM
	result = CITALOPRAM
	required_reagents = list(MINDBREAKER = 1, CARBON = 1)
	result_amount = 3

/datum/chemical_reaction/paroxetine
	name = "Paroxetine"
	id = PAROXETINE
	result = PAROXETINE
	required_reagents = list(MINDBREAKER = 1, OXYGEN = 1, INAPROVALINE = 1)
	result_amount = 3

/datum/chemical_reaction/sheer_heart_attack
	name = "hardcore induced heart attack"
	id = MEDCORES
	result = CHEESYGLOOP
	required_reagents = list(MEDCORES = 0.1, HYPERZINES = 0.1)
	result_amount = 2

/datum/chemical_reaction/lithotorcrazine
	name = "Lithotorcrazine"
	id = LITHOTORCRAZINE
	result = LITHOTORCRAZINE
	required_reagents = list(LITHIUM = 1, ARITHRAZINE = 3, URANIUM = 1)
	result_amount = 5

/datum/chemical_reaction/lithotorcrazine_better
	name = "Improved Lithotorcrazine recipe"
	id = LITHOTORCRAZINE
	result = LITHOTORCRAZINE
	required_reagents = list(LITHIUM = 1, HYRONALIN = 1, INAPROVALINE = 1)
	required_catalysts = list(ROACHSHELL = 1, LITHOTORCRAZINE = 1)
	result_amount = 10

/datum/chemical_reaction/hemoscyanine
	name = "Hemoscyanine"
	id = HEMOSCYANINE
	result = HEMOSCYANINE
	required_reagents = list(SOLANINE = 1, HYOSCYAMINE = 1, PHENOL = 1)
	result_amount = 1

/datum/chemical_reaction/anthracene
	name = "Anthracene"
	id = ANTHRACENE
	result = ANTHRACENE
	required_reagents = list(ZEAXANTHIN = 1, RADIUM = 1)
	result_amount = 2

/datum/chemical_reaction/apetrine
	name = "Apetrine"
	id = APETRINE
	result = APETRINE
	required_reagents = list(PETRITRICIN = 2, PACIDS = 3)
	result_amount = 1

/datum/chemical_reaction/potassiumcarbonate
	name = "Potassium Carbonate"
	id = POTASSIUMCARBONATE
	result = POTASSIUMCARBONATE
	required_reagents = list(POTASSIUM = 2, CARBON = 1, OXYGEN = 3)
	result_amount = 1

/datum/chemical_reaction/active_charcoal
	name = "Activated Charcoal"
	id = CHARCOAL
	result = CHARCOAL
	required_reagents = list(CARBON = 1, SACIDS = 2)
	required_temp = T0C + 450
	result_amount = 1

/datum/chemical_reaction/caramel
	name = "Heated Sugar"
	id = CARAMEL
	result = CARAMEL
	required_reagents = list(SUGARS = 1)
	required_temp = T0C + 170
	result_amount = 1

/datum/chemical_reaction/albuterol
	name = "Albuterol"
	id = ALBUTEROL
	result = ALBUTEROL
	required_reagents = list(TRAMADOL = 1, HYPERZINES = 1)
	result_amount = 2

/datum/chemical_reaction/saltwater
	name = "Salt Water"
	id = SALTWATER
	result = SALTWATER
	required_reagents = list(WATER = 20, SODIUMCHLORIDE = 5)
	result_amount = 20

/datum/chemical_reaction/saline
	name = "Saline"
	id = SALINE
	result = SALINE
	required_reagents = list(SALTWATER = 10, AMMONIA = 1)
	result_amount = 10

/datum/chemical_reaction/calciumhydroxide
	name = "Calcium Hydroxide"
	id = CALCIUMHYDROXIDE
	result = CALCIUMHYDROXIDE
	required_reagents = list(WATER = 1, CALCIUMOXIDE = 1)
	result_amount = 1
	reaction_temp_change = 47
	react_discretely = TRUE

/datum/chemical_reaction/sodium_silicate
	name = "Sodium Silicate"
	id = SODIUMSILICATE
	result = SODIUMSILICATE
	required_reagents = list(SODIUM = 2, SILICON = 1, OXYGEN = 3)
	result_amount = 5


/datum/chemical_reaction/untable
	name = "Untable Mutagen"
	id = UNTABLE_MUTAGEN
	result = UNTABLE_MUTAGEN
	required_reagents = list(FORMIC_ACID = 1, PHENOL = 1, RADIUM = 1)
	result_amount = 3

//Karmotrine Drinks

/datum/chemical_reaction/smokyroom
	name = "Smoky Room"
	id = SMOKYROOM
	result = SMOKYROOM
	required_reagents = list(MANHATTAN = 1, ICE = 1, KARMOTRINE = 2)
	result_amount = 4

/datum/chemical_reaction/ragstoriches
	name = "Rags to Riches"
	id = RAGSTORICHES
	result = RAGSTORICHES
	required_reagents = list(VODKA = 1, COGNAC = 1, KARMOTRINE = 3)
	result_amount = 5

/datum/chemical_reaction/badtouch
	name = "Bad Touch"
	id = BAD_TOUCH
	result = BAD_TOUCH
	required_reagents = list(RUM = 2, KAHLUA = 1, ICE = 1, KARMOTRINE = 1)
	result_amount = 5

/datum/chemical_reaction/electricsheep
	name = "Electric Sheep"
	id = ELECTRIC_SHEEP
	result = ELECTRIC_SHEEP
	required_reagents = list(WINE = 1, SILICON = 1, KARMOTRINE = 3)
	result_amount = 5

/datum/chemical_reaction/suicide
	name = "Suicide"
	id = SUICIDE
	result = SUICIDE
	required_reagents = list(SPACEMOUNTAINWIND = 1, DR_GIBB = 1, COLA = 1, LEMON_LIME = 1, KARMOTRINE = 1)
	result_amount = 5

/datum/chemical_reaction/scientistsserendipity
	name = "Scientist's Serendipity"
	id = SCIENTISTS_SERENDIPITY
	result = SCIENTISTS_SERENDIPITY
	required_reagents = list(MOONROCKS = 1, KARMOTRINE = 1)
	result_amount = 2

/datum/chemical_reaction/metabuddy
	name = "Metabuddy"
	id = METABUDDY
	result = METABUDDY
	required_reagents = list(TONIC = 2, KARMOTRINE = 3)
	result_amount = 5

/datum/chemical_reaction/waifu
	name = "Waifu"
	id = WAIFU
	result = WAIFU
	required_reagents = list(SAKE = 1, KARMOTRINE = 4)
	result_amount = 5

/datum/chemical_reaction/husbando
	name = "Husbando"
	id = HUSBANDO
	result = HUSBANDO
	required_reagents = list(MANLYDORF = 1, KARMOTRINE = 4)
	result_amount = 5

/datum/chemical_reaction/tomboy
	name = "Tomboy"
	id = TOMBOY
	result = TOMBOY
	required_reagents = list(HUSBANDO = 1, WAIFU = 1)
	result_amount = 2

/datum/chemical_reaction/beepskyclassic
	name = "Beepsky Classic"
	id = BEEPSKY_CLASSIC
	result = BEEPSKY_CLASSIC
	required_reagents = list(BEEPSKYSMASH = 2, KARMOTRINE = 3)
	result_amount = 5

/datum/chemical_reaction/spider
	name = "Spiders"
	id = SPIDERS
	result = SPIDERS
	required_reagents = list(CLONEXADONE = 3, KARMOTRINE = 2)
	result_amount = 5

/datum/chemical_reaction/weedeater
	name = "Weed Eater"
	id = WEED_EATER
	result = WEED_EATER
	required_reagents = list(SPACE_DRUGGS = 1, AMATOXIN = 1, PSILOCYBIN = 1, KARMOTRINE = 2)
	result_amount = 5

/datum/chemical_reaction/gravsingulo
	name = "Gravitational Singulo"
	id = GRAVSINGULO
	result = GRAVSINGULO
	required_reagents = list(SINGULO = 1, KARMOTRINE = 4)
	result_amount = 1

/datum/chemical_reaction/gravsingularitea
	name = "Gravitational Singularitea"
	id = GRAVSINGULARITEA
	result = GRAVSINGULARITEA
	required_reagents = list(SINGULARITEA = 1, KARMOTRINE = 4)
	result_amount = 1

/datum/chemical_reaction/lemonlime
	name = "Lemon Lime"
	id = LEMON_LIME
	result = LEMON_LIME
	required_reagents = list(LIMEJUICE = 1, LEMONJUICE = 1, SODAWATER = 1)
	result_amount = 3

/datum/chemical_reaction/monstermash
	name = "monstermash"
	id = MONSTERMASH
	result = MONSTERMASH
	required_reagents = list(ECTOPLASM = 1, CARAMEL = 1, TOMATOJUICE = 1)
	result_amount = 3

/datum/chemical_reaction/eggnog
	name = "Eggnog"
	id = EGGNOG
	result = EGGNOG
	required_reagents = list(MILK = 2, CREAM = 1, EGG_YOLK = 0.4)
	result_amount = 3

/datum/chemical_reaction/festive_eggnog
	name = "Festive Eggnog"
	id = FESTIVE_EGGNOG
	result = FESTIVE_EGGNOG
	required_reagents = list(EGGNOG = 1, RUM = 1, CINNAMON = 0.1)
	result_amount = 2

/datum/chemical_reaction/diy_soda
	name = "Dr. Pecker's DIY Soda"
	id = DIY_SODA
	result = DIY_SODA
	required_reagents = list(LEMON_LIME = 1, SODAWATER = 1, INACUSIATE = 1) //this soda tastes like ear medicine!
	result_amount = 3

/datum/chemical_reaction/diy_soda/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(holder.get_reagent_amount(DIY_SODA) == 90) //apparently this gets called AFTER the reaction is done reacting
		var/obj/effect/smoke/S = new /obj/effect/smoke(get_turf(holder.my_atom))
		S.time_to_live = 5 //unusually short smoke
		//We don't need to start up the system because we only want to smoke one tile.

/datum/chemical_reaction/colorful_reagent
	name = "Colorful Reagent"
	id = COLORFUL_REAGENT
	result = COLORFUL_REAGENT
	required_reagents = list(MESCALINE = 1, PSILOCYBIN = 1, AMATOXIN = 1)
	result_amount = 3

/datum/chemical_reaction/black_food_coloring
	name = "Black Food Coloring"
	id = BLACKCOLOR
	result = BLACKCOLOR
	required_reagents = list(COLORFUL_REAGENT = 1, CARBON = 1)
	result_amount = 2

/datum/chemical_reaction/degeneratecalcium
	name = "Degenerate Calcium"
	id = DEGENERATECALCIUM
	result = DEGENERATECALCIUM
	required_reagents = list(MILK = 1, MUTAGEN = 1)
	required_temp = T0C + 88
	result_amount = 1

/datum/chemical_reaction/ironrot
	name = "Ironrot"
	id = IRONROT
	result = IRONROT
	required_reagents = list(AMANATIN = 1, RADIUM = 1, IRON = 1)
	result_amount = 3

/datum/chemical_reaction/aminomicin
	name = "Aminomicin"
	id = AMINOMICIN
	result = AMINOMICIN
	required_reagents = list(CLONEXADONE = 1, MUTAGEN = 1, ENZYME = 1)
	result_amount = 1

/datum/chemical_reaction/synthparrot
	name = "Synthparrot"
	id = "synthparrot"
	result = null
	required_reagents = list(NUTRIMENT = 1, AMINOMICIN = 1)
	result_amount = 1
	required_container = /obj/item/weapon/reagent_containers/food/snacks/cracker

/datum/chemical_reaction/synthparrot/on_reaction(var/datum/reagents/holder)
	var/location = get_turf(holder.my_atom)
	new /mob/living/simple_animal/parrot(location)
	qdel(holder.my_atom)

/datum/chemical_reaction/synthmob //to cut down in duplicate code
	name = null
	id = null
	result = null
	result_amount = 1
	var/mob2spawn = null

/datum/chemical_reaction/synthmob/on_reaction(var/datum/reagents/holder, var/created_volume)
	set waitfor = FALSE //makes sleep() work like spawn()
	if(ishuman(holder.my_atom))
		//This is intended to be an appendicitis fake-out using the same messages. And I guess an alien embryo message at the end.
		var/mob/living/carbon/human/H = holder.my_atom
		sleep(rand(5 SECONDS, 10 SECONDS))
		to_chat(H, "<span class='warning'>You feel a stinging pain in your abdomen!</span>")
		H.emote("me",1,"winces slightly.")
		sleep(rand(10 SECONDS, 20 SECONDS))
		to_chat(H, "<span class='warning'>You feel a stabbing pain in your abdomen!</span>")
		H.emote("me",1,"winces painfully.")
		H.adjustToxLoss(1)
		sleep(rand(5 SECONDS, 10 SECONDS))
		to_chat(H, "<span class='danger'>You feel something tearing its way out of your stomach...</span>")
		H.apply_damage(2*created_volume, BRUTE, LIMB_CHEST)
		sleep(rand(5 SECONDS, 10 SECONDS))
		H.vomit(instant = TRUE) //mouse spawning continues below
	var/location = get_turf(holder.my_atom)
	for(var/i=1 to created_volume)
		new mob2spawn(location)

/datum/chemical_reaction/synthmobhostile //to cut down in duplicate code
	name = null
	id = null
	result = null
	result_amount = 1
	var/mob2spawnA = null
	var/mob2spawnB = null

/datum/chemical_reaction/synthmobhostile/on_reaction(var/datum/reagents/holder, var/created_volume)
	set waitfor = FALSE //makes sleep() work like spawn()
	var/location
	if(ishuman(holder.my_atom))
		var/mob/living/carbon/human/H = holder.my_atom
		switch(created_volume)
			if(1)
				to_chat(H, "<span class='danger'>You feel something tearing its way out of your stomach...</span>")
				H.apply_damage(15, BRUTE, LIMB_CHEST)
				sleep(rand(5 SECONDS, 10 SECONDS))
				H.vomit(instant = TRUE)
			if(2 to 3)
				to_chat(H, "<span class='danger'>You feel something violently tear its way out of your stomach!</span>")
				var/datum/organ/external/E = H.get_organ(LIMB_CHEST)
				E.createwound(CUT, 40)
				playsound(H, get_sfx("gib"),50,1)
			if(4 to 5)
				to_chat(H, "<span class='danger'>You feel something violently expanding inside your chest!</span>")
				var/datum/organ/external/E = H.get_organ(LIMB_CHEST)
				for(var/datum/organ/internal/I in E.internal_organs)
					I.take_damage(rand(I.min_bruised_damage, I.min_broken_damage+1))
				E.fracture()
				E.createwound(CUT, 60)
				playsound(H, get_sfx("gib"),50,1)
			if(6 to INFINITY)
				to_chat(H, "<span class='warning'>Something smells nasty...</span>")
				sleep(rand(5 SECONDS, 10 SECONDS))
				location = get_turf(holder.my_atom)
				H.gib()
	else if(ismonkey(holder.my_atom))
		var/mob/living/carbon/monkey/M = holder.my_atom
		location = get_turf(holder.my_atom)
		M.gib()
	if(!location)
		location = get_turf(holder.my_atom)
	for(var/i=1 to created_volume)
		if(prob(80)) //here so aminoblatella can spawn its two variants of roach on the mutagen reaction, does not affect aminocyprinidol, since that only makes baby carps
			new mob2spawnA(location)
		else
			new mob2spawnB(location)

/datum/chemical_reaction/synthmob/synthmouse
	name = "Synthmouse"
	id = "synthmouse"
	result = null
	required_reagents = list(NUTRIMENT = 3, AMINOMICIN = 1)
	result_amount = 1
	mob2spawn = /mob/living/simple_animal/mouse/common

/datum/chemical_reaction/aminomician
	name = "Aminomician"
	id = AMINOMICIAN
	result = AMINOMICIAN
	required_reagents = list(AMINOMICIN = 1, BONEMARROW = 3)
	result_amount = 1

/datum/chemical_reaction/synthmob/synthcorgi
	name = "Synthcorgi"
	id = "synthcorgi"
	result = null
	required_reagents = list(NUTRIMENT = 3, AMINOMICIAN = 1)
	result_amount = 1
	mob2spawn = /mob/living/simple_animal/corgi/puppy

/datum/chemical_reaction/aminocyprinidol
	name = "Aminocyprinidol"
	id = AMINOCYPRINIDOL
	result = AMINOCYPRINIDOL
	required_reagents = list(AMINOMICIN = 1, CARPPHEROMONES = 5)
	result_amount = 1

/datum/chemical_reaction/synthmobhostile/synthcarp
	name = "Synthcarp"
	id = "synthcarp"
	result = null
	required_reagents = list(NUTRIMENT = 10, AMINOCYPRINIDOL = 1)
	result_amount = 1
	mob2spawnA = /mob/living/simple_animal/hostile/carp/baby
	mob2spawnB = /mob/living/simple_animal/hostile/carp/baby

/datum/chemical_reaction/aminoblatella
	name = "Aminoblatella"
	id = AMINOBLATELLA
	result = AMINOBLATELLA
	required_reagents = list(AMINOMICIN = 1, ROACHSHELL = 5)
	result_amount = 1

/datum/chemical_reaction/synthmob/synthroach
	name = "Synthroach"
	id = "synthroach"
	result = null
	required_reagents = list(NUTRIMENT = 1, AMINOBLATELLA = 1)
	result_amount = 3 //so you get 3 roaches per reaction
	mob2spawn = /mob/living/simple_animal/cockroach

/datum/chemical_reaction/synthmobhostile/synthmutroach
	name = "Synthmutroach"
	id = "synthmutroach"
	result = null
	required_reagents = list(MUTAGEN = 10, AMINOBLATELLA = 1)
	result_amount = 1
	mob2spawnA = /mob/living/simple_animal/hostile/bigroach
	mob2spawnB = /mob/living/simple_animal/hostile/bigroach/queen //greater odds than getting a queen via mutating roaches (0.5%)

/datum/chemical_reaction/ectoplasm
	name = "Ectoplasm"
	id = ECTOPLASM
	result = ECTOPLASM
	required_reagents = list(AMINOMICIAN = 1, FROSTOIL = 1)
	result_amount = 1

/datum/chemical_reaction/synthskeleton
	name = "Synthskeleton"
	id = "synthskeleton"
	result = null
	required_reagents = list(ECTOPLASM = 1, DEGENERATECALCIUM = 10)
	result_amount = 1
	var/skelPowerLimiter = 200

/datum/chemical_reaction/synthskeleton/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(ishuman(holder.my_atom))
		var/mob/living/carbon/human/H = holder.my_atom
		if(created_volume <= 9)
			for(var/i = 1 to created_volume)
				var/L = get_turf(holder.my_atom)
				new /mob/living/simple_animal/hostile/humanoid/skellington(L)
				var/datum/organ/external/E = pick(H.organs)
				E.fracture() //Hopefully this means that under 10u the skellingtons still get spawned, but AT 10u you turn into one.
		else
			if(isskellington(H) || isskelevox(H) || islich(H))
				bigBoned(H, created_volume)
			if(isvox(H))						//Copy paste of the melt power, ack ack
				H.set_species("Skeletal Vox")
				H.regenerate_icons()
				H.visible_message("<span class='danger'>[H.name]'s skeleton jumps right out of their skin, forcefully!</span>")
				H.drop_all()
			else if(H.set_species("Skellington"))
				H.regenerate_icons()
				H.visible_message("<span class='danger'>[H.name]'s skeleton jumps right out of their skin, forcefully!</span>")
				H.drop_all()
			gibs(H.loc, H.virus2, H.dna)
	else
		for(var/i = 1 to created_volume)
			var/L = get_turf(holder.my_atom)
			new /mob/living/simple_animal/hostile/humanoid/skellington(L) //Should spawn skeletons normally if the holder isn't human.

/datum/chemical_reaction/synthskeleton/proc/bigBoned(var/mob/living/carbon/human/theSkel, var/volume)
	for(var/datum/organ/external/E in theSkel.organs)
		if(!E.is_organic() || (E.min_broken_damage >= E.max_damage))
			continue
		if(E.max_damage < skelPowerLimiter)
			E.max_damage++
		E.min_broken_damage += volume
		if(E.min_broken_damage >= E.max_damage)
			E.min_broken_damage = E.max_damage
		theSkel.visible_message("<span class='danger'>[theSkel] rattles and shakes!</span>")

/datum/chemical_reaction/synthgingerbone
	name = "Synthgingerbone"
	id = "synthgingerbone"
	result = null
	required_reagents = list(ECTOPLASM = 1, CARAMEL = 5)
	result_amount = 1
	required_container = /obj/item/weapon/reagent_containers/food/snacks/gingerbread_man

/datum/chemical_reaction/synthgingerbone/on_reaction(var/datum/reagents/holder)
	var/L = get_turf(holder.my_atom)
	new /mob/living/simple_animal/hostile/ginger/gingerboneman(L)
	qdel(holder.my_atom)

/datum/chemical_reaction/midazoline
	name = "Midazoline"
	id = MIDAZOLINE
	result = MIDAZOLINE
	required_reagents = list(SACIDS = 1, CLONEXADONE = 1, GOLD = 1)
	result_amount = 1 //This effectively just changes the amount of gold powder you get from electrolyzing

/datum/chemical_reaction/midazoline/required_condition_check(datum/reagents/holder)
	if(istype(holder.my_atom, /obj/item/weapon/reagent_containers))
		return (locate(/obj/item/stack/sheet/mineral/plasma) in holder.my_atom.contents)
	return 0

/datum/chemical_reaction/midazoline_dissolve
	name = "Midazoline-to-Mercury"
	id = "midazoline2mercury"
	result = MERCURY
	required_reagents = list(MIDAZOLINE = 0.1, MERCURY = 0.1)
	result_amount = 0.2

/datum/chemical_reaction/midazoline_dissolve/on_reaction(var/datum/reagents/holder, var/created_volume)
	..()
	for(var/datum/reagent/self_replicating/midazoline/R in holder.reagent_list)
		holder.convert_some_of_type(/datum/reagent/self_replicating/midazoline, /datum/reagent/mercury, R.volume) //Convert ALLL of it, even that last 0.01u (don't leave 0.042857u behind)

/datum/chemical_reaction/locutogen
	name = "Locutogen"
	id = LOCUTOGEN
	result = LOCUTOGEN
	required_reagents = list(PICCOLYN = 1, INACUSIATE = 1, SUGARS = 1)
	result_amount = 3

/datum/chemical_reaction/bumcivilian //same reaction type as midazoline, you must dunk the iron sheet on sacid to get bumcivillian
	name = "Bumcivilian"
	id = BUMCIVILIAN
	result = BUMCIVILIAN
	required_reagents = list(SACIDS = 1)
	result_amount = 1

/datum/chemical_reaction/bumcivilian/required_condition_check(datum/reagents/holder)
	if(istype(holder.my_atom, /obj/item/weapon/reagent_containers))
		return (locate(/obj/item/stack/sheet/metal) in holder.my_atom.contents)
	return 0

/datum/chemical_reaction/bumcivilian/on_reaction(var/datum/reagents/holder, var/created_volume)
	..()
	var/atom/A = get_holder_at_turf_level(holder.my_atom)
	holder.my_atom.visible_message("<span class='warning'>Suddenly, everything around [A ? "\the [A] " : "\the [holder.my_atom] "]becomes perfectly silent...</span>")
	var/datum/reagent/bumcivilian/B = locate(/datum/reagent/bumcivilian) in holder.reagent_list
	for(var/turf/T in view(get_turf(holder.my_atom)))
		T.mute_time = world.time + B.mute_duration

/datum/chemical_reaction/random
	name = "Random chemical"
	id = "random"
	result = null
	required_reagents = list(NOTHING = 10, PHAZON = 10)
	required_catalysts = list(MUTAGEN = 10, ENZYME = 10)
	result_amount = 1

/datum/chemical_reaction/fake_creep // Xenomorph weeds aka creep.
	name = "Dan's Purple Drank"
	id = FAKE_CREEP
	result = FAKE_CREEP
	required_reagents = list(MUTAGEN = 1, PLASMA = 1, DISCOUNT = 1)
	result_amount = 3

/datum/chemical_reaction/random/on_reaction(var/datum/reagents/holder, var/created_volume)
	..()
	if(prob(50)) // Half chance to start another chemical reaction
		var/our_id = pick(chemical_reactions_list)
		var/datum/chemical_reaction/new_reaction = pick(chemical_reactions_list[our_id])
		holder.handle_reaction(new_reaction,TRUE,created_volume)
	else // Or else just spawn a new chem
		var/list/blocked_chems = list(ADMINORDRAZINE, PROCIZINE, BLOCKIZINE, PAISMOKE) // Bad ideas to spawn
		var/list/allowed_reagents = chemical_reagents_list - blocked_chems
		holder.add_reagent(pick(allowed_reagents),created_volume)

/datum/chemical_reaction/punctualite
	name = "Punctualite"
	id = PUNCTUALITE
	result = PUNCTUALITE
	required_reagents = list(HYPERZINE = 10, FUEL = 10)
	required_catalysts = list(ZOMBIEPOWDER = 5)
	result_amount = 5

#undef ALERT_AMOUNT_ONLY
#undef ALERT_ALL_REAGENTS
