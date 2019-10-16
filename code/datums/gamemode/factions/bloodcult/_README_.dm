//CULT 3.0 BY DEITY LINK (2018)
//BASED ON THE ORIGINAL GAME MODE BY URIST MCDORF

/*

[bloodcult.dm]

	> global variable
		* veil_thickness
			-> sets powers are currently available to cult, along with other behaviours such as reaction to holy water
			-> the var increases as the cult progresses, which makes them more powerful in terms of tools available, but also easier to find

	* faction code

	> special procs:
		* get_available_blood
			-> returns a /list with information on nearby available blood. For use by use_available_blood().
		* use_available_blood
			-> actually removes the blood from containers, displays flavor texts, and returns a /list with informations on the success/failure of the proc.
			-> this proc is used by any ritual that requires a blood cost (rune, talisman, tattoo, etc)
		* spawn_bloodstones
			-> called at the start of ACT III, or by set_veil_thickness. Triggers the rise of bloodstones accross the station Z level.
		* prepare_cult_holomap
			-> initialize the cult holomap displayed by Altars, and Bloodstones when it gets checked by a cultist
		* cult_risk
			-> rolls for a chance to reveal the presence of the cult to the crew prior to ACT III, called after a ritual that increases the cultist count.

	> /obj/item procs:
		* get_cult_power
			-> returns the item's cult power. set manually for each item in bloodcult_items.dm.
	> /mob procs:
		* get_cult_power
			-> returns the combined cult power of every item worn by that mob.
			-> cult power improves the efficiency of some rituals
	> /client procs:
		* set_veil_thickness
			-> debug proc that lets you manipulate what powers are currently available to cult, disregarding the current completion of their objectives
			-> WARNING: setting to "3" will trigger the rise of bloodstones.


[bloodcult_buildings.dm]

	* /obj/structure/cult
		> procs
			* conceal
				-> hides the structure inside an invisible /obj/structure/cult/concealed
			* reveal
				-> removes /obj/structure/cult/concealed and pulls out the concealed structure
			* takeDamage
				-> called by anything that can deal damage to cult structures. handles its destruction.
			* cultist_act
				-> result of a cultist's attack_hand
			* noncultist_act
				-> result of a non-cultist's attack_hand
			* update_progbar
				-> updates the progression bar (used by altars, forges, and bloodstones)
			* safe_space
				-> rebuilds the area around the structure, removing adjacent obstacle to allow free pathing directly around it,
				-> while adding some walls further out to prevent possible breach into space
			* dance_start
				-> used by Altars and Bloodstones in their rituals
			* dance_step
				-> used by Altars and Bloodstones in their rituals

		* /concealed

		* /altar
			> procs
				* checkPosition
				* stopWatching
					-> holomap stuff

		* /spire
			> procs
				* upgrade
				* update_stage

		* /forge
			> procs
				* setup_overlays

		* /pillar

		* /bloodstone
			> procs
				* checkPosition
				* stopWatching
					-> holomap stuff
				* set_animate
					-> activates the pulsating animation of the anchor
				* summon_backup
					-> triggers the arrival of a few hostile simple animals that attack non-cultists

[bloodcult_cultify_exceptions.dm]

	* lists all the machinery and stuff that gets deleted by Cultify() instead of getting converted into a cult structure.
	* mostly machinery that has no density by default, newscasters and the likes.


[bloodcult_data.dm]

	* /datum
		* /runeset, might allow non-bloodcult runes down the line, courtesy of GlassEclipse
		* /runeword
			-> data for each cult word


[bloodcult_effects.dm]
	* /obj/effect
		* /cult_ritual
			-> an anchored no-mouse-opacity object, mainly used to carry visual effects of cult rituals
			* /backup_spawn
				-> causes the apparition of a hostile cult simple animal.
				-> the spawned animals become stronger the more this object is created

		* /red_afterimage
			-> afterimage left behind by a dashing juggernaut

		* /bloodcult_jaunt
			-> holds atoms currently performing a cult jaunt, due to either a Path or Magnetism ritual
			> procs:
				* move_to_edge
					-> if the effect targets a turf on another Z level, it'll teleport to the edge of that Z level closest from the target turf
				* init_angle
					-> turns the effect toward its target
				* update_pixel()
				* bresenham_step
				* process_step
					-> bunch of magic that lets the effect move smoothly in a straight line
				* init_jaunt
					-> prevents mobs inside the effect from clicking anything
				* bump_target_check
					-> checking if we've arrived

		* /stun_indicator
			-> displays an indicator above people that have been hit by stun talisman, visible to all nearby cultists.
			-> the indicator ticks down as the victim's stun duration goes down
			> procs:
				* update_indicator
				* place_indicator


[bloodcult_flavourlines.dm]

	* post-conversion flavor text, courtesy of Shifty

[bloodcult_hell_rising.dm]

	* if I do that post-narsie update at some point in the future, this is where its code will be. Behold and despair.

[bloodcult_items.dm]

	* /obj
		* /item
			* /weapon
				* /tome
					-> a cultist's guide to the various runes and the goals of the cult
					-> greatly eases the process of writing runes when held, also a decent weapon on non-cultists
					-> if you hit a ghost made visible through usage of a Seer rune, that ghost will become visible to everyone, until banished by a chaplain
					-> you can store talismans in it, and quickly cast them from it through its UI (or an alt-click, courtesy of Yred)
					> procs:
						* tome_text
							-> formats the content of the tome, depending on which runes are available at the current veil thickness
							-> the description for each rune is defined in bloodcult_runespells.dm
						* page_special
							-> extra pages pre-written here

				* /talisman
					-> a concealed piece of parchment that cultists can imbue with a rune
					-> can be used on a held cult blade to reduce it to dust
					-> can be used on ghosts made visible (through usage of a Seer rune) to have them write a message
					> procs:
						* talisman_name
							-> returns the talisman's name based on its imbued rune or ghostly message, for displaying inside a tome
						* trigger
							-> called by attack_self, invokes the imbued spell, or read the message
						* imbue
							-> called when a blank talisman is used on any rune
						* word_pulse
							-> called by imbue, creates a pulsating miniature image of the rune word given as arg, added as overlay

				* /melee
					* /cultblade
						-> can be improved into a soul blade when a cultist inserts a soul gem in it

						* /nocult
							-> a broken cult blade

					* /soulblade
						>procs:
							* takeDamage
								-> handles the blade taking damage and breaking

					* /blood_dagger

				* /storage
					* /backpack/cultpack
						-> chaplains can also spawn those
					* /cult
						-> a coffer, spawned by those who refused conversion, holds their loot

				* /bloodcult_pamphlet
					-> a debug item that turns its user into a cultist, while properly initializing the faction and other stuff
					-> NOT consumed upon use, so don't just spawn one of those during a round, outside of an isolated cult lesson

				* /bloodcult_jaunter
					-> a debug item used to debug cult jaunts

				* /reagent_containers/food/drinks/cult
					-> tempting goblet

				* /blood_tesseract
					-> stores the apparel of cultists who used a Summon Robe rune, and lets them immediately switch back to those clothes.

			* /device
				* /soulstone
					-> defined in soulstone.dm
					* /gem
						-> breaks into a soul stone shard when thrown

			* /clothing
				* /head
					* /culthood
						* /old
					* /helmet/space/cult
					* /magus

				* /shoes
					* /cult
				* /suit
					* /cultrobes
						* /old
					* /space/cult
					* /magusred

		* /structure
			/bloodcult_jaunt_target
				-> spawned by a bloodcult_jaunter debug item

[bloodcult_mobs_and_constructs.dm]

	* /mob/living/simple_animal
		* /construct
			* /armoured
				-> juggernaut
				-> defined in constructs.dm
				* /perfect

			* /wraith
				-> defined in constructs.dm
				* /perfect

			* /builder
				-> artificer
				-> defined in constructs.dm
				* /perfect

		* /hostile/hex
			-> spawned by perfects artificers

	* /obj
		* /item/projectile/wraithnail
			-> projectiles shot by perfect wraiths
			-> very low damage, but nails people in place

		* /obj/effect/overlay
			* /wraithnail
				-> the nail that appears over targets hit by wraith nails. Can be clicked to unstick it after a second.
				> procs:
					* stick_to
					* unstick

			* /artificerray
				-> visual ray that appears when artificers

[bloodcult_narsie.dm]

	* if I do that post-narsie update at some point in the future, I'll have to rewrite narsie probably from scratch and this is where I'll write the code
	* in the meantime, there's some soothing white space to look at

[bloodcult_projectiles.dm]

	* /obj/item/projectile
		* /soulbullet
			-> thrown soul blade
			> procs:
				* redirect
					-> the Perforate soul blade spell can be cast by doing a drag n drop, allowing the blade to change direction mid-flight
					-> this proc is called when the direction change occurs

		* /bloodslash
			-> swung soul blade
			-> hex projectile attack

		* /blooddagger
			-> thrown blood dagger

[bloodcult_runes.dm]

	* /obj/effect/rune
		> procs:
			* can_read_rune
				-> whether a player can examine a rune
			* make_iconcache
				-> creating and caching the rune's icon
			* idle_pulse
				-> passive pulsations of a working rune
			* one_pulse
				-> strong pulse called when a rune is triggered
			* trigger
				-> called when a cultist touches it or an attuned talisman gets triggered
			* fizzle
				-> the rune failed to activate, and the invoker spouts some gibberish
			* conceal
				-> turns the rune invisible
			* reveal
				-> reveal the rune if invisible

		* /blood_cult
			-> the runes used by the cult of narsie

	> special procs:
		* write_rune_word
			-> tries to write/add a given word to a rune on a given turf, using a given blood source
			-> the written rune will carry the DNA info and diseases of the source blood
		* erase_rune_word
			-> tries to erase a word from a rune on the given turf


[bloodcult_runespells.dm]

	* lists all the runes available to the cult

	> special procs:
		* get_rune_spell
			-> tries to find a spell corresponding to the given words, and gives a different return value depending on the specified use arg
		* shadow
			-> creates a neat shadow effect moving from a turf to another one, using a specified icon_state.

	* /datum/rune_spell
		> procs:
			* invoke
				-> has the caster pronounce the spell's invocation, whispering if using a talisman, or not at all if bearing the Silent Casting tattoo
			* pre_cast
				-> checking if the spell can be cast, in regard to veil thickness, or requirements such as standing on top of the rune
			* pay_blood
				-> calls use_available_blood and aborts the process if there is no blood available despite it being a requirement (some runes require no blood)
			* Added
				-> called by /obj/effect/rune/Crossed, allows you to set up spell behaviours triggered by things moving on top of a rune.
				-> used by Reveal
			* Removed
				-> called by /obj/effect/rune/Uncrossed, allows you to set up spell behaviours triggered by things away from a rune.
				-> used by Conversion, and Astraly Journey
			* midcast
				-> called when a cultist triggers a rune that's already currently channeling a spell, such as when joining a Magnetism or Raise Structure ritual
			* cast
				-> called when the spell is cast from a rune (that's not already channeling)
			* abort
				-> called when a spell has to stop for any reason. Takes care of freeing variables and deleting the datum.
			* missing_ingredients_count
				-> used by runes requiring ingredients (only Resurrect for now) to tell the caster which ones are missing
			* update_progbar
				-> updates the progression bar, generally in the case of channeling rituals

		* /blood_cult
			> procs:
				* cast_talisman
					-> called when the spell is cast from a talisman (with the talisman's attack_self)
				* cast_touch
					-> called when the spell is cast by touching a mob with a talisman
				* midcast_talisman
					-> called when the spell is cast from a talisman that's already channeling a spell (only Path Entrance / Path Exit for now)

			* /raisestructure
			* /communication
			* /summontome
			* /conjuretalisman
			* /conversion
			* /stun
			* /blind
				-> Confusion
			* /deafmute
			* /hide
				-> Conceal
			* /reveal
			* /seer
			* /summonrobes
			* /door
			* /fervor
			* /summoncultist
				-> Blood Magnetism
			* /portalentrance
			* /portalexit
			* /pulse
				-> EMP
			* /astraljourney
			* /resurrect

	* /obj/effect/cult_ritual
		* /cult_communication
			-> created by a Communication rune, listens to the voice of the caster on top of it.
		* /conversion
			-> created by a Conversion rune
		* /stun
			-> created by a Stun rune, self-destructs 1 second after spawning, stunning everyone around
		* /confusion
			-> created by a Confusion rune, handles the vision given to the victims
		* /reveal
			-> created by a Reveal rune, handles the revealing of cult runes and structures, and stuns nearby non-cultists
		* /seer
			-> created by a Seer rune, only visible to those who can see ghosts, therefore enables ghosts to notice cultists who can see them
		* /feet_portal
			-> appears bellow the feet of cultists participating in a Magnetism (rejoin) ritual
		* /resurrect
			-> created by a Resurrect rune


[bloodcult_spells.dm]

	* /spell/cult
			* /trace_rune
				* /blood_cult
					-> Allows cultists to write down runes

			* /erase_rune
				-> Allows cultists to erase runes

			* /blood_dagger
				-> Manifests a dagger made of the caster's blood in their hand

			* /arcane_dimension
				-> Lets cultists hide an arcane tome through the veil


[bloodcult_tattoos.dm]

	* /datum/cult_tattoo
		-> tattoos are stored in the mob's cultist role, they will therefore keep them if their mind moves to another body, while their old body will lose them.
		> procs:
			* getTattoo
				-> handles things that happen when you get the tattoo (getting a new spell, a new species, etc)

		* /bloodpool
		* /silent
		* /dagger
		* /holy
		* /memorize
		* /chat
		* /manifest
		* /fast
		* /shortcut

	* /mob
		> procs:
			* checkTattoo
				-> checks if the mob bears the given tattoo

*/