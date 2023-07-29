// You should only modify this file if you're creating new maps or deleting them
// welcome to macro hell

// here's how this works (you don't need to know this):
// each map file (tgstation.dm, test_tiny.dm, etc.) is enclosed in a `#ifndef MAP_OVERRIDE`
// - on a freshly pulled unmodified build: MAP_OVERRIDE is not defined, so
//   whatever map is specified in the .dme is compiled
// - if MAP_OVERRIDE is set to one of the magic numbers corresponding to a map:
//   the abomination below will undefine the MAP_OVERRIDE macro, include the map,
//   then redefine it so that the map specified by the .dme is skipped

#ifdef MAP_OVERRIDE
	#if MAP_OVERRIDE == 0
		#undef MAP_OVERRIDE
		#include "bagelstation.dm"
		#define MAP_OVERRIDE 0
	#elif MAP_OVERRIDE == 1
		#undef MAP_OVERRIDE
		#include "defficiency.dm"
		#define MAP_OVERRIDE 1
	#elif MAP_OVERRIDE == 2
		#undef MAP_OVERRIDE
		#include "metaclub.dm"
		#define MAP_OVERRIDE 2
	#elif MAP_OVERRIDE == 3
		#undef MAP_OVERRIDE
		#include "packedstation.dm"
		#define MAP_OVERRIDE 3
	#elif MAP_OVERRIDE == 4
		#undef MAP_OVERRIDE
		#include "roidstation.dm"
		#define MAP_OVERRIDE 4
	#elif MAP_OVERRIDE == 6
		#undef MAP_OVERRIDE
		#include "test_tiny.dm"
		#define MAP_OVERRIDE 6
	#elif MAP_OVERRIDE == 7
		#undef MAP_OVERRIDE
		#include "tgstation.dm"
		#define MAP_OVERRIDE 7
	#elif MAP_OVERRIDE == 8
		#undef MAP_OVERRIDE
		#include "snaxi.dm"
		#define MAP_OVERRIDE 8
	#elif MAP_OVERRIDE == 9
		#undef MAP_OVERRIDE
		#include "nrvhorizon.dm"
		#define MAP_OVERRIDE 9
	#elif MAP_OVERRIDE == 10
		#undef MAP_OVERRIDE
		#include "synergy.dm"
		#define MAP_OVERRIDE 10
	#elif MAP_OVERRIDE == 11
		#undef MAP_OVERRIDE
		#include "waystation.dm"
		#define MAP_OVERRIDE 11
	#elif MAP_OVERRIDE == 12
		#undef MAP_OVERRIDE
		#include "lowfatbagel.dm"
		#define MAP_OVERRIDE 12
	#elif MAP_OVERRIDE == 13
		#undef MAP_OVERRIDE
		#include "line.dm"
		#define MAP_OVERRIDE 13
	#elif MAP_OVERRIDE == 14
		#undef MAP_OVERRIDE
		#include "test_very_tiny.dm"
		#define MAP_OVERRIDE 14
	#elif MAP_OVERRIDE == 15
		#undef MAP_OVERRIDE
		#include "test_vault.dm"
		#define MAP_OVERRIDE 15
	#endif
#endif
