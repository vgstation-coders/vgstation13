#if DM_VERSION < 514

// This is a byond proc in versions above 514
/proc/rgb2num(var/colour_string)
	return GetHexColors(colour_string)

#endif
