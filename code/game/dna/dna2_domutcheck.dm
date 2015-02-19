// (Re-)Apply mutations.
// TODO: Turn into a /mob proc, change inj to a bitflag for various forms of differing behavior.
// M: Mob to mess with
// connected: Machine we're in, type unchecked so I doubt it's used beyond monkeying
// flags: See below, bitfield.
#define MUTCHK_FORCED        1
/proc/domutcheck(var/mob/living/M, var/connected=null, var/flags=0)
	for(var/datum/dna/gene/gene in dna_genes)
		if(!M)
			return
		if(!gene.block)
			continue

		if(istype(M,/mob/living/simple_animal/chicken) && M.dna)
			var/datum/dna/chicken_dna = M.dna
			if(chicken_dna.SE[54] < 800)
				chicken_dna.chicken2vox(M,chicken_dna)//havinagiggle.tiff

		domutation(gene, M, connected, flags)
		// To prevent needless copy pasting of code i put this commented out section
		// into domutation so domutcheck and genemutcheck can both use it.
		/*
		// Sanity checks, don't skip.
		if(!gene.can_activate(M,flags))
			//testing("[M] - Failed to activate [gene.name] (can_activate fail).")
			continue

		// Current state
		var/gene_active = (gene.flags & GENE_ALWAYS_ACTIVATE)
		if(!gene_active)
			gene_active = M.dna.GetSEState(gene.block)

		// Prior state
		var/gene_prior_status = (gene.type in M.active_genes)
		var/changed = gene_active != gene_prior_status || (gene.flags & GENE_ALWAYS_ACTIVATE)

		// If gene state has changed:
		if(changed)
			// Gene active (or ALWAYS ACTIVATE)
			if(gene_active || (gene.flags & GENE_ALWAYS_ACTIVATE))
				testing("[gene.name] activated!")
				gene.activate(M,connected,flags)
				if(M)
					M.active_genes |= gene.type
					M.update_icon = 1
			// If Gene is NOT active:
			else
				testing("[gene.name] deactivated!")
				gene.deactivate(M,connected,flags)
				if(M)
					M.active_genes -= gene.type
					M.update_icon = 1
		*/

// Use this to force a mut check on a single gene!
/proc/genemutcheck(var/mob/living/M, var/block, var/connected=null, var/flags=0)
	if(!M)
		return
	if(block < 0)
		return

	var/datum/dna/gene/gene = assigned_gene_blocks[block]
	domutation(gene, M, connected, flags)


/proc/domutation(var/datum/dna/gene/gene, var/mob/living/M, var/connected=null, var/flags=0)
	if(!gene || !istype(gene))
		return 0

	// Sanity checks, don't skip.
	if(!gene.can_activate(M,flags))
		//testing("[M] - Failed to activate [gene.name] (can_activate fail).")
		return 0

	// Current state
	var/gene_active = (gene.flags & GENE_ALWAYS_ACTIVATE)
	if(!gene_active)
		gene_active = M.dna.GetSEState(gene.block)

	// Prior state
	var/gene_prior_status = (gene.type in M.active_genes)
	var/changed = gene_active != gene_prior_status || (gene.flags & GENE_ALWAYS_ACTIVATE)

	// If gene state has changed:
	if(changed)
		// Gene active (or ALWAYS ACTIVATE)
		if(gene_active || (gene.flags & GENE_ALWAYS_ACTIVATE))
			testing("[gene.name] activated!")
			gene.activate(M,connected,flags)
			if(M)
				M.active_genes |= gene.type
				M.update_icon = 1
		// If Gene is NOT active:
		else
			testing("[gene.name] deactivated!")
			gene.deactivate(M,connected,flags)
			if(M)
				M.active_genes -= gene.type
				M.update_icon = 1

/datum/dna/proc/chicken2vox(var/mob/living/simple_animal/chicken/C, var/datum/dna/D)//sadly doesn't let you turn normal chicken into voxes since they don't have any DNA

	var/mob/living/carbon/human/vox/V = new(C.loc)

	if (D.GetUIState(DNA_UI_GENDER))
		V.gender = FEMALE
	else
		V.gender = MALE

	if(C.mind)
		C.mind.transfer_to(V)

	del(C)
