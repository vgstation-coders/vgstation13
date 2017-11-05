// This file lists all religions, as well as the prototype for a religion, and a proc to design your own if you want to.
/datum/religion
	// Following tradition, the default is Space Jesus (this is here to avoid people getting an empty relgion)
	var/name = "Christianity"
	var/deity_name = "Space Jesus"
	var/bible_name = "The Holy Bible"
	var/male_adept = "Chaplain"
	var/female_adept = "Chaplain"
	var/bible_type = /obj/item/weapon/storage/bible

	var/list/bible_names = list()
	var/list/deity_names = list()

	var/list/keys = list() // What you need to type to get this particular relgion.

/datum/religion/New() // For religions with several bibles/deities
	if (bible_names.len)
		bible_name = pick(bible_names)
	if (deity_names.len)
		deity_name = pick(deity_names)

/datum/religion/proc/misc(var/mob/living/carbon/human/H, var/obj/item/weapon/storage/bible/B)
	return TRUE // Nothing to see here, but redefined in some other religions !

// The list of all religions spacemen have designed, so far.
/datum/religion/catholic
	name = "Catholicism"
	deity_name = "Jesus Christ"
	bible_name = "The Holy Bible"
	male_adept = "Bishop"
	female_adept = "Bishop"
	keys = list("catholic", "catholicism", "roman catholicism")

/datum/religion/catholic/misc(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/head/mitre(H), slot_head)

/datum/religion/theism
	name = "Theism"
	deity_name = "God"
	bible_names = list("The Gnostic Bible", "The Dead Seas Scrolls")
	keys = list("theist", "gnosticism", "theism")

/datum/religion/satanism
	name = "Satanism"
	deity_name = "Satan"
	bible_name = "The Satanic Bible" //What I found on Google, ergo the truth
	male_adept = "Magister"
	female_adept = "Magistera"
	keys = list("satan", "evil", "satanism")

/datum/religion/lovecraft
	name = "Esoteric order of Dagon"
	deity_name = "Cthulhu" //I hope it's spelt correctly
	bible_names = list("The Necronomicon", "The Book of Eibon", "De Vermis Mysteriis", "Unaussprechlichen Kulten")
	keys = list("cthulhu", "old ones", "great old ones", "outer gods", "elder gods", "esoteric order of dagon")

/datum/religion/islam
	name = "Islam"
	deity_name = "Allah"
	bible_name = "The Quran"
	male_adept = "Imam"
	female_adept = "Imam"
	keys = list("islam", "muslim")

/datum/religion/slam
	name = "Slam"
	deity_name = "Charles Barkley"
	bible_name = "Barkley: Shut Up and Jam - Gaiden"
	male_adept = "Master of Slam"
	female_adept = "Mistress of Slam"
	keys = list("slam", "bball", "basketball", "basket ball")

/datum/religion/judaism
	name = "Judaism"
	deity_name = "Yahweh"
	bible_names = list("The Torah", "The Talmud")
	male_adept = "Rabbi"
	female_adept = "Rabbi"
	keys = list("jew", "judaism", "jews")

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
	male_adept = "Guru"
	female_adept = "Guru"
	keys = list("hindu", "hinduism", "india")

/datum/religion/shintoism
	name = "Shintoism"
	deity_name = "Kami" //Polytheist and shit, do I sound like a weeb ?
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

/datum/religion/nordic
	name = "Viking Mythos"
	deity_names = list("Thor", "Odin", "Freyja", "Loki", "Tyr")
	bible_name = "The Eddas"
	male_adept = "Godi"
	female_adept = "Godi"
	keys = list("norse", "german pagan","viking")

/datum/religion/celtic
	name = "Celtic Mythos"
	deity_names = list("Toutatis", "Belenus", "Britannia") //Hon
	bible_name = "The Book of Leinster"
	male_adept = "Druid"
	female_adept = "Druidess"
	keys = list("druidism", "celtic")

/datum/religion/atheism
	name = "Atheism"
	deity_name = "Richard Dawkins"
	bible_name = "The God Delusion"
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "Militant Atheist" // Wasn't defined so the poor dude ended up being a chaplain
	female_adept = "Militant Atheist"
	keys = list("atheism", "none")

/datum/religion/atheism/misc(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/head/fedora(H), slot_head)

/datum/religion/evolution
	name = "Theory of Evolution"
	deity_name = "Charles Darwin"
	bible_name = "The God Delusion"
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "Biologist"
	female_adept = "Biologist"
	keys = list("evolution", "biology", "monkey", "monkeys")

/datum/religion/scientology
	name = "Scientology"
	deity_name = "The Eighth Dynamic" //Don't ask, just don't
	bible_names = list("The Biography of L. Ron Hubbard", "Dianetics")
	male_adept = "OT III"
	female_adept = "OT III"
	keys = list("scientology")

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

/datum/religion/hellenism
	name = "Hellenism"
	deity_names = list("Zeus", "Poseidon", "Athena", "Persephone", "Ares", "Apollo")
	bible_name = "The Odyssey"
	male_adept = "Oracle"
	female_adept = "Oracle"
	keys = list("hellenism", "greece", "greek")

/datum/religion/latin
	name = "Cult of Rome"
	deity_names = list("Jupiter", "Neptune", "Mars", "Minerva", "Rome", "Julius Caeser", "Roma")
	bible_name = "Cult of Rome"
	male_adept = "Pontifex"
	female_adept = "Pontifex"
	keys = list("latin", "rome", "roma", "roman")

/datum/religion/latin/misc(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/head/helmet/roman/legionaire(H), slot_head)
	H.equip_or_collect(new /obj/item/clothing/under/roman(H), slot_w_uniform)

/datum/religion/pastafarianism
	name = "Pastafarianism"
	deity_name = "The Flying Spaghetti Monster"
	bible_name = "The Gospel of the Flying Spaghetti Monster"
	keys = list("pastafarianism")

/datum/religion/chaos
	name = "Chaos"
	deity_names = list("Khorne", "Nurgle", "Tzeentch", "Slaanesh")
	bible_names = list("The Book of Lorgar", "The Book of Magnus")
	male_adept = "Apostate Preacher"
	female_adept = "Apostate Preacher"
	keys = list("chaos")

/datum/religion/imperium
	name = "The Imperial Creed"
	deity_name = "God-Emperor of Mankind"
	bible_names = list("An Uplifting Primer", "Codex Astartes", "Codex Hereticus")
	male_adept = "Confessor"
	female_adept = "Prioress"
	keys = list("imperium", "imperial cult")

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

/datum/religion/homosexuality/misc(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/under/darkholme(H), slot_w_uniform)

/datum/religion/retard
	name = "Retardation"
	deity_name = "Brian Damag" //Ha
	bible_names = list("Woody's Got Wood: The Aftermath", "War of the Cocks", "Sweet Bro and Hella Jef: Expanded Edition", "The Book of Pomf")
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "Retard"
	female_adept = "Retard"
	keys = list("lol", "wtf", "ass", "poo", "badmin", "shitmin", "deadmin", "nigger", "dickbutt", ":^)", "XD", "le", "meme", "memes", "ayy", "ayy lmao", "lmao", "reddit", "4chan", "tumblr", "9gag")

/datum/religion/retard/misc(var/mob/living/carbon/human/H)
	H.setBrainLoss(100) //Starts off retarded as fuck, that'll teach him

/datum/religion/science
	name = "Science"
	deity_names = list("Albert Einstein", "Isaac Newton", "Niels Bohr", "Stephen Hawking")
	bible_names = list("Principle of Relativity", "Quantum Enigma: Physics Encounters Consciousness", "Programming the Universe", "Quantum Physics and Theology", \
							  "For I Have Tasted The Fruit", "Non-Linear Genetics", "The Mysteries of Bluespace", "Playing God: Collector's Edition")
	male_adept = "Academician"
	female_adept = "Academician"
	keys = list("Science")

/datum/religion/justice
	name = "Justice"
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

/datum/religion/deadra
	name = "Cult of the Deadreas"
	deity_names = list("Azura", "Boethiah", "Sheogorath", "Sanguine", "Hircine", "Meridia", "Hermaeus Mora", "Nocturnal")
	bible_name = list("The Blessings of Sheogorath", "Boethiah's Pillow Book", "Invocation of Azura")
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
	deity_name = "The Marker"
	bible_name = "Teachings of Unitology"
	male_adept = "Disciple"
	female_adept = "Disciple"
	keys = list("unitology", "marker")

/datum/religion/ianism
	name = "Ianism"
	deity_name = "Ian"
	bible_name = "The Porky Little Puppy"
	bible_type = /obj/item/weapon/storage/bible/booze
	male_adept = "Veterinarian"
	female_adept = "Veterinarian"
	keys = list("ianism", "ian", "dog", "puppy", "doggo", "pupper")

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
	keys = list("coding", "coder", "coders", "coderbus")

/datum/religion/spooky
	name = "The Ultimate Question"
	deity_name = "The Spook" //SPOOK
	bible_name = "The Spooky Spook"//SPOOK
	male_adept = "Ghost"
	female_adept = "Ghost"
	keys = list("spook", "spooky", "boo", "ghost", "halloween", "2spooky")

/datum/religion/spooky/misc(var/mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/head/pumpkinhead(H), slot_head)
