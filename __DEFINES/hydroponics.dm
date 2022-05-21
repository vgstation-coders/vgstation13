#define HYDRO_SPEED_MULTIPLIER 1

// Definitions for genes (trait groupings)
#define GENE_PHYTOCHEMISTRY "phytochemistry"
#define GENE_MORPHOLOGY "morphology"
#define GENE_BIOLUMINESCENCE "bioluminescence"
#define GENE_ECOLOGY "ecology"
#define GENE_ECOPHYSIOLOGY "ecophysiology"
#define GENE_METABOLISM "metabolism"
#define GENE_NUTRITION "nutrition"
#define GENE_DEVELOPMENT "development"

// Defines for mutation categories and names.
#define MUTCAT_GOOD "SomethingGood"
#define MUTCAT_WEIRD "SomethingWeird"
#define MUTCAT_BAD "SomethingBad"
#define MUTCAT_DANGEROUS "SomethingDangerous"


//Defines for maximum amounts in the trays
#define MUTATIONLEVEL_MAX 100
#define NUTRIENTLEVEL_MAX 100
#define WATERLEVEL_MAX 100
#define PESTLEVEL_MAX 100
#define WEEDLEVEL_MAX 100
#define TOXINLEVEL_MAX 100
#define YIELDMOD_MAX 2
#define MUTATIONMOD_MAX 3

// Xenobotany machines
#define GENEGUN_MODE_SPLICE 1
#define GENEGUN_MODE_PURGE 2

#define HYDRO_PREHISTORIC 1
#define HYDRO_VOX 2


//Xenobotany

//Good
#define PLANT_STAT_POTENCY (1<<0)
#define PLANT_STAT_YIELD (1<<1)
#define PLANT_STAT_WEEDTOLERANCE (1<<2)
#define PLANT_STAT_TOXINAFFINITY (1<<3)
#define PLANT_STAT_LIFESPAN (1<<4)
#define PLANT_STAT_ENDURANCE (1<<5)
#define PLANT_STAT_PRODUCTION (1<<6)
#define PLANT_STAT_MATURATION (1<<7)
#define PLANT_STAT_HEAT (1<<8)
#define PLANT_STAT_PRESSURE (1<<9)
#define PLANT_STAT_LIGHT (1<<10)
#define PLANT_STAT_NUTRIENT (1<<11)
#define PLANT_STAT_FLUID (1<<12)
#define PLANT_STAT_HARVEST (1<<13)

//Weird
#define PLANT_BIOLUM_COLOR (1<<0)
#define PLANT_BIOLUM (1<<1)
#define PLANT_JUICY (1<<2)
#define PLANT_SLIPPERY(1<<3)
#define PLANT_THORNY (1<<4)
#define PLANT_PARASITIC (1<<5)
#define PLANT_CARNIVOROUS (1<<6)
#define PLANT_CARNIVOROUS2 (1<<7)
#define PLANT_LIGNEOUS (1<<8)

//BAD
9;						PLANT_STAT_POTENCY, \
S.yield == -1 ? 0 : 6;	PLANT_STAT_YIELD, \
1;						PLANT_STAT_WEEDTOLERANCE, \
1;                      PLANT_STAT_TOXINAFFINITY, \
2;						PLANT_STAT_LIFESPAN, \
2;                      PLANT_STAT_ENDURANCE, \
2;						PLANT_STAT_PRODUCTION, \
2;                      PLANT_STAT_MATURATION, \
1;                      PLANT_STAT_HEAT, \
1;						PLANT_STAT_PRESSURE,\
2;						PLANT_STAT_LIGHT, \
1;						"plusstat_nutrient&water_consumption", \
S.yield != -1 && !S.harvest_repeat ? 0.4 : 0;	"toggle_repeatharvest"
)
if(MUTCAT_WEIRD)
mutation_type = pick(\
S.biolum ? 10 : 0;			"biolum_changecolor",\
S.biolum ? 1 : 10;			"trait_biolum",\
S.juicy ? 0.5 : 5;			"trait_juicy", \
S.juicy == 1 ? 10 : 2 ;		"trait_slippery", \
S.thorny ? 0.2 : 5;			"trait_thorns",\
S.parasite ? 0.2 : 5;		"trait_parasitic",\
S.carnivorous ? 0.1 : 5;	"trait_carnivorous",\
S.carnivorous == 1 ? 8 : 2;	"trait_carnivorous2",\
S.ligneous ? 0.2 : 5;		"trait_ligneous"
)
if(MUTCAT_WEIRD2)
mutation_type = pick(\
4;					"chemical_exotic", \
6;					"fruit_exotic", \
2;					"change_appearance", \
S.spread ? 0.1 : 1;	"trait_creepspread"
)
if(MUTCAT_BAD)
mutation_type = pick(\
3;	"tox_increase", \
2;	"weed_increase", \
2;	"pest_increase", \
5;	"stunt_growth"
)
if(MUTCAT_BAD2)
mutation_type = pick(\
S.hematophage ? 0.2 : 5;	"trait_hematophage", \
5;							"randomize_light", \
5;							"randomize_temperature", \
2;							"breathe_aliengas", \
S.yield != -1 && S.harvest_repeat ? 2 : 0;	"toggle_repeatharvest",\
)
if(MUTCAT_DANGEROUS)
mutation_type = pick(\
4;						"spontaneous_creeper", \
1;						"spontaneous_kudzu", \
S.spread == 1 ? 5 : 1;	"trait_vinespread",
S.stinging ? 0.2 : 4;	"trait_stinging", \
1;						"exude_dangerousgas", \
S.alter_temp ? 0.2 : 2;	"change_roomtemp"