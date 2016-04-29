/datum/admins/proc/EconomyPanel(action, hrefs)
    to_chat(world, "honk")
    if(!check_rights(0))	return

    var/dat= ""
    var/datum/money_account/detailed_account_view
    var/creating_new_account

    if(hrefs["choice"])
        switch(hrefs["choice"])
            if("create_account")
                creating_new_account = 1
            if("finalise_create_account")
                var/account_name = hrefs["holder_name"]
                var/starting_funds = max(text2num(hrefs["starting_funds"]), 0)
                if ((station_account.money - starting_funds) > 0)
                    station_account.money -= starting_funds
                    if(starting_funds >0)
                        //Create a transaction log entry if you need to
                        var/datum/transaction/T = new()
                        T.target_name = account_name
                        T.purpose = "New account funds initialisation"
                        T.amount = "([starting_funds])"
                        T.date = current_date_string
                        T.time = worldtime2text()
                        T.source_terminal = "$EE^$%$%ERROR$%#@#"
                        station_account.transaction_log.Add(T)
                    create_account(account_name, starting_funds, src)
                    creating_new_account = 0
            if("view_account_detail")
                var/index = text2num(hrefs["account_index"])
                if(index && index <= all_money_accounts.len)
                    detailed_account_view = all_money_accounts[index]
            if("view_accounts_list")
                detailed_account_view = null
                creating_new_account = 0

    if(creating_new_account)

        dat += {"<br>
            <a href='?src=\ref[src];econ_panel=view_accounts_list;'>Return to accounts list</a>
            <form name='create_account' action='?src=\ref[src]' method='get'>
            <input type='hidden' name='src' value='\ref[src]'>
            <input type='hidden' name='choice' value='finalise_create_account'>
            <b>Holder name:</b> <input type='text' id='holder_name' name='holder_name' style='width:250px; background-color:white;'><br>
            <b>Initial funds:</b> <input type='text' id='starting_funds' name='starting_funds' style='width:250px; background-color:white;'> (subtracted from station account.)<br>
            <i>New accounts are automatically assigned a secret number and pin, which are printed separately in a sealed package.</i><br>
            <b>Ensure that the station account has enough money to create the account, or it will not be created</b>
            <input type='submit' value='Create'><br>
            </form>"}
    else
        if(detailed_account_view)

            dat += {"<br>
                <a href='?src=\ref[src];econ_panel=view_accounts_list;'>Return to accounts list</a><hr>
                <b>Account number:</b> #[detailed_account_view.account_number]<br>
                <b>Account holder:</b> [detailed_account_view.owner_name]<br>
                <b>Account balance:</b> $[detailed_account_view.money]<br>
                <b>Assigned wage payout:</b> $[detailed_account_view.wage_gain]<br>
                <table border=1 style='width:100%'>
                <tr>
                <td><b>Date</b></td>
                <td><b>Time</b></td>
                <td><b>Target</b></td>
                <td><b>Purpose</b></td>
                <td><b>Value</b></td>
                <td><b>Source terminal ID</b></td>
                </tr>"}
            for(var/datum/transaction/T in detailed_account_view.transaction_log)

                dat += {"<tr>
                    <td>[T.date]</td>
                    <td>[T.time]</td>
                    <td>[T.target_name]</td>
                    <td>[T.purpose]</td>
                    <td>$[T.amount]</td>
                    <td>[T.source_terminal]</td>
                    </tr>"}
            dat += "</table>"
        else

            dat += {"<a href='?src=\ref[src];econ_panel=create_account;'>Create new account</a><br><br>
                <table border=1 style='width:100%'>"}
            for(var/i=1, i<=all_money_accounts.len, i++)
                var/datum/money_account/D = all_money_accounts[i]

                dat += {"<tr>
                    <td>#[D.account_number]</td>
                    <td>[D.owner_name]</td>
                    <td><a href='?src=\ref[src];econ_panel=view_account_detail;account_index=[i]'>View in detail</a></td>
                    </tr>"}
            dat += "</table>"

    usr << browse(dat, "window=econ_panel")
