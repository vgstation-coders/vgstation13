/datum/pomf_tip
	var/title = "Title"
	var/desc = "The desc of the tip"
	var/category = "Abstract"
	var/weight = 0

// -- Admins

/datum/pomf_tip/always_ahelp
	title = "Always ahelp!"
	desc = "Admins are here to help. If you are not sure about doing something, or if you think someone is breaking the rules, you can always ahelp it by pressing F1."
	category = "Admins"
	weight = 3

/datum/pomf_tip/antag_seeds
	title = "Antag seeds"
	desc = "There is no such thing as an antag seed. Stop asking."
	category = "Admins"
	weight = 1

// -- Roleplay

/datum/pomf_tip/coop
	title = "Cooperation"
	desc = "Cooperation is key. A friendly word or PDA message can make a much more fun round."
	category = "Roleplay"
	weight = 3

/datum/pomf_tip/coop
	title = "Losing is fun"
	desc = "Sometimes things don't go your way. Try and enjoy the ride, there's always next shift and maybe your story helped make someone else's."
	category = "Roleplay"
	weight = 3

/datum/pomf_tip/sniper
	title = "Losing is fun"
	desc = "Be polite. Be efficient. Have a plan to slip everyone you meet."
	category = "Roleplay"
	weight = 1

/datum/pomf_tip/teaching
	title = "Teach"
	desc = "Teaching your fellow spaceman is a time honored tradition. Help the newbies out, pass on the torch."
	category = "Roleplay"
	weight = 3

/datum/pomf_tip/forever
	title = "There is never an end to ss13"
	desc = "Don't forget. You're here forever."
	category = "Roleplay"
	weight = 1

// -- General

/datum/pomf_tip/ground_up
	title = "Grinding items"
	desc = "A lot of things can be ground up to make chemicals and materials. Try and grind up a Danitos package, if you dare!"
	category = "General"
	weight = 3

/datum/pomf_tip/alt_click
	title = "Containers"
	desc = "You can alt-click containers to show their contents and put items in them without picking them up."
	category = "General"
	weight = 3

/datum/pomf_tip/hotkey_mode
	title = "Hotkey mode"
	desc = "You can press TAB to enable hotkey mode and use WASD movement, T for talk, and other keyboard shortcuts. Consult the wiki for a full list."
	category = "General"
	weight = 3

/datum/pomf_tip/pda_messages
	title = "PDAs"
	desc = "Your PDA has a lot of utility. Buy some programs for it, or send everyone in a department a message if they're not listening to the radio! Some can even be health scanners!"
	category = "General"
	weight = 3

/datum/pomf_tip/antag_objectives
	title = "Solo objectives"
	desc = "If you lack inspiration or prefer to have a defined set of challenges, you can opt to have defined antagonist objectives by selecting the option in character setup."
	category = "General"
	weight = 3

/datum/pomf_tip/runechat
	title = "Runechat"
	desc = "In your options tab, 'runechat' refers to animations of the text said by players being displayed over their heads as they are talking."
	category = "General"
	weight = 3

/datum/pomf_tip/attack_anims
	title = "Attack animations"
	desc = "Confusing about who's hitting who? You can toggle attack animations in your preferences."
	category = "General"
	weight = 3

/datum/pomf_tip/vox_rights
	title = "Vox rights!"
	desc = "Vox rights are NOT human rights. Make sure to consult with the silicons and command staff before doing anything you'll regret when playing one!"
	category = "General"
	weight = 1

// -- Command

/datum/pomf_tip/chain_of_command
	title = "Chain of command"
	desc = "When there is no captain at roundstart, other heads of staff can become acting captain and secure important items such as the captain's spare and do job changes."
	category = "Command"
	weight = 3

// -- Silicon laws

/datum/pomf_tip/emotional_harm
	title = "Emotional harm"
	desc = "On the Asimov lawset, emotional harm is not considered human harm."
	category = "Silicon laws"
	weight = 3

/datum/pomf_tip/self_harm
	title = "Self harm"
	desc = "On the Asimov lawset, self-harm is not considered human harm."
	category = "Silicon laws"
	weight = 3

/datum/pomf_tip/burgs
	title = "Robot names"
	desc = "As a cyborg, minor misspelling of your name are NOT a good reason to ignore orders."
	category = "Silicon laws"
	weight = 3

/datum/pomf_tip/law_orders
	title = "Self harm"
	desc = "When they blatantly conflict, silicon laws are to be interpreted in descending order - higher laws have higher priority - unless otherwise specified. When obeying a higher law, you must avoid violating lower laws if possible."
	category = "Silicon laws"
	weight = 3

/datum/pomf_tip/slaved_borg
	title = "Cyborgs are slaved to their AI"
	desc = "As a cyborg slaved to an AI, you are expected (as far as reasonably possible) to obey your AI when it does not come into conflicts with your laws."
	category = "Silicon laws"
	weight = 3

/datum/pomf_tip/mommis
	title = "MoMMis"
	desc = "Non-emagged MoMMis are not meant to interact with the crew too much - but a little wiggling has never hurt anybody."
	category = "Silicon laws"
	weight = 3

// -- Science

/datum/pomf_tip/xenoarch
	title = "Artifacts"
	desc = "Bringing an Artifact to the station is risky for your health! Reconsider, before people reconstruct your body into burgers."
	category = "Science"
	weight = 3

/datum/pomf_tip/science
	title = "Science goodies"
	desc = "Science can do great things with what they have. Encourage them to be active, they usually just become hermits."
	category = "Science"
	weight = 3

// -- Cargo

/datum/pomf_tip/materials
	title = "Materials"
	desc = "Remember to give some materials to the Mechanics as a Miner, Science always hoards that stuff."
	category = "Miner"
	weight = 3

// -- Security

/datum/pomf_tip/broken_window_theory
	title = "Broken Window Theory"
	desc = "A janitor is a sec mans best friend. Don't let the broken windows stack, or hell will come to your brig soon enough."
	category = "Security"
	weight = 3

/datum/pomf_tip/letter_and_spirit_of_the_law
	title = "Letter and spirit of the Law"
	desc = "Following the law is good, but don't overdo it as a security officer. A more relaxed sec man is less likely to be lynched, and less likely to be bwoinked."
	category = "Security"
	weight = 3

/datum/pomf_tip/no_brakes_on_the_escalation_train
	title = "There are no brakes on the escalation train"
	desc = "The shotgun doesn't miss, but neither do the admins. Remember not to escalate too hard."
	category = "Security"
	weight = 1

// -- Librarian

/datum/pomf_tip/do_you_have_anything
	title = "Do you have ANYTHING that isn't..."
	desc = "There's more than just porn in the library. Please print good books."
	category = "Librarian"
	weight = 3

// -- Clown and mime

/datum/pomf_tip/gimmick_repeating
	title = "Ugh! It's my gimmick!"
	desc = "Gimmicks are fun as long as they're novel, but lose their shine quickly over time. Always try to innovate and switch up your tactics, especially as clown or mime."
	category = "Clown and mimes"
	weight = 3

// -- Medical

/datum/pomf_tip/viruses
	title = "Viruses"
	desc = "Low strength viruses can be cured with spacecilin, but for stronger ones, you will need to use the virology machines."
	category = "Medical"
	weight = 3

/datum/pomf_tip/surgery
	title = "Surgery"
	desc = "Patients undergoing surgery may wince and shake in pain if not properly anaesthetised."
	category = "Medical"
	weight = 3

// --- REMOVED ---

/datum/pomf_tip/multikeying
	title = "Multikeying"
	desc = "Multikeying - using multiple accounts to play in the same round - is strictly forbidden."
	category = "Admins"
	weight = 0

/datum/pomf_tip/be_honest
	title = "Be honest in ahelps"
	desc = "Lying to bwoink man is bad for your employment record. Be honest, you'll probably be fine."
	category = "Admins"
	weight = 0
