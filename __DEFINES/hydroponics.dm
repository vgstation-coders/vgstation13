#define HYDRO_SPEED_MULTIPLIER 1

// Xenobotany machines
#define GENEGUN_MODE_SPLICE 1
#define GENEGUN_MODE_PURGE 2

#define HYDRO_PREHISTORIC 1
#define HYDRO_VOX 2

// Definitions for genes (trait groupings)
#define GENE_PHYTOCHEMISTRY "phytochemistry"
#define GENE_MORPHOLOGY "morphology"
#define GENE_BIOLUMINESCENCE "bioluminescence"
#define GENE_ECOLOGY "ecology"
#define GENE_ECOPHYSIOLOGY "ecophysiology"
#define GENE_METABOLISM "metabolism"
#define GENE_DEVELOPMENT "development"
#define GENE_XENOPHYSIOLOGY "xenophysiology"

//Defines for maximum amounts in the trays
#define WATERLEVEL_MAX 100
#define NUTRIENTLEVEL_MAX 100
#define PESTLEVEL_MAX 100
#define WEEDLEVEL_MAX 100
#define TOXINLEVEL_MAX 100

//Xenobotany mutations
//Phytochemistry
#define PLANT_CHEMICAL (1<<0)
#define PLANT_POTENCY (1<<1) 

//Morphology
#define PLANT_PRODUCTS (1<<0)
#define PLANT_THORNY (1<<1)
#define PLANT_STINGING (1<<2)
#define PLANT_LIGNEOUS (1<<3)
#define PLANT_JUICY (1<<4)
#define PLANT_APPEARANCE (1<<5)

//Bioluminescence
#define PLANT_BIOLUM_COLOR (1<<0)
#define PLANT_BIOLUM (1<<1)

//Ecology
#define PLANT_TEMPERATURE_IDEAL (1<<0)
#define PLANT_HEAT_TOLERANCE (1<<1)
#define PLANT_PRESSURE_TOLERANCE (1<<2)
#define PLANT_LIGHT_IDEAL (1<<3)
#define PLANT_LIGHT_TOLERANCE (1<<4)

//Ecophysiology
#define PLANT_TOXIN_AFFINITY (1<<0)
#define PLANT_WEED_TOLERANCE (1<<1)
#define PLANT_PEST_TOLERANCE (1<<2)
#define PLANT_LIFESPAN (1<<3)
#define PLANT_ENDURANCE (1<<4)

//Metabolism
#define PLANT_NUTRIENT_CONSUMPTION (1<<0)
#define PLANT_FLUID_CONSUMPTION (1<<1)
#define PLANT_VORACIOUS (1<<2)
#define PLANT_HEMATOPHAGE (1<<3)

//Development
#define PLANT_PRODUCTION (1<<0)
#define PLANT_MATURATION (1<<1)
#define PLANT_SPREAD (1<<2)
#define PLANT_HARVEST (1<<3) //note that auto_harvest = 2 is unused
#define PLANT_YIELD (1<<4)

//Xenophysiology
#define PLANT_TELEPORT (1<<0)
#define PLANT_ROOMTEMP (1<<1)
#define PLANT_GAS (1<<2)
#define PLANT_NOREACT (1<<3) //unique to xeno plants, unused