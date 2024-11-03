#define CHAT_MESSAGE_SPAWN_TIME		0.2 SECONDS
#define CHAT_MESSAGE_LIFESPAN		5 SECONDS
#define CHAT_MESSAGE_EOL_FADE		0.7 SECONDS
#define CHAT_MESSAGE_EXP_DECAY		0.8 // Messages decay at pow(factor, idx in stack)
#define CHAT_MESSAGE_HEIGHT_DECAY	0.7 // Increase message decay based on the height of the message
#define CHAT_MESSAGE_APPROX_LHEIGHT	11 // Approximate height in pixels of an 'average' line, used for height decay
#define CHAT_MESSAGE_WIDTH			96 // pixels
#define CHAT_MESSAGE_MAX_LENGTH		68 // characters

/// Macro from Lummox used to get height from a MeasureText proc.
/// resolves the MeasureText() return value once, then resolves the height, then sets return_var to that.
/// TG uses this a macro - there's no real reason for this not to be a proc, it defies all logic
/proc/WXH_TO_HEIGHT(measurement, return_var)
	var/_measurement = measurement
	return_var = text2num(copytext(_measurement, findtextEx(_measurement, "x") + 1))
	return return_var

/**
  * # Chat Message Overlay
  *
  * Datum for generating a message overlay on the map
  * Ported from TGStation; https://github.com/tgstation/tgstation/pull/50608/, author:  bobbahbrown
  */

// Cached runechat icon
var/runechat_icon = null

/datum/chatmessage
	/// The visual element of the chat messsage
	var/image/message
	/// The location in which the message is appearing
	var/atom/message_loc
	/// The client who heard this message
	var/client/owned_by
	/// Contains the scheduled destruction time
	var/scheduled_destruction
	/// Contains the approximate amount of lines for height decay
	var/approx_lines

/**
  * Constructs a chat message overlay
  *
  * Arguments:
  * * text - The text content of the overlay
  * * target - The target atom to display the overlay at
  * * owner - The mob that owns this overlay, only this mob will be able to view it
  * * extra_classes - Extra classes to apply to the span that holds the text
  * * lifespan - The lifespan of the message in deciseconds
  */
/datum/chatmessage/New(text, atom/target, mob/owner, list/extra_classes = null, lifespan = CHAT_MESSAGE_LIFESPAN)
	. = ..()
	if (!istype(target))
		CRASH("Invalid target given for chatmessage")
	if(!istype(owner) || owner.gcDestroyed || !owner.client)
		stack_trace("/datum/chatmessage created with [isnull(owner) ? "null" : "invalid"] mob owner")
		qdel(src)
		return
	generate_image(text, target, owner, extra_classes, lifespan)

/datum/chatmessage/Destroy()
	if (owned_by)
		owned_by.seen_messages.Remove(src)
		owned_by.images.Remove(message)
		owned_by.mob.unregister_event(/event/destroyed, src, nameof(src::qdel_self()))
	owned_by = null
	message_loc = null
	message = null
	return ..()

/**
  * Generates a chat message image representation
  *
  * Arguments:
  * * text - The text content of the overlay
  * * target - The target atom to display the overlay at
  * * owner - The mob that owns this overlay, only this mob will be able to view it
  * * extra_classes - Extra classes to apply to the span that holds the text
  * * lifespan - The lifespan of the message in deciseconds
  */
/datum/chatmessage/proc/generate_image(text, atom/target, mob/owner, list/extra_classes, lifespan)
	set waitfor = FALSE
	// Register client who owns this message
	owned_by = owner.client
	owner.register_event(/event/destroyed, src, nameof(src::qdel_self()))

	// Clip message
	var/maxlen = owned_by.prefs.max_chat_length
	if (length_char(text) > maxlen)
		text = copytext_char(text, 1, maxlen + 1) + "..." // BYOND index moment

	// Calculate target color if not already present
	if (!target.chat_color || target.chat_color_name != target.name)
		target.chat_color = colorize_string(target.name)
		target.chat_color_darkened = colorize_string(target.name, 0.85, 0.85)
		target.chat_color_name = target.name

	// Get rid of any URL schemes that might cause BYOND to automatically wrap something in an anchor tag
	var/static/regex/url_scheme = new(@"[A-Za-z][A-Za-z0-9+-\.]*:\/\/", "g")
	text = replacetext(text, url_scheme, "")

	// Reject whitespace
	var/static/regex/whitespace = new(@"^\s*$")
	if (whitespace.Find(text))
		qdel(src)
		return

	// Non mobs speakers can be small
	if (!ismob(target))
		extra_classes |= "small"

	// If we heard our name, it's important
	var/list/names = splittext(owner.name, " ")
	for (var/word in names)
		if(word)
			text = replacetext(text, word, "<b>[word]</b>")

	// Append radio icon if comes from a radio
	if (extra_classes.Find("spoken_into_radio"))
		if (!runechat_icon)
			var/image/r_icon = image('icons/chat_icons.dmi', icon_state = "radio")
			runechat_icon =  "\icon[r_icon]&nbsp;"
		text = runechat_icon + text

	// We dim italicized text to make it more distinguishable from regular text
	var/tgt_color = extra_classes.Find("italics") ? target.chat_color_darkened : target.chat_color
	// Approximate text height
	// Note we have to replace HTML encoded metacharacters otherwise MeasureText will return a zero height
	// BYOND Bug #2563917
	// Construct text
	var/static/regex/html_metachars = new(@"&[A-Za-z]{1,7};", "g")
	var/complete_text = "<span class='center maptext [extra_classes != null ? extra_classes.Join(" ") : ""]' style='color: [tgt_color];'>[text]</span>"

	var/mheight = WXH_TO_HEIGHT(owned_by.MeasureText(complete_text, null, CHAT_MESSAGE_WIDTH))


	if(!TICK_CHECK)
		return finish_image_generation(mheight, target, owner, complete_text, lifespan)

	var/callback/our_callback = new /callback(src, nameof(src::finish_image_generation()), mheight, target, owner, complete_text, lifespan)
	SSrunechat.message_queue += our_callback
	return

///finishes the image generation after the MeasureText() call in generate_image().
///necessary because after that call the proc can resume at the end of the tick and cause overtime.
/datum/chatmessage/proc/finish_image_generation(mheight, atom/target, mob/owner, complete_text, lifespan)
	approx_lines = max(1, mheight / CHAT_MESSAGE_APPROX_LHEIGHT)

	// Translate any existing messages upwards, apply exponential decay factors to timers
	message_loc = target
	if (owned_by?.seen_messages)
		var/idx = 1
		var/combined_height = approx_lines
		for(var/datum/chatmessage/msg in owned_by.seen_messages)
			animate(msg.message, pixel_y = msg.message.pixel_y + mheight, time = CHAT_MESSAGE_SPAWN_TIME)
			combined_height += msg.approx_lines
			var/sched_remaining = msg.scheduled_destruction - world.time
			if (sched_remaining > CHAT_MESSAGE_SPAWN_TIME)
				var/remaining_time = max(0, (sched_remaining) * (CHAT_MESSAGE_EXP_DECAY ** idx++) * (CHAT_MESSAGE_HEIGHT_DECAY ** combined_height))
				msg.scheduled_destruction = world.time + remaining_time
				spawn(remaining_time)
					msg.end_of_life()

	// Build message image
	message = image(loc = message_loc, layer = CHAT_LAYER)
	message.plane = ABOVE_HUMAN_PLANE
	message.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	message.alpha = 0
	message.pixel_y = owner.bound_height * 0.95
	message.maptext_width = CHAT_MESSAGE_WIDTH
	message.maptext_height = mheight
	message.maptext_x = (CHAT_MESSAGE_WIDTH - owner.bound_width) * -0.5
	message.maptext = complete_text

	if (is_holder_of(owner, target)) // Special case, holding an atom speaking (pAI, recorder...)
		message.plane = ABOVE_HUD_PLANE

	// View the message
	if (owned_by)
		owned_by.seen_messages.Add(src)
		owned_by.images += message
	animate(message, alpha = 255, time = CHAT_MESSAGE_SPAWN_TIME)

	// Prepare for destruction
	scheduled_destruction = world.time + (lifespan - CHAT_MESSAGE_EOL_FADE)
	spawn(lifespan - CHAT_MESSAGE_EOL_FADE)
		end_of_life()

/datum/chatmessage/proc/qdel_self(var/datum/thing)
	qdel(src)


/**
  * Applies final animations to overlay CHAT_MESSAGE_EOL_FADE deciseconds prior to message deletion
  */
/datum/chatmessage/proc/end_of_life(fadetime = CHAT_MESSAGE_EOL_FADE)
	if (gcDestroyed)
		return
	animate(message, alpha = 0, time = fadetime, flags = ANIMATION_PARALLEL)
	spawn(fadetime)
		qdel(src)

/**
  * Creates a message overlay at a defined location for a given speaker
  *
  * Arguments:
  * * speaker - The atom who is saying this message
  * * message_language - The language that the message is said in
  * * raw_message - The text content of the message
  * * spans - Additional classes to be added to the message
  * * message_mode - Bitflags relating to the mode of the message
  */
/mob/proc/create_chat_message(atom/movable/speaker, datum/language/message_language, raw_message, mode, list/existing_extra_classes)
	// Check for virtual speakers (aka hearing a message through a radio)
	if (existing_extra_classes.Find("radio"))
		return

	var/list/extra_classes = list()
	extra_classes += existing_extra_classes

	if (mode == SPEECH_MODE_WHISPER)
		extra_classes += "small"

	if (client.toggle_runechat_outlines)
		extra_classes += "black_outline"

	var/dist = get_dist(src, speaker)
	switch (dist)
		if (4 to 5)
			extra_classes |= "small"
		if (5 to 16)
			extra_classes += "very_small"

	if (message_language && !say_understands(speaker, message_language))
		raw_message = message_language.scramble(raw_message)

	// Display visual above source
	new /datum/chatmessage(raw_message, speaker, src, extra_classes)

// Tweak these defines to change the available color ranges
#define CM_COLOR_SAT_MIN	0.6
#define CM_COLOR_SAT_MAX	0.95
#define CM_COLOR_LUM_MIN	0.70
#define CM_COLOR_LUM_MAX	0.90

/**
  * Gets a color for a name, will return the same color for a given string consistently within a round.atom
  *
  * Note that this proc aims to produce pastel-ish colors using the HSL colorspace. These seem to be favorable for displaying on the map.
  *
  * Arguments:
  * * name - The name to generate a color for
  * * sat_shift - A value between 0 and 1 that will be multiplied against the saturation
  * * lum_shift - A value between 0 and 1 that will be multiplied against the luminescence
  */
/datum/chatmessage/proc/colorize_string(name, sat_shift = 1, lum_shift = 1)
	// seed to help randomness
	var/static/rseed = rand(1,26)

	// get hsl using the selected 6 characters of the md5 hash
	var/hash = copytext(md5(name + "[world_startup_time]"), rseed, rseed + 6)
	var/h = hex2num(copytext(hash, 1, 3)) * (360 / 255)
	var/s = (hex2num(copytext(hash, 3, 5)) >> 2) * ((CM_COLOR_SAT_MAX - CM_COLOR_SAT_MIN) / 63) + CM_COLOR_SAT_MIN
	var/l = (hex2num(copytext(hash, 5, 7)) >> 2) * ((CM_COLOR_LUM_MAX - CM_COLOR_LUM_MIN) / 63) + CM_COLOR_LUM_MIN

	// adjust for shifts
	s *= clamp(sat_shift, 0, 1)
	l *= clamp(lum_shift, 0, 1)

	// convert to rgba
	var/h_int = round(h/60) // mapping each section of H to 60 degree sections
	var/c = (1 - abs(2 * l - 1)) * s
	var/x = c * (1 - abs((h / 60) % 2 - 1))
	var/m = l - c * 0.5
	x = (x + m) * 255
	c = (c + m) * 255
	m *= 255
	switch(h_int)
		if(0)
			return rgb(c,x,m)
		if(1)
			return rgb(x,c,m)
		if(2)
			return rgb(m,c,x)
		if(3)
			return rgb(m,x,c)
		if(4)
			return rgb(x,m,c)
		if(5)
			return rgb(c,m,x)

/client/verb/toggle_runechat_outline()
	set category = "OOC"
	set name = "Toggle Runechat Outlines"
	toggle_runechat_outlines = !toggle_runechat_outlines
	to_chat(mob, "<span class='notice'>Runechat outlines are now [toggle_runechat_outlines ? "enabled" : "disabled"].</span>")
