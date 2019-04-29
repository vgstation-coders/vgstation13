// Component Signal names.
// Avoids any mishaps caused by typos.

/** Sent when a mob AI component wants to set new machine state.
 * @param state mixed: The new machine state (HOSTILE_STANCE_IDLE, etc)
 */
#define COMSIG_STATE "state"

/** Sent when we've been bumped.
 * @param movable /atom/movable: The bumping entity.
 */
#define COMSIG_BUMPED "bumped"

/** Sent when we've bumped someone else.
 * @param movable /atom/movable: The bumped entity.
 */
#define COMSIG_BUMP   "bump"

/** Sent by mob Life() tick. No arguments.
 */
#define COMSIG_LIFE   "life"

/** Sent when a mob AI component has identified a new target.
 * @param target /atom: The targetted entity.
 */
#define COMSIG_TARGET "target"

/** Sent when a mob wants to move or stop.
 * @param dir integer: 0 to stop, NORTH/SOUTH/WEST/EAST/etc to move in that direction.
 * @param loc /turf: Specify to move in the direction of that turf.
 */
#define COMSIG_MOVE "move"

/** Sent when a mob wants to take a single step.
 * @param dir integer: NORTH/SOUTH/WEST/EAST/etc to move in that direction.
 */
#define COMSIG_STEP "step"


/** BLURB
 * @param temp decimal: Adds value to body temperature
 */
#define COMSIG_ADJUST_BODYTEMP "add body temp" // DONE, NEEDS IMPL


/** BLURB
 * @param amount decimal: Adjust bruteloss by the given amount.
 */
#define COMSIG_ADJUST_BRUTE "adjust brute loss" // DONE, NEEDS IMPL


/** BLURB
 * @param target /atom: The target being attacked.
 */
#define COMSIG_ATTACKING "attacking target" // DONE


/** BLURB
 * @param state boolean: Busy if true.
 */
#define COMSIG_BUSY "busy" // DONE, NEEDS IMPL


/** BLURB
 * @param temp decimal: Sets body temperature to provided value, in kelvin.
 */
#define COMSIG_SET_BODYTEMP "body temp" // DONE, NEEDS IMPL

/** Sent when a component is added to the container.
 * @param component /datum/component: Component being added.
 */
#define COMSIG_COMPONENT_ADDED "component added"

/** Sent when a component is being removed from the container.
 * @param component /datum/component: Component being removed.
 */
#define COMSIG_COMPONENT_REMOVING "component removing"

/** Sent when a mob wants to drop the item in its active hand. No arguments.
 */
#define COMSIG_DROP "drop"

/** Sent when a mob wants to click on something.
 * @param target /atom: The thing to be clicked on.
 */
#define COMSIG_CLICKON "clickon"

/** Sent when a mob wants to activate a hand which is holding a specific item.
 * @param target /atom: The item in question.
 */
#define COMSIG_ACTVHANDBYITEM "actvhandbyitem"

/** Sent when a mob wants to activate an empty hand. No arguments.
 */
#define COMSIG_ACTVEMPTYHAND "actvemptyhand"

/** Sent when a mob wants to throw the item in its active hand at something.
 * @param target /atom: The atom at which to throw.
 */
#define COMSIG_THROWAT "throwat"

/** Sent when a mob wants to call attack_self() on the item in its active hand. No arguments.
 */
#define COMSIG_ITMATKSELF "itmatkself"

/** Sent when a mob wants to quick-equip the item in its active hand. No arguments.
 */
#define COMSIG_EQUIPACTVHAND "equipactvhand"

/** Sent when a mob is attacking the controller.
 * @param assailant /mob: The mob attacking the controller
 * @param damage int: Damage done in this attack
 */

#define COMSIG_ATTACKEDBY "attacked_by"

/** Sent when a mob wants to update their current target zone.
 * @param target /mob: What the mob wants to attack
 * @param damagetype string: What damagetype will be used (melee, bullet, laser, etc.)
 */

#define COMSIG_GETDEFZONE "get_def_zone"

/** Sent when a mob wants whatever damage type (according to the armor list values) they may be wanting to use.
 * @param user /mob: What mob in question is asking for a damage type
 * @return a damage type ("melee","laser","energy", etc.)
 */

#define COMSIG_GETDAMTYPE "get_dam_type"

