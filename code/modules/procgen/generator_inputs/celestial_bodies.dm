//Planet types and their biome mappings are defined here.
var/list/datum/procgen/celestial_body/celestial_bodies = list(
	/datum/procgen/celestial_body/asteroids,
	/datum/procgen/celestial_body/moon,
	/datum/procgen/celestial_body/planet,
	/datum/procgen/celestial_body/xeno
)

/datum/procgen/celestial_body
	var/list/body_atmospheres = list()
	var/list/body_biomes = list()
	var/list/body_precipitation = list()
	var/weight
	var/list/map_size = list()

/datum/procgen/celestial_body/asteroids
	name = "Asteroid Field"
	desc = "One or more asteroids floating through space."
	body_atmospheres = list(PG_VACUUM)
	body_precipitation = list(PG_NO_PRECIP)
	body_biomes = list(PG_ASTEROID, PG_COMET)
	weight = PG_ASTEROID_WEIGHT
	map_size = list(PG_SMALL)

/datum/procgen/celestial_body/moon
	name = "Moon"
	desc = "A lifeless mass of rock, lava, or ice."
	body_atmospheres = list(PG_VACUUM, PG_THIN)
	body_precipitation = list(PG_NO_PRECIP, PG_L_PRECIP, PG_M_PRECIP, PG_H_PRECIP, PG_VH_PRECIP) //preciptation is used to determine amount of ash plains vs magma fields
	body_biomes = list(PG_PERMAFROST, PG_ICE_SHEET, PG_ROCK, PG_MAGMA, PG_ASH)
	weight = PG_MOON_WEIGHT
	map_size = list(PG_SMALL, PG_MEDIUM)

/datum/procgen/celestial_body/planet
	name = "Planet"
	desc = "A planet which may contain an atmosphere, flora, and fauna."
	body_atmospheres = list(PG_THIN, PG_BREATHABLE)
	body_precipitation = list(PG_NO_PRECIP, PG_L_PRECIP, PG_M_PRECIP, PG_H_PRECIP, PG_VH_PRECIP)
	body_biomes = list(PG_PERMAFROST, PG_ICE_SHEET, PG_TUNDRA, PG_FOREST, PG_PLAINS, PG_SHRUBLAND, PG_SWAMPLAND, PG_RAINFOREST, PG_SAVANNA, PG_DESERT, PG_MAGMA, PG_ASH)
	weight = PG_PLANET_WEIGHT
	map_size = list(PG_MEDIUM, PG_LARGE)

/datum/procgen/celestial_body/xeno
	name = "Xeno Planet"
	desc = "A planet which may contain a toxic atmosphere along with mysterious flora and fauna."
	body_atmospheres = list(PG_BREATHABLE, PG_TOXIC)
	body_precipitation = list(PG_NO_PRECIP, PG_L_PRECIP, PG_M_PRECIP, PG_H_PRECIP, PG_VH_PRECIP)
	body_biomes = list()
	weight = PG_XENO_WEIGHT
	map_size = list(PG_MEDIUM, PG_LARGE)
