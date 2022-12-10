//Mob-reagent thermal interactions
#define MOB_HEAT_MULT 0.05 //Multiplier to mob thermal mass to scale how drinking hot or cold reagents impacts the mob's body temperature. Lower causes the thermal shift to be higher.
#define SPECHEATCAP_HUMANBODY 2.98 //Specific heat capacity of the human body.
#define SPECHEATCAP_MUSHROOM 3.935 //Specific heat of mushrooms.
#define SPECHEATCAP_LEAF 4.2 //Dionaea
#define SPECHEATCAP_BONE 1.313 //Cortical bone.
#define SPECHEATCAP_PLASMA (200 / 405) //For plasmamen, values taken from XGM_gases.dm. It's gas phase there and solid here but should be okay.
#define SPECHEATCAP_SLIME 1.24 //Same as slime jelly.
#define SPECHEATCAP_ADAMANTINE 0.2 //For golems, around the same range as gold and silver.
#define HUMANBODY_BONE_FRACTION 0.15 //Skellington and plasmaman mass multiplier to account for being mostly bones (or plasma bones).
#define HUMANBODY_BLOOD_FRACTION 0.1 //Blood mass fraction of the human body.