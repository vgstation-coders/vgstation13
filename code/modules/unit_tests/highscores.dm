/datum/unit_test/highscores/start()
    var/datum/persistence_task/highscores/task = SSpersistence_misc.tasks["/datum/persistence_task/highscores"]
    task.file_path = "data/persistence/money_highscores_test.json"
    task.clear_records()

    var/datum/record/money/test_record = new("somebody", "Assistant", 40000)
    var/datum/record/money/test_record2 = new("a condom", "Captain", 35000)
    var/datum/record/money/test_record3 = new("this should not appear", "Nobody", 10000)
    var/datum/record/money/test_record4 = new("cuban pete", "Miner", 50000)
    var/datum/record/money/test_record5 = new("pedro cubano", "Miner", 30000)
    var/datum/record/money/test_record6 = new("frank sinatra", "Miner", 9999999)
    var/list/records = list(test_record, test_record2, test_record3, test_record4, test_record5, test_record6)

    task.insert_records(records)

    assert_eq(task.data[1].cash, 9999999)
    assert_eq(task.data[2].cash, 50000)
    assert_eq(task.data[3].cash, 40000)
    assert_eq(task.data[4].cash, 35000)
    assert_eq(task.data[5].cash, 30000)

    assert_eq(task.data[1].role, "Miner")
    assert_eq(task.data[2].role, "Miner")
    assert_eq(task.data[3].role, "Assistant")
    assert_eq(task.data[4].role, "Captain")
    assert_eq(task.data[5].role, "Miner")

    if(task.data.len > 5)
        fail("[task.name] is storing more than five entries. Len: [task.data.len]")

    task.on_shutdown()
    task.on_init()

    assert_eq(task.data[1].cash, 9999999)
    assert_eq(task.data[2].cash, 50000)
    assert_eq(task.data[3].cash, 40000)
    assert_eq(task.data[4].cash, 35000)
    assert_eq(task.data[5].cash, 30000)
