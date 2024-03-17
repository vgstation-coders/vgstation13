/////VENDING MACHINES PACKS////////

/datum/supply_packs/snackmachines
	name = "Snacks n Cigs stack of packs"
	contains = list(/obj/structure/vendomatpack/snack,
					/obj/structure/vendomatpack/snack,
					/obj/structure/vendomatpack/snack,
					/obj/structure/vendomatpack/cola,
					/obj/structure/vendomatpack/coffee,
					/obj/structure/vendomatpack/cigarette)
	cost = 30
	containertype = /obj/structure/stackopacks
	containername = "\improper Snacks n Cigs stack of packs"
	group = "Vending Machine packs"
	containsicon = /obj/machinery/vending/snack
	containsdesc = "The official NT-approved vending machine pack set. Contains the following supplies: three Getmore Chocolate refills, one Robust Softdrinks refill, one Hot Drinks refill, and one Cigarette machine refill."

/datum/supply_packs/snackmachinesalt
	name = "Groans n Dan stack of packs"
	contains = list(/obj/structure/vendomatpack/discount,
					/obj/structure/vendomatpack/discount,
					/obj/structure/vendomatpack/groans,
					/obj/structure/vendomatpack/groans)
	cost = 20
	containertype = /obj/structure/stackopacks
	containername = "\improper Groans n Dan stack of packs"
	group = "Vending Machine packs"
	containsicon = /obj/machinery/vending/discount
	containsdesc = "Only the best from Discount Dan. Two packs each of the classic Discount Dan Vending Machine and the best Groans Soda to wash it down with."

/datum/supply_packs/hospitalitymachines
	name = "Theatre, Bar, Kitchen stack of packs"
	contains = list(/obj/structure/vendomatpack/boozeomat,
					/obj/structure/vendomatpack/dinnerware,
					/obj/structure/vendomatpack/autodrobe)
	cost = 15
	containertype = /obj/structure/stackopacks
	containername = "\improper Theatre, Bar, Kitchen stack of packs"
	group = "Vending Machine packs"
	containsicon = /obj/machinery/vending/boozeomat
	containsdesc = "A set of three packs. Includes one Booze-O-Mat, one Dinnerware machine, and one Autodrobe."

/datum/supply_packs/securitymachines
	name = "Security stack of packs"
	contains = list(/obj/structure/vendomatpack/security,
					/obj/structure/vendomatpack/security)
	cost = 10
	containertype = /obj/structure/stackopacks
	containername = "security stack of packs"
	group = "Vending Machine packs"
	containsicon = /obj/machinery/vending/security
	containsdesc = "Two SecTech packs. For when you've got so many clowns, but only so many donuts to go around."

/datum/supply_packs/medbaymachines
	name = "Medical stack of packs"
	contains = list(/obj/structure/vendomatpack/medical,
					/obj/structure/vendomatpack/medical)
	cost = 10
	containertype = /obj/structure/stackopacks
	containername = "medical stack of packs"
	group = "Vending Machine packs"
	containsicon = /obj/machinery/vending/medical
	containsdesc = "Two NanoMed refill packs. An excellent deal for saving lives."

/datum/supply_packs/botanymachines
	name = "Hydroponics stack of packs"
	contains = list(/obj/structure/vendomatpack/hydronutrients,
					/obj/structure/vendomatpack/hydroseeds)
	cost = 10
	containertype = /obj/structure/stackopacks
	containername = "hydroponics stack of packs"
	group = "Vending Machine packs"
	containsicon = /obj/machinery/vending/hydronutrients
	containsdesc = "A NutriMax and a MegaSeed pack. The best in selection for a new hydroponics expert."

/datum/supply_packs/toolsmachines
	name = "Tools n Engineering stack of packs"
	contains = list(/obj/structure/vendomatpack/tool,
					/obj/structure/vendomatpack/building,
					/obj/structure/vendomatpack/assist,
					/obj/structure/vendomatpack/engivend)
	cost = 20
	containertype = /obj/structure/stackopacks
	containername = "\improper Tools n Engineering stack of packs"
	group = "Vending Machine packs"
	containsicon = /obj/machinery/vending/tool
	containsdesc = "A variety of engineering vending machines for your constructive use. One YouTool, one Habitat Depot, one StockPro, and one EngiVend."

/datum/supply_packs/clothesmachines
	name = "Clothing stack of packs"
	contains = list(/obj/structure/vendomatpack/hatdispenser,
					/obj/structure/vendomatpack/suitdispenser,
					/obj/structure/vendomatpack/shoedispenser)
	cost = 15
	containertype = /obj/structure/stackopacks
	containername = "clothing stack of packs"
	group = "Vending Machine packs"
	containsicon = /obj/machinery/vending/hatdispenser
	containsdesc = "The standard for all dorms. Includes a Hatlord 9000, Suitlord 9000, and Shoelord 9000 refill pack."

/datum/supply_packs/barbermachines
	name = "Barber packs"
	contains = list(/obj/structure/vendomatpack/barbervend,
					/obj/structure/vendomatpack/barbervend)
	cost = 15
	containertype = /obj/structure/stackopacks
	containername = "\improper Barber stack of packs"
	group = "Vending Machine packs"
	containsicon = /obj/machinery/vending/barber
	containsdesc = "Two packs of BarberVend. Great for restyling the whole crew!"

/datum/supply_packs/makeupmachines
	name = "Cosmetics packs"
	contains = list(/obj/structure/vendomatpack/makeup,
					/obj/structure/vendomatpack/makeup)
	cost = 15
	containertype = /obj/structure/stackopacks
	containername = "\improper Cosmetics stack of packs"
	group = "Vending Machine packs"
	containsicon = /obj/machinery/vending/makeup
	containsdesc = "Sapphire Cosmetics. For when the crew is just that bored. Contains two packs."

/datum/supply_packs/offlicencemachines
	name = "Off-Licence packs"
	contains = list(/obj/structure/vendomatpack/offlicence,
					/obj/structure/vendomatpack/offlicence)
	cost = 15
	containertype = /obj/structure/stackopacks
	containername = "\improper Off-Licence stack of packs"
	group = "Vending Machine packs"
	containsicon = /obj/machinery/vending/offlicence
	containsdesc = "Need to drown your sorrows and finances? Offworld Off-Licence is just for you. Contains two packs."

/datum/supply_packs/circus
	name = "Toy packs"
	contains = list(/obj/structure/vendomatpack/circus,
					/obj/structure/vendomatpack/circus)
	cost = 15
	containertype = /obj/structure/stackopacks
	containername = "\improper Toy stack of packs"
	group = "Vending Machine packs"
	containsicon = /obj/machinery/vending/circus
	containsdesc = "Honk. Honk."

/datum/supply_packs/sovietmachines
	name = "Old and Forgotten stack of packs"
	contains = list(/obj/structure/vendomatpack/nazivend,
					/obj/structure/vendomatpack/sovietvend)
	cost = 20
	containertype = /obj/structure/stackopacks
	containername = "Old and Forgotten stack of packs"
	group = "Vending Machine packs"
	hidden = 1
	containsicon = /obj/machinery/vending/sovietvend
	containsdesc = "For when Space Capitalism has failed you for the last time."

/datum/supply_packs/sovietsodamachines
	name = "Russian Beverage stack of packs"
	contains = list(/obj/structure/vendomatpack/sovietsoda,
					/obj/structure/vendomatpack/sovietsoda)
	cost = 10
	containertype = /obj/structure/stackopacks
	containername = "Russian Beverage stack of packs"
	group = "Vending Machine packs"
	contraband = 1
	containsicon = /obj/machinery/vending/sovietsoda
	containsdesc = "BODA for all your needing. Comrade Dan not strong enough quench great thirst."

/datum/supply_packs/magimachines
	name = "Strange and Bright stack of packs"
	contains = list(/obj/structure/vendomatpack/magivend)
	cost = 80
	containertype = /obj/structure/stackopacks
	containername = "\improper Strange and Bright stack of packs"
	group = "Vending Machine packs"
	hidden = 1
	containsicon = /obj/machinery/vending/magivend
	containsdesc = "A surplus magical machine. Likely obtained from the Wizard Federation."

/datum/supply_packs/miningmachines
	name = "Dwarven Mining Equipment stack of packs"
	contains = list(/obj/structure/vendomatpack/mining,
					/obj/structure/vendomatpack/mining)
	cost = 10
	containertype = /obj/structure/stackopacks
	containername = "\improper Mining stack of packs"
	group = "Vending Machine packs"
	containsicon = /obj/machinery/vending/mining
	containsdesc = "Did ya lose ya vendin' machines to a singularity, sonny? Don't'cha worry, got two more right here for dem miners of yers."

/datum/supply_packs/gamesmachines
	name = "Al's Fun And Games stack of packs"
	contains = list(/obj/structure/vendomatpack/games, /obj/structure/vendomatpack/games)
	cost = 10
	containertype = /obj/structure/stackopacks
	containername = "Al's Fun And Games stack of packs"
	group = "Vending Machine Packs"
	containsicon = /obj/machinery/vending/games
	containsdesc = "Oh, what fun! Two packs of fun toy-and-game-filled joy."

/datum/supply_packs/teamsecurity
	name = "Team Security stack of packs"
	contains = list(/obj/structure/vendomatpack/team_security, /obj/structure/vendomatpack/team_security)
	cost = 10
	containertype = /obj/structure/stackopacks
	containername = "Team Security stack of packs"
	group = "Vending Machine packs"
	containsicon = /obj/machinery/vending/team_security
	containsdesc = "Support your local Team today. Contains two packs. Both for the same team."

/datum/supply_packs/telecomms
	name = "Telecommunications Parts stack of packs"
	contains = list(/obj/structure/vendomatpack/telecomms, /obj/structure/vendomatpack/telecomms)
	cost = 50
	containertype = /obj/structure/stackopacks
	containername = "Telecommunications Parts stack of packs"
	group = "Vending Machine packs"
	containsicon = /obj/machinery/vending/telecomms
	containsdesc = "Two packs of Telecommunication Parts refills. Great for making two extra telecomms on your station."

/datum/supply_packs/zamsnax
	name = "Zam Snax stack of packs"
	contains = list(/obj/structure/vendomatpack/zamsnax,
					/obj/structure/vendomatpack/zamsnax)
	cost = 25
	containertype = /obj/structure/stackopacks
	containername = "\improper Zam Snax stack of packs"
	group = "Vending Machine packs"
	containsicon = /obj/machinery/vending/zamsnax
	containsdesc = "Zamm... For the hungriest of Greys. Two packs."

/datum/supply_packs/lotto
	name = "Lotto Ticket stack of packs"
	contains = list(/obj/structure/vendomatpack/lotto,
					/obj/structure/vendomatpack/lotto)
	cost = 20
	containertype = /obj/structure/stackopacks
	containername = "\improper Lotto Ticket stack of packs"
	group = "Vending Machine packs"
	containsicon = /obj/machinery/vending/lotto
	containsdesc = "Feeling lucky, punk? Two packs, a winner in every one."

/datum/supply_packs/meat
	name = "Meat Fridge stack of packs"
	contains = list(/obj/structure/vendomatpack/meat,
					/obj/structure/vendomatpack/meat,
					/obj/item/voucher/free_item/meat)
	cost = 20
	containertype = /obj/structure/stackopacks
	containername = "\improper Meat Fridge stack of packs"
	group = "Vending Machine packs"
	containsicon = /obj/machinery/vending/meat
	containsdesc = "The latest from Discount Dan, the Meat Fridge. Includes two packs and a bonus voucher for a free slab of meat!"

/datum/supply_packs/art
	name = "Art Supply stack of packs"
	contains = list(/obj/structure/vendomatpack/artsupply,
					/obj/structure/vendomatpack/artsupply)
	cost = 20
	containertype = /obj/structure/stackopacks
	containername = "\improper Le Patron des Arts stack of packs"
	group = "Vending Machine packs"
	containsicon = /obj/machinery/vending/art
	containsdesc = "Fournitures d'arts plastiques pour des créations du plus bel effet."
