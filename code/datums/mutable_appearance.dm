// Mutable appearances are an inbuilt byond datastructure. Read the documentation on them by hitting F1 in DM.
// Basically use them instead of images for overlays/underlays and when changing an object's appearance if you're doing so with any regularity.
// Unless you need the overlay/underlay to have a different direction than the base object. Then you have to use an image due to a bug.

// Mutable appearances are children of images, just so you know.

// Mutable appearances erase template vars on new, because they accept an appearance to copy as an arg
// If we have nothin to copy, we set the float plane
/mutable_appearance/New(mutable_appearance/to_copy)
	..()
	if(!to_copy)
		plane = FLOAT_PLANE

/** Helper similar to image()
 *
 * icon - Our appearance's icon
 * icon_state - Our appearance's icon state
 * layer - Our appearance's layer
 * plane - The plane to use for the appearance.
 * alpha - Our appearance's alpha
 * appearance_flags - Our appearance's appearance_flags
**/
/proc/mutable_appearance(icon, icon_state = "", layer = FLOAT_LAYER, plane = FLOAT_PLANE, alpha = 255, appearance_flags = NONE)
	var/mutable_appearance/appearance = new()
	appearance.icon = icon
	appearance.icon_state = icon_state
	appearance.layer = layer
	appearance.plane = plane
	appearance.alpha = alpha
	appearance.appearance_flags |= appearance_flags
	return appearance
