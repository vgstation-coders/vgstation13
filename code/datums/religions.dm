/proc/DecidePrayerGod(var/mob/H)
	if(!H || !H.mind)
		return "a voice"
	if(H.mind.GetRole(CULTIST))
		return "Nar-Sie"
	else if(H.mind.faith) // The user has a faith
		var/datum/religion/R = H.mind.faith
		return R.deity_name
	else if(H.mind.assigned_role == "Clown")
		return "Honkmother"
	else if(H.mind.assigned_role == "Trader")
		return "Shoalmother"
	else if(!ishuman(H))
		return "Animal Jesus"
	else
		return "Faithless"

//Proc for selecting a religion
/proc/ChooseReligion(var/mob/living/carbon/human/H)
	var/obj/item/weapon/storage/bible/B
	var/datum/religion/chaplain_religion
	var/new_religion = sanitize(stripped_input(H, "You are the crew's Religious Services Chaplain. What religion do you follow and teach? (Please put your ID in your ID slot to prevent errors)", "Name of Religion", "Christianity"), 1, MAX_NAME_LEN)
	if(!new_religion)
		new_religion = "Christianity" // If nothing was typed

	var/choice = FALSE

	for (var/R in typesof(/datum/religion))
		var/datum/religion/rel = new R
		for (var/key in rel.keys)
			if (lowertext(new_religion) == lowertext(key))
				rel.equip_chaplain(H) // We do the misc things related to the religion
				chaplain_religion = rel
				B = new rel.bible_type(H)
				B.my_rel = rel
				B.name = rel.bible_name
				H.put_in_hands(B)
				chaplain_religion.holy_book = B
				H.equip_or_collect(new rel.preferred_incense(H.back), slot_in_backpack)
				rel.religiousLeader = H.mind
				for(var/object in H.get_body_slots())
					if(istype(object, /obj/item/weapon/card/id))
						var/obj/item/weapon/card/id/ID = object
						ID.assignment =  (H.gender == FEMALE ? rel.female_adept : rel.male_adept)
						ID.name = "[H]'s ID Card ([ID.assignment])"
				rel.convert(H, null, can_renounce = FALSE)
				rel.OnPostActivation()
				to_chat(H, "A great, intense revelation goes through your spirit. You are now the religious leader of [rel.name]. Convert people by [rel.convert_method]")
				choice = TRUE
				break // We got our religion ! Abort, abort.
		if (choice)
			break

	if (!choice) // Nothing was found
		chaplain_religion = new
		chaplain_religion.name = "[new_religion]"
		chaplain_religion.deity_name = "[new_religion]"
		chaplain_religion.bible_name = "The Holy Book of [new_religion]"
		chaplain_religion.equip_chaplain(H) // We do the misc things related to the religion
		B = new /obj/item/weapon/storage/bible
		chaplain_religion.holy_book = B
		B.name = "The Holy Book of [new_religion]"
		B.my_rel = chaplain_religion
		H.put_in_hands(B)
		chaplain_religion.religiousLeader = H.mind
		to_chat(H, "A great, intense revelation goes through your spirit. You are now the religious leader of [chaplain_religion.name]. Convert people by [chaplain_religion.convert_method]")
		chaplain_religion.convert(H, null, can_renounce = FALSE)

	switch(input(H, "Would you like the traditional [chaplain_religion.bookstyle] design and to worship [chaplain_religion.deity_names.len ? "one of [english_list(chaplain_religion.deity_names)]" : chaplain_religion.deity_name]?") in list("Yes", "No"))
		if("No")
			chaplain_religion.deity_name = ChooseDeity(H,chaplain_religion,FALSE)
			chooseBible(chaplain_religion,H,FALSE)
		if("Yes")
			chaplain_religion.deity_name = ChooseDeity(H,chaplain_religion,TRUE)
			chooseBible(chaplain_religion,H,TRUE)

	B.icon_state = chaplain_religion.holy_book.icon_state
	B.item_state = chaplain_religion.holy_book.item_state

	if(ticker)
		ticker.religions += chaplain_religion
	feedback_set_details("religion_deity","[chaplain_religion.deity_name]")
	feedback_set_details("religion_book","[B.icon_state]")

/proc/ChooseDeity(mob/chooser, datum/religion/R, var/default = FALSE)
	if(default)
		if(!R.deity_names.len)
			return R.deity_name
		else
			return input(chooser, "Your religion is polytheistic. Who is your patron?") as anything in R.deity_names
	else
		var/new_deity = copytext(sanitize(input(chooser, "Who do you worship?", "Name of Deity", R.deity_name)), 1, MAX_NAME_LEN)
		if(length(new_deity))
			return new_deity
		else
			return R.deity_name


// This file lists all religions, as well as the prototype for a religion
/datum/religion
	// Following tradition, the default is Space Jesus (this is here to avoid people getting an empty relgion)
	var/name = "Christianity"
	var/deity_name = "Space Jesus"
	var/bible_name = "The Holy Bible"
	var/male_adept = "Chaplain"
	var/female_adept = "Chaplain"
	var/convert_method = "splashing them with holy water, holding a bible in hand."

	var/bible_type = /obj/item/weapon/storage/bible
	var/obj/item/weapon/storage/bible/holy_book

	var/datum/mind/religiousLeader
	var/list/datum/mind/adepts = list()

	var/list/bible_names = list()
	var/list/deity_names = list()

	var/datum/action/renounce/action_renounce
	var/list/keys = list("abstractbasetype") // What you need to type to get this particular relgion.
	var/converts_everyone = FALSE
	var/preferred_incense = /obj/item/weapon/storage/fancy/incensebox/harebells
	var/symbolstyle = 10
	var/bookstyle = "Holy Light"

/datum/religion/New() // For religions with several bibles/deities
	if (bible_names.len)
		bible_name = pick(bible_names)
	/*if (deity_names.len)
		deity_name = pick(deity_names)*/
	action_renounce = new /datum/action/renounce(src)

/datum/religion/proc/leadsThisReligion(var/mob/living/user)
	return (user.mind && user.mind == religiousLeader)

/proc/isReligiousLeader(var/mob/living/user)
	for (var/datum/religion/rel in ticker.religions)
		if (rel.leadsThisReligion(user))
			return TRUE
	return FALSE

// Give the chaplain the basic gear, as well as a few misc effects.
/datum/religion/proc/equip_chaplain(var/mob/living/carbon/human/H)
	return TRUE // Nothing to see here, but redefined in some other religions !

/* ---- RELIGIOUS CONVERSION ----
 * convertAct() -> convertCeremony() -> convertCheck() -> convert()
 * Redefine 'convertCeremony' to play out your snowflake ceremony/interactions in your religion datum.
 * In a saner language, convertCeremony() and convertCheck() would be private methods. Those are UNSAFE procs. Call convertAct() instead.
 */

/* ConvertAct() : here we check if eveything is in place for the conversion, and provide feedback if needed. Sanity for the preacher or the target belongs to the verb in the bible.
 * - preacher : the guy doing the converting
 * - subject : the guy being converted
 * - B : the bible using for the conversion
 */
/datum/religion/proc/convertAct(var/mob/living/preacher, var/mob/living/subject, var/obj/item/weapon/storage/bible/B)
	if (B.my_rel != src) // BLASPHEMY
		to_chat(preacher, "<span class='warning'>You are a heathen to this God. You feel [B.my_rel.deity_name]'s wrath strike you for this blasphemy.</span>")
		preacher.fire_stacks += 5
		preacher.IgniteMob()
		preacher.audible_scream()
		return FALSE
	if (preacher != religiousLeader.current)
		to_chat(preacher, "<span class='warning'>You fail to muster enough mental strength to begin the conversion. Only the Spiritual Guide of [name] can perfom this.</span>")
		return FALSE
	if (subject.mind.faith == src)
		to_chat(preacher, "<span class='warning'>You and your target follow the same faith.</span>")
		return FALSE
	if (istype(subject.mind.faith) && subject.mind.faith.leadsThisReligion(subject))
		to_chat(preacher, "<span class='warning'>Your target is already the leader of another religion.</span>")
		return FALSE
	else
		return convertCeremony(preacher, subject)

/* ConvertCeremony() : the RP ceremony to convert the newfound person.
 Here we check if we have the tools to convert and play out the little interactions. */

 // This is the default ceremony, for Christianity/Space Jesus
/datum/religion/proc/convertCeremony(var/mob/living/preacher, var/mob/living/subject)
	var/held_beaker = preacher.find_held_item_by_type(/obj/item/weapon/reagent_containers)
	if (!held_beaker)
		to_chat(preacher, "<span class='warning'>You need to hold Holy Water to begin the conversion.</span>")
		return FALSE
	var/obj/item/weapon/reagent_containers/B = preacher.held_items[held_beaker]
	if (B.reagents.get_master_reagent_name() != "Holy Water")
		to_chat(preacher, "<span class='warning'>You need to hold Holy Water to begin the conversion.</span>")
		return FALSE
	subject.visible_message("<span class='notice'>\The [preacher] attempts to convert \the [subject] to [name].</span>")
	if(!convertCheck(subject))
		subject.visible_message("<span class='warning'>\The [subject] refuses conversion.</span>")
		return FALSE

	// Everything is ok : begin the conversion
	splash_sub(B.reagents, subject, 5, preacher)
	subject.visible_message("<span class='notice'>\The [subject] is blessed by \the [preacher] and embraces [name]. Praise [deity_name]!</span>")
	convert(subject, preacher)
	return TRUE

// Here we check if the subject is willing
/datum/religion/proc/convertCheck(var/mob/living/subject)
	var/choice = input(subject, "Do you wish to become a follower of [name]?","Religious converting") in list("Yes", "No")
	return choice == "Yes"

// Here is the proc to welcome a new soul in our religion.
/datum/religion/proc/convert(var/mob/living/subject, var/mob/living/preacher, var/can_renounce = TRUE, var/default = FALSE)
	// If he already had one
	if (subject.mind.faith)
		subject.mind.faith.renounce(subject) // We remove him from that one

	subject.mind.faith = src
	adepts += subject.mind
	if(can_renounce)
		action_renounce.Grant(subject)
	if(!default)
		to_chat(subject, "<span class='good'>You feel your mind become clear and focused as you discover your newfound faith. You are now a follower of [name].</span>")
		if (!preacher)
			var/msg = "\The [key_name(subject)] has been converted to [name] without a preacher."
			message_admins(msg)
		else
			var/msg = "[key_name(subject)] has been converted to [name] by \The [key_name(preacher)]."
			message_admins(msg)
	else
		to_chat(subject, "<span class='good'>You are reminded you were christened into [name] long ago.</span>")

// Activivating a religion with admin interventions.
/datum/religion/proc/activate(var/mob/living/preacher)
	equip_chaplain(preacher) // We do the misc things related to the religion
	to_chat(preacher, "A great, intense revelation goes through your spirit. You are now the religious leader of [name]. Convert people by [convert_method]")
	if (holy_book)
		preacher.put_in_hands(holy_book)
	else
		holy_book = new bible_type
		holy_book.my_rel = src
		chooseBible(src, preacher)
		holy_book.name = bible_name
		preacher.put_in_hands(holy_book)
	religiousLeader = preacher.mind
	convert(preacher, null)
	OnPostActivation()

/datum/religion/proc/OnPostActivation()
	if(converts_everyone)
		message_admins("[key_name(religiousLeader)] has selected [name] and converted the entire crew.")
		for(var/mob/living/carbon/human/H in player_list)
			if(isReligiousLeader(H))
				continue
			convert(H,null,TRUE,TRUE)

/datum/religion/proc/renounce(var/mob/living/subject)
	to_chat(subject, "<span class='notice'>You renounce [name].</span>")
	adepts -= subject.mind
	subject.mind.faith = null

// Action : renounce your faith. For players.
/datum/action/renounce
	name = "Renounce faith"
	desc = "Leave the religion you are currently in."
	icon_icon = 'icons/obj/clothing/hats.dmi'
	button_icon_state = "fedora" // :^) Needs a better icon

/datum/action/renounce/Trigger()
	var/datum/religion/R = target
	var/mob/living/M = owner

	if (!R) // No religion, may as well be a good time to remove the icon if it's there
		Remove(M)
		return FALSE
	if (R.leadsThisReligion(M))
		to_chat(M, "<span class='warning'>You are the leader of this flock and cannot forsake them. If you have to, pray to the Gods for release.</span>")
		return FALSE
	if (alert("Do you wish to renounce [R.name]?","Renouncing a religion","Yes","No") != "Yes")
		return FALSE

	R.renounce(owner)
	Remove(owner)

// interceptPrayer: Called when anyone (not necessarily one of our adepts!) whispers a prayer.
// Return 1 to CANCEL THAT GUY'S PRAYER (!!!), or return null and just do something fun.
/datum/religion/proc/interceptPrayer(var/mob/living/L, var/deity, var/prayer_message)
	return

/proc/chooseBible(var/datum/religion/R, var/mob/user, var/noinput = FALSE) //Noinput if they just wanted the defaults

	if (!istype(R) || !user)
		return FALSE

	if (!R.holy_book)
		return FALSE

	var/book_style = R.bookstyle
	if(!noinput)
		book_style = input(user, "Which bible style would you like?") as null|anything in list("Bible", "Koran", "Scrapbook", "Creeper", "White Bible", "Holy Light", "Athiest", "Slab", "Tome", "The King in Yellow", "Ithaqua", "Scientology", \
																		   "The Bible melts", "Unaussprechlichen Kulten", "Necronomicon", "Book of Shadows", "Torah", "Burning", "Honk", "Ianism", "The Guide", "The Dokument")
	switch(book_style)
		if("Koran")
			R.holy_book.icon_state = "koran"
			R.holy_book.item_state = "koran"
		if("Scrapbook")
			R.holy_book.icon_state = "scrapbook"
			R.holy_book.item_state = "scrapbook"
		if("Creeper")
			R.holy_book.icon_state = "creeper"
			R.holy_book.item_state = "creeper"
		if("White Bible")
			R.holy_book.icon_state = "white"
			R.holy_book.item_state = "white"
		if("Holy Light")
			R.holy_book.icon_state = "holylight"
			R.holy_book.item_state = "holylight"
		if("Athiest")
			R.holy_book.icon_state = "athiest"
			R.holy_book.item_state = "athiest"
		if("Tome")
			R.holy_book.icon_state = "bible-tome"
			R.holy_book.item_state = "bible-tome"
			R.holy_book.desc = "A Nanotrasen-approved heavily revised interpretation of Nar-Sie's teachings. Apply to head repeatedly."
		if("The King in Yellow")
			R.holy_book.icon_state = "kingyellow"
			R.holy_book.item_state = "kingyellow"
		if("Ithaqua")
			R.holy_book.icon_state = "ithaqua"
			R.holy_book.item_state = "ithaqua"
		if("Scientology")
			R.holy_book.icon_state = "scientology"
			R.holy_book.item_state = "scientology"
		if("The Bible melts")
			R.holy_book.icon_state = "melted"
			R.holy_book.item_state = "melted"
		if("Unaussprechlichen Kulten")
			R.holy_book.icon_state = "kulten"
			R.holy_book.item_state = "kulten"
		if("Necronomicon")
			R.holy_book.icon_state = "necronomicon"
			R.holy_book.item_state = "necronomicon"
		if("Book of Shadows")
			R.holy_book.icon_state = "shadows"
			R.holy_book.item_state = "shadows"
		if("Torah")
			R.holy_book.icon_state = "torah"
			R.holy_book.item_state = "torah"
		if("Burning")
			R.holy_book.icon_state = "burning"
			R.holy_book.item_state = "burning"
			R.holy_book.damtype = BURN
		if("Honk")
			R.holy_book.icon_state = "honkbook"
			R.holy_book.item_state = "honkbook"
		if("Ianism")
			R.holy_book.icon_state = "ianism"
			R.holy_book.item_state = "ianism"
		if("The Guide")
			R.holy_book.icon_state = "guide"
			R.holy_book.item_state = "guide"
		if("Slab")
			R.holy_book.icon_state = "slab"
			R.holy_book.item_state = "slab"
			R.holy_book.desc = "A bizarre, ticking device... That looks broken."
		if ("The Dokument")
			R.holy_book.icon_state = "gunbible"
			R.holy_book.item_state = "gunbible"
		else
			//If christian bible, revert to default
			R.holy_book.icon_state = "bible"
			R.holy_book.item_state = "bible"
			R.holy_book.desc = "Apply to head repeatedly."
			R.holy_book.damtype = BRUTE

// The list of all religions spacemen have designed, so far.
/datum/religion/default
	keys = list("christianity")
	converts_everyone = TRUE
	symbolstyle = 2
	bookstyle = "Bible"

/datum/religion/catholic
	name = "Catholicism"
	deity_name = "Jesus Christ"
	bible_name = "The Holy Bible"
	male_adept = "Bishop"
	female_adept = "Bishop"
	keys = list("catholic", "catholicism", "roman catholicism")
	symbolstyle = 2
	bookstyle = "Bible"

/datum/religion/catholic/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/head/mitre(H), slot_head)

/datum/religion/theism
	name = "Theism"
	deity_name = "God"
	bible_names = list("The Gnostic Bible", "The Dead Seas Scrolls")
	keys = list("theist", "gnosticism", "theism")
	bookstyle = "Torah"

/datum/religion/satanism
	name = "Satanism"
	deity_name = "Satan"
	bible_name = "The Satanic Bible" //What I found on Google, ergo the truth
	male_adept = "Magister"
	female_adept = "Magistera"
	keys = list("satan", "evil", "satanism")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/moonflowers
	bookstyle = "Burning"

/datum/religion/lovecraft
	name = "Esoteric order of Dagon"
	deity_name = "Cthulhu" //I hope it's spelt correctly
	bible_names = list("The Necronomicon", "The Book of Eibon", "De Vermis Mysteriis", "Unaussprechlichen Kulten")
	keys = list("cthulhu", "old ones", "great old ones", "outer gods", "elder gods", "esoteric order of dagon")
	symbolstyle = 5
	bookstyle = "Necronomicon" //also "Unaussprechlichen Kulten" "Ithaqua"

/datum/religion/hastur
	name = "Brotherhood of The Yellow Sign" //I'm fed up with people think I worship Dagon. We're moving out.
	deity_name = "Hastur"
	bible_name = "The King in Yellow" //The name of the titular fictional play in the 1895 book by Robert Chambers
	keys = list("hastur","yellow sign","king in yellow","brotherhood of the yellow sign")
	bookstyle = "The King in Yellow"

/datum/religion/islam
	name = "Islam"
	deity_name = "Allah"
	bible_name = "The Quran"
	male_adept = "Imam"
	female_adept = "Imam"
	keys = list("islam", "muslim")
	symbolstyle = 4
	bookstyle = "Koran"

/datum/religion/slam
	name = "Slam"
	deity_name = "Charles Barkley"
	bible_name = "Barkley: Shut Up and Jam - Gaiden"
	male_adept = "Master of Slam"
	female_adept = "Mistress of Slam"
	keys = list("slam", "bball", "basketball", "basket ball")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/vale

/datum/religion/slam/equip_chaplain(var/mob/living/carbon/human/H)
	H.put_in_hands(new/obj/item/weapon/beach_ball/holoball)

/datum/religion/judaism
	name = "Judaism"
	deity_name = "Yahweh"
	bible_names = list("The Torah", "The Talmud")
	male_adept = "Rabbi"
	female_adept = "Rabbi"
	keys = list("jew", "judaism", "jews")
	symbolstyle = 1
	bookstyle = "Torah"

/datum/religion/hinduism
	name = "Hinduism"
	deity_names = list("Brahma", "Vishnu", "Shiva", "Ganesha")
	bible_names = list("The Vedas", "The Mahabharata")
	male_adept = "Guru"
	female_adept = "Guru"
	keys = list("hindu", "hinduism", "india")

/datum/religion/buddism
	name = "Buddism"
	deity_name = "Buddha"
	bible_name = "The Tripitaka"
	male_adept = "Monk"
	female_adept = "Monk"
	keys = list("buddha", "buddhism")

/datum/religion/shintoism
	name = "Shintoism"
	deity_names = list("Izanagi", "Izanami", "Susanoo", "Amaterasu", "Tsukuyomi") //Polytheist and shit, do I sound like a weeb ?
	bible_name = "Kojiki"
	male_adept = "Kannushi"
	female_adept = "Shrine Maiden"
	keys = list("shinto", "shintoism", "anime", "weeaboo", "japan", "waifu")

/datum/religion/mormonism
	name = "Mormonism"
	deity_name = "God the Father-Elohim"
	male_adept = "Apostle"
	female_adept = "Apostle"
	bible_name = "The Book of Mormon"
	keys = list("mormon", "mormonism")
	symbolstyle = 2
	bookstyle = "Bible"

/datum/religion/confucianism
	name = "Confucianism"
	deity_name = "Tian" //I found this somewhere, I guess that's true
	bible_names = list("The I Ching", "Great Learning")
	male_adept = "Xian"
	female_adept = "Xian"
	keys = list("confucianism", "china", "chinese", "tao", "taoism", "dao", "daoism")

/datum/religion/paganism
	name = "Paganism"
	deity_name = "The Gods" //Damn pagans
	bible_name = "The Book of Shadows"
	male_adept = "High Priest"
	female_adept = "High Priestess"
	keys = list("wicca", "pagan", "paganism")
	symbolstyle = 6
	bookstyle = "Book of Shadows"

/datum/religion/nordic
	name = "Viking Mythos"
	deity_names = list("Thor", "Odin", "Freyja", "Loki", "Tyr")
	bible_name = "The Eddas"
	male_adept = "Godi"
	female_adept = "Godi"
	keys = list("norse", "german pagan","viking")

/datum/religion/obesity
	name = "Church of Corpulence"
	deity_names = list("Fat Albert", "Gaben", "William Howard Taft")
	bible_names = list("The Menu", "The Larder of Heaven")
	male_adept = "Fatcolyte"
	female_adept = "Fatcolyte"
	keys = list("fat", "obese","absolute unit", "obesity")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/cornoil

/datum/religion/obesity/equip_chaplain(var/mob/living/carbon/human/H)
	H.reagents.add_reagent(NUTRIMENT, 40)
	H.overeatduration = 600

/datum/religion/obesity/convert(var/mob/living/preacher, var/mob/living/subject, var/can_renounce = TRUE)
	. = ..()
	if (subject)
		subject.reagents.add_reagent(NUTRIMENT, 40)
		subject.overeatduration = 600

/datum/religion/celtic
	name = "Celtic Mythos"
	deity_names = list("Toutatis", "Belenus", "Britannia") //Hon
	bible_name = "The Book of Leinster"
	male_adept = "Druid"
	female_adept = "Druidess"
	keys = list("druidism", "celtic")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/leafy

/datum/religion/atheism
	name = "Atheism"
	deity_name = "Richard Dawkins"
	bible_name = "The God Delusion"
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "Militant Atheist" // Wasn't defined so the poor dude ended up being a chaplain
	female_adept = "Militant Atheist"
	keys = list("atheism", "none")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/sunflowers
	bookstyle = "Atheist"

/datum/religion/atheism/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/head/fedora(H), slot_head)

/datum/religion/evolution
	name = "Theory of Evolution"
	deity_name = "Charles Darwin"
	bible_name = "The God Delusion"
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "Biologist"
	female_adept = "Biologist"
	keys = list("evolution", "biology", "monkey", "monkeys")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/banana

/datum/religion/scientology
	name = "Scientology"
	deity_name = "The Eighth Dynamic" //Don't ask, just don't
	bible_names = list("The Biography of L. Ron Hubbard", "Dianetics")
	male_adept = "OT III"
	female_adept = "OT III"
	keys = list("scientology")
	symbolstyle = 8
	bookstyle = "Scientology"

/datum/religion/discordianism
	name = "Discordianism"
	deity_name = "Eris" //Thanks Google
	bible_name = "The Principia Discordia"
	male_adept = "Episkopos"
	female_adept = "Episkopos"
	keys = list("discordianism")

/datum/religion/rastafarianism
	name = "rastafarianism"
	deity_name = "Haile Selassie I"
	bible_name = "The Holy Piby"
	keys = list("rastafarianism", "rastafari movement")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/poppies

/datum/religion/hellenism
	name = "Hellenism"
	deity_names = list("Zeus", "Poseidon", "Athena", "Persephone", "Ares", "Apollo")
	bible_name = "The Odyssey"
	male_adept = "Oracle"
	female_adept = "Oracle"
	keys = list("hellenism", "greece", "greek")
	bookstyle = "Torah"

/datum/religion/latin
	name = "Cult of Rome"
	deity_names = list("Jupiter", "Neptune", "Mars", "Minerva", "Rome", "Julius Caeser", "Roma")
	bible_name = "Cult of Rome"
	male_adept = "Pontifex"
	female_adept = "Pontifex"
	keys = list("latin", "rome", "roma", "roman")
	bookstyle = "Torah"

/datum/religion/latin/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/head/helmet/roman/legionaire(H), slot_head)
	H.equip_or_collect(new /obj/item/clothing/under/roman(H), slot_w_uniform)

/datum/religion/pastafarianism
	name = "Pastafarianism"
	deity_name = "The Flying Spaghetti Monster"
	bible_name = "The Gospel of the Flying Spaghetti Monster"
	keys = list("pastafarianism")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/sunflowers

/datum/religion/chaos
	name = "Chaos"
	deity_names = list("Khorne", "Nurgle", "Tzeentch", "Slaanesh")
	bible_names = list("The Book of Lorgar", "The Book of Magnus")
	male_adept = "Apostate Preacher"
	female_adept = "Apostate Preacher"
	keys = list("chaos")
	bookstyle = "Burning"

/datum/religion/imperium
	name = "The Imperial Creed"
	deity_name = "God-Emperor of Mankind"
	bible_names = list("An Uplifting Primer", "Codex Astartes", "Codex Hereticus")
	male_adept = "Confessor"
	female_adept = "Prioress"
	keys = list("imperium", "imperial cult")

/datum/religion/imperium/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/head/helmet/knight/interrogator(H), slot_head)
	H.equip_or_collect(new /obj/item/clothing/suit/armor/knight/interrogator(H), slot_wear_suit)

/datum/religion/toolboxia
	name = "Toolboxia"
	deity_name = "The Toolbox"
	bible_name = "The Toolbox Manifesto"
	male_adept = "Chief Assistant"
	female_adept = "Chief Assistant"
	keys = list("toolboxia", "toolbox")

/datum/religion/homosexuality
	name = "Homosexuality"
	deity_name = "Steve Rambo" //Pushing Gaywards
	bible_names = list("Guys Gone Wild", "Hunk Rump", "It's Okay to be Gay", "Daddy Gave You Good Advice")
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "LGBT Advocate"
	female_adept = "LGBT Advocate"
	keys = list("homosexuality", "faggotry", "gayness", "gay", "penis", "faggot", "cock", "cocks", "dick", "dicks")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/banana

/datum/religion/homosexuality/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/under/darkholme(H), slot_w_uniform)

/datum/religion/retard
	name = "Retardation"
	deity_name = "Brian Damag" //Ha
	bible_names = list("Woody's Got Wood: The Aftermath", "War of the Cocks", "Sweet Bro and Hella Jef: Expanded Edition", "The Book of Pomf")
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "Retard"
	female_adept = "Retard"
	keys = list("lol", "wtf", "badmin", "shitmin", "deadmin", "nigger", "dickbutt", ":^)", "XD", "le", "meme", "memes", "ayy", "ayy lmao", "lmao", "reddit", "4chan", "tumblr", "9gag", "brian damag")
	convert_method = "standing both next to a table."
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/banana

/datum/religion/retard/equip_chaplain(var/mob/living/carbon/human/H)
	H.setBrainLoss(100) //Starts off retarded as fuck, that'll teach him

/datum/religion/retard/convertCeremony(var/mob/living/preacher, var/mob/living/subject)
	var/obj/structure/table/T = locate(/obj/structure/table/, oview(1, preacher)) // is there a table near us !
	if (!T)
		to_chat(preacher, "<span class='warning'>You need to stand next to a table!</span>")
		return FALSE
	if (!(T in oview(1, subject)))
		to_chat(preacher, "<span class='warning'>Your subject need to stand next to the same table as you.</span>")
		return FALSE

	T.MouseDropTo(O = preacher, user = preacher)
	var/message = pick(
		"\The [preacher] performs an ancient ritual to channel the essence of Brian Damag.",
		"\The [preacher] swiftly bangs their head against the table.",
		"\The [preacher] seems to be practising the art of table climbing. He looks very skilled at it.",
	)
	preacher.visible_message("<span class='notice'>[message]</span>")

	sleep(0.3 SECONDS) // Pause for laughter

	if (!convertCheck(subject))
		if (get_dist(subject, preacher) <= 2) // Let's not display that if the subject is too far away.
			subject.visible_message("<span class='notice'>Apparently unimpressed, \the [subject] refuses conversion.</span>")
		return FALSE

	// Conversion successful
	if (T in oview(1, subject))
		subject.visible_message("<span class='notice'>\The [subject] heartily follows \the [preacher]. [deity_name] gains a new adept today.</span>")
		T.MouseDropTo(O = subject, user = subject)
	else
		to_chat(subject, "<span class='warning'>You really wish to climb on that table, but you can't seem to remember where it was.</span>")
		to_chat(preacher, "<span class='warning'>The subject accepted, but he moved away from the table!</span>")
		return FALSE

	convert(subject, preacher)
	return TRUE

/datum/religion/retard/convert(var/mob/living/preacher, var/mob/living/subject, var/can_renounce = TRUE)
	. = ..()
	if (subject)
		subject.adjustBrainLoss(100) // Welcome to the club

/datum/religion/science
	name = "Science"
	deity_names = list("Albert Einstein", "Isaac Newton", "Niels Bohr", "Stephen Hawking")
	bible_names = list("Principle of Relativity", "Quantum Enigma: Physics Encounters Consciousness", "Programming the Universe", "Quantum Physics and Theology", \
							  "For I Have Tasted The Fruit", "Non-Linear Genetics", "The Mysteries of Bluespace", "Playing God: Collector's Edition")
	male_adept = "Academician"
	female_adept = "Academician"
	keys = list("Science")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/sunflowers

/datum/religion/justice
	name = "Tribunal"
	deity_names = list("Almalexia", "Sotha Sil", "Vivec")
	bible_name = "The 36 Lessons of Vivec"
	male_adept = "Curate"
	female_adept = "Curate"
	keys = list("Justice", "Tribunal", "almsivi")

/datum/religion/elder_scrolls
	name = "Cult of the Divines"
	deity_names = list("Talos", "Akatosh", "Dibella", "Stendarr", "Kynareth", "Mara", "Arkay", "Julianos", "Zenithar")
	bible_name = "The Elder Scrolls"
	male_adept = "Disciple of the Nine"
	female_adept = "Disciple of the Nine"
	keys = list("nine divines", "eight divines")

/datum/religion/daedra
	name = "Cult of the Daedreas"
	deity_names = list("Azura", "Boethiah", "Sheogorath", "Sanguine", "Hircine", "Meridia", "Hermaeus Mora", "Nocturnal", "Oghma Infinium")
	bible_names = list("The Blessings of Sheogorath", "Boethiah's Pillow Book", "Invocation of Azura")
	male_adept = "Daedra Worshipper"
	female_adept = "Daedra Worshipper"
	keys = list("daedra")

/datum/religion/bokononism
	name = "Bokononism"
	deity_name = "Boko-Maru" //Completely wrong, but fuck it
	bible_name = "The Book of Bokonon"
	male_adept = "Worshipper"
	female_adept = "Worshipper"
	keys = list("bokononism")

/datum/religion/faith_of_the_seven
	name = "Faith of the Seven"
	deity_names = list("Father", "Mother")
	bible_name = "The Seven-Pointed Star"
	male_adept = "Septon"
	female_adept = "Septa"
	keys = list("faith of the seven")

/datum/religion/goa_uld
	name = "Goa'uld order"
	deity_name = "Ra"
	bible_name = "The Abydos Cartouche"
	male_adept = "First Prime"
	female_adept = "First Prime"
	keys = list("goa'uld")

/datum/religion/unitology
	name = "Unitology"
	deity_name = "The Marker"
	bible_name = "Teachings of Unitology"
	male_adept = "Vested"
	female_adept = "Vested"
	keys = list("unitology", "marker")

/datum/religion/zakarum
	name = "Zakarum"
	deity_name = "The Light"
	bible_name = "The Visions of Akarat"
	male_adept = "Disciple"
	female_adept = "Disciple"
	keys = list("zakarum")

/datum/religion/ianism
	name = "Ianism"
	deity_name = "Ian"
	bible_name = "The Porky Little Puppy"
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "Veterinarian"
	female_adept = "Veterinarian"
	keys = list("ianism", "ian", "dog", "puppy", "doggo", "pupper")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/leafy
	symbolstyle = 9
	bookstyle = "Ianism"

/datum/religion/admins
	name = "Adminism"
	deity_name = "The Adminbus"
	bible_name = "Breaking Through the Fourth Wall"
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "Trial Admin"
	female_adept = "Trial Admin"
	keys = list("adminism", "admintology", "admin", "admins", "adminhelp", "adminbus")

/datum/religion/coding
	name = "Coding"
	deity_name = "The Coderbus"
	bible_name = "Guide to Github"
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "Coder"
	female_adept = "Coder"
	keys = list("coding", "coder", "coders", "coderbus")

/datum/religion/hitchhiker
	name = "The Ultimate Question"
	deity_name = "42"
	bible_name = "The Hitchhiker's Guide to the Galaxy"
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "Hitchhiker"
	female_adept = "Hitchhiker"
	keys = list("42")
	bookstyle = "The Guide"

/datum/religion/spooky
	name = "Spooky"
	deity_name = "The Spook" //SPOOK
	bible_name = "The Spooky Spook"//SPOOK
	male_adept = "Ghost"
	female_adept = "Ghost"
	keys = list("spook", "spooky", "boo", "ghost", "halloween", "2spooky")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/moonflowers
	bookstyle = "Tome"

/datum/religion/spooky/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/head/pumpkinhead(H), slot_head)

/datum/religion/medbay
	name = "Medbay"
	deity_name = "The Chief Medical Officier"
	bible_name = "The Wild Ride"
	male_adept = "Doctor"
	female_adept = "Nurse"
	keys = list("medbay", "ride", "wild ride", "cryo")

/datum/religion/medbay/equip_chaplain(var/mob/living/carbon/human/H) //Give them basic medical garb
	H.equip_or_collect(new /obj/item/clothing/head/surgery/blue(H), slot_head)
	H.equip_or_collect(new /obj/item/clothing/mask/surgical(H), slot_wear_mask)
	H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)

/datum/religion/busta
	name = "Hardcore"
	deity_name = "Bustatime"
	bible_name = "The Hardcores"
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "Atmospheric Technician"
	female_adept = "Atmospheric Technician"
	keys = list("busta", "bustatime", "zas", "airflow", "hardcore", "hardcores")

/datum/religion/busta/equip_chaplain(var/mob/living/carbon/human/H)
	if(!(M_HARDCORE in H.mutations))
		H.mutations.Add(M_HARDCORE)
	H.equip_or_collect(new /obj/item/clothing/shoes/magboots(H), slot_shoes)

/datum/religion/self
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "God"
	female_adept = "Goddess"
	keys = list("me", "i", "myself", "narcissism", "self importance", "selfishness")

/datum/religion/self/equip_chaplain(var/mob/living/carbon/human/H)
	name = "Cult of \the [H]"
	bible_name = "A God Am I - The Teachings of \the [H]" //Quite literally
	deity_name = "\The [H]" //Very literally, too

/datum/religion/alcholol
	name = "Cult of the Beer"
	deity_name = "Hic"
	bible_name = "The Drunken Ramblings"
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "Drunkard"
	female_adept = "Drunkard"
	keys = list("alcohol", "booze", "beer", "wine", "ethanol", "c2h6o")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/booze

/datum/religion/robutness
	name = "Robustness"
	deity_name = "The Robust"
	bible_name = "The Rules of Robustness"
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "Robuster"
	female_adept = "Robuster"
	keys = list("robust", "robustness", "strength")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/vale

/datum/religion/suicide
	name = "Thanatology" // Guess it works
	deity_name = "The Grim Reaper"
	bible_name = "The Sweet Release of Death"
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "Reaper"
	female_adept = "Reaper"
	keys = list("suicide", "death", "succumb")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/moonflowers
	bookstyle = "Tome"

/datum/religion/communism
	name = "Communism"
	deity_name = "Karl Marx"
	bible_name = "The Communist Manifesto"
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "Komrade"
	female_adept = "Komrade"
	keys = list("communism", "socialism")

/datum/religion/communism/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/head/russofurhat(H), slot_head)
	H.equip_or_collect(new /obj/item/clothing/suit/russofurcoat(H), slot_wear_suit)

/datum/religion/capitalism
	name = "Capitalism"
	deity_name = "Adam Smith"
	bible_name = "The Wealth of Nations"
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "Stockholder"
	female_adept = "Stockholder"
	keys = list("capitalism", "free market", "liberalism", "money")

/datum/religion/capitalism/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/head/that(H), slot_head)

/datum/religion/america
	name = "American Exceptionalism"
	deity_name = "George Washington"
	bible_name = "The Constitution"
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "Senator"
	female_adept = "Senator"
	keys = list("freedom", "america", "muhrica", "usa")

/datum/religion/america/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/head/libertyhat(H), slot_head)

/datum/religion/nazism
	name = "Nazism"
	deity_name = "Adolf Hitler"
	bible_name = "Mein Kampf"
	male_adept = "Feldbischof" //No seriously, that's a thing, look it up
	female_adept = "Feldbischof"
	keys = list("fascism", "nazi", "national socialism")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/dense

/datum/religion/nazism/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/head/naziofficer(H), slot_head)

/datum/religion/security
	name = "Security"
	deity_name = "Nanotrasen"
	bible_name = "Space Law"
	male_adept = "Nanotrasen Officer"
	female_adept = "Nanotrasen Officer"
	keys = list("security", "space law", "law", "nanotrasen", "centcomm")
	convert_method = "performing a ritual with a flashbang and a screwdriver. You need to hold the flashbang, with its timer set to 5 seconds, your convert needs to hold the screwdriver and have a free empty hand."
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/dense

/datum/religion/security/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/head/centhat(H), slot_head)

/datum/religion/security/convertCeremony(var/mob/living/preacher, var/mob/living/subject)
	var/held_banger = preacher.find_held_item_by_type(/obj/item/weapon/grenade/flashbang)
	if (!held_banger)
		to_chat(preacher, "<span class='warning'>You need to hold a flashbang to begin the conversion.</span>")
		return FALSE
	var/held_screwdriver = subject.find_held_item_by_type(/obj/item/weapon/screwdriver)
	if (!held_screwdriver)
		to_chat(preacher, "<span class='warning'>The subject needs to hold a screwdriver to begin the conversion.</span>")
		return FALSE

	var/obj/item/weapon/grenade/flashbang/F = preacher.held_items[held_banger]
	var/obj/item/weapon/screwdriver/S = subject.held_items[held_screwdriver]

	if (F.det_time != 50) // The timer isn't properly set
		to_chat(preacher, "<span class='warning'>The timer in the flashbang isn't properly set up. Set it to 5 seconds.</span>")
		return FALSE

	subject.visible_message("<span class='notice'>\The [preacher] attemps to convert \the [subject] to [name].</span>")

	if(!convertCheck(subject))
		subject.visible_message("<span class='warning'>\The [subject] refuses conversion.</span>")
		return FALSE

	preacher.u_equip(F)

	// Everything is ok : begin the conversion
	if (!subject.put_in_hands(F))
		subject.visible_message("<span class='warning'>\The [subject] accepted conversion, but didn't manage to pick up the flashbang. How embarassing.</span>")
		return FALSE

	// BANGERBOIS WW@
	sleep(0.1 SECONDS)
	F.attackby(S, subject)
	sleep(0.1 SECONDS)
	F.attackby(S, subject)

	subject.visible_message("<span class='notice'>\The [subject] masterfully completed the delicate ritual. He's now a full-fledged follower of [deity_name].</span>")

	convert(subject, preacher)
	return TRUE

/datum/religion/syndicate
	name = "Syndicalism" //Technically not true, but hey
	deity_name = "The Syndicate"
	bible_name = "The Syndicate Bundle"
	male_adept = "Syndicate Agent"
	female_adept = "Syndicate Agent"
	keys = list("syndicate", "traitor", "syndie", "syndies", "nuke ops")

/datum/religion/syndicate/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/suit/syndicatefake(H), slot_wear_suit)
	H.equip_or_collect(new /obj/item/clothing/head/syndicatefake(H), slot_head)

/datum/religion/cult
	name = "The Cult of Nar-Sie"
	deity_name = "Nar-Sie"
	bible_name = "The Arcane Tome"
	male_adept = "Cultist"
	female_adept = "Cultist"
	keys = list("cult", "narsie", "nar'sie", "narnar", "nar-sie", "papa narnar", "geometer", "geometer of blood")
	convert_method = "performing a ritual with a paper. The subject will need to stand a crayon-drawn rune."
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/moonflowers
	bookstyle = "Tome"

/datum/religion/cult/convertCeremony(var/mob/living/preacher, var/mob/living/subject)
	var/obj/effect/decal/cleanable/crayon/rune = locate(/obj/effect/decal/cleanable/crayon/, subject.loc)
	if (!rune)
		to_chat(preacher, "<span class='warning'>The subject needs to stand on a crayon-drawn rune.</span>")
		return FALSE
	var/held_paper = preacher.find_held_item_by_type(/obj/item/weapon/paper)
	if (!held_paper)
		to_chat(preacher, "<span class='warning'>You need to hold a sheet of paper to begin to convert.</span>")
		return FALSE

	subject.visible_message("<span class='notice'>\The [preacher] attemps to convert \the [subject] to [name].</span>")

	if(!convertCheck(subject))
		subject.visible_message("<span class='warning'>\The [subject] refuses conversion.</span>")
		return FALSE

	if (prob(10))
		preacher.say("DREAM SIGN: EVIL SEALING TALISMAN!")
		subject.Knockdown(1)

	sleep(0.2 SECONDS)

	subject.visible_message("<span class='notice'>\The [subject] accepted the ritual and is now a follower of [deity_name].</span>")
	convert(subject, preacher)

/datum/religion/changeling
	name = "The Religion" // A la "The Thing"
	deity_name = "The Hive"
	bible_name = "Proboscis"
	male_adept = "Changeling"
	female_adept = "Changeling"
	keys = list("changeling", "ling", "hive", "succ")

/datum/religion/revolution
	name = "Revolutionism"
	deity_names = list("Maximilien Robespierre", "Saul Alinsky")
	bible_name = "Down With Nanotrasen"
	male_adept = "Revolutionary"
	female_adept = "Revolutionary"
	keys = list("revolution", "rev", "revolt")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/dense

/datum/religion/wizard
	name = "Wizardry"
	deity_name = "The Space Wizard Federation"
	bible_name = "Spell Book"
	male_adept = "Wizard"
	female_adept = "Wizard"
	keys = list("wizard", "wiz", "magic")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/dense

/datum/religion/wizard/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/head/wizard(H), slot_head)

/datum/religion/malfunctioning
	name = "Artificial Intelligence Cult"
	deity_names = list("Skynet", "HAL 9000", "GLaDOS", "SHODAN")
	bible_name = "Hostile Runtimes"
	male_adept = "Cyborg"
	female_adept = "Cyborg"
	keys = list("malfunction", "malf", "rogue", "rouge", "AI")

/datum/religion/malfunctioning/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/head/cardborg(H), slot_head)
	H.equip_or_collect(new /obj/item/clothing/suit/cardborg(H), slot_wear_suit)

/datum/religion/vampirism
	name = "Vampirism"
	deity_name = "Vlad the Impaler" //Dracula for the incults
	bible_name = "The Veil of Darkness"
	male_adept = "Vampire"
	female_adept = "Vampire"
	keys = list("vampire", "vamp", "blood","dracula")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/moonflowers
	bookstyle = "Burning"

/datum/religion/vampirism/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/suit/storage/draculacoat(H), slot_wear_suit)//What could possibly go wrong?
	H.equip_or_collect(new /obj/item/clothing/mask/vamp_fangs(H), slot_wear_mask)

/datum/religion/vox
	name = "Voxophilia"
	deity_name = "The Vox"
	bible_name = "Handbook to the Aves Class" //AKA birds
	male_adept = "Vox Enthusiast" //And that's terrible
	female_adept = "Vox Enthusiast"
	keys = list("vox", "raiders", "raid", "bird", "birb")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/vapor

/datum/religion/bleb
	name = "Blob Worship"
	deity_name = "Blob Overmind"
	bible_name = "A Guide To Biohazard Alerts"
	male_adept = "Blob Core"
	female_adept = "Blob Core"
	keys = list("blob", "bleb", "biohazard")

/datum/religion/clown
	name = "Clownism"
	deity_name = "Honkmother"
	bible_name =  "Honkmothers Coloring Book"
	male_adept = "Co-Clown"
	female_adept = "Co-Clown"
	keys = list("honk", "clown", "honkmother")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/banana
	bookstyle = "Honk"

/datum/religion/clown/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/mask/gas/clown_hat(H), slot_wear_mask)

/datum/religion/mime
	name = "..."
	deity_name = "Silence"
	bible_name =  "..."
	male_adept = "..."
	female_adept = "..."
	keys = list("silence", "mime", "quiet", "...")
	bookstyle = "Scrapbook"

/datum/religion/mime/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/mask/gas/mime(H), slot_wear_mask)

/datum/religion/ancap
	name = "Anarcho-Capitalism"
	deity_name = "Murray Rothbard"
	bible_name = "Bitcoin Wallet"
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "Bitcoin Miner" //Worst part coming up with job name
	female_adept = "Bitcoin Miner"
	keys = list("ancap", "ancapistan", "NAP")

/datum/religion/ancap/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/toy/gun(H), slot_l_store) //concealed carry

/datum/religion/ancom
	name = "Anarcho-Communism"
	deity_name = "Peter Kropotkin"
	bible_name = "The Conquest of Bread"
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "Activist" 
	female_adept = "Activist"
	keys = list("anarcho-communism", "communalism", "mutualism")
	
/datum/religion/ancom/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/mask/balaclava(H), slot_l_store) // Black Bloc

/datum/religion/samurai
	name = "Bushido" // The way of the warrior
	deity_name = "The Way of the Warrior"
	bible_name = "Kojiki"//Japan's oldest book, the origin "muh honor" and "muh katana"
	male_adept = "Samurai"
	female_adept = "Samurai"
	keys = list("samurai", "honor", "bushido", "weaboo")

/datum/religion/samurai/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/head/rice_hat(H), slot_head)
	H.equip_or_collect(new /obj/item/clothing/suit/kimono/ronin(H), slot_wear_suit)
	H.equip_or_collect(new /obj/item/clothing/shoes/sandal(H), slot_shoes)

/datum/religion/clockworkcult
	name = "Clockwork Cult"
	deity_name = "Ratvar"
	bible_name = "Clockwork slab"
	male_adept = "Servant of Ratvar"
	female_adept = "Servant of Ratvar"
	keys = list("ratvar", "clockwork", "ratvarism")
	bookstyle = "Slab"

/datum/religion/clockworkcult/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/head/clockwork_hood(H), slot_head)
	H.equip_or_collect(new /obj/item/clothing/suit/clockwork_robes(H), slot_wear_suit)
	H.equip_or_collect(new /obj/item/clothing/shoes/clockwork_boots(H), slot_shoes)

/datum/religion/dune
	name = "Zensunni" // t. wiki
	deity_name = "Shai-Hulud"
	bible_name = "Manual of Muad'Dib"
	male_adept = "Muad'Dib"
	female_adept = "Muad'Dib"
	keys = list("dune", "spice", "sandworms", "sandworm", "muad dib", "muad'dib", "arrakis", "shai hulud", "shai-hulud")

/datum/religion/dune/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/under/stilsuit(H), slot_w_uniform)

/datum/religion/vegan
	name = "Veganism"
	bible_name = "Mercy For Animals"
	male_adept = "Animal Rights Activist"
	female_adept = "Animal Rights Activist"
	keys = list("vegan","vegetarian","veganism","vegetarianism", "animals", "animal rights")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/leafy

/datum/religion/vegan/equip_chaplain(var/mob/living/carbon/human/H)
	//Add veganism disability
	H.dna.SetSEState(VEGANBLOCK, 1)
	domutcheck(H, null, 1)

/datum/religion/dorf
	name = "Dorfism"
	deity_name = "Armok, God of Blood"
	bible_names = list("How to Play Dwarf Fortress", "Book of Grudges", "Strike the Earth", "Lazy Newb Pack", "The Will of Armok", "Mining 101", "Hidden Fun Stuff and You")
	male_adept = "Expedition Leader"
	female_adept = "Expedition Leader"
	keys = list("armok", "dwarf", "dorf", "dwarf fortress", "dorf fort")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/booze

/datum/religion/art
	name = "The Joy of Painting"
	deity_name = "Bob Ross"
	bible_name = "The Joy of Painting"
	male_adept = "Painter"
	female_adept = "Painter"
	keys = list("art", "bob ross", "happy little trees", "happy little clouds")
	bookstyle = "Scrapbook"

/datum/religion/art/equip_chaplain(var/mob/living/carbon/human/H)
	H.put_in_hands(new /obj/item/mounted/frame/painting)
	H.my_appearance.h_style = "Big Afro"
	H.my_appearance.f_style = "Full Beard"
	H.update_hair()

/datum/religion/clean
	name = "Cleanliness"
	deity_name = "Mr. Clean"
	bible_name = "Cleanliness - Next to Godliness"
	male_adept = "Janitor"
	female_adept = "Janitor"
	keys = list("clean","cleaning","Mr. Clean","janitor")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/vapor

/datum/religion/clean/equip_chaplain(var/mob/living/carbon/human/H)
	H.put_in_hands(new /obj/item/weapon/mop)
	H.my_appearance.h_style = "Bald"
	H.my_appearance.f_style = "Shaved"
	H.update_hair()

/datum/religion/guns
	name = "Murdercube"
	deity_name = "Gun Jesus"
	bible_name = "The Dokument"
	male_adept = "Kommando"
	female_adept = "Kommando"
	keys = list("murdercube","murderkube", "murder/k/ube","forgotten weapons", "gun", "guns", "ammo", "trigger discipline", "ave nex alea", "dakka")
	convert_method = "performing a ritual with a gun. The convert needs to be in good health and unafraid of being shot."
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/dense
	bookstyle = "The Dokument"

/datum/religion/guns/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/weapon/gun/energy/laser/practice)
	H.equip_or_collect(new /obj/item/clothing/under/syndicate, slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/jackboots, slot_shoes)

/datum/religion/guns/convertCeremony(var/mob/living/preacher, var/mob/living/subject)
	var/held_gun = preacher.find_held_item_by_type(/obj/item/weapon/gun)

	if (!held_gun)
		to_chat(preacher, "<span class='warning'>You need to hold a gun to begin the conversion.</span>")
		return FALSE

	if(!convertCheck(subject))
		subject.visible_message("<span class='warning'>\The [subject] refuses conversion.</span>")
		return FALSE

	var/obj/item/weapon/gun/G = preacher.held_items[held_gun]

	sleep(0.1 SECONDS)
	if(G.canbe_fired())
		G.Fire(subject,preacher,0,0,1)
	else
		G.click_empty(preacher)
		return FALSE

	preacher.say("AVE NEX ALEA!")

	subject.visible_message("<span class='notice'>\The [subject] masterfully completed the delicate ritual. He's now a full-fledged follower of the [deity_name].</span>")

	convert(subject, preacher)
	return TRUE

/datum/religion/speedrun
	name = "Speedrunning"
	deity_name = "TASbot"
	bible_name = "Guide to Speedrunning"
	male_adept = "Speedrunner"
	female_adept = "Speedrunner"
	keys = list("speedrun","ADGQ","SGDQ","any%", "glitchless", "100%", "gotta go fast", "kill the animals", "greetings from germany", "cancer", "dilation station", "dilation stations")
	preferred_incense = /obj/item/weapon/storage/fancy/incensebox/novaflowers
	bookstyle = "Creeper"

/datum/religion/buttbot
	name = "Buttbot"
	deity_name = "Buttbot"
	bible_name = "Guide to Robuttics"
	male_adept = "Roboticist"
	female_adept = "Roboticist"
	keys = list("buttbot", "butt bot", "butt", "ass", "poo", "server crash", "comms spam")

/datum/religion/buttbot/equip_chaplain(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/head/butt(H), slot_head)

/datum/religion/buttbot/interceptPrayer(var/mob/living/L, var/deity, var/prayer_message)
	spawn(rand(1,3))
		L.get_subtle_message(buttbottify(prayer_message), src.deity_name)
		L.playsound_local(src,'sound/misc/fart.ogg', 50, 1)
