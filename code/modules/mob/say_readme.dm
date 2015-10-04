/*=============================================================
======================MIAUW'S SAY REWRITE======================
===============================================================

This is a basic explanation of how say() works. Read this if you don't understand something.

The basic "flow" of say() is that a speaker says a message, which is heard by hearers. What appears on screen
is constructed by each hearer seperately, and not by the speaker.

This rewrite was needed, but is far from perfect. Report any bugs you come across and feel free to fix things up.
Radio code, while very much related to saycode, is not something I wanted to touch, so the code related to that may be messy.

If you came here to see how to use saycode, all you will ever really need to call is say(message).
To have things react when other things speak around them, add the HEAR flag to their flags variable and
override their Hear() proc.

=======================PROCS & VARIABLES=======================
	Here follows a list of say()-related procs and variables.
global procs
	get_radio_span(freq)
		Returns the span class associated with that frequency.

	get_radio_name(freq)
		Returns the name of that frequency.

	get_hearers_in_view(R, atom/source)
		Self-explanatory. Calls get_hear() and then calls recursive_hear_check on everything that get_hear() returns.

	recursive_hear_check(atom/O)
		Checks for hearers by looping through the contents of O and the contents of the contents of O and etc and checking
		each object for the HEAR flag. Returns a list of objects with the HEAR flag.

	get_hear(range, atom/source)
		Like view(), but ignores luminosity.

/atom/movable
	flags
		The HEAR flag determines whether something is a hearer or not.
		Hear() is only called on procs with this flag.

 *	No longer used
 *	languages
 *		Bitmask variable.
 *		What languages this object speaks/understands. If the languages of the speaker don't match the languages
 *		of the hearer, the message will be modified in the hearer's lang_treat().

	mob/languages
		list of languages
		What language(s) the speaker speaks, and the hearer understands. 
		If the hearer doesn't understand it will be treated in lang_treat()

	mob/universal_speak
		Gift of Gab
		Mainly used in non-human mobs.
		Regardless of the language spoken this mob can understand it, and other mobs can understand it perfectly.

	mob/universal_understand
		Mainly used in non-human mobs.
		Regardless of the language heard this mob understands it.

	say(message)
		Say() is the "mother-proc". It calls all the other procs required for speaking, but does little itself.
		At the atom/movable level, say() just calls send_speech.

	Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq)
		This proc handles hearing. What it does varies. For mobs, it treats the message with hearer-specific things
		like language and deafness, then outputs it to the hearer.
		
		IMPORTANT NOTE: If radio_freq is not null, the code will assume that the speaker is virtual! (more info on this in the Radios section below)

	send_speech(message, range, datum/language/speaking)
		This proc composes a list of hearers (things with the HEAR flag + dead people) and calls Hear() on them.
		Message treatment or composition of output are not done by this proc, these are handled by the rest of
		say() and the hearer respectively.

	lang_treat(message, atom/movable/speaker, message_langs, raw_message)
		Modifies the message by comparing the languages of the speaker with the languages of the hearer.
		Called on the hearer.

	say_quote(text)
		Adds a verb and quotes to a message, according to the type of mob. Called on the speaker.

/mob
	say_dead(message)
		Sends a message to all dead people. Does not use Hear().

	compose_message(message, atom/movable/speaker, message_langs, raw_message, radio_freq)
		Composes the message mobs see on their screen when they hear something.

	compose_track_href(message, atom/movable/speaker, message_langs, raw_message, radio_freq)
		Composes the href tags used by the AI for tracking. Returns "" for all mobs except AIs.

	compose_job(message, atom/movable/speaker, message_langs, raw_message, radio_freq)
		Composes the job and the end tag for tracking hrefs. Returns "" for all mobs except AIs.

	hivecheck()
		Returns 1 if the mob can hear and talk in the alien hivemind.

	lingcheck()
		Returns 1 if the mob can hear and talk in the changeling hivemind.

/mob/living
	say(message)
		The say() of mob_living is significantly more complex than that of objects.
		Most of the extra code has to do with radios and message treatment.

	check_emote(message)
		Checks if the message begins with an * and is thus an emote.

	can_speak(message)
		Calls can_speak_basic() and can_speak_vocal()

	can_speak_basic(message)
		Sees if the mob can "think" the message. Does not include vocalization or stat checks.
		Vocalization checks are in can_speak_vocal, stat checks have to be done manually.
		Called right before handle_inherent_channels()

	can_speak_vocal(message)
		Checks if the mob can vocalize their message. This is seperate so, for example, muzzles don't block
		hivemind chat.
		Called right after handle_inherent_channels()

	get_message_mode(message)
		Checks the start of the message for a message mode, then returns said message mode.
		DOES NOT TRIM THE MESSAGE. This is done manually.

	handle_inherent_channels(message, message_mode)
		If message_mode is MODE_BINARY, MODE_ALIEN or MODE_CHANGELING (or, for AIs, MODE_HOLOPAD), this will
		handle speaking in those modes. Return 1 to exit say().

	treat_message(message)
		What it says on the tin. Treats the message according to masks, mutantraces, mutations, etc.
		Please try to keep things in a logical order (e.g. don't have masks handled before mutations),
		even if that means you have to call ..() in the middle of the proc.

	radio(message, message_mode, raw_message, datum/language/speaking)
		Handles talking into radios. Uses a switch to determine what radio to speak into and in which manner to do so.

		Return is a bitflag.
		NOPASS = terminate say() (used for whispers)
		ITALICS = add italics to the message
		REDUCE_RANGE = reduce the message range to one tile.

		Return 0 if no radio was spoken into.
		IMPORTANT: remember to call ..() and check for ..()'s return value properly!

============================RADIOS=============================

I did not want to interfere with radios too much, but I sort of had to.
For future generations, here is how radio code works:
First, talk_into() is called on a radio. This sends a signal datum into the magic machine that is tcomms, which
eventually results in broadcast_message() being called.

Broadcast_message() does NOT call say() on radios, but rather calls Hear() on everyone in range of a radio.
This is because the system does not like repeating says.

Furthermore, I changed radios to not be in the radio_controller. Instead, they are in a global list called all_radios.
This is an associative list, and the numbers as strings are the keys. The values are lists of radios that can hear said frequency.

To add a radio, simply use add_radio(radio, frequency). To remove a radio, use remove_radio(radio, frequency).
To remove a radio from ALL frequencies, use remove_radio_all(radio).

VIRTUAL SPEAKERS:
Virtual speakers are simply atom/movables with a few extra variables.
If radio_freq is not null, the code will rely on the fact that the speaker is virtual. This means that several procs will return something:
	(all of these procs are defined at the atom/movable level and return "" at that level.)
	GetJob()
		Returns the job string variable of the virtual speaker.
	GetTrack()
		Returns wether the tracking href should be fake or not.
	GetSource()
		Returns the source of the virtual speaker.
	GetRadio()
		Returns the radio that was spoken through by the source. Needed for AI tracking.

This is fairly hacky, but it means that I can advoid using istypes. It's mainly relevant for AI tracking and AI job display.

That's all, folks!*/