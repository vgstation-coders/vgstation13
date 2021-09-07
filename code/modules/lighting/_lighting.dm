// Huge, huge, immense thanks to Nandrew of the BYOND forums for posting their demo of the new lighting methods, upon which
// this is being built! Thread can be found at the following address:
// https://web.archive.org/web/20160809005336/http://www.byond.com/forum/?post=2033630 (original link is dead for some reason. Look in the internet archive)
// Additional thanks to Mloc, whose previous work a lot of this draws on, PJ and ErikHanson, for advice and assistance,
// BordListian on Reddit for more advice and discussion, and whoever else was involved that I have forgotten.
// Also thanks to Lummox for BYOND 510's awesome new features.

// Ported to /vg/station by Clusterfack and Unusual Crow.
// Thanks a ton to Bilgecrank for his wonderful sprite work.

// Re-ported in a new and improved version in 2021 by ShiftyRail.
// The code for generating light sprites and masks can be found at :
// https://gist.github.com/ShiftyRail/911f608f122c3ce355b3a67c16a23718

#define LIGHTING_PLANEMASTER_COLOR list(null,null,null,"#0000","#000F")

/turf/shadow_dummy
	opacity = 0
