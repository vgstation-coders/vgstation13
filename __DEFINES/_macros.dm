//Define your macros here if they're used in general code

//Typechecking macros
// fun if you want to typecast humans/monkeys/etc without writing long path-filled lines.
#define ishuman(A) istype(A, /mob/living/carbon/human)

#define isjusthuman(A) (ishuman(A) && istype(A:species, /datum/species/human))

#define ismonkey(A) istype(A, /mob/living/carbon/monkey)

#define ismartian(A) istype(A, /mob/living/carbon/complex/martian)

#define ishigherbeing(A) (ishuman(A) || ismartian(A) || (ismonkey(A) && A.dexterity_check()))

#define ismanifested(A) (ishuman(A) && istype(A:species, /datum/species/manifested))

#define isvox(A) (ishuman(A) && istype(A:species, /datum/species/vox))

#define isinsectoid(A) (ishuman(A) && istype(A:species, /datum/species/insectoid))

#define isdiona(A) (ishuman(A) && istype(A:species, /datum/species/diona))

#define isgrey(A) (ishuman(A) && istype(A:species, /datum/species/grey))

#define isplasmaman(A) (ishuman(A) && istype(A:species, /datum/species/plasmaman))

#define isskellington(A) (ishuman(A) && istype(A:species, /datum/species/skellington))

#define isskelevox(A) (ishuman(A) && istype(A:species, /datum/species/skellington/skelevox))

#define iscatbeast(A) (ishuman(A) && istype(A:species, /datum/species/tajaran))

#define isunathi(A) (ishuman(A) && istype(A:species, /datum/species/unathi))

#define isskrell(A) (ishuman(A) && istype(A:species, /datum/species/skrell))

#define ismuton(A) (ishuman(A) && istype(A:species, /datum/species/muton))

#define isgolem(A) (ishuman(A) && istype(A:species, /datum/species/golem))

#define isslimeperson(A) (ishuman(A) && istype(A:species, /datum/species/slime))

#define ishorrorform(A) (ishuman(A) && istype(A:species, /datum/species/horror))

#define isgrue(A) (ishuman(A) && istype(A:species, /datum/species/grue))

#define ismushroom(A) ((ishuman(A) && istype(A:species, /datum/species/mushroom)) || (istype(A, /mob/living/carbon/monkey/mushroom)))

#define islich(A)  (ishuman(A) && istype(A:species, /datum/species/lich))

#define istruelich(A) ((islich(A) && (iswizard(A) || iswearinglichcrown(A))

#define iswearinglichcrown(A) (ishuman(A) && (istype(A:head, /obj/item/clothing/head/wizard/skelelich)) //|| istype(A:head, /obj/item/clothing

#define ishologram(A) (istype(A, /mob/living/simple_animal/hologram/advanced))

#define isbrain(A) istype(A, /mob/living/carbon/brain)

#define isalien(A) istype(A, /mob/living/carbon/alien)

#define isalienadult(A) istype(A, /mob/living/carbon/alien/humanoid)

#define isalienqueen(A)	istype(A, /mob/living/carbon/alien/humanoid/queen)

#define isaliendrone(A)	istype(A, /mob/living/carbon/alien/humanoid/drone)

#define islarva(A) istype(A, /mob/living/carbon/alien/larva)

#define iszombie(A) istype(A, /mob/living/simple_animal/hostile/necro/zombie)

#define isslime(A) (istype(A, /mob/living/carbon/slime) || istype(A, /mob/living/simple_animal/slime))

#define isgremlin(A) (istype(A, /mob/living/simple_animal/hostile/gremlin))

#define isgrinch(A) (istype(A, /mob/living/simple_animal/hostile/gremlin/grinch))

#define ispulsedemon(A) (istype(A, /mob/living/simple_animal/hostile/pulse_demon))

#define isslimeadult(A) istype(A, /mob/living/carbon/slime/adult)

#define isrobot(A) istype(A, /mob/living/silicon/robot)

#define isanimal(A) istype(A, /mob/living/simple_animal)

#define iscorgi(A) istype(A, /mob/living/simple_animal/corgi)

#define iscrab(A) istype(A, /mob/living/simple_animal/crab)

#define iscat(A) istype(A, /mob/living/simple_animal/cat)

#define ismouse(A) istype(A, /mob/living/simple_animal/mouse)

#define isbear(A) istype(A, /mob/living/simple_animal/hostile/bear)

#define iscarp(A) istype(A, /mob/living/simple_animal/hostile/carp)

#define isspider(A) istype(A, /mob/living/simple_animal/hostile/giant_spider)

#define isclown(A) istype(A, /mob/living/simple_animal/hostile/retaliate/clown)

#define iscluwne(A) istype(A, /mob/living/simple_animal/hostile/retaliate/cluwne)

#define isclowngoblin(A) istype(A, /mob/living/simple_animal/hostile/retaliate/cluwne/goblin)

#define isAI(A) istype(A, /mob/living/silicon/ai)

#define isAIEye(A) istype(A, /mob/camera/aiEye)

#define ispAI(A) istype(A, /mob/living/silicon/pai)

#define iscarbon(A) istype(A, /mob/living/carbon)

#define issilicon(A) istype(A, /mob/living/silicon)

#define isMoMMI(A) istype(A, /mob/living/silicon/robot/mommi)

#define isSaMMI(A) istype(A, /mob/living/silicon/robot/mommi/sammi)

#define isbot(A) istype(A, /obj/machinery/bot)

#define isborer(A) istype(A, /mob/living/simple_animal/borer)

#define isshade(A) istype(A, /mob/living/simple_animal/shade)

#define isconstruct(A) istype(A, /mob/living/simple_animal/construct)

#define isliving(A) istype(A, /mob/living)

#define isobserver(A) istype(A, /mob/dead/observer)

#define isjustobserver(A) (isobserver(A) && !isAdminGhost(A))

#define isnewplayer(A) istype(A, /mob/new_player)

#define isovermind(A) istype(A, /mob/camera/blob)

#define isorgan(A) istype(A, /datum/organ/external)

#define isitem(A) istype(A, /obj/item)

#define isclothing(A) istype(A, /obj/item/clothing)

#define iswearingredtag(A) istype(get_tag_armor(A), /obj/item/clothing/suit/tag/redtag)

#define iswearingbluetag(A) istype(get_tag_armor(A), /obj/item/clothing/suit/tag/bluetag)

#define isEmag(A) istype(A, /obj/item/weapon/card/emag)

#define istool(A) is_type_in_list(A, common_tools)

#define iswelder(A) istype(A, /obj/item/tool/weldingtool)

#define isshovel(A) istype(A, /obj/item/weapon/pickaxe/shovel)

#define ishammer(A) is_type_in_list(A, list(/obj/item/weapon/hammer, /obj/item/weapon/storage/toolbox))

#define iscablecoil(A) istype(A, /obj/item/stack/cable_coil)

#define iscoin(A) is_type_in_list(A, list(/obj/item/weapon/coin, /obj/item/weapon/reagent_containers/food/snacks/chococoin))

#define iswirecutter(A) istype(A, /obj/item/tool/wirecutters)

#define iswiretool(A) (iswirecutter(A) || ismultitool(A) || issignaler(A))

#define isbikehorn(A) istype(A, /obj/item/weapon/bikehorn)

#define isbanana(A) istype(A, /obj/item/weapon/reagent_containers/food/snacks/grown/banana)

#define isgun(A) istype(A, /obj/item/weapon/gun)

#define ispowercell(A) istype(A, /obj/item/weapon/cell)

#define ismultitool(A) istype(A, /obj/item/device/multitool)

#define iscrowbar(A) istype(A, /obj/item/tool/crowbar)

#define issolder(A) istype(A, /obj/item/tool/solder)

#define issocketwrench(A) istype(A, /obj/item/tool/wrench/socket)

#define isswitchtool(A) istype(A, /obj/item/weapon/switchtool)

#define isglasssheet(A) istype(A, /obj/item/stack/sheet/glass)

#define iscamera(A) istype(A, /obj/machinery/camera)

#define islightingoverlay(A) (istype(A, /atom/movable/light))

#define ischair(A) (istype(A, /obj/structure/bed/chair))

#define isvehicle(A) (istype(A, /obj/structure/bed/chair/vehicle))

#define istable(A) (istype(A, /obj/structure/table))

#define issilicatesprayer(A) (istype(A, /obj/item/device/silicate_sprayer))

#define iswindow(A) (istype(A, /obj/structure/window))

#define isfullwindow(A) (istype(A, /obj/structure/window/full))

#define isgripper(G) (istype(G, /obj/item/weapon/gripper))

#define isholyweapon(I) (istype(I, /obj/item/weapon/nullrod) || istype(I, /obj/item/weapon/gun/hookshot/whip/vampkiller))

#define isholyprotection(I) (istype(I, /obj/item/weapon/nullrod))

#define isAPC(A) istype(A, /obj/machinery/power/apc)

#define isimage(A) (istype(A, /image))

#define isdatum(A) (istype(A, /datum))

#define isclient(A) (istype(A, /client))

#define isatom(A) isloc(A)

#define isrealobject(A) (istype(A, /obj/item) || istype(A, /obj/structure) || istype(A, /obj/machinery) || istype(A, /obj/mecha))

#define iscleanaway(A) (istype(A,/obj/effect/decal/cleanable) || (istype(A,/obj/effect/overlay) && !istype(A,/obj/effect/overlay/puddle) && !istype(A, /obj/effect/overlay/hologram)) || istype(A,/obj/effect/rune_legacy) || (A.ErasableRune()))

#define ismatrix(A) (istype(A, /matrix))

#define ismecha(A) (istype(A, /obj/mecha))

#define isID(A) (istype(A, /obj/item/weapon/card/id))

#define isRoboID(A) (istype(A, /obj/item/weapon/card/robot))

#define isPDA(A) (istype(A, /obj/item/device/pda))

#define isfloor(A) (istype(A, /turf/simulated/floor) || istype(A, /turf/unsimulated/floor) || istype(A, /turf/simulated/floor/shuttle) || istype(A, /turf/simulated/floor/shuttle/brig))

#define isshuttleturf(A) (istype(A, /turf/simulated/wall/shuttle) || istype(A, /turf/simulated/floor/shuttle))

#define iswallturf(A) (istype(A, /turf/simulated/wall) || istype(A, /turf/unsimulated/wall) || istype(A, /turf/simulated/shuttle/wall))

#define issilent(A) (A.silent || (ishuman(A) && (A.mind && A.mind.miming || A:species:flags & SPECIES_NO_MOUTH))) //Remember that silent is not the same as miming. Miming you can emote, silent you can't gesticulate at all

#define hasanvil(H) (isturf(H) && (locate(/obj/item/anvil) in H))

#define ishoe(O) (is_type_in_list(O, list(/obj/item/weapon/minihoe, /obj/item/weapon/kitchen/utensil/fork)))

#define isbeam(I) (istype(I, /obj/item/projectile/beam) || istype(I, /obj/effect/beam))

#define isbelt(O) (istype(O, /obj/item/weapon/storage/belt) || istype(O, /obj/item/red_ribbon_arm))

#define isrig(O) (istype(O, /obj/item/clothing/suit/space/rig))

#define isrighelmet(O) (istype(O, /obj/item/clothing/head/helmet/space/rig))

#define isNonTimeDataReagent(R) (is_type_in_list(R, list( /datum/reagent/citalopram, /datum/reagent/paroxetine)))

#define isinvisible(A) (A.invisibility || A.alpha <= 1)

#define format_examine(A,B) "<span class = 'info'><a HREF='?src=\ref[user];lookitem=\ref[A]'>[B].</a></span>"

//Macros for roles/antags
#define isfaction(A) (istype(A, /datum/faction))

#define isrole(type, H) (H.mind && H.mind.GetRole(type))

#define isanyantag(H) (H.mind && H.mind.antag_roles.len)

#define hasFactionIcons(H) (H.mind && H.mind.hasFactionsWithHUDIcons())

#define isvampire(H) (H.mind ? H.mind.GetRole(VAMPIRE) : FALSE)

#define isthrall(H) (H.mind ? H.mind.GetRole(THRALL) : FALSE)

#define iscultist(H) (H.mind ? H.mind.GetRole(CULTIST) : FALSE)

#define isstreamer(H) (H.mind && H.mind.GetRole(STREAMER))

#define isvoxraider(H) (H.mind && H.mind.GetRole(VOXRAIDER))

#define islegacycultist(H) (H.mind && H.mind.GetRole(LEGACY_CULTIST))

#define isanycultist(H) (islegacycultist(H) || iscultist(H))

#define ischangeling(H) (H.mind && H.mind.GetRole(CHANGELING))

#define isrev(H) (isrevnothead(H) || isrevhead(H))

#define isrevnothead(H) (H.mind && H.mind.GetRole(REV))

#define isrevhead(H) (H.mind && H.mind.GetRole(HEADREV))

#define istraitor(H) (H.mind && H.mind.GetRole(TRAITOR))

#define ischallenger(H) (H.mind && H.mind.GetRole(CHALLENGER))

#define iselitesyndie(H) (H.mind && H.mind.GetRole(SYNDIESQUADIE))

#define ismalf(H) (H.mind && H.mind.GetRole(MALF))

#define isnukeop(H) (H.mind && H.mind.GetRole(NUKE_OP))

#define issyndicate(H) (H.mind && (H.mind.GetRole(TRAITOR) ||  H.mind.GetRole(SYNDIESQUADIE) || H.mind.GetRole(NUKE_OP) || H.mind.GetRole(CHALLENGER)))

#define iswizard(H) (H.mind && H.mind.GetRole(WIZARD))

#define isapprentice(H) (H.mind && H.mind.GetRole(WIZAPP))

#define isbadmonkey(H) ((/datum/disease/jungle_fever in H.viruses) || (H.mind && H.mind.GetRole(MADMONKEY)))

#define isdeathsquad(H) (H.mind && H.mind.GetRole(DEATHSQUADIE))

#define isbomberman(H) (H.mind && H.mind.GetRole(BOMBERMAN))

#define ishighlander(H) (H.mind && H.mind.GetRole(HIGHLANDER))

#define issurvivor(H) (H.mind && H.mind.GetRole(SURVIVOR))

#define iscrusader(H) (H.mind && H.mind.GetRole(CRUSADER))

#define ismagician(H) (H.mind && H.mind.GetRole(MAGICIAN))

#define isninja(H) (H.mind && H.mind.GetRole(NINJA))

#define isrambler(H) (H.mind && H.mind.GetRole(RAMBLER))

#define isloosecatbeast(H) (H.mind && H.mind.GetRole(CATBEAST))

#define istimeagent(H) (H.mind && (H.mind.GetRole(TIMEAGENT) || (H.mind.GetRole(TIMEAGENTTWIN))))

#define isERT(H) (H.mind && H.mind.GetRole(RESPONDER))

#define isclownling(H) (H.mind && H.mind.GetRole(CLOWN_LING))

#define istagmime(H) (H.mind && H.mind.GetRole(TAG_MIME))

//Banning someone from the Syndicate role bans them from all antagonist roles
#define isantagbanned(H) (jobban_isbanned(H, "Syndicate"))

#define iscluwnebanned(H) (jobban_isbanned(H, "Cluwne"))

// This might look silly. But it saves you up to 2 procs calls and a contents search. When you do thousands of it, it adds up.
#define CHECK_OCCLUSION(T) ((T?.blocks_light > 0) || CheckOcclusion(T))

//Macro for AREAS!

#define isspace(A) (A.type == /area)

#define isopenspace(A) istype(A, /turf/simulated/open)

//This one returns the "space" area
//#define get_space_area (get_area(locate(1,1,2))) //xd
/proc/get_space_area()
	//global.space_area is defined in code/game/areas/areas.dm, and set when the space area is created
	if(!global.space_area)
		var/area/new_space_area = new /area

		global.space_area = new_space_area

	return global.space_area

/**
	checks if the given atom is on a shuttle (non-specific)
	args: atom
	returns: shuttle type (or null if not on shuttle)
**/

/proc/is_on_shuttle(var/atom/A)
	var/area/AA = get_area(A)

	if(!AA) //How doth
		return 0

	for(var/datum/shuttle/S in shuttles)
		if(S.linked_area == AA)
			return S

	return 0

//1 line helper procs compressed into defines.

//Returns 1 if the variable contains a protected list that can't be edited
#define variable_contains_protected_list(var_name) (((var_name) == "contents") || ((var_name) == "locs") || ((var_name) == "vars"))

#define CLAMP01(x) 		(clamp(x, 0, 1))

//CPU lag shit
#define calculateticks(x)	x * world.tick_lag // Converts your ticks to proper tenths.
#define tcheck(CPU,TOSLEEP)	if(world.cpu > CPU) sleep(calculateticks(TOSLEEP)) //Shorthand of checking and then sleeping a process based on world CPU

//get_turf(): Returns the turf that contains the atom.
//Example: A fork inside a box inside a locker will return the turf the locker is standing on.
//Yes, this is the fastest known way to do it.
#define get_turf(A) (get_step(A, 0))

//Helper to check if two things are in the same z-level
#define	atoms_share_level(A, B) (A && B && A.z == B.z)

//HARDCORE MODE STUFF (mainly hunger)

#define hardcore_mode_on (hardcore_mode)//((ticker) && (ticker.hardcore_mode))
#define eligible_for_hardcore_mode(M) (M.ckey && M.client)

//Helper macro for eggs, called in process() of all fertilized eggs. If it returns 0, the egg will no longer be able to hatch
#define is_in_valid_nest(egg) (isturf(egg.loc))


#define subtypesof(A) (typesof(A) - A)

#define LIBVG(function, arguments...) call("./libvg.[world.system_type == UNIX ? "so" : "dll"]", function)(arguments)

// For areas that are on the map, `x` is the coordinate of the turf with the lowest z, y, and x coordinate (in that order) that is contained by the area.
#define is_area_in_map(A) (A.x)

#define SNOW_THEME (map.snow_theme || Holiday == XMAS || Holiday == XMAS_EVE)

#define get_conductivity(A) (A ? A.siemens_coefficient : 1)

//Swaps the contents of the variables A and B. The if(TRUE) is there simply to restrict the scope of _.
//Yes, _ is a shitty variable name. Hopefully so shitty it won't ever be used anywhere it could conflict with this.
#define swap_vars(A, B) if(TRUE){var/_ = A; A = B; B = _}

// To prevent situations of trying to take funds that are factions of our lowest denomination
#define LOWEST_DENOMINATION 1
#define round_to_lowest_denomination(A) (round(A, LOWEST_DENOMINATION))

#define create_trader_account create_account("Trader Shoal", 0, null, 0, 1, TRUE, FALSE)
//Starts 0 credits, not sourced from any database, earns 0 credits, hidden

// strips all newlines from a string, replacing them with null
#define STRIP_NEWLINE(S) replacetextEx(S, "\n", null)

#define istransformable(A) (isatom(A))
#define isapperanceeditable(A) (isatom(A))

#define OMNI_LINK(A,B) isliving(A) && A:omnitool_connect(B)
