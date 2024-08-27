//Biomes and their temperature-precipitation mappings, flora, and structures are defined here.
/datum/procgen/biome
	var/list/temperature = list()
	var/list/precipitation = list()
	var/list/turf/floor_turfs = list()
	var/list/turf/wall_turfs = list()
	var/list/obj/structure/flora = list()
	var/list/obj/structure/structures = list()

/datum/procgen/biome/permafrost
	name = "Permafrost"
	desc = "Permanently-frozen layer of ice covering rock."
	temperature = list(PG_FROZEN)
	precipitation = list(PG_NO_PRECIP, PG_L_PRECIP, PG_M_PRECIP, PG_H_PRECIP, PG_VH_PRECIP)
	floor_turfs = list()
	wall_turfs = list()
	flora = list()
	structures = list()

/datum/procgen/biome/ice_sheet
	name = "Ice Sheet"
	desc = "A thick sheet of ice covering liquid water."
	temperature = list(PG_COLD, PG_FROZEN)
	precipitation = list(PG_NO_PRECIP, PG_L_PRECIP, PG_M_PRECIP, PG_H_PRECIP, PG_VH_PRECIP)
	floor_turfs = list()
	wall_turfs = list()
	flora = list()
	structures = list()

/datum/procgen/biome/tundra
	name = "Tundra"
	desc = "A biome where plant growth is hindered by extreme cold."
	temperature = list(PG_COLD)
	precipitation = list(PG_NO_PRECIP, PG_L_PRECIP)
	floor_turfs = list()
	wall_turfs = list()
	flora = list()
	structures = list()

/datum/procgen/biome/taiga
	name = "Taiga"
	desc = "A biome filled with confierous forests and thick snow."
	temperature = list(PG_COLD, PG_BRISK)
	precipitation = list(PG_NO_PRECIP, PG_L_PRECIP, PG_M_PRECIP)
	floor_turfs = list()
	wall_turfs = list()
	flora = list()
	structures = list()

/datum/procgen/biome/forest
	name = "Forest"
	desc = "Deciduous forest."
	temperature = list(PG_COLD, PG_BRISK, PG_TEMPERATE)
	precipitation = list(PG_M_PRECIP, PG_H_PRECIP, PG_VH_PRECIP)
	floor_turfs = list()
	wall_turfs = list()
	flora = list()
	structures = list()

/datum/procgen/biome/plains
	name = "Plains"
	desc = "Open fields of grass and bushes."
	temperature = list(PG_BRISK, PG_TEMPERATE)
	precipitation = list(PG_NO_PRECIP, PG_L_PRECIP, PG_M_PRECIP)
	floor_turfs = list()
	wall_turfs = list()
	flora = list()
	structures = list()

/datum/procgen/biome/shrubland
	name = "Shrubland"
	desc = "Hot fields of short grass and shrubs."
	temperature = list(PG_WARM)
	precipitation = list(PG_L_PRECIP, PG_M_PRECIP)
	floor_turfs = list()
	wall_turfs = list()
	flora = list()
	structures = list()

/datum/procgen/biome/swamp
	name = "Swamp"
	desc = "Wet grassland with mangroves."
	temperature = list(PG_TEMPERATE, PG_WARM)
	precipitation = list(PG_H_PRECIP)
	floor_turfs = list()
	wall_turfs = list()
	flora = list()
	structures = list()

/datum/procgen/biome/rainforest
	name = "Rainforest"
	desc = "Dense forest with lots of undergrowth."
	temperature = list(PG_TEMPERATE, PG_WARM, PG_HOT)
	precipitation = list(PG_VH_PRECIP)
	floor_turfs = list()
	wall_turfs = list()
	flora = list()
	structures = list()

/datum/procgen/biome/savanna
	name = "Savanna"
	desc = "Open fields of short grass with limited vegetation."
	temperature = list(PG_HOT)
	precipitation = list(PG_M_PRECIP, PG_H_PRECIP)
	floor_turfs = list()
	wall_turfs = list()
	flora = list()
	structures = list()

/datum/procgen/biome/desert
	name = "Desert"
	desc = "Rolling plains of sand with sparse vegetation."
	temperature = list(PG_HOT)
	precipitation = list(PG_NO_PRECIP, PG_L_PRECIP)
	floor_turfs = list()
	wall_turfs = list()
	flora = list()
	structures = list()

/datum/procgen/biome/magma
	name = "Magma Fields"
	desc = "Fields of igneous rocks and magma pools."
	temperature = list(PG_LAVA)
	precipitation = list(PG_NO_PRECIP,PG_L_PRECIP)
	floor_turfs = list()
	wall_turfs = list()
	flora = list()
	structures = list()

/datum/procgen/biome/ash
	name = "Ash Plains"
	desc = "Open fields of soot."
	temperature = list(PG_LAVA)
	precipitation = list(PG_L_PRECIP, PG_M_PRECIP, PG_H_PRECIP, PG_VH_PRECIP)
	floor_turfs = list()
	wall_turfs = list()
	flora = list()
	structures = list()

/datum/procgen/biome/asteroid
	name = "Asteroid"
	desc = "Standard asteroid biome."
	temperature = list(PG_TEMPERATE, PG_WARM, PG_HOT)
	precipitation = list(PG_NO_PRECIP)
	floor_turfs = list()
	wall_turfs = list()
	flora = list()
	structures = list()

/datum/procgen/biome/comet
	name = "Comet"
	desc = "Frozen version of an asteroid."
	temperature = list(PG_FROZEN, PG_COLD)
	precipitation = list(PG_NO_PRECIP)
	floor_turfs = list()
	wall_turfs = list()
	flora = list()
	structures = list()

/datum/procgen/biome/rock
	name = "Rock Fields"
	desc = "Sparse fields of grey sand and rocks."
	temperature = list(PG_TEMPERATE, PG_WARM)
	precipitation = list(PG_NO_PRECIP, PG_L_PRECIP, PG_M_PRECIP, PG_H_PRECIP, PG_VH_PRECIP)
	floor_turfs = list()
	wall_turfs = list()
	flora = list()
	structures = list()
