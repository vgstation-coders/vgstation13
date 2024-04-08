//  Ported from Baystation with permission from CrimsonShrike
//  https://github.com/Baystation12/Baystation12/pull/30310
//
//	Observer Pattern Implementation: Exited
//		Registration type: /atom
//
//		Raised when: An /atom/movable instance has exited an atom.
//
//		Arguments that the called proc should expect:
//			/atom/entered: The atom that was exited from
//			/atom/movable/exitee: The instance that exited the atom
//			/atom/new_loc: The atom the exitee is now residing in
//

var/event/exited/exited_event = new()

/event/exited
	expected_type = /atom

/******************
* Exited Handling *
******************/

/atom/Exited(atom/movable/exitee, atom/new_loc)
	. = ..()
	var/list/inputs = list(exitee, new_loc)
	exited_event.invoke_event(src, inputs)
