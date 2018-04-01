#define SOLID 			1
#define LIQUID			2
#define GAS				3


// container_type defines
#define INJECTABLE		1	// Makes it possible to add reagents through droppers and syringes.
#define DRAWABLE		2	// Makes it possible to remove reagents through syringes.

#define REFILLABLE		4	// Makes it possible to add reagents through any reagent container.
#define DRAINABLE		8	// Makes it possible to remove reagents through any reagent container.

#define TRANSPARENT		16	// Used on containers which you want to be able to see the reagents off.
#define AMOUNT_VISIBLE	32	// For non-transparent containers that still have the general amount of reagents in them visible.

// Is an open container for all intents and purposes.
#define OPENCONTAINER 	REFILLABLE | DRAINABLE | TRANSPARENT


#define TOUCH			1	// splashing
#define INGEST			2	// ingestion
#define VAPOR			3	// foam, spray, blob attack
#define PATCH			4	// patches
#define INJECT			5	// injection


//defines passed through to the on_reagent_change proc
#define DEL_REAGENT		1	// reagent deleted (fully cleared)
#define ADD_REAGENT		2	// reagent added
#define REM_REAGENT		3	// reagent removed (may still exist)
