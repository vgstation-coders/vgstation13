///////////////////////////////////////////////////////////////////////////////////
datum
	chemical_reaction
		var/name = null
		var/id = null
		var/result = null
		var/list/required_reagents = new/list()
		var/list/required_catalysts = new/list()

		// Both of these variables are mostly going to be used with slime cores - but if you want to, you can use them for other things
		var/atom/required_container = null // the container required for the reaction to happen
		var/required_other = 0 // an integer required for the reaction to happen

		var/result_amount = 0
		var/secondary = 0 // set to nonzero if secondary reaction
		var/list/secondary_results = list()		//additional reagents produced by the reaction
		var/requires_heating = 0

		// /vg/: Send admin alerts with standardized code.
		proc/send_admin_alert(var/datum/reagents/holder, var/reaction_name=src.name)
			var/message_prefix = "\A [reaction_name] reaction has occured"
			var/message="[message_prefix]"
			var/atom/A = holder.my_atom
			if(A)
				var/turf/T = get_turf(A)
				var/area/my_area = get_area(T)

				message += " in [formatJumpTo(T)]. (<A HREF='?_src_=vars;Vars=\ref[A]'>VV</A>)"
				var/mob/M = get(A, /mob)
				if(M)
					message += " - Carried By: [M.real_name] ([M.key]) (<A HREF='?_src_=holder;adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>)"
					log_game("[message_prefix] in [my_area.name] ([T.x],[T.y],[T.z]) - Carried by [M.real_name] ([M.key])")
				else
					message += " - Last Fingerprint: [(A.fingerprintslast ? A.fingerprintslast : "N/A")]"
					log_game("[message_prefix] in [my_area.name] ([T.x],[T.y],[T.z]) - last fingerprint  [(A.fingerprintslast ? A.fingerprintslast : "N/A")]")
			else
				message += "."
			message_admins(message, 0, 1)

		proc/on_reaction(var/datum/reagents/holder, var/created_volume)
			return

		//I recommend you set the result amount to the total volume of all components.

		explosion_potassium
			name = "Explosion"
			id = "explosion_potassium"
			result = null
			required_reagents = list("water" = 1, "potassium" = 1)
			result_amount = 2
			on_reaction(var/datum/reagents/holder, var/created_volume)
				send_admin_alert(holder, reaction_name="water/potassium explosion")
				var/datum/effect/effect/system/reagents_explosion/e = new()
				e.set_up(round (created_volume/10, 1), holder.my_atom, 0, 0)
				e.holder_damage(holder.my_atom)
				if(isliving(holder.my_atom))
					e.amount *= 0.5
					var/mob/living/L = holder.my_atom
					if(L.stat!=DEAD)
						e.amount *= 0.5
				e.start()
				holder.clear_reagents()
				return

		creatine
			name = "Creatine"
			id = "creatine"
			result = "creatine"
			required_reagents = list("nutriment"=1, "bicaridine"=1, "hyperzine"=1, "mutagen"=1)
			result_amount = 2

		discount
			name = "Discount Dan's Special Sauce"
			id = "discount"
			result = "discount"
			required_reagents = list("irradiatedbeans"=1, "toxicwaste"=1, "refriedbeans"=1, "mutatedbeans"=1, "beff"=1, "horsemeat"=1,"moonrocks"=1, "offcolorcheese"=1, "bonemarrow"=1, "greenramen"=1, "glowingramen"=1, "deepfriedramen"=1)
			result_amount = 12

		peptobismol
			name = "Peptobismol"
			id = "peptobismol"
			result = "peptobismol"
			required_reagents = list("anti_toxin"=1, "discount"=1)
			result_amount = 2

		emp_pulse
			name = "EMP Pulse"
			id = "emp_pulse"
			result = null
			required_reagents = list("uranium" = 1, "iron" = 1) // Yes, laugh, it's the best recipe I could think of that makes a little bit of sense
			result_amount = 2

			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				// 100 created volume = 4 heavy range & 7 light range. A few tiles smaller than traitor EMP grandes.
				// 200 created volume = 8 heavy range & 14 light range. 4 tiles larger than traitor EMP grenades.
				empulse(location, round(created_volume / 24), round(created_volume / 14), 1)
				holder.clear_reagents()
				return

		silicate
			name = "Silicate"
			id = "silicate"
			result = "silicate"
			required_reagents = list("aluminum" = 1, "silicon" = 1, "oxygen" = 1)
			result_amount = 9

		phalanximine
			name = "Phalanximine"
			id = "phalanximine"
			result = "phalanximine"
			required_reagents = list("arithrazine" = 1, "diethylamine" = 1, "mutagen" = 1)
			result_amount = 1

		stoxin
			name = "Sleep Toxin"
			id = "stoxin"
			result = "stoxin"
			required_reagents = list("chloralhydrate" = 1, "sugar" = 4)
			result_amount = 5

		sterilizine
			name = "Sterilizine"
			id = "sterilizine"
			result = "sterilizine"
			required_reagents = list("ethanol" = 1, "anti_toxin" = 1, "chlorine" = 1)
			result_amount = 3

		inaprovaline
			name = "Inaprovaline"
			id = "inaprovaline"
			result = "inaprovaline"
			required_reagents = list("oxygen" = 1, "carbon" = 1, "sugar" = 1)
			result_amount = 3

		anti_toxin
			name = "Anti-Toxin (Dylovene)"
			id = "anti_toxin"
			result = "anti_toxin"
			required_reagents = list("silicon" = 1, "potassium" = 1, "nitrogen" = 1)
			result_amount = 3

		mutagen
			name = "Unstable mutagen"
			id = "mutagen"
			result = "mutagen"
			required_reagents = list("radium" = 1, "phosphorus" = 1, "chlorine" = 1)
			result_amount = 3

		tramadol
			name = "Tramadol"
			id = "tramadol"
			result = "tramadol"
			required_reagents = list("inaprovaline" = 1, "ethanol" = 1, "oxygen" = 1)
			result_amount = 3

		oxycodone
			name = "Oxycodone"
			id = "oxycodone"
			result = "oxycodone"
			required_reagents = list("ethanol" = 1, "tramadol" = 1, "plasma" = 1)
			result_amount = 1

		//cyanide
		//	name = "Cyanide"
		//	id = "cyanide"
		//	result = "cyanide"
		//	required_reagents = list("hydrogen" = 1, "carbon" = 1, "nitrogen" = 1)
		//	result_amount = 1

/* You attempt to make water by mixing the ingredients for Hydroperoxyl, but you get a big, whopping sum of nothing!
		water //Keeping this commented out for posterity.
			name = "Water"
			id = "water"
			result = null //I can't believe it's not water!
			required_reagents = list("oxygen" = 2, "hydrogen" = 1) //And there goes the atmosphere, thanks greenhouse gases!
			result_amount = 1
*/

		water
			name = "Water"
			id = "water"
			result = "water"
			required_reagents = list("hydrogen" = 2, "oxygen" = 1)
			result_amount = 1

		sacid
			name = "Sulphuric Acid"
			id = "sacid"
			result = "sacid"
			required_reagents = list("sulfur" = 2, "oxygen" = 3, "water" = 2)
			result_amount = 2

		thermite
			name = "Thermite"
			id = "thermite"
			result = "thermite"
			required_reagents = list("aluminum" = 1, "iron" = 1, "oxygen" = 1)
			result_amount = 3

		lexorin
			name = "Lexorin"
			id = "lexorin"
			result = "lexorin"
			required_reagents = list("plasma" = 1, "hydrogen" = 1, "nitrogen" = 1)
			result_amount = 3

		space_drugs
			name = "Space Drugs"
			id = "space_drugs"
			result = "space_drugs"
			required_reagents = list("mercury" = 1, "sugar" = 1, "lithium" = 1)
			result_amount = 3

		lube
			name = "Space Lube"
			id = "lube"
			result = "lube"
			required_reagents = list("water" = 1, "silicon" = 1, "oxygen" = 1)
			result_amount = 4

		pacid
			name = "Polytrinic acid"
			id = "pacid"
			result = "pacid"
			required_reagents = list("sacid" = 1, "chlorine" = 1, "potassium" = 1)
			result_amount = 3

		synaptizine
			name = "Synaptizine"
			id = "synaptizine"
			result = "synaptizine"
			required_reagents = list("sugar" = 1, "lithium" = 1, "water" = 1)
			result_amount = 3

		hyronalin
			name = "Hyronalin"
			id = "hyronalin"
			result = "hyronalin"
			required_reagents = list("radium" = 1, "anti_toxin" = 1)
			result_amount = 2

		arithrazine
			name = "Arithrazine"
			id = "arithrazine"
			result = "arithrazine"
			required_reagents = list("hyronalin" = 1, "hydrogen" = 1)
			result_amount = 2

		impedrezene
			name = "Impedrezene"
			id = "impedrezene"
			result = "impedrezene"
			required_reagents = list("mercury" = 1, "oxygen" = 1, "sugar" = 1)
			result_amount = 2

		kelotane
			name = "Kelotane"
			id = "kelotane"
			result = "kelotane"
			required_reagents = list("silicon" = 1, "carbon" = 1)
			result_amount = 2

		virus_food
			name = "Virus Food"
			id = "virusfood"
			result = "virusfood"
			required_reagents = list("water" = 5, "milk" = 5)
			result_amount = 15

		leporazine
			name = "Leporazine"
			id = "leporazine"
			result = "leporazine"
			required_reagents = list("silicon" = 1, "copper" = 1)
			required_catalysts = list("plasma" = 5)
			result_amount = 2

		cryptobiolin
			name = "Cryptobiolin"
			id = "cryptobiolin"
			result = "cryptobiolin"
			required_reagents = list("potassium" = 1, "oxygen" = 1, "sugar" = 1)
			result_amount = 3

		tricordrazine
			name = "Tricordrazine"
			id = "tricordrazine"
			result = "tricordrazine"
			required_reagents = list("inaprovaline" = 1, "anti_toxin" = 1)
			result_amount = 2

		alkysine
			name = "Alkysine"
			id = "alkysine"
			result = "alkysine"
			required_reagents = list("chlorine" = 1, "nitrogen" = 1, "anti_toxin" = 1)
			result_amount = 2

		dexalin
			name = "Dexalin"
			id = "dexalin"
			result = "dexalin"
			required_reagents = list("oxygen" = 2)
			required_catalysts = list("plasma" = 5)
			result_amount = 1

		dermaline
			name = "Dermaline"
			id = "dermaline"
			result = "dermaline"
			required_reagents = list("oxygen" = 1, "phosphorus" = 1, "kelotane" = 1)
			result_amount = 3

		dexalinp
			name = "Dexalin Plus"
			id = "dexalinp"
			result = "dexalinp"
			required_reagents = list("dexalin" = 1, "carbon" = 1, "iron" = 1)
			result_amount = 3

		bicaridine
			name = "Bicaridine"
			id = "bicaridine"
			result = "bicaridine"
			required_reagents = list("inaprovaline" = 1, "carbon" = 1)
			result_amount = 2

		hyperzine
			name = "Hyperzine"
			id = "hyperzine"
			result = "hyperzine"
			required_reagents = list("sugar" = 1, "phosphorus" = 1, "sulfur" = 1,)
			result_amount = 3

		ryetalyn
			name = "Ryetalyn"
			id = "ryetalyn"
			result = "ryetalyn"
			required_reagents = list("arithrazine" = 1, "carbon" = 1)
			result_amount = 2

		cryoxadone
			name = "Cryoxadone"
			id = "cryoxadone"
			result = "cryoxadone"
			required_reagents = list("dexalin" = 1, "water" = 1, "oxygen" = 1)
			result_amount = 3

		clonexadone
			name = "Clonexadone"
			id = "clonexadone"
			result = "clonexadone"
			required_reagents = list("cryoxadone" = 1, "sodium" = 1)
			required_catalysts = list("plasma" = 5)
			result_amount = 2

		spaceacillin
			name = "Spaceacillin"
			id = "spaceacillin"
			result = "spaceacillin"
			required_reagents = list("cryptobiolin" = 1, "inaprovaline" = 1)
			result_amount = 2

		imidazoline
			name = "imidazoline"
			id = "imidazoline"
			result = "imidazoline"
			required_reagents = list("carbon" = 1, "hydrogen" = 1, "anti_toxin" = 1)
			result_amount = 2

		inacusiate
			name = "inacusiate"
			id = "inacusiate"
			result = "inacusiate"
			required_reagents = list("water" = 1, "carbon" = 1, "anti_toxin" = 1)
			result_amount = 3

		ethylredoxrazine
			name = "Ethylredoxrazine"
			id = "ethylredoxrazine"
			result = "ethylredoxrazine"
			required_reagents = list("oxygen" = 1, "anti_toxin" = 1, "carbon" = 1)
			result_amount = 3

		ethanoloxidation
			name = "ethanoloxidation"	//Kind of a placeholder in case someone ever changes it so that chemicals
			id = "ethanoloxidation"		//	react in the body. Also it would be silly if it didn't exist.
			result = "water"
			required_reagents = list("ethylredoxrazine" = 1, "ethanol" = 1)
			result_amount = 2

		glycerol
			name = "Glycerol"
			id = "glycerol"
			result = "glycerol"
			required_reagents = list("cornoil" = 3, "sacid" = 1)
			result_amount = 1

		nitroglycerin
			name = "Nitroglycerin"
			id = "nitroglycerin"
			result = "nitroglycerin"
			required_reagents = list("glycerol" = 1, "pacid" = 1, "sacid" = 1)
			result_amount = 2
			on_reaction(var/datum/reagents/holder, var/created_volume)
				send_admin_alert(holder, reaction_name="nitroglycerin explosion")
				var/datum/effect/effect/system/reagents_explosion/e = new()
				e.set_up(round (created_volume/2, 1), holder.my_atom, 0, 0)
				e.holder_damage(holder.my_atom)
				if(isliving(holder.my_atom))
					e.amount *= 0.5
					var/mob/living/L = holder.my_atom
					if(L.stat!=DEAD)
						e.amount *= 0.5
				e.start()

				holder.clear_reagents()
				return

		sodiumchloride
			name = "Sodium Chloride"
			id = "sodiumchloride"
			result = "sodiumchloride"
			required_reagents = list("sodium" = 1, "chlorine" = 1)
			result_amount = 2

		flash_powder
			name = "Flash powder"
			id = "flash_powder"
			result = null
			required_reagents = list("aluminum" = 1, "potassium" = 1, "sulfur" = 1 )
			result_amount = null
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(2, 1, location)
				s.start()

				playsound(get_turf(src), 'sound/effects/phasein.ogg', 25, 1)

				var/eye_safety = 0

				for(var/mob/living/carbon/M in viewers(get_turf(holder.my_atom), null))
					if(iscarbon(M))
						eye_safety = M.eyecheck()

					if (get_dist(M, location) <= 3)
						if(eye_safety < 1)
							M.flash_eyes(visual = 1)
							M.Weaken(15)
					else if (get_dist(M, location) <= 5)
						if(eye_safety < 1)
							M.flash_eyes(visual = 1)
							M.Stun(5)

		napalm
			name = "Napalm"
			id = "napalm"
			result = null
			required_reagents = list("aluminum" = 1, "plasma" = 1, "sacid" = 1 )
			result_amount = 1
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/turf/location = get_turf(holder.my_atom.loc)
				for(var/turf/simulated/floor/target_tile in range(0,location))

					var/datum/gas_mixture/napalm = new
					var/datum/gas/volatile_fuel/fuel = new
					fuel.moles = created_volume
					napalm.trace_gases += fuel

					napalm.temperature = 400+T0C
					napalm.update_values()

					target_tile.assume_air(napalm)
					spawn (0) target_tile.hotspot_expose(700, 400,surfaces=1)
				holder.del_reagent("napalm")
				return

		/*
		smoke
			name = "Smoke"
			id = "smoke"
			result = null
			required_reagents = list("potassium" = 1, "sugar" = 1, "phosphorus" = 1 )
			result_amount = null
			secondary = 1
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				var/datum/effect/system/bad_smoke_spread/S = new /datum/effect/system/bad_smoke_spread
				S.attach(location)
				S.set_up(10, 0, location)
				playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
				spawn(0)
					S.start()
					sleep(10)
					S.start()
					sleep(10)
					S.start()
					sleep(10)
					S.start()
					sleep(10)
					S.start()
				holder.clear_reagents()
				return	*/

		chemsmoke
			name = "Chemsmoke"
			id = "chemsmoke"
			result = null
			required_reagents = list("potassium" = 1, "sugar" = 1, "phosphorus" = 1)
			result_amount = null
			secondary = 1
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				var/datum/effect/effect/system/smoke_spread/chem/S = new /datum/effect/effect/system/smoke_spread/chem
				S.attach(location)
				S.set_up(holder, 10, 0, location)
				playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
				spawn(0)
					S.start()
					sleep(10)
					S.start()
				holder.clear_reagents()
				return

		chloralhydrate
			name = "Chloral Hydrate"
			id = "chloralhydrate"
			result = "chloralhydrate"
			required_reagents = list("ethanol" = 1, "chlorine" = 3, "water" = 1)
			result_amount = 1

		zombiepowder
			name = "Zombie Powder"
			id = "zombiepowder"
			result = "zombiepowder"
			required_reagents = list("carpotoxin" = 5, "stoxin" = 5, "copper" = 5)
			result_amount = 2

		rezadone
			name = "Rezadone"
			id = "rezadone"
			result = "rezadone"
			required_reagents = list("carpotoxin" = 1, "cryptobiolin" = 1, "copper" = 1)
			result_amount = 3

		mindbreaker
			name = "Mindbreaker Toxin"
			id = "mindbreaker"
			result = "mindbreaker"
			required_reagents = list("silicon" = 1, "hydrogen" = 1, "anti_toxin" = 1)
			result_amount = 5

		lipozine
			name = "Lipozine"
			id = "Lipozine"
			result = "lipozine"
			required_reagents = list("sodiumchloride" = 1, "ethanol" = 1, "radium" = 1)
			result_amount = 3

		carp_pheromones
			name = "Carp pheromones"
			id = "carppheromones"
			result = "carppheromones"
			required_reagents = list("carpotoxin" = 1, "leporazine" = 1, "carbon" = 1)
			result_amount = 3

		plasmasolidification
			name = "Solid Plasma"
			id = "solidplasma"
			result = null
			required_reagents = list("iron" = 5, "frostoil" = 5, "plasma" = 20)
			result_amount = 1
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				new /obj/item/stack/sheet/mineral/plasma(location)
				return

		plastication
			name = "Plastic"
			id = "solidplastic"
			result = null
			required_reagents = list("pacid" = 10, "plasticide" = 20)
			result_amount = 1
			on_reaction(var/datum/reagents/holder)
				new /obj/item/stack/sheet/mineral/plastic(get_turf(holder.my_atom),10)
				return

/*
		mix_virus
			name = "Mix Virus"
			id = "mixvirus"
			result = "blood"
			required_reagents = list("virusfood" = 5)
			required_catalysts = list("blood")
			var/level = 2

			on_reaction(var/datum/reagents/holder, var/created_volume)

				var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
				if(B && B.data)
					var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
					if(D)
						D.Evolve(level - rand(0, 1))


			mix_virus_2

				name = "Mix Virus 2"
				id = "mixvirus2"
				required_reagents = list("mutagen" = 5)
				level = 4

			rem_virus

				name = "Devolve Virus"
				id = "remvirus"
				required_reagents = list("synaptizine" = 5)

				on_reaction(var/datum/reagents/holder, var/created_volume)

					var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
					if(B && B.data)
						var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
						if(D)
							D.Devolve()
*/
		condensedcapsaicin
			name = "Condensed Capsaicin"
			id = "condensedcapsaicin"
			result = "condensedcapsaicin"
			required_reagents = list("capsaicin" = 1, "ethanol" = 5)
			result_amount = 5

		methylin
			name = "Methylin"
			id = "methylin"
			result = "methylin"
			required_reagents = list("hydrogen" = 1, "chlorine" = 1, "ethanol" = 1)
			required_catalysts = list("fluorine" = 5)
			result_amount = 1

		explosion_bicarodyne
			name = "Explosion"
			id = "explosion_bicarodyne"
			result = null
			required_reagents = list("bicarodyne" = 1, "paracetamol" = 1)
			result_amount = 1
			on_reaction(var/datum/reagents/holder, var/created_volume)
				explosion(get_turf(holder.my_atom),1,2,4)
				holder.clear_reagents()
				return

		nanobots
			name = "Nanobots"
			id = "nanobots"
			result = "nanobots"
			required_reagents = list("nanites" = 1, "uranium" = 10, "gold" = 10, "nutriment" = 10, "silicon" = 10)
			result_amount = 2

		nanobots2
			name = "Nanobots2"
			id = "nanobots2"
			result = "nanobots"
			required_reagents = list("mednanobots" = 1, "cryoxadone" = 2)
			result_amount = 1

		mednanobots
			name = "Medical Nanobots"
			id = "mednanobots"
			result = "mednanobots"
			required_reagents = list("nanobots" = 1, "doctorsdelight" = 5)
			result_amount = 1

		comnanobots
			name = "Combat Nanobots"
			id = "comnanobots"
			result = "comnanobots"
			required_reagents = list("nanobots" = 1, "mutagen" = 5, "silicate" = 5, "iron" = 10)
			result_amount = 1

///////////////////////////////////////////////////////////////////////////////////

// foam and foam precursor

		surfactant
			name = "Foam surfactant"
			id = "foam surfactant"
			result = "fluorosurfactant"
			required_reagents = list("fluorine" = 2, "carbon" = 2, "sacid" = 1)
			result_amount = 5


		foam
			name = "Foam"
			id = "foam"
			result = null
			required_reagents = list("fluorosurfactant" = 1, "water" = 1)
			result_amount = 2

			on_reaction(var/datum/reagents/holder, var/created_volume)


				var/location = get_turf(holder.my_atom)
				for(var/mob/M in viewers(5, location))
					to_chat(M, "<span class='warning'>The solution violently bubbles!</span>")

				location = get_turf(holder.my_atom)

				for(var/mob/M in viewers(5, location))
					to_chat(M, "<span class='warning'>The solution spews out foam!</span>")

//				to_chat(world, "Holder volume is [holder.total_volume]")
				//for(var/datum/reagent/R in holder.reagent_list)
//					to_chat(world, "[R.name] = [R.volume]")

				var/datum/effect/effect/system/foam_spread/s = new()
				s.set_up(created_volume, location, holder, 0)
				s.start()
				holder.clear_reagents()
				return

		metalfoam
			name = "Metal Foam"
			id = "metalfoam"
			result = null
			required_reagents = list("aluminum" = 3, "foaming_agent" = 1, "pacid" = 1)
			result_amount = 5

			on_reaction(var/datum/reagents/holder, var/created_volume)


				var/location = get_turf(holder.my_atom)

				for(var/mob/M in viewers(5, location))
					to_chat(M, "<span class='warning'>The solution spews out a metalic foam!</span>")

				var/datum/effect/effect/system/foam_spread/s = new()
				s.set_up(created_volume, location, holder, 1)
				s.start()
				return

		ironfoam
			name = "Iron Foam"
			id = "ironlfoam"
			result = null
			required_reagents = list("iron" = 3, "foaming_agent" = 1, "pacid" = 1)
			result_amount = 5

			on_reaction(var/datum/reagents/holder, var/created_volume)


				var/location = get_turf(holder.my_atom)

				for(var/mob/M in viewers(5, location))
					to_chat(M, "<span class='warning'>The solution spews out a metalic foam!</span>")

				var/datum/effect/effect/system/foam_spread/s = new()
				s.set_up(created_volume, location, holder, 2)
				s.start()
				return



		foaming_agent
			name = "Foaming Agent"
			id = "foaming_agent"
			result = "foaming_agent"
			required_reagents = list("lithium" = 1, "hydrogen" = 1)
			result_amount = 1

		// Synthesizing these three chemicals is pretty complex in real life, but fuck it, it's just a game!
		ammonia
			name = "Ammonia"
			id = "ammonia"
			result = "ammonia"
			required_reagents = list("hydrogen" = 3, "nitrogen" = 1)
			result_amount = 3

		diethylamine
			name = "Diethylamine"
			id = "diethylamine"
			result = "diethylamine"
			required_reagents = list ("ammonia" = 1, "ethanol" = 1)
			result_amount = 2

		space_cleaner
			name = "Space cleaner"
			id = "cleaner"
			result = "cleaner"
			required_reagents = list("ammonia" = 1, "water" = 1)
			result_amount = 2

		plantbgone
			name = "Plant-B-Gone"
			id = "plantbgone"
			result = "plantbgone"
			required_reagents = list("toxin" = 1, "water" = 4)
			result_amount = 5

//Special reaction for mimic meat: injecting it with 5 units of blood causes it to turn into a random food item. Makes more sense than hitting it with a fking rolling pin

		mimicshift
			name = "Shapeshift"
			id = "mimic_meat_shift"
			result = null
			required_reagents = list("blood" = 5)
			result_amount = 1
			required_container = /obj/item/weapon/reagent_containers/food/snacks/meat/mimic

			on_reaction(var/datum/reagents/holder)
				if(istype(holder.my_atom, /obj/item/weapon/reagent_containers/food/snacks/meat/mimic))
					var/obj/item/weapon/reagent_containers/food/snacks/meat/mimic/M = holder.my_atom
					M.shapeshift()

					if(ismob(holder.my_atom.loc))
						var/mob/mob_holder = holder.my_atom.loc
						mob_holder.drop_item(holder.my_atom) //Bandaid to work around items becoming invisible when their appearance is changed!


/////////////////////////////////////OLD SLIME CORE REACTIONS ///////////////////////////////
/*
		slimepepper
			name = "Slime Condensedcapaicin"
			id = "m_condensedcapaicin"
			result = "condensedcapsaicin"
			required_reagents = list("sugar" = 1)
			result_amount = 1
			required_container = /obj/item/slime_core
			required_other = 1
		slimefrost
			name = "Slime Frost Oil"
			id = "m_frostoil"
			result = "frostoil"
			required_reagents = list("water" = 1)
			result_amount = 1
			required_container = /obj/item/slime_core
			required_other = 1
		slimeglycerol
			name = "Slime Glycerol"
			id = "m_glycerol"
			result = "glycerol"
			required_reagents = list("blood" = 1)
			result_amount = 1
			required_container = /obj/item/slime_core
			required_other = 1

		slime_explosion
			name = "Slime Explosion"
			id = "m_explosion"
			result = null
			required_reagents = list("blood" = 1)
			result_amount = 2
			required_container = /obj/item/slime_core
			required_other = 2
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				var/datum/effect/effect/system/reagents_explosion/e = new()
				e.set_up(round (created_volume/10, 1), location, 0, 0)
				e.start()

				holder.clear_reagents()
				return
		slimejam
			name = "Slime Jam"
			id = "m_jam"
			result = "slimejelly"
			required_reagents = list("water" = 1)
			result_amount = 1
			required_container = /obj/item/slime_core
			required_other = 2
		slimesynthi
			name = "Slime Synthetic Flesh"
			id = "m_flesh"
			result = null
			required_reagents = list("sugar" = 1)
			result_amount = 1
			required_container = /obj/item/slime_core
			required_other = 2
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				new /obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh(location)
				return

		slimeenzyme
			name = "Slime Enzyme"
			id = "m_enzyme"
			result = "enzyme"
			required_reagents = list("blood" = 1, "water" = 1)
			result_amount = 2
			required_container = /obj/item/slime_core
			required_other = 3
		slimeplasma
			name = "Slime Plasma"
			id = "m_plasma"
			result = "plasma"
			required_reagents = list("sugar" = 1, "blood" = 2)
			result_amount = 2
			required_container = /obj/item/slime_core
			required_other = 3
		slimevirus
			name = "Slime Virus"
			id = "m_virus"
			result = null
			required_reagents = list("sugar" = 1, "sacid" = 1)
			result_amount = 2
			required_container = /obj/item/slime_core
			required_other = 3
			on_reaction(var/datum/reagents/holder, var/created_volume)
				holder.clear_reagents()

				var/virus = pick(/datum/disease/advance/flu, /datum/disease/advance/cold, \
				 /datum/disease/pierrot_throat, /datum/disease/fake_gbs, \
				 /datum/disease/brainrot, /datum/disease/magnitis)


				var/datum/disease/F = new virus(0)
				var/list/data = list("viruses"= list(F))
				holder.add_reagent("blood", 20, data)

				holder.add_reagent("cyanide", rand(1,10))

				return

		slimeteleport
			name = "Slime Teleport"
			id = "m_tele"
			result = null
			required_reagents = list("pacid" = 2, "mutagen" = 2)
			required_catalysts = list("plasma" = 1)
			result_amount = 1
			required_container = /obj/item/slime_core
			required_other = 4
			on_reaction(var/datum/reagents/holder, var/created_volume)

				// Calculate new position (searches through beacons in world)
				var
				/chosen
				var/list/possible = list()
				for(var/obj/item/beacon/W in beacons)
					possible += W

				if(possible.len > 0)
					chosen = pick(possible)

				if(chosen)
				// Calculate previous position for transition

					var/turf/FROM = get_turf(holder.my_atom) // the turf of origin we're travelling FROM
					var/turf/TO = get_turf(chosen)			 // the turf of origin we're travelling TO

					playsound(TO, 'sound/effects/phasein.ogg', 100, 1)

					var/list/flashers = list()
					for(var/mob/living/carbon/human/M in viewers(TO, null))
						if(M.eyecheck() <= 0)
							flick("e_flash", M.flash) // flash dose faggots
							flashers += M

					var/y_distance = TO.y - FROM.y
					var/x_distance = TO.x - FROM.x
					for (var/atom/movable/A in range(2, FROM )) // iterate thru list of mobs in the area
						if(istype(A, /obj/item/beacon)) continue // don't teleport beacons because that's just insanely stupid
						if( A.anchored && !istype(A, /mob/dead/observer) ) continue // don't teleport anchored things (computers, tables, windows, grilles, etc) because this causes problems!
						// do teleport ghosts however because hell why not

						var/turf/newloc = locate(A.x + x_distance, A.y + y_distance, TO.z) // calculate the new place
						if(!A.Move(newloc)) // if the atom, for some reason, can't move, FORCE them to move! :) We try Move() first to invoke any movement-related checks the atom needs to perform after moving
							A.loc = locate(A.x + x_distance, A.y + y_distance, TO.z)

						spawn()
							if(ismob(A) && !(A in flashers)) // don't flash if we're already doing an effect
								var/mob/M = A
								if(M.client)
									var/obj/blueeffect = new /obj(src)
									blueeffect.screen_loc = "WEST,SOUTH to EAST,NORTH"
									blueeffect.icon = 'icons/effects/effects.dmi'
									blueeffect.icon_state = "shieldsparkles"
									blueeffect.layer = 17
									blueeffect.mouse_opacity = 0
									M.client.screen += blueeffect
									sleep(20)
									M.client.screen -= blueeffect
									del(blueeffect)
		slimecrit
			name = "Slime Crit"
			id = "m_tele"
			result = null
			required_reagents = list("sacid" = 1, "blood" = 1)
			required_catalysts = list("plasma" = 1)
			result_amount = 1
			required_container = /obj/item/slime_core
			required_other = 4
			on_reaction(var/datum/reagents/holder, var/created_volume)

				var/blocked = list(/mob/living/simple_animal/hostile,
					/mob/living/simple_animal/hostile/pirate,
					/mob/living/simple_animal/hostile/pirate/ranged,
					/mob/living/simple_animal/hostile/russian,
					/mob/living/simple_animal/hostile/russian/ranged,
					/mob/living/simple_animal/hostile/syndicate,
					/mob/living/simple_animal/hostile/syndicate/melee,
					/mob/living/simple_animal/hostile/syndicate/melee/space,
					/mob/living/simple_animal/hostile/syndicate/ranged,
					/mob/living/simple_animal/hostile/syndicate/ranged/space,
					/mob/living/simple_animal/hostile/alien/queen/large,
					/mob/living/simple_animal/clown
					)//exclusion list for things you don't want the reaction to create.
				var/list/critters = typesof(/mob/living/simple_animal/hostile) - blocked // list of possible hostile mobs

				playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

				for(var/mob/living/carbon/human/M in viewers(get_turf(holder.my_atom), null))
					if(M.eyecheck() <= 0)
						flick("e_flash", M.flash)

				for(var/i = 1, i <= created_volume, i++)
					var/chosen = pick(critters)
					var/mob/living/simple_animal/hostile/C = new chosen
					C.loc = get_turf(holder.my_atom)
					if(prob(50))
						for(var/j = 1, j <= rand(1, 3), j++)
							step(C, pick(NORTH,SOUTH,EAST,WEST))
		slimebork
			name = "Slime Bork"
			id = "m_tele"
			result = null
			required_reagents = list("sugar" = 1, "water" = 1)
			result_amount = 2
			required_container = /obj/item/slime_core
			required_other = 4
			on_reaction(var/datum/reagents/holder, var/created_volume)

				var/list/borks = typesof(/obj/item/weapon/reagent_containers/food/snacks) - /obj/item/weapon/reagent_containers/food/snacks
				// BORK BORK BORK

				playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

				for(var/mob/living/carbon/human/M in viewers(get_turf(holder.my_atom), null))
					if(M.eyecheck() <= 0)
						flick("e_flash", M.flash)

				for(var/i = 1, i <= created_volume + rand(1,2), i++)
					var/chosen = pick(borks)
					var/obj/B = new chosen
					if(B)
						B.loc = get_turf(holder.my_atom)
						if(prob(50))
							for(var/j = 1, j <= rand(1, 3), j++)
								step(B, pick(NORTH,SOUTH,EAST,WEST))



		slimechloral
			name = "Slime Chloral"
			id = "m_bunch"
			result = "chloralhydrate"
			required_reagents = list("blood" = 1, "water" = 2)
			result_amount = 2
			required_container = /obj/item/slime_core
			required_other = 5
		slimeretro
			name = "Slime Retro"
			id = "m_xeno"
			result = null
			required_reagents = list("sugar" = 1)
			result_amount = 1
			required_container = /obj/item/slime_core
			required_other = 5
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/datum/disease/F = new /datum/disease/dna_retrovirus(0)
				var/list/data = list("viruses"= list(F))
				holder.add_reagent("blood", 20, data)
		slimefoam
			name = "Slime Foam"
			id = "m_foam"
			result = null
			required_reagents = list("sacid" = 1)
			result_amount = 2
			required_container = /obj/item/slime_core
			required_other = 5

			on_reaction(var/datum/reagents/holder, var/created_volume)


				var/location = get_turf(holder.my_atom)
				for(var/mob/M in viewers(5, location))
					to_chat(M, "<span class='warning'>The solution violently bubbles!</span>")

				location = get_turf(holder.my_atom)

				for(var/mob/M in viewers(5, location))
					to_chat(M, "<span class='warning'>The solution spews out foam!</span>")

//				to_chat(world, "Holder volume is [holder.total_volume]")
				//for(var/datum/reagent/R in holder.reagent_list)
//					to_chat(world, "[R.name] = [R.volume]")

				var/datum/effect/effect/system/foam_spread/s = new()
				s.set_up(created_volume, location, holder, 0)
				s.start()
				holder.clear_reagents()
				return
*/
/////////////////////////////////////////////NEW SLIME CORE REACTIONS/////////////////////////////////////////////

//Grey
		slimespawn
			name = "Slime Spawn"
			id = "m_spawn"
			result = null
			required_reagents = list("plasma" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/grey
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				if (istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
					send_admin_alert(holder, reaction_name="grey slime in a grenade")
				else
					send_admin_alert(holder, reaction_name="grey slime")

				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				if (istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
					holder.my_atom.visible_message("<span class='rose'>The grenade bursts open and a new baby slime emerges from it!</span>")
				else
					holder.my_atom.visible_message("<span class='rose'>Infused with plasma, the core begins to quiver and grow, and soon a new baby slime emerges from it!</span>")
				var/mob/living/carbon/slime/S = new /mob/living/carbon/slime
				S.loc = get_turf(holder.my_atom)

		slimemonkey
			name = "Slime Monkey"
			id = "m_monkey"
			result = null
			required_reagents = list("blood" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/grey
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				for(var/i = 1, i <= 3, i++)
					var /obj/item/weapon/reagent_containers/food/snacks/monkeycube/M = new /obj/item/weapon/reagent_containers/food/snacks/monkeycube
					M.loc = get_turf(holder.my_atom)

//Green
		slimemutate
			name = "Mutation Toxin"
			id = "mutationtoxin"
			result = "mutationtoxin"
			required_reagents = list("plasma" = 5)
			result_amount = 1
			required_other = 1
			required_container = /obj/item/slime_extract/green

		slimeperidaxon
			name = "Slime Peridaxon"
			id = "m_peridaxon"
			result = null
			required_reagents = list("water" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/green
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/item/weapon/reagent_containers/glass/bottle/B = new /obj/item/weapon/reagent_containers/glass/bottle
				B.name = "peridaxon bottle"
				B.reagents.add_reagent("peridaxon",5)
				B.loc = get_turf(holder.my_atom)

		slimedexplus
			name = "Slime Dexalin Plus"
			id = "m_dexplus"
			result = null
			required_reagents = list("oxygen" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/green
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/item/weapon/reagent_containers/glass/bottle/B = new /obj/item/weapon/reagent_containers/glass/bottle
				B.name = "Dexalin Plus Bottle"
				B.reagents.add_reagent("dexalinp",5)
				B.loc = get_turf(holder.my_atom)

		slimesdelight
			name = "Slime Doctor's Delight"
			id = "m_doctordelight"
			result = null
			required_reagents = list("sugar" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/green
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/item/weapon/reagent_containers/glass/bottle/B = new /obj/item/weapon/reagent_containers/glass/bottle
				B.name = "Doctor's Delight bottle"
				B.reagents.add_reagent("doctorsdelight",10)
				B.loc = get_turf(holder.my_atom)

		slimebicard
			name = "Slime Bicaridine"
			id = "m_bicaridine"
			result = null
			required_reagents = list("carbon" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/green
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/item/weapon/reagent_containers/glass/bottle/B = new /obj/item/weapon/reagent_containers/glass/bottle
				B.name = "bicaridine bottle"
				B.reagents.add_reagent("bicaridine",10)
				B.loc = get_turf(holder.my_atom)

		slimedermaline
			name = "Slime Dermaline"
			id = "m_dermaline"
			result = null
			required_reagents = list("phosphorus" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/green
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/item/weapon/reagent_containers/glass/bottle/B = new /obj/item/weapon/reagent_containers/glass/bottle
				B.name = "Dermaline bottle"
				B.reagents.add_reagent("dermaline",5)
				B.loc = get_turf(holder.my_atom)

//Metal
		slimemetal
			name = "Slime Metal"
			id = "m_metal"
			result = null
			required_reagents = list("plasma" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/metal
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(holder.my_atom))
				M.amount = 15
				var/obj/item/stack/sheet/plasteel/P = new /obj/item/stack/sheet/plasteel
				P.amount = 5
				P.loc = get_turf(holder.my_atom)

		slimegold
			name = "Slime Gold"
			id = "m_gold"
			result = null
			required_reagents = list("copper" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/metal
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				var/obj/item/stack/sheet/mineral/gold/G = new /obj/item/stack/sheet/mineral/gold
				G.amount = 5
				G.loc = get_turf(holder.my_atom)

		slimesilver
			name = "Slime Silver"
			id = "m_silver"
			result = null
			required_reagents = list("tungsten" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/metal
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				var/obj/item/stack/sheet/mineral/silver/S = new /obj/item/stack/sheet/mineral/silver
				S.amount = 5
				S.loc = get_turf(holder.my_atom)

		slimeuranium
			name = "Slime Uranium"
			id = "m_uranium"
			result = null
			required_reagents = list("radium" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/metal
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				var/obj/item/stack/sheet/mineral/uranium/U = new /obj/item/stack/sheet/mineral/uranium
				U.amount = 5
				U.loc = get_turf(holder.my_atom)

		slimediamond
			name = "Slime diamond"
			id = "m_diamond"
			result = null
			required_reagents = list("carbon" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/metal
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				var/obj/item/stack/sheet/mineral/diamond/K = new /obj/item/stack/sheet/mineral/diamond
				K.amount = 2
				K.loc = get_turf(holder.my_atom)


//Gold
		slimecrit
			name = "Slime Crit"
			id = "m_tele"
			result = null
			required_reagents = list("plasma" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/gold
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				if (!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
					holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently !</span>")
					send_admin_alert(holder, reaction_name="gold slime + plasma")
					sleep(50)
				else
					send_admin_alert(holder, reaction_name="gold slime + plasma in a grenade!!")//expect to this this one spammed in the times to come

				var/blocked = list(
					/mob/living/simple_animal/hostile/alien/queen/large,
					/mob/living/simple_animal/hostile/faithless,
					/mob/living/simple_animal/hostile/faithless/cult,
					/mob/living/simple_animal/hostile/scarybat/cult,
					/mob/living/simple_animal/hostile/creature/cult,
					/mob/living/simple_animal/hostile/retaliate/clown,
					/mob/living/simple_animal/hostile/mushroom,
					/mob/living/simple_animal/hostile/carp/holocarp,
					/mob/living/simple_animal/hostile/slime,
					/mob/living/simple_animal/hostile/slime/adult,
					/mob/living/simple_animal/hostile/mining_drone,
					/mob/living/simple_animal/hostile/mimic,
					/mob/living/simple_animal/hostile/mimic/crate,
					/mob/living/simple_animal/hostile/mimic/crate/chest,
					/mob/living/simple_animal/hostile/mimic/crate/item,
					) + typesof(/mob/living/simple_animal/hostile/humanoid) + typesof(/mob/living/simple_animal/hostile/asteroid)//exclusion list for things you don't want the reaction to create.
				var/list/critters = existing_typesof(/mob/living/simple_animal/hostile) - blocked // list of possible hostile mobs


				playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

				for(var/mob/O in viewers(get_turf(holder.my_atom), null))
					if (istype(O, /mob/living/carbon/human/))
						var /mob/living/carbon/human/H = O
						if((H.eyecheck() <= 0)&&(!istype(H.glasses, /obj/item/clothing/glasses/science)))
							H.flash_eyes(visual = 1)
							to_chat(O, "<span class='danger'>A flash blinds you while you start hearing terrifying noises !</span>")
						else
							to_chat(O, "<span class='danger'>You hear a rumbling as a troup of monsters phases into existence !</span>")
					else
						to_chat(O, "<span class='danger'>You hear a rumbling as a troup of monsters phases into existence !</span>")

				for(var/i = 1, i <= 5, i++)
					var/chosen = pick(critters)
					var/mob/living/simple_animal/hostile/C = new chosen(get_turf(holder.my_atom))
					C.faction = "slimesummon"
					if(prob(50))
						for(var/j = 1, j <= rand(1, 3), j++)
							step(C, pick(NORTH,SOUTH,EAST,WEST))

		slimecritlesser
			name = "Slime Crit Lesser"
			id = "m_tele3"
			result = null
			required_reagents = list("blood" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/gold
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				if (!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
					holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently !</span>")
					send_admin_alert(holder, reaction_name="gold slime + blood")
					sleep(50)
				else
					send_admin_alert(holder, reaction_name="gold slime + blood in a grenade")

				var/blocked = list(
					/mob/living/simple_animal/hostile/alien/queen/large,
					/mob/living/simple_animal/hostile/retaliate/clown,
					/mob/living/simple_animal/hostile/mushroom,
					/mob/living/simple_animal/hostile/carp/holocarp,
					/mob/living/simple_animal/hostile/faithless/cult,
					/mob/living/simple_animal/hostile/scarybat/cult,
					/mob/living/simple_animal/hostile/creature/cult,
					/mob/living/simple_animal/hostile/slime,
					/mob/living/simple_animal/hostile/slime/adult,
					/mob/living/simple_animal/hostile/hivebot/tele,//this thing spawns hostile mobs
					/mob/living/simple_animal/hostile/mining_drone,
					) + typesof(/mob/living/simple_animal/hostile/humanoid) + typesof(/mob/living/simple_animal/hostile/asteroid)//exclusion list for things you don't want the reaction to create.
				var/list/critters = existing_typesof(/mob/living/simple_animal/hostile) - blocked // list of possible hostile mobs

				send_admin_alert(holder, reaction_name="gold slime + blood")

				playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

				for(var/mob/O in viewers(get_turf(holder.my_atom), null))
					if (istype(O, /mob/living/carbon/human/))
						var /mob/living/carbon/human/H = O
						if((H.eyecheck() <= 0)&&(!istype(H.glasses, /obj/item/clothing/glasses/science)))
							H.flash_eyes(visual = 1)
							to_chat(O, "<span class='rose'>A flash blinds and you can feel a new presence !</span>")
						else
							to_chat(O, "<span class='rose'>You hear a crackling as a creature manifests before you !</span>")
					else
						to_chat(O, "<span class='rose'>You hear a crackling as a creature manifests before you !</span>")

				var/chosen = pick(critters)
				var/mob/living/simple_animal/hostile/C = new chosen
				C.faction = "neutral" // Uh, beepsky ignores mobs in this faction as of Redmine #147 - N3X
				C.loc = get_turf(holder.my_atom)

		slimecritweak
			name = "Slime Animation"
			id = "m_tele4"
			result = null
			required_reagents = list("water" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/gold
			required_other = 1

			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				if (!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
					holder.my_atom.visible_message("<span class='warning'>The slime extract begins to slowly vibrate!</span>")
					send_admin_alert(holder, reaction_name="gold slime + water")
				else
					send_admin_alert(holder, reaction_name="gold slime + water in a grenade")

				spawn(50)
					var/atom/location = holder.my_atom.loc
					if(istype(location, /turf))
						var/list/disguise_candidates = list()

						for(var/obj/item/I in oview(4, holder.my_atom))
							disguise_candidates += I

						var/atom/disguise = null

						if(disguise_candidates.len)
							disguise = pick(disguise_candidates)

						//If there are no nearby items to copy, become a completely random item!

						new/mob/living/simple_animal/hostile/mimic/crate/item(location, disguise) //Create a mimic identical to a nearby item
					else if(istype(location, /obj/structure/closet))
						var/mob/living/simple_animal/hostile/mimic/crate/new_mimic = new(get_turf(location), location.type)
						new_mimic.appearance = location.appearance //Create a crate mimic that looks exactly like the closet!

						for(var/atom/movable/AM in location.contents)
							AM.forceMove(new_mimic) //Move all items from the closet/crate to the new mimic

						qdel(location) //Delete the old closet
					else if(istype(location, /obj/item))
						new /mob/living/simple_animal/hostile/mimic/crate/item(get_turf(location), location) //Copy the item we're inside of, drop it outside the item!
					else if(ismob(location)) //Copy the mob! Owwwwwwwwwww this is going to be fun
						var/mob/M = location

						var/mob/mimic = new /mob/living/simple_animal/hostile/mimic/crate(get_turf(location), location)
						mimic.appearance = M.appearance //Because mimics copy appearances from paths, not actual existing objects.

						to_chat(M, "<span class='sinister'>You feel something thoroughly analyzing you from inside...</span>")
					else
						new /mob/living/simple_animal/hostile/mimic/crate

//Silver
		slimebork
			name = "Slime Bork"
			id = "m_tele2"
			result = null
			required_reagents = list("plasma" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/silver
			required_other = 1
			on_reaction(var/datum/reagents/holder)

				var/blocked = list(
					/obj/item/weapon/reagent_containers/food/snacks,
					/obj/item/weapon/reagent_containers/food/snacks/snackbar,
					/obj/item/weapon/reagent_containers/food/snacks/grown,
					)
				blocked += typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable)	//silver-slime spawned customizable food is borked

				var/list/borks = existing_typesof(/obj/item/weapon/reagent_containers/food/snacks) - blocked
				// BORK BORK BORK

				playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

				for(var/mob/O in viewers(get_turf(holder.my_atom), null))
					if (istype(O, /mob/living/carbon/human/))
						var /mob/living/carbon/human/H = O
						if((H.eyecheck() <= 0)&&(!istype(H.glasses, /obj/item/clothing/glasses/science)))
							H.flash_eyes(visual = 1)
							to_chat(O, "<span class='caution'>A white light blinds you and you think you can smell some food nearby !</span>")
						else
							to_chat(O, "<span class='notice'>A bunch of snacks appears before your very eyes !</span>")
					else
						to_chat(O, "<span class='notice'>A bunch of snacks appears before your very eyes !</span>")

				for(var/i = 1, i <= 4 + rand(1,2), i++)
					var/chosen = pick(borks)
					var/obj/B = new chosen
					if(B)
						B.loc = get_turf(holder.my_atom)

						if (istype(B,/obj/item/weapon/reagent_containers/food/snacks/meat/human))
							B.name = "human-meat"
						if (istype(B,/obj/item/weapon/reagent_containers/food/snacks/human))
							B.name = "human-meat burger"
						if (istype(B,/obj/item/weapon/reagent_containers/food/snacks/fortunecookie))
							var/obj/item/weapon/paper/paper = new /obj/item/weapon/paper(B)
							paper.info = pick("power to the slimes","have a slime day","today, you will meet a very special slime","stay away from cold showers")
							var/obj/item/weapon/reagent_containers/food/snacks/fortunecookie/cookie = B
							cookie.trash = paper

						if(prob(50))
							for(var/j = 1, j <= rand(1, 3), j++)
								step(B, pick(NORTH,SOUTH,EAST,WEST))
		slimedrinks
			name = "Slime Drinks"
			id = "m_tele3"
			result = null
			required_reagents = list("water" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/silver
			required_other = 1
			on_reaction(var/datum/reagents/holder)

				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")

				var/blocked = list(
					/obj/item/weapon/reagent_containers/food/drinks,
					)
				blocked += typesof(/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable)	//silver-slime spawned customizable food is borked
				blocked += typesof(/obj/item/weapon/reagent_containers/food/drinks/golden_cup)		//was probably never intended to spawn outside admin events

				var/list/borks = existing_typesof(/obj/item/weapon/reagent_containers/food/drinks) - blocked
				// BORK BORK BORK

				playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

				for(var/mob/O in viewers(get_turf(holder.my_atom), null))
					if (istype(O, /mob/living/carbon/human/))
						var /mob/living/carbon/human/H = O
						if((H.eyecheck() <= 0)&&(!istype(H.glasses, /obj/item/clothing/glasses/science)))
							H.flash_eyes(visual = 1)
							to_chat(O, "<span class='caution'>A white light blinds you and you think you can hear bottles rolling on the floor !</span>")
						else
							to_chat(O, "<span class='notice'>A bunch of drinks appears before you !</span>")
					else
						to_chat(O, "<span class='notice'>A bunch of drinks appears before you !</span>")

				for(var/i = 1, i <= 4 + rand(1,2), i++)
					var/chosen = pick(borks)
					var/obj/B = new chosen
					if(B)
						B.loc = get_turf(holder.my_atom)

						if (istype(B,/obj/item/weapon/reagent_containers/food/drinks/sillycup))
							B.reagents.add_reagent("water", 10)


						if (istype(B,/obj/item/weapon/reagent_containers/food/drinks/flask))
							B.reagents.add_reagent("whiskey", 60)


						if (istype(B,/obj/item/weapon/reagent_containers/food/drinks/shaker))
							B.reagents.add_reagent("gargleblaster", 100)

						if(prob(50))
							for(var/j = 1, j <= rand(1, 3), j++)
								step(B, pick(NORTH,SOUTH,EAST,WEST))

		slimematerials
			name = "Slime Materials"
			id = "m_mats"
			result = null
			required_reagents = list("carbon" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/silver
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				var/list/paths = list(/obj/item/stack/sheet/plasteel,
						/obj/item/stack/sheet/metal,
						/obj/item/stack/sheet/mineral/plasma,
						/obj/item/stack/sheet/mineral/silver,
						/obj/item/stack/sheet/mineral/gold,
						/obj/item/stack/sheet/mineral/uranium)
				getFromPool(pick(paths), get_turf(holder.my_atom), 5)
				getFromPool(pick(paths), get_turf(holder.my_atom), 5)


//Blue
		slimefrost
			name = "Slime Frost Oil"
			id = "m_frostoil"
			result = "frostoil"
			required_reagents = list("plasma" = 5)
			result_amount = 10
			required_container = /obj/item/slime_extract/blue
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")

//Dark Blue
		slimefreeze
			name = "Slime Freeze"
			id = "m_freeze"
			result = null
			required_reagents = list("plasma" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/darkblue
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				if (!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
					holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently !</span>")
					send_admin_alert(holder, reaction_name="dark blue slime + plasma (Freeze)")
					sleep(50)
				else
					send_admin_alert(holder, reaction_name="dark blue slime + plasma (Freeze) in a grenade")

				playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)
				for(var/mob/living/M in range (get_turf(holder.my_atom), 7))
					M.bodytemperature -= 6
					to_chat(M, "<span class='notice'>You feel a chill!</span>")

		slimenutrient
			name = "Slime Nutrient"
			id = "m_nutrient"
			result = null
			required_reagents = list("blood" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/darkblue
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/item/weapon/slimenutrient/P = new /obj/item/weapon/slimenutrient
				P.loc = get_turf(holder.my_atom)

//Orange
		slimecasp
			name = "Slime Capsaicin Oil"
			id = "m_capsaicinoil"
			result = "capsaicin"
			required_reagents = list("blood" = 5)
			result_amount = 10
			required_container = /obj/item/slime_extract/orange
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")

		slimefire
			name = "Slime fire"
			id = "m_fire"
			result = null
			required_reagents = list("plasma" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/orange
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				if (!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
					holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently !</span>")
					send_admin_alert(holder, reaction_name="orange slime + plasma (Napalm)")
					sleep(50)
				else
					send_admin_alert(holder, reaction_name="orange slime + plasma (Napalm)in a grenade")
				var/turf/location = get_turf(holder.my_atom.loc)
				for(var/turf/simulated/floor/target_tile in range(0,location))

					var/datum/gas_mixture/napalm = new

					napalm.toxins = 25
					napalm.temperature = 1400

					target_tile.assume_air(napalm)
					spawn (0) target_tile.hotspot_expose(700, 400,surfaces=1)

//Yellow
		slimeoverload
			name = "Slime EMP"
			id = "m_emp"
			result = null
			required_reagents = list("blood" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/yellow
			required_other = 1
			on_reaction(var/datum/reagents/holder, var/created_volume)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				if (!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
					send_admin_alert(holder, reaction_name="yellow slime + blood (EMP)")
				else
					send_admin_alert(holder, reaction_name="yellow slime + blood (EMP) in a grenade")
				empulse(get_turf(holder.my_atom), 3, 7)


		slimecell
			name = "Slime Powercell"
			id = "m_cell"
			result = null
			required_reagents = list("plasma" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/yellow
			required_other = 1
			on_reaction(var/datum/reagents/holder, var/created_volume)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/item/weapon/cell/slime/P = new /obj/item/weapon/cell/slime
				P.loc = get_turf(holder.my_atom)

		slimeglow					//Was a broken recipe that was supposed to make the extract produce some light
			name = "Slime Glow"		//I changed it, so it now creates an /obj/item/device/flashlight/lamp/slime.
			id = "m_glow"			//Basically a lamp with two brightness settings. light slightly yellow.
			result = null
			required_reagents = list("water" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/yellow
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/item/device/flashlight/lamp/slime/P = new /obj/item/device/flashlight/lamp/slime
				P.loc = get_turf(holder.my_atom)


//Purple

		slimepsteroid
			name = "Slime Steroid"
			id = "m_steroid"
			result = null
			required_reagents = list("plasma" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/purple
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/item/weapon/slimesteroid/P = new /obj/item/weapon/slimesteroid
				P.loc = get_turf(holder.my_atom)

		slimejam
			name = "Slime Jam"
			id = "m_jam"
			result = "slimejelly"
			required_reagents = list("sugar" = 5)
			result_amount = 10
			required_container = /obj/item/slime_extract/purple
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				if (istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
					send_admin_alert(holder, reaction_name="purple slime + sugar (Slime Jelly) in a grenade")

//Dark Purple
		slimeplasma
			name = "Slime Plasma"
			id = "m_plasma"
			result = null
			required_reagents = list("plasma" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/darkpurple
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/item/stack/sheet/mineral/plasma/P = new /obj/item/stack/sheet/mineral/plasma
				P.amount = 10
				P.loc = get_turf(holder.my_atom)

//Red
		slimeglycerol
			name = "Slime Glycerol"
			id = "m_glycerol"
			result = "glycerol"
			required_reagents = list("plasma" = 5)
			result_amount = 8
			required_container = /obj/item/slime_extract/red
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				if (istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
					send_admin_alert(holder, reaction_name="red slime + plasma (Glycerol) in a grenade")

		slimeres
			name = "Slime Res"
			id = "m_nutrient"
			result = null
			required_reagents = list("sugar" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/red
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/item/weapon/slimeres/P = new /obj/item/weapon/slimeres
				P.loc = get_turf(holder.my_atom)

		slimebloodlust
			name = "Bloodlust"
			id = "m_bloodlust"
			result = null
			required_reagents = list("blood" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/red
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				if (!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
					send_admin_alert(holder, reaction_name="red slime + blood (Slime Frenzy)")
				else
					send_admin_alert(holder, reaction_name="red slime + blood (Slime Frenzy) in a grenade")
				for(var/mob/living/carbon/slime/slime in viewers(get_turf(holder.my_atom), null))
					slime.rabid()
					holder.my_atom.visible_message("<span class='warning'>The [slime] is driven into a frenzy !</span>")
				for(var/mob/living/simple_animal/slime/slime in viewers(get_turf(holder.my_atom), null))
					slime.rabid()
					holder.my_atom.visible_message("<span class='warning'>The [slime] is driven into a frenzy !</span>")
				for(var/mob/living/simple_animal/adultslime/slime in viewers(get_turf(holder.my_atom), null))
					slime.rabid()
					holder.my_atom.visible_message("<span class='warning'>The [slime] is driven into a frenzy !</span>")

//Pink
		slimeppotion
			name = "Slime Potion"
			id = "m_potion"
			result = null
			required_reagents = list("plasma" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/pink
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/item/weapon/slimepotion/P = new /obj/item/weapon/slimepotion
				P.loc = get_turf(holder.my_atom)


//Black
		slimemutate2
			name = "Advanced Mutation Toxin"
			id = "mutationtoxin2"
			result = "amutationtoxin"
			required_reagents = list("plasma" = 5)
			result_amount = 1
			required_other = 1
			required_container = /obj/item/slime_extract/black
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				if (istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
					send_admin_alert(holder, reaction_name="black slime + plasma (Mutates to Slime) in a grenade")

		slimemednanobots
			name = "Slime Medical Nanobots"
			id = "m_mednanobots"
			result = "mednanobots"
			required_reagents = list("gold" = 5)
			result_amount = 1
			required_other = 1
			required_container = /obj/item/slime_extract/black
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				send_admin_alert(holder, reaction_name="black slime + gold (Medical Nanobots) in a grenade")


		slimecomnanobots
			name  = "Slime Combat Nanobots"
			id = "m_comnanobots"
			result = "comnanobots"
			required_reagents = list("uranium" = 5)
			result_amount = 1
			required_other = 1
			required_container = /obj/item/slime_extract/black
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				send_admin_alert(holder, reaction_name="black slime + uranium (Combat Nanobots) in a grenade")

//Oil
		slimeexplosion
			name = "Slime Explosion"
			id = "m_explosion"
			result = null
			required_reagents = list("plasma" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/oil
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				if (!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
					holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently !</span>")
					send_admin_alert(holder, reaction_name="oil slime + plasma (Explosion)")
					sleep(50)
				else
					send_admin_alert(holder, reaction_name="oil slime + plasma (Explosion) in a grenade")
				explosion(get_turf(holder.my_atom), 1 ,3, 6)

		slimegenocide
			name = "Slime Genocide" //oy vey
			id = "m_genocide"
			result = null
			required_reagents = list("blood" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/oil
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				if (!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
					send_admin_alert(holder, reaction_name="oil slime + blood (Slime Genocide)")
				else
					send_admin_alert(holder, reaction_name="oil slime + blood (Slime Genocide) in a grenade")
				for(var/mob/living/carbon/slime/S in viewers(get_turf(holder.my_atom), null)) // kills slimes
					S.death(0)
				for(var/mob/living/simple_animal/slime/S in viewers(get_turf(holder.my_atom), null)) // kills pet slimes too
					S.death(0)
				for(var/mob/living/simple_animal/adultslime/S in viewers(get_turf(holder.my_atom), null)) // no survivors
					S.death(0)

//Light Pink
		slimepotion2
			name = "Slime Potion 2"
			id = "m_potion2"
			result = null
			result_amount = 1
			required_container = /obj/item/slime_extract/lightpink
			required_reagents = list("plasma" = 5)
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/item/weapon/slimepotion2/P = new /obj/item/weapon/slimepotion2
				P.loc = get_turf(holder.my_atom)

//Adamantine
		slimegolem
			name = "Slime Golem"
			id = "m_golem"
			result = null
			required_reagents = list("plasma" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/adamantine
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/effect/golem_rune/Z = new /obj/effect/golem_rune
				Z.loc = get_turf(holder.my_atom)
				Z.announce_to_ghosts()


		slimediamond2
			name = "Slime Diamond2"
			id = "m_Diamond2"
			result = null
			result_amount = 1
			required_container = /obj/item/slime_extract/adamantine
			required_reagents = list("carbon" = 5)
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/item/stack/sheet/mineral/diamond/D = new /obj/item/stack/sheet/mineral/diamond
				D.amount = 5
				D.loc = get_turf(holder.my_atom)


		slimephazon
			name = "Slime Phazon"
			id = "m_Phazon"
			result = null
			result_amount = 1
			required_container = /obj/item/slime_extract/adamantine
			required_reagents = list("gold" = 5)
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/item/stack/sheet/mineral/phazon/P = new /obj/item/stack/sheet/mineral/phazon
				P.amount = 5
				P.loc = get_turf(holder.my_atom)

		slimeclown
			name = "Slime Clown"
			id = "m_Clown"
			result = null
			required_reagents = list("silver" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/adamantine
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/item/stack/sheet/mineral/clown/C = new /obj/item/stack/sheet/mineral/clown
				C.amount = 5
				C.loc = get_turf(holder.my_atom)



//Bluespace
		slimeteleport
			name = "Slime Teleport"
			id = "m_tele"
			result = null
			required_reagents = list("plasma" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/bluespace
			required_other = 1
			on_reaction(var/datum/reagents/holder, var/created_volume)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				if (!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
					send_admin_alert(holder, reaction_name="bluespace slime + plasma (Mass Teleport)")
				else
					send_admin_alert(holder, reaction_name="bluespace slime + plasma (Mass Teleport) in a grenade")
				// Calculate new position (searches through beacons in world)
				var/obj/item/beacon/chosen
				var/list/possible = list()
				for(var/obj/item/beacon/W in beacons)
					possible += W

				if(possible.len > 0)
					chosen = pick(possible)

				if(chosen)
				// Calculate previous position for transition

					var/turf/FROM = get_turf(holder.my_atom) // the turf of origin we're travelling FROM
					var/turf/TO = get_turf(chosen)			 // the turf of origin we're travelling TO

					playsound(TO, 'sound/effects/phasein.ogg', 100, 1)

					var/list/flashers = list()
					for(var/mob/living/carbon/human/M in viewers(TO, null))
						if((M.eyecheck() <= 0)&&(!istype(M.glasses, /obj/item/clothing/glasses/science)))
							M.flash_eyes(visual = 1)
							flashers += M

					var/y_distance = TO.y - FROM.y
					var/x_distance = TO.x - FROM.x
					for (var/atom/movable/A in range(4, FROM )) // iterate thru list of mobs in the area
						if(istype(A, /obj/item/beacon)) continue // don't teleport beacons because that's just insanely stupid
						if(A.anchored) continue
						if(istype(A, /obj/structure/cable )) continue

						var/turf/newloc = locate(A.x + x_distance, A.y + y_distance, TO.z) // calculate the new place
						if(!A.Move(newloc)) // if the atom, for some reason, can't move, FORCE them to move! :) We try Move() first to invoke any movement-related checks the atom needs to perform after moving
							A.loc = locate(A.x + x_distance, A.y + y_distance, TO.z)

						spawn()
							if(ismob(A) && !(A in flashers)) // don't flash if we're already doing an effect
								var/mob/M = A
								if(M.client)
									var/obj/blueeffect = new /obj(src)
									blueeffect.screen_loc = "WEST,SOUTH to EAST,NORTH"
									blueeffect.icon = 'icons/effects/effects.dmi'
									blueeffect.icon_state = "shieldsparkles"
									blueeffect.layer = 17
									blueeffect.mouse_opacity = 0
									M.client.screen += blueeffect
									sleep(20)
									M.client.screen -= blueeffect
									qdel(blueeffect)
									blueeffect = null
		slimecrystal
			name = "Slime Crystal"
			id = "m_crystal"
			result = null
			required_reagents = list("blood" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/bluespace
			required_other = 1
			on_reaction(var/datum/reagents/holder, var/created_volume)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				if(holder.my_atom)
					var/obj/item/bluespace_crystal/BC = new(get_turf(holder.my_atom))
					BC.visible_message("<span class='notice'>The [BC.name] appears out of thin air!</span>")


//Cerulean

		slimepsteroid2
			name = "Slime Steroid 2"
			id = "m_steroid2"
			result = null
			required_reagents = list("plasma" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/cerulean
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/item/weapon/slimesteroid2/P = new /obj/item/weapon/slimesteroid2
				P.loc = get_turf(holder.my_atom)

		slimedupe
			name = "Slime Duplicator"
			id = "m_dupe"
			result = null
			required_reagents = list("blood" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/cerulean
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/item/weapon/slimedupe/P = new /obj/item/weapon/slimedupe
				P.loc = get_turf(holder.my_atom)

//sepia
		slimecamera
			name = "Slime Camera"
			id = "m_camera"
			result = null
			required_reagents = list("plasma" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/sepia
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/item/device/camera/sepia/P = new /obj/item/device/camera/sepia
				P.loc = get_turf(holder.my_atom)

		slimefilm
			name = "Slime Film"
			id = "m_film"
			result = null
			required_reagents = list("blood" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/sepia
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/obj/item/device/camera_film/P = new /obj/item/device/camera_film
				P.loc = get_turf(holder.my_atom)


//Pyrite

		slimepaint
			name = "Slime Paint"
			id = "s_paint"
			result = null
			required_reagents = list("plasma" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/pyrite
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
				var/list/paints = typesof(/obj/item/weapon/reagent_containers/glass/paint) - /obj/item/weapon/reagent_containers/glass/paint
				var/chosen = pick(paints)
				var/obj/P = new chosen
				if(P)
					P.loc = get_turf(holder.my_atom)

		slimecash
			name = "Slime Cash"
			id = "m_cash"
			result = null
			required_reagents = list("blood" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/pyrite
			required_other = 1
			on_reaction(var/datum/reagents/holder)
				var/obj/item/weapon/spacecash/c100/C = new /obj/item/weapon/spacecash/c100/
				C.amount = 1
				C.loc = get_turf(holder.my_atom)



//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////

		enzyme
			name = "Universal Enzyme"
			id = "enzyme"
			result = "enzyme"
			required_reagents = list("sodiumchloride" = 1, "nutriment" = 1, "blood" = 1)
			result_amount = 1

		tofu
			name = "Tofu"
			id = "tofu"
			result = null
			required_reagents = list("soymilk" = 10)
			required_catalysts = list("enzyme" = 5)
			result_amount = 1
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				for(var/i = 1, i <= created_volume, i++)
					new /obj/item/weapon/reagent_containers/food/snacks/tofu(location)
				return

		chocolate_bar
			name = "Chocolate Bar"
			id = "chocolate_bar"
			result = null
			required_reagents = list("soymilk" = 2, "coco" = 2, "sugar" = 2)
			result_amount = 1
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				for(var/i = 1, i <= created_volume, i++)
					new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)
				return

		chocolate_bar2
			name = "Chocolate Bar"
			id = "chocolate_bar"
			result = null
			required_reagents = list("milk" = 2, "coco" = 2, "sugar" = 2)
			result_amount = 1
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				for(var/i = 1, i <= created_volume, i++)
					new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)
				return

		hot_coco
			name = "Hot Coco"
			id = "hot_coco"
			result = "hot_coco"
			required_reagents = list("water" = 5, "coco" = 1)
			result_amount = 5

		/*coffee
			name = "Coffee"
			id = "coffee"
			result = "coffee"
			required_reagents = list("coffeepowder" = 1, "water" = 5)
			result_amount = 5*/

		/*tea
			name = "Tea"
			id = "tea"
			result = "tea"
			required_reagents = list("teapowder" = 1, "water" = 5)
			result_amount = 5*/

		soysauce
			name = "Soy Sauce"
			id = "soysauce"
			result = "soysauce"
			required_reagents = list("soymilk" = 4, "sacid" = 1)
			result_amount = 5

		vinegar
			name = "Malt Vinegar"
			id = "vinegar"
			result = "vinegar"
			required_reagents = list("ethanol" = 5)
			required_catalysts = list("enzyme" = 1)
			result_amount = 5

		sprinkles
			name = "Sprinkles"
			id = "sprinkles"
			result = "sprinkles"
			required_reagents = list("sugar" = 5)
			required_catalysts = list("enzyme" = 1)
			result_amount = 5

		cheesewheel
			name = "Cheesewheel"
			id = "cheesewheel"
			result = null
			required_reagents = list("milk" = 40)
			required_catalysts = list("enzyme" = 5)
			result_amount = 1
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				new /obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel(location)
				return
		Cream
			name = "Cream"
			id = "cream"
			result = "cream"
			required_reagents = list("milk" = 10,"sacid" = 1)
			result_amount = 5

		syntiflesh
			name = "Syntiflesh"
			id = "syntiflesh"
			result = null
			required_reagents = list("blood" = 5, "clonexadone" = 1)
			result_amount = 1
			on_reaction(var/datum/reagents/holder, var/created_volume)
				var/location = get_turf(holder.my_atom)
				new /obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh(location)
				return

		hot_ramen
			name = "Hot Ramen"
			id = "hot_ramen"
			result = "hot_ramen"
			required_reagents = list("water" = 1, "dry_ramen" = 3)
			result_amount = 3

		hell_ramen
			name = "Hell Ramen"
			id = "hell_ramen"
			result = "hell_ramen"
			required_reagents = list("capsaicin" = 1, "hot_ramen" = 6)
			result_amount = 6


////////////////////////////////////////// COCKTAILS //////////////////////////////////////


		goldschlager
			name = "Goldschlager"
			id = "goldschlager"
			result = "goldschlager"
			required_reagents = list("vodka" = 10, "gold" = 1)
			result_amount = 10

		patron
			name = "Patron"
			id = "patron"
			result = "patron"
			required_reagents = list("tequila" = 10, "silver" = 1)
			result_amount = 10

		bilk
			name = "Bilk"
			id = "bilk"
			result = "bilk"
			required_reagents = list("milk" = 1, "beer" = 1)
			result_amount = 2

		icetea
			name = "Iced Tea"
			id = "icetea"
			result = "icetea"
			required_reagents = list("ice" = 1, "tea" = 3)
			result_amount = 4

		arnoldpalmer
			name = "Arnold Palmer"
			id = "arnoldpalmer"
			result = "arnoldpalmer"
			required_reagents = list("lemonade" = 1, "icetea" = 1)
			result_amount = 2

		icecoffee
			name = "Iced Coffee"
			id = "icecoffee"
			result = "icecoffee"
			required_reagents = list("ice" = 1, "coffee" = 3)
			result_amount = 4

		nuka_cola
			name = "Nuka Cola"
			id = "nuka_cola"
			result = "nuka_cola"
			required_reagents = list("uranium" = 1, "cola" = 6)
			result_amount = 6

		moonshine
			name = "Moonshine"
			id = "moonshine"
			result = "moonshine"
			required_reagents = list("cornoil" = 10)
			required_catalysts = list("enzyme" = 5)
			result_amount = 10

		wine
			name = "Wine"
			id = "wine"
			result = "wine"
			required_reagents = list("berryjuice" = 10)
			required_catalysts = list("enzyme" = 5)
			result_amount = 10

		pinacolada
			name = "Pina Colada"
			id = "pinacolada"
			result = "pinacolada"
			required_reagents = list("rum" = 2, "ice" = 1, "cream" = 1)
			result_amount = 4

		spacebeer
			name = "Space Beer"
			id = "spacebeer"
			result = "beer"
			required_reagents = list("flour" = 10)
			required_catalysts = list("enzyme" = 5)
			result_amount = 10

		vodka
			name = "Vodka"
			id = "vodka"
			result = "vodka"
			required_reagents = list("potato" = 10)
			required_catalysts = list("enzyme" = 5)
			result_amount = 10
		sake
			name = "Sake"
			id = "sake"
			result = "sake"
			required_reagents = list("rice" = 10)
			required_catalysts = list("enzyme" = 5)
			result_amount = 10

		kahlua
			name = "Kahlua"
			id = "kahlua"
			result = "kahlua"
			required_reagents = list("coffee" = 5, "sugar" = 5)
			required_catalysts = list("enzyme" = 5)
			result_amount = 5

		gin_tonic
			name = "Gin and Tonic"
			id = "gintonic"
			result = "gintonic"
			required_reagents = list("gin" = 2, "tonic" = 1)
			result_amount = 3

		cuba_libre
			name = "Cuba Libre"
			id = "cubalibre"
			result = "cubalibre"
			required_reagents = list("rum" = 2, "cola" = 1)
			result_amount = 3

		martini
			name = "Classic Martini"
			id = "martini"
			result = "martini"
			required_reagents = list("gin" = 2, "vermouth" = 1)
			result_amount = 3

		vodkamartini
			name = "Vodka Martini"
			id = "vodkamartini"
			result = "vodkamartini"
			required_reagents = list("vodka" = 2, "vermouth" = 1)
			result_amount = 3

		white_russian
			name = "White Russian"
			id = "whiterussian"
			result = "whiterussian"
			required_reagents = list("blackrussian" = 3, "cream" = 2)
			result_amount = 5

		whiskey_cola
			name = "Whiskey Cola"
			id = "whiskeycola"
			result = "whiskeycola"
			required_reagents = list("whiskey" = 2, "cola" = 1)
			result_amount = 3

		screwdriver
			name = "Screwdriver"
			id = "screwdrivercocktail"
			result = "screwdrivercocktail"
			required_reagents = list("vodka" = 2, "orangejuice" = 1)
			result_amount = 3

		bloody_mary
			name = "Bloody Mary"
			id = "bloodymary"
			result = "bloodymary"
			required_reagents = list("vodka" = 1, "tomatojuice" = 2, "limejuice" = 1)
			result_amount = 4

		gargle_blaster
			name = "Pan-Galactic Gargle Blaster"
			id = "gargleblaster"
			result = "gargleblaster"
			required_reagents = list("vodka" = 1, "gin" = 1, "whiskey" = 1, "cognac" = 1, "limejuice" = 1)
			result_amount = 5

		brave_bull
			name = "Brave Bull"
			id = "bravebull"
			result = "bravebull"
			required_reagents = list("tequila" = 2, "kahlua" = 1)
			result_amount = 3

		tequila_sunrise
			name = "Tequila Sunrise"
			id = "tequilasunrise"
			result = "tequilasunrise"
			required_reagents = list("tequila" = 2, "orangejuice" = 1)
			result_amount = 3

		toxins_special
			name = "Toxins Special"
			id = "toxinsspecial"
			result = "toxinsspecial"
			required_reagents = list("rum" = 2, "vermouth" = 1, "plasma" = 2)
			result_amount = 5

		beepsky_smash
			name = "Beepksy Smash"
			id = "beepksysmash"
			result = "beepskysmash"
			required_reagents = list("limejuice" = 2, "whiskey" = 2, "iron" = 1)
			result_amount = 4

		doctor_delight
			name = "The Doctor's Delight"
			id = "doctordelight"
			result = "doctorsdelight"
			required_reagents = list("limejuice" = 1, "tomatojuice" = 1, "orangejuice" = 1, "cream" = 1, "tricordrazine" = 1)
			result_amount = 5

		irish_cream
			name = "Irish Cream"
			id = "irishcream"
			result = "irishcream"
			required_reagents = list("whiskey" = 2, "cream" = 1)
			result_amount = 3

		manly_dorf
			name = "The Manly Dorf"
			id = "manlydorf"
			result = "manlydorf"
			required_reagents = list ("beer" = 1, "ale" = 2)
			result_amount = 3

		hooch
			name = "Hooch"
			id = "hooch"
			result = "hooch"
			required_reagents = list ("sugar" = 1, "ethanol" = 2, "fuel" = 1)
			result_amount = 3

		irish_coffee
			name = "Irish Coffee"
			id = "irishcoffee"
			result = "irishcoffee"
			required_reagents = list("irishcream" = 1, "coffee" = 1)
			result_amount = 2

		b52
			name = "B-52"
			id = "b52"
			result = "b52"
			required_reagents = list("irishcarbomb" = 1, "kahlua" = 1, "cognac" = 1)
			result_amount = 3

		atomicbomb
			name = "Atomic Bomb"
			id = "atomicbomb"
			result = "atomicbomb"
			required_reagents = list("b52" = 10, "uranium" = 1)
			result_amount = 10

		margarita
			name = "Margarita"
			id = "margarita"
			result = "margarita"
			required_reagents = list("tequila" = 2, "limejuice" = 1)
			result_amount = 3

		longislandicedtea
			name = "Long Island Iced Tea"
			id = "longislandicedtea"
			result = "longislandicedtea"
			required_reagents = list("vodka" = 1, "gin" = 1, "tequila" = 1, "cubalibre" = 1, "ice" = 1)
			result_amount = 5

		threemileisland
			name = "Three Mile Island Iced Tea"
			id = "threemileisland"
			result = "threemileisland"
			required_reagents = list("longislandicedtea" = 10, "uranium" = 1)
			result_amount = 10

		whiskeysoda
			name = "Whiskey Soda"
			id = "whiskeysoda"
			result = "whiskeysoda"
			required_reagents = list("whiskey" = 2, "sodawater" = 1)
			result_amount = 3

		black_russian
			name = "Black Russian"
			id = "blackrussian"
			result = "blackrussian"
			required_reagents = list("vodka" = 3, "kahlua" = 2)
			result_amount = 5

		manhattan
			name = "Manhattan"
			id = "manhattan"
			result = "manhattan"
			required_reagents = list("whiskey" = 2, "vermouth" = 1)
			result_amount = 3

		manhattan_proj
			name = "Manhattan Project"
			id = "manhattan_proj"
			result = "manhattan_proj"
			required_reagents = list("manhattan" = 10, "uranium" = 1)
			result_amount = 10

		vodka_tonic
			name = "Vodka and Tonic"
			id = "vodkatonic"
			result = "vodkatonic"
			required_reagents = list("vodka" = 2, "tonic" = 1)
			result_amount = 3

		gin_fizz
			name = "Gin Fizz"
			id = "ginfizz"
			result = "ginfizz"
			required_reagents = list("gin" = 2, "sodawater" = 1, "limejuice" = 1)
			result_amount = 4

		bahama_mama
			name = "Bahama mama"
			id = "bahama_mama"
			result = "bahama_mama"
			required_reagents = list("rum" = 2, "orangejuice" = 2, "limejuice" = 1, "ice" = 1)
			result_amount = 6

		singulo
			name = "Singulo"
			id = "singulo"
			result = "singulo"
			required_reagents = list("vodka" = 5, "radium" = 1, "wine" = 5)
			result_amount = 10

		alliescocktail
			name = "Allies Cocktail"
			id = "alliescocktail"
			result = "alliescocktail"
			required_reagents = list("martini" = 1, "vodka" = 1)
			result_amount = 2

		demonsblood
			name = "Demons Blood"
			id = "demonsblood"
			result = "demonsblood"
			required_reagents = list("rum" = 1, "spacemountainwind" = 1, "blood" = 1, "dr_gibb" = 1)
			result_amount = 4

		booger
			name = "Booger"
			id = "booger"
			result = "booger"
			required_reagents = list("cream" = 1, "banana" = 1, "rum" = 1, "watermelonjuice" = 1)
			result_amount = 4

		antifreeze
			name = "Anti-freeze"
			id = "antifreeze"
			result = "antifreeze"
			required_reagents = list("vodka" = 2, "cream" = 1, "ice" = 1)
			result_amount = 4

		barefoot
			name = "Barefoot"
			id = "barefoot"
			result = "barefoot"
			required_reagents = list("berryjuice" = 1, "cream" = 1, "vermouth" = 1)
			result_amount = 3


////DRINKS THAT REQUIRED IMPROVED SPRITES BELOW:: -Agouri/////

		sbiten
			name = "Sbiten"
			id = "sbiten"
			result = "sbiten"
			required_reagents = list("vodka" = 10, "capsaicin" = 1)
			result_amount = 10

		red_mead
			name = "Red Mead"
			id = "red_mead"
			result = "red_mead"
			required_reagents = list("blood" = 1, "mead" = 1)
			result_amount = 2

		mead
			name = "Mead"
			id = "mead"
			result = "mead"
			required_reagents = list("sugar" = 1, "water" = 1)
			required_catalysts = list("enzyme" = 5)
			result_amount = 2

		iced_beer
			name = "Iced Beer"
			id = "iced_beer"
			result = "iced_beer"
			required_reagents = list("beer" = 10, "frostoil" = 1)
			result_amount = 10

		iced_beer2
			name = "Iced Beer"
			id = "iced_beer"
			result = "iced_beer"
			required_reagents = list("beer" = 5, "ice" = 1)
			result_amount = 6

		grog
			name = "Grog"
			id = "grog"
			result = "grog"
			required_reagents = list("rum" = 1, "water" = 1)
			result_amount = 2

		soy_latte
			name = "Soy Latte"
			id = "soy_latte"
			result = "soy_latte"
			required_reagents = list("espresso" = 1, "soymilk" = 1)
			result_amount = 2

		cafe_latte
			name = "Latte"
			id = "cafe_latte"
			result = "cafe_latte"
			required_reagents = list("espresso" = 1, "milk" = 1)
			result_amount = 2

		acidspit
			name = "Acid Spit"
			id = "acidspit"
			result = "acidspit"
			required_reagents = list("sacid" = 1, "wine" = 5)
			result_amount = 6

		amasec
			name = "Amasec"
			id = "amasec"
			result = "amasec"
			required_reagents = list("iron" = 1, "wine" = 5, "vodka" = 5)
			result_amount = 10

		changelingsting
			name = "Changeling Sting"
			id = "changelingsting"
			result = "changelingsting"
			required_reagents = list("screwdrivercocktail" = 1, "limejuice" = 1, "lemonjuice" = 1)
			result_amount = 5

		aloe
			name = "Aloe"
			id = "aloe"
			result = "aloe"
			required_reagents = list("cream" = 1, "whiskey" = 1, "watermelonjuice" = 1)
			result_amount = 2

		andalusia
			name = "Andalusia"
			id = "andalusia"
			result = "andalusia"
			required_reagents = list("rum" = 1, "whiskey" = 1, "lemonjuice" = 1)
			result_amount = 3

		neurotoxin
			name = "Neurotoxin"
			id = "neurotoxin"
			result = "neurotoxin"
			required_reagents = list("gargleblaster" = 1, "stoxin" = 1)
			result_amount = 2

		snowwhite
			name = "Snow White"
			id = "snowwhite"
			result = "snowwhite"
			required_reagents = list("beer" = 1, "lemon_lime" = 1)
			result_amount = 2

		irishcarbomb
			name = "Irish Car Bomb"
			id = "irishcarbomb"
			result = "irishcarbomb"
			required_reagents = list("ale" = 1, "irishcream" = 1)
			result_amount = 2

		syndicatebomb
			name = "Syndicate Bomb"
			id = "syndicatebomb"
			result = "syndicatebomb"
			required_reagents = list("beer" = 1, "whiskeycola" = 1)
			result_amount = 2

		erikasurprise
			name = "Erika Surprise"
			id = "erikasurprise"
			result = "erikasurprise"
			required_reagents = list("ale" = 1, "limejuice" = 1, "whiskey" = 1, "banana" = 1, "ice" = 1)
			result_amount = 5

		devilskiss
			name = "Devils Kiss"
			id = "devilskiss"
			result = "devilskiss"
			required_reagents = list("blood" = 1, "kahlua" = 1, "rum" = 1)
			result_amount = 3

		hippiesdelight
			name = "Hippies Delight"
			id = "hippiesdelight"
			result = "hippiesdelight"
			required_reagents = list("psilocybin" = 1, "gargleblaster" = 1)
			result_amount = 2

		bananahonk
			name = "Banana Honk"
			id = "bananahonk"
			result = "bananahonk"
			required_reagents = list("banana" = 1, "cream" = 1, "sugar" = 1)
			result_amount = 3

		silencer
			name = "Silencer"
			id = "silencer"
			result = "silencer"
			required_reagents = list("nothing" = 1, "cream" = 1, "sugar" = 1)
			result_amount = 3

		driestmartini
			name = "Driest Martini"
			id = "driestmartini"
			result = "driestmartini"
			required_reagents = list("nothing" = 1, "gin" = 1)
			result_amount = 2

		lemonade
			name = "Lemonade"
			id = "lemonade"
			result = "lemonade"
			required_reagents = list("lemonjuice" = 1, "sugar" = 1, "water" = 1)
			result_amount = 3

		kiraspecial
			name = "Kira Special"
			id = "kiraspecial"
			result = "kiraspecial"
			required_reagents = list("orangejuice" = 1, "limejuice" = 1, "sodawater" = 1)
			result_amount = 2

		brownstar
			name = "Brown Star"
			id = "brownstar"
			result = "brownstar"
			required_reagents = list("kahlua" = 1, "irish_cream" = 4)
			result_amount = 5

		milkshake
			name = "Milkshake"
			id = "milkshake"
			result = "milkshake"
			required_reagents = list("cream" = 1, "ice" = 2, "milk" = 2)
			result_amount = 5

		rewriter
			name = "Rewriter"
			id = "rewriter"
			result = "rewriter"
			required_reagents = list("spacemountainwind" = 1, "coffee" = 1)
			result_amount = 2

		vinegar
			name = "Vinegar"
			id = "vinegar"
			result = "vinegar"
			required_reagents = list("wine" = 5)
			required_catalysts = list("enzyme" = 5)
			result_amount = 5

			//cafe stuff!


		acidtea
			name = "Earl's Grey Tea"
			id = "acidtea"
			result = "acidtea"
			required_reagents = list("sacid" = 1, "tea" = 1)
			result_amount = 2

		chifir
			name = "Chifir"
			id = "chifir"
			result = "chifir"
			required_reagents = list("tea" = 5, "redtea" = 5, "greentea" = 5)
			result_amount = 15

		yinyang
			name = "Zen Tea"
			id = "yinyang"
			result = "yinyang"
			required_reagents = list("tea" = 5, "nothing" = 5)
			result_amount = 10

		singularitea
			name = "Singularitea"
			id = "singularitea"
			result = "singularitea"
			required_reagents = list("radium" = 1, "tea" = 5, "redtea" = 5)
			result_amount = 10

		gyro
			name = "Gyro"
			id = "gyro"
			result = "gyro"
			required_reagents = list("greentea" = 5, "whiskey" = 5, "iron" = 1)
			result_amount = 10

		plasmatea
			name = "Plasma Pekoe"
			id = "plasmatea"
			result = "plasmatea"
			required_reagents = list("tea" = 5, "plasma" = 5)
			result_amount = 10

		espresso
			name = "Espresso"
			id = "espresso"
			result = "espresso"
			required_reagents = list("coffee" = 1, "water" = 1)
			result_amount = 2


		cappuccino
			name = "Cappuccino"
			id = "cappuccino"
			result = "cappuccino"
			required_reagents = list("espresso" = 1, "cream" = 1)
			result_amount = 2

		tonio
			name = "Tonio"
			id = "tonio"
			result = "tonio"
			required_reagents = list("coffee" = 5, "limejuice" = 1, "tomatojuice" = 1, "lemonjuice" = 1, "watermelonjuice" = 1, "honey" = 1)
			result_amount = 10

		doppio
			name = "Doppio"
			id = "doppio"
			result = "doppio"
			required_reagents = list("coffee" = 5, "redtea" = 5, "greentea" = 5)
			result_amount = 10

		passione
			name = "Passione"
			id = "passione"
			result = "passione"
			required_reagents = list("cappuccino" = 5, "gold" = 1, "honey" =5)
			result_amount = 10

		seccoffee
			name = "Wake up call"
			id = "seccoffee"
			result = "seccoffee"
			required_reagents = list("coffee" = 5, "sprinkles" = 1, "beepskysmash" = 5)
			result_amount = 10

		medcoffee
			name = "Lifeline"
			id = "medcoffee"
			result = "medcoffee"
			required_reagents = list("coffee" = 5, "doctorsdelight" = 5, "blood" = 1)
			result_amount = 10

		detcoffee
			name = "Joe"
			id = "detcoffee"
			result = "detcoffee"
			required_reagents = list("coffee" = 5, "whiskey" = 5)
			result_amount = 5

		etank
			name = "Recharger"
			id = "tank"
			result = "etank"
			required_reagents = list("coffee" = 1, "iron" = 1, "lithium" = 1, "fuel" = 1, "aluminum" = 1)
			result_amount = 5

		greytea
			name = "Tide"
			id = "greytea"
			result = "greytea"
			required_reagents = list("water" = 5, "fuel" = 5)
