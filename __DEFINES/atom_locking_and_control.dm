/* Atom Locking */

// Flags for the locking categories.
#define LOCKED_SHOULD_LIE            1
#define DENSE_WHEN_LOCKING           2
#define CANT_BE_MOVED_BY_LOCKED_MOBS 4
#define LOCKED_CAN_LIE_AND_STAND     8

// Flags for atom.lockflags
#define DENSE_WHEN_LOCKED            1


/* Atom Control */

//Flags for the control datum
#define REVERT_ON_CONTROLLER_DAMAGED 1
#define LOCK_EYE_TO_CONTROLLED 2
#define LOCK_MOVEMENT_OF_CONTROLLER 4
#define REQUIRES_CONTROL 8
