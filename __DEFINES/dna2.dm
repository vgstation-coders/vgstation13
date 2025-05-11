// What each index means:
#define DNA_OFF_LOWERBOUND 1
#define DNA_OFF_UPPERBOUND 2
#define DNA_ON_LOWERBOUND  3
#define DNA_ON_UPPERBOUND  4

// Define block bounds (off-low,off-high,on-low,on-high)
// Used in setupgame.dm
#define DNA_DEFAULT_BOUNDS list(1,2049,2050,4095)
#define DNA_HARDER_BOUNDS  list(1,3049,3050,4095)
#define DNA_HARD_BOUNDS    list(1,3490,3500,4095)

// UI Indices (can change to mutblock style, if desired)
#define DNA_UI_HAIR_R      1
#define DNA_UI_HAIR_G      2
#define DNA_UI_HAIR_B      3
#define DNA_UI_BEARD_R     4
#define DNA_UI_BEARD_G     5
#define DNA_UI_BEARD_B     6
#define DNA_UI_SKIN_TONE   7
#define DNA_UI_EYES_R      8
#define DNA_UI_EYES_G      9
#define DNA_UI_EYES_B      10
#define DNA_UI_GENDER      11
#define DNA_UI_BEARD_STYLE 12
#define DNA_UI_HAIR_STYLE  13
#define DNA_UI_LENGTH      13 // Update this when you add something, or you WILL break shit.

// Bit flag related to a dna2 block.
#define MUTCHK_FORCED        1

/////////////////
// GENE DEFINES
/////////////////

// Skip checking if it's already active.
// Used for genes that check for value rather than a binary on/off.
#define GENE_ALWAYS_ACTIVATE   1

// One of the genes that can't be handed out at roundstart
#define GENE_UNNATURAL         2

// Species gene
#define GENE_NATURAL           4

#define GENETYPE_BAD  0
#define GENETYPE_GOOD 1
