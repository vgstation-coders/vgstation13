#if UNIT_TESTS_ENABLED

#define assert_eq(a, b) (a == b || (fail("[__FILE__]:[__LINE__]: assert_eq failed. Expected [b], got [a].")))

#endif
