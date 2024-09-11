//Biomes and their temperature-precipitation mappings, flora, and structures are defined here.
/datum/procedural_biome
	var/list/temperature = list()
	var/list/precipitation = list()
	var/list/turf/floor_turfs = list()
	var/list/turf/wall_turfs = list()
	var/turf/water_turf = /turf/unsimulated/beach/water
	var/list/obj/structure/flora = list()
	var/list/obj/structure/structures = list()
	var/area/biome_area

/datum/procedural_biome/permafrost // Permanently-frozen layer of ice covering rock.
	temperature = list(PG_FROZEN)
	precipitation = list(PG_NO_PRECIP, PG_L_PRECIP, PG_M_PRECIP, PG_H_PRECIP, PG_VH_PRECIP)
	floor_turfs = list(
		/turf/unsimulated/floor/snow/permafrost,
		/turf/unsimulated/floor/snow
		)
	wall_turfs = list(/turf/unsimulated/wall/rock/ice, /turf/unsimulated/mineral/snow)
	flora = list()
	structures = list()

/datum/procedural_biome/ice_sheet // A thick sheet of ice covering liquid water."
	temperature = list(PG_COLD, PG_FROZEN)
	precipitation = list(PG_NO_PRECIP, PG_L_PRECIP, PG_M_PRECIP, PG_H_PRECIP, PG_VH_PRECIP)
	floor_turfs = list(/turf/unsimulated/floor/snow/permafrost)
	wall_turfs = list(/turf/unsimulated/wall/rock/ice)
	flora = list()
	structures = list()

/datum/procedural_biome/tundra // A biome where plant growth is hindered by extreme cold.
	temperature = list(PG_COLD)
	precipitation = list(PG_NO_PRECIP, PG_L_PRECIP)
	floor_turfs = list(
		/turf/unsimulated/floor/snow,
		/turf/unsimulated/floor/snow/dirt
		)
	wall_turfs = list(/turf/unsimulated/wall/rock/ice)
	flora = list()
	structures = list()

/datum/procedural_biome/taiga // A biome filled with confierous forests and thick snow.
	temperature = list(PG_COLD, PG_BRISK)
	precipitation = list(PG_NO_PRECIP, PG_L_PRECIP, PG_M_PRECIP)
	floor_turfs = list(/turf/unsimulated/floor/snow)
	wall_turfs = list(/turf/unsimulated/mineral/underground)
	flora = list()
	structures = list()

/datum/procedural_biome/forest // Deciduous forest.
	temperature = list(PG_COLD, PG_BRISK, PG_TEMPERATE)
	precipitation = list(PG_M_PRECIP, PG_H_PRECIP, PG_VH_PRECIP)
	floor_turfs = list(/turf/unsimulated/floor/asteroid)
	wall_turfs = list(/turf/unsimulated/wall/rock)
	flora = list()
	structures = list()

/datum/procedural_biome/plains // Open fields of grass and bushes.
	temperature = list(PG_BRISK, PG_TEMPERATE)
	precipitation = list(PG_NO_PRECIP, PG_L_PRECIP, PG_M_PRECIP)
	floor_turfs = list(/turf/unsimulated/floor/asteroid)
	wall_turfs = list(/turf/unsimulated/wall/rock)
	flora = list()
	structures = list()

/datum/procedural_biome/shrubland // Hot fields of short grass and shrubs.
	temperature = list(PG_WARM)
	precipitation = list(PG_L_PRECIP, PG_M_PRECIP)
	floor_turfs = list(/turf/unsimulated/floor/asteroid)
	wall_turfs = list(/turf/unsimulated/wall/rock)
	flora = list()
	structures = list()

/datum/procedural_biome/swamp // Wet grassland with mangroves.
	temperature = list(PG_TEMPERATE, PG_WARM)
	precipitation = list(PG_H_PRECIP)
	floor_turfs = list(/turf/unsimulated/floor/asteroid)
	wall_turfs = list(/turf/unsimulated/wall/rock)
	flora = list()
	structures = list()

/datum/procedural_biome/rainforest // Dense forest with lots of undergrowth.
	temperature = list(PG_TEMPERATE, PG_WARM, PG_HOT)
	precipitation = list(PG_VH_PRECIP)
	floor_turfs = list(/turf/unsimulated/floor/asteroid)
	wall_turfs = list(/turf/unsimulated/wall/rock)
	flora = list()
	structures = list()

/datum/procedural_biome/savanna // Open fields of short grass with limited vegetation.
	temperature = list(PG_HOT)
	precipitation = list(PG_M_PRECIP, PG_H_PRECIP)
	floor_turfs = list(/turf/unsimulated/floor/asteroid)
	wall_turfs = list(/turf/unsimulated/wall/rock)
	flora = list()
	structures = list()

/datum/procedural_biome/desert // Rolling plains of sand with sparse vegetation.
	temperature = list(PG_HOT)
	precipitation = list(PG_NO_PRECIP, PG_L_PRECIP)
	floor_turfs = list(/turf/unsimulated/floor/asteroid)
	wall_turfs = list(/turf/unsimulated/wall/rock)
	flora = list()
	structures = list()

/datum/procedural_biome/magma // Fields of igneous rocks and magma pools.
	temperature = list(PG_LAVA)
	precipitation = list(PG_NO_PRECIP,PG_L_PRECIP)
	floor_turfs = list(/turf/unsimulated/floor/asteroid)
	wall_turfs = list(/turf/unsimulated/wall/rock)
	flora = list()
	structures = list()

/datum/procedural_biome/ash // Open fields of soot.
	temperature = list(PG_LAVA)
	precipitation = list(PG_L_PRECIP, PG_M_PRECIP, PG_H_PRECIP, PG_VH_PRECIP)
	floor_turfs = list()
	wall_turfs = list(/turf/unsimulated/wall/rock)
	flora = list(/turf/unsimulated/floor/asteroid)
	structures = list()

/datum/procedural_biome/asteroid // Standard asteroid biome."
	temperature = list(PG_TEMPERATE, PG_WARM, PG_HOT)
	precipitation = list(PG_NO_PRECIP)
	floor_turfs = list(/turf/unsimulated/floor/asteroid)
	wall_turfs = list(/turf/unsimulated/wall/rock)
	flora = list()
	structures = list()

/datum/procedural_biome/comet // Frozen version of an asteroid.
	temperature = list(PG_FROZEN, PG_COLD)
	precipitation = list(PG_NO_PRECIP)
	floor_turfs = list(/turf/unsimulated/floor/asteroid)
	wall_turfs = list(/turf/unsimulated/wall/rock/ice)
	flora = list()
	structures = list()

/datum/procedural_biome/rock // Sparse fields of grey sand and rocks.
	temperature = list(PG_TEMPERATE, PG_WARM)
	precipitation = list(PG_NO_PRECIP, PG_L_PRECIP, PG_M_PRECIP, PG_H_PRECIP, PG_VH_PRECIP)
	floor_turfs = list()
	wall_turfs = list(/turf/unsimulated/wall/rock)
	flora = list()
	structures = list()
