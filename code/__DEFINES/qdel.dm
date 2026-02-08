//! Defines that give qdel hints.
//!
//! These can be given as a return in [/atom/proc/Destroy] or by calling [/proc/qdel].

/// `qdel` should queue the object for deletion.
#define QDEL_HINT_QUEUE 0
/// `qdel` should let the object live after calling [/atom/proc/Destroy].
#define QDEL_HINT_LETMELIVE 1
/// Functionally the same as the above. `qdel` should assume the object will gc on its own, and not check it.
#define QDEL_HINT_IWILLGC 2
/// Qdel should assume this object won't GC, and queue a hard delete using a hard reference.
#define QDEL_HINT_HARDDEL 3
// Qdel should assume this object won't gc, and hard delete it posthaste.
#define QDEL_HINT_HARDDEL_NOW 4

// Defines for the [gc_destroyed][/datum/var/gc_destroyed] var.
#define GC_CURRENTLY_BEING_QDELETED -2
