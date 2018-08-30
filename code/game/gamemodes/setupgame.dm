var/BLINDBLOCK = 0
var/DEAFBLOCK = 0
var/HULKBLOCK = 0
var/TELEBLOCK = 0
var/FIREBLOCK = 0
var/XRAYBLOCK = 0
var/CLUMSYBLOCK = 0
var/FAKEBLOCK = 0
var/COUGHBLOCK = 0
var/GLASSESBLOCK = 0
var/EPILEPSYBLOCK = 0
var/TWITCHBLOCK = 0
var/NERVOUSBLOCK = 0
var/MONKEYBLOCK = DNA_SE_LENGTH

var/BLOCKADD = 0
var/DIFFMUT = 0

var/HEADACHEBLOCK = 0
var/NOBREATHBLOCK = 0
var/REMOTEVIEWBLOCK = 0
var/REGENERATEBLOCK = 0
var/INCREASERUNBLOCK = 0
var/REMOTETALKBLOCK = 0
var/MORPHBLOCK = 0
var/COLDBLOCK = 0
var/HALLUCINATIONBLOCK = 0
var/NOPRINTSBLOCK = 0
var/SHOCKIMMUNITYBLOCK = 0
var/SMALLSIZEBLOCK = 0

///////////////////////////////
// Goon Stuff
///////////////////////////////
// Disabilities
var/LISPBLOCK = 0
var/MUTEBLOCK = 0
var/RADBLOCK = 0
var/FATBLOCK = 0
var/CHAVBLOCK = 0
var/SWEDEBLOCK = 0
var/SCRAMBLEBLOCK = 0
var/TOXICFARTBLOCK = 0
var/STRONGBLOCK = 0
var/HORNSBLOCK = 0
var/SMILEBLOCK = 0
var/ELVISBLOCK = 0

// Powers
var/SOBERBLOCK = 0
var/PSYRESISTBLOCK = 0
//var/SHADOWBLOCK = 0
var/FARSIGHTBLOCK = 0
var/CHAMELEONBLOCK = 0
var/CRYOBLOCK = 0
var/EATBLOCK = 0
var/JUMPBLOCK = 0
var/MELTBLOCK = 0
var/EMPATHBLOCK = 0
var/SUPERFARTBLOCK = 0
var/IMMOLATEBLOCK = 0
var/POLYMORPHBLOCK = 0

///////////////////////////////
// /vg/ Mutations
///////////////////////////////
var/LOUDBLOCK = 0
var/WHISPERBLOCK = 0
var/DIZZYBLOCK = 0
var/SANSBLOCK = 0
var/NOIRBLOCK = 0
var/VEGANBLOCK = 0
var/ASTHMABLOCK = 0
var/LACTOSEBLOCK = 0


/proc/getAssignedBlock(var/name,var/list/blocksLeft, var/activity_bounds=DNA_DEFAULT_BOUNDS, var/good=0)
	if(blocksLeft.len==0)
		warning("[name]: No more blocks left to assign!")
		return 0
	var/assigned = pick(blocksLeft)
	blocksLeft.Remove(assigned)
	if(good)
		good_blocks += assigned
	else
		bad_blocks += assigned
	assigned_blocks[assigned]=name
	dna_activity_bounds[assigned]=activity_bounds
	//testing("[name] assigned to block #[assigned].")
	return assigned

/proc/setupgenetics()


	if (prob(50))
		BLOCKADD = rand(-300,300)
	if (prob(75))
		DIFFMUT = rand(0,20)

	//Thanks to nexis for the fancy code
	// BITCH I AIN'T DONE YET

	// SE blocks to assign.
	var/list/numsToAssign=new()
	for(var/i=1;i<DNA_SE_LENGTH;i++)
		numsToAssign += i

	//testing("Assigning DNA blocks:")

	// Standard muts
	BLINDBLOCK         = getAssignedBlock("BLIND",         numsToAssign)
	DEAFBLOCK          = getAssignedBlock("DEAF",          numsToAssign)
	HULKBLOCK          = getAssignedBlock("HULK",          numsToAssign, DNA_HARD_BOUNDS, good=1)
	TELEBLOCK          = getAssignedBlock("TELE",          numsToAssign, DNA_HARD_BOUNDS, good=1)
	FIREBLOCK          = getAssignedBlock("FIRE",          numsToAssign, DNA_HARDER_BOUNDS, good=1)
	XRAYBLOCK          = getAssignedBlock("XRAY",          numsToAssign, DNA_HARDER_BOUNDS, good=1)
	CLUMSYBLOCK        = getAssignedBlock("CLUMSY",        numsToAssign)
	FAKEBLOCK          = getAssignedBlock("FAKE",          numsToAssign)
	COUGHBLOCK         = getAssignedBlock("COUGH",         numsToAssign)
	GLASSESBLOCK       = getAssignedBlock("GLASSES",       numsToAssign)
	EPILEPSYBLOCK      = getAssignedBlock("EPILEPSY",      numsToAssign)
	TWITCHBLOCK        = getAssignedBlock("TWITCH",        numsToAssign)
	NERVOUSBLOCK       = getAssignedBlock("NERVOUS",       numsToAssign)

	// Bay muts
	HEADACHEBLOCK      = getAssignedBlock("HEADACHE",      numsToAssign)
	NOBREATHBLOCK      = getAssignedBlock("NOBREATH",      numsToAssign, DNA_HARD_BOUNDS, good=1)
	REMOTEVIEWBLOCK    = getAssignedBlock("REMOTEVIEW",    numsToAssign, DNA_HARDER_BOUNDS, good=1)
	REGENERATEBLOCK    = getAssignedBlock("REGENERATE",    numsToAssign, DNA_HARDER_BOUNDS, good=1)
	INCREASERUNBLOCK   = getAssignedBlock("INCREASERUN",   numsToAssign, DNA_HARDER_BOUNDS, good=1)
	REMOTETALKBLOCK    = getAssignedBlock("REMOTETALK",    numsToAssign, DNA_HARDER_BOUNDS, good=1)
	MORPHBLOCK         = getAssignedBlock("MORPH",         numsToAssign, DNA_HARDER_BOUNDS, good=1)
	COLDBLOCK          = getAssignedBlock("COLD",          numsToAssign, good=1)
	HALLUCINATIONBLOCK = getAssignedBlock("HALLUCINATION", numsToAssign)
	NOPRINTSBLOCK      = getAssignedBlock("NOPRINTS",      numsToAssign, DNA_HARD_BOUNDS, good=1)
	SHOCKIMMUNITYBLOCK = getAssignedBlock("SHOCKIMMUNITY", numsToAssign, good=1)
	SMALLSIZEBLOCK     = getAssignedBlock("SMALLSIZE",     numsToAssign, DNA_HARD_BOUNDS, good=1)

	//
	// Goon muts
	/////////////////////////////////////////////

	// Disabilities
	LISPBLOCK      = getAssignedBlock("LISP",       numsToAssign)
	MUTEBLOCK      = getAssignedBlock("MUTE",       numsToAssign)
	RADBLOCK       = getAssignedBlock("RAD",        numsToAssign)
	FATBLOCK       = getAssignedBlock("FAT",        numsToAssign)
	CHAVBLOCK      = getAssignedBlock("CHAV",       numsToAssign)
	SWEDEBLOCK     = getAssignedBlock("SWEDE",      numsToAssign)
	SCRAMBLEBLOCK  = getAssignedBlock("SCRAMBLE",   numsToAssign)
	TOXICFARTBLOCK = getAssignedBlock("TOXICFART",  numsToAssign, good=1)
	STRONGBLOCK    = getAssignedBlock("STRONG",     numsToAssign, good=1)
	HORNSBLOCK     = getAssignedBlock("HORNS",      numsToAssign)
	SMILEBLOCK     = getAssignedBlock("SMILE",      numsToAssign)
	ELVISBLOCK     = getAssignedBlock("ELVIS",      numsToAssign)

	// Powers
	SOBERBLOCK     = getAssignedBlock("SOBER",      numsToAssign, good=1)
	PSYRESISTBLOCK = getAssignedBlock("PSYRESIST",  numsToAssign, DNA_HARD_BOUNDS, good=1)
	//SHADOWBLOCK  = getAssignedBlock("SHADOW",     numsToAssign, DNA_HARDER_BOUNDS, good=1)
	FARSIGHTBLOCK  = getAssignedBlock("FARSIGHT",   numsToAssign, DNA_HARDER_BOUNDS, good=1)
	CHAMELEONBLOCK = getAssignedBlock("CHAMELEON",  numsToAssign, DNA_HARDER_BOUNDS, good=1)
	CRYOBLOCK      = getAssignedBlock("CRYO",       numsToAssign, DNA_HARD_BOUNDS, good=1)
	EATBLOCK       = getAssignedBlock("EAT",        numsToAssign, DNA_HARD_BOUNDS, good=1)
	JUMPBLOCK      = getAssignedBlock("JUMP",       numsToAssign, DNA_HARD_BOUNDS, good=1)
	MELTBLOCK      = getAssignedBlock("MELT",       numsToAssign, good=1)
	IMMOLATEBLOCK  = getAssignedBlock("IMMOLATE",   numsToAssign)
	EMPATHBLOCK    = getAssignedBlock("EMPATH",     numsToAssign, DNA_HARD_BOUNDS, good=1)
	SUPERFARTBLOCK = getAssignedBlock("SUPERFART",  numsToAssign, DNA_HARDER_BOUNDS, good=1)
	POLYMORPHBLOCK = getAssignedBlock("POLYMORPH",  numsToAssign, DNA_HARDER_BOUNDS, good=1)

	//
	// /vg/ Blocks
	/////////////////////////////////////////////

	// Disabilities
	LOUDBLOCK      = getAssignedBlock("LOUD",       numsToAssign)
	WHISPERBLOCK   = getAssignedBlock("WHISPER",    numsToAssign)
	DIZZYBLOCK     = getAssignedBlock("DIZZY",      numsToAssign)
	SANSBLOCK      = getAssignedBlock("SANS",       numsToAssign)
	NOIRBLOCK      = getAssignedBlock("NOIR",       numsToAssign)
	VEGANBLOCK     = getAssignedBlock("VEGAN",      numsToAssign)
	ASTHMABLOCK    = getAssignedBlock("ASTHMA",     numsToAssign)
	LACTOSEBLOCK   = getAssignedBlock("LACTOSE",    numsToAssign)

	//
	// Static Blocks
	/////////////////////////////////////////////.

	// Monkeyblock is always last.
	MONKEYBLOCK = DNA_SE_LENGTH

	// And the genes that actually do the work. (domutcheck improvements)
	var/list/blocks_assigned[DNA_SE_LENGTH]
	for(var/gene_type in typesof(/datum/dna/gene))
		var/datum/dna/gene/G = new gene_type
		if(G.block)
			if(G.block in blocks_assigned)
				warning("DNA2: Gene [G.name] trying to use already-assigned block [G.block] (used by [english_list(blocks_assigned[G.block])])")
			dna_genes[G.type] = G
			var/list/assignedToBlock[0]
			if(blocks_assigned[G.block])
				assignedToBlock=blocks_assigned[G.block]
			assignedToBlock.Add(G.name)
			blocks_assigned[G.block]=assignedToBlock

	// I WILL HAVE A LIST OF GENES THAT MATCHES THE RANDOMIZED BLOCKS GODDAMNIT!
	for(var/block=1;block<=DNA_SE_LENGTH;block++)
		var/name = assigned_blocks[block]
		for(var/gene_type in dna_genes)
			var/datum/dna/gene/gene = dna_genes[gene_type]
			if(gene.name == name || gene.block == block)
				if(gene.block in assigned_gene_blocks)
					warning("DNA2: Gene [gene.name] trying to add to already assigned gene block list (used by [english_list(assigned_gene_blocks[block])])")
				assigned_gene_blocks[block] = gene

	//testing("DNA2: [numsToAssign.len] blocks are unused: [english_list(numsToAssign)]")

// Run AFTER genetics setup and AFTER species setup.
/proc/setup_species()
	// SPECIES GENETICS FUN
	for(var/name in all_species)
		// I hate BYOND.  Can't just call while it's in the list.
		var/datum/species/species = all_species[name]
		if(species.default_block_names.len>0)
//			testing("Setting up genetics for [species.name] (needs [english_list(species.default_block_names)])")
			species.default_blocks.len = 0

			for(var/block=1;block<DNA_SE_LENGTH;block++)
				if(assigned_blocks[block] in species.default_block_names)
//					testing("  Found [assigned_blocks[block]] ([block])")
					species.default_blocks.Add(block)

			if(species.default_blocks.len)
				all_species[name]=species


/proc/setupfactions()
	// Populate the factions list:
	for(var/x in typesof(/datum/faction))
		var/datum/faction/F = new x
		if(!F.name)
			del(F)
			continue
		else
			ticker.factions.Add(F)
			ticker.availablefactions.Add(F)

	// Populate the syndicate coalition:
	for(var/datum/faction/syndicate/S in ticker.factions)
		ticker.syndicate_coalition.Add(S)
