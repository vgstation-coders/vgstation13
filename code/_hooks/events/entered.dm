//  Ported from Baystation with permission from CrimsonShrike
//  https://github.com/Baystation12/Baystation12/pull/30310
//
//	Observer Pattern Implementation: Entered
//		Registration type: /atom
//
//		Raised when: An /atom/movable instance has entered an atom.
//
//		Arguments that the called proc should expect:
//			/atom/entered: The atom that was entered
//			/atom/movable/enterer: The instance that entered the atom
//			/atom/old_loc: The atom the enterer came from
//

var/event/entered/entered_event = new()

/event/entered
	expected_type = /atom

/*******************
* Entered Handling *
*******************/

/atom/Entered(atom/movable/enterer, atom/old_loc)
	..()
	INVOKE_EVENT(src,/event/entered,enterer,old_loc)
