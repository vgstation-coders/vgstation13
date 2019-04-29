# What is this?
These are tests.
Tests are just procs that run any number of checks and might call the `fail()` proc.
If that happens, it is said the test failed, and a test failing means your changes cannot be merged.

# How do I write a test?
Define a new `/datum/unit_test` subtype.
The only requirement for a unit test datum is that you override the `start()` proc.
Your test might look something like this:
```
/datum/unit_test/my_feature/start()
    var/obj/item/my_feature/object = new
    if(object.this_proc_should_return_one_when_passed_zero(0) != 1)
        fail("[object.type] did not return 1 when it was supposed to!")
```
Put that into a new file in this directory, then add that file to `__unit_test_includes.dm`:
```
...
#include "my_feature.dm"
...
```
That's mostly it. Additional documentation is available in `_unit_test.dm`.

# Anything else I need to know?
- Runtime errors that happen while your test is running will automatically `fail()` with a detailed error message.
- Unit tests are not compiled by default, they have to be enabled in `__DEFINES/__compile_options.dm`.
- You can easily check the result of unit tests using the "Unit test report" verb, under the Debug category.

# Why would I want to do this?
The guarantees that the DM compiler can grant you are not many: code that compiles doesn't necessarily mean it will do what you intended it to, at run-time.
Unit testing helps you gain some confidence that your code works.
Not only that: if `your_feature` gets changed in the future, or if changes are done to some system `your_feature` depended on, a test will let you know before the damage is done.
