/datum/language/clockcultcommon
	name			= "Clockwork Cult"
	desc			= "The language of the Justiciar, the incomprehensible." // "An archaic language of an otherworldly civilization. Incomprehensible to all but the eternal and their servants." until I realised Velard already defined a clockcult language.
	speech_verb		= "recites"
	ask_verb		= "chatters"
	exclaim_verb	= "bellows"
	colour			= "clockwork"
	key				= "6"
	flags			= RESTRICTED
	space_chance	= 30

	// Yes I literally took the most common syllables in english (google) and ran them through Rot 13.
	syllables = list(
		"gur", "naq", "vat", "ure", "lbh", "ire",
		"jnf", "ung", "abg", "sbe", "guv", "gun",
		"uvf", "rag", "vgu", "vba", "rer", "jvg",
		"nyy", "rir", "bhy", "hyq", "gvb", "gre",
		"ura", "unq", "fub", "bhe", "uva", "ren", 
		"ner", "grq", "bzr", "ohg",

		"gu", "ur", "na", "re", "va", "er", "aq",
		"bh", "ra", "ba", "rq", "gb", "vg", "un",
		"ng", "ir", "be", "nf", "uv", "ne", "gr",
		"rf", "at", "vf", "fg", "yr", "ny", "gv",
		"fr", "jn", "rn", "zr", "ag", "ar"

		// To add some semi frequent ' to the mix.
		"'", "'", "'", "'", "'", "'", "'", "'"
	)
