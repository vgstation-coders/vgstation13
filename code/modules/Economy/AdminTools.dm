/datum/admins/proc/EconomyPanel()
    if(!check_rights(0))	return
        dat += {"<head>
			<script type='text/javascript'>

				var locked_tabs = new Array();

				function updateSearch(){


					var filter_text = document.getElementById('filter');
					var filter = filter_text.value.toLowerCase();

					if(complete_list != null && complete_list != ""){
						var mtbl = document.getElementById("maintable_data_archive");
						mtbl.innerHTML = complete_list;
					}

					if(filter.value == ""){
						return;
					}else{

						var maintable_data = document.getElementById('maintable_data');
						var ltr = maintable_data.getElementsByTagName("tr");
						for ( var i = 0; i < ltr.length; ++i )
						{
							try{
								var tr = ltr\[i\];
								if(tr.getAttribute("id").indexOf("data") != 0){
									continue;
								}
								var ltd = tr.getElementsByTagName("td");
								var td = ltd\[0\];
								var lsearch = td.getElementsByTagName("b");
								var search = lsearch\[0\];
								//var inner_span = li.getElementsByTagName("span")\[1\] //Should only ever contain one element.
								//document.write("<p>"+search.innerText+"<br>"+filter+"<br>"+search.innerText.indexOf(filter))
								if ( search.innerText.toLowerCase().indexOf(filter) == -1 )
								{
									//document.write("a");
									//ltr.removeChild(tr);
									td.innerHTML = "";
									i--;
								}
							}catch(err) {   }
						}
					}

					var count = 0;
					var index = -1;
					var debug = document.getElementById("debug");

				}

				function expand(id,ref, balance){

					clearAll();

					var span = document.getElementById(id);

                    body +=
					body += "<a href='?src=\ref[src];adminplayeropts="+ref+"'>Account Details</a> "


					span.innerHTML = body
				}

				function clearAll(){
					var spans = document.getElementsByTagName('span');
					for(var i = 0; i < spans.length; i++){
						var span = spans\[i\];

						var id = span.getAttribute("id");

						if(!(id.indexOf("item")==0))
							continue;

						span.innerHTML = "";
					}
				}

				function selectTextField(){
					var filter_text = document.getElementById('filter');
					filter_text.focus();
					filter_text.select();
				}

			</script>
		</head>"}

        //body tag start + onload and onkeypress (onkeyup) javascript event calls
    	dat += "<body onload='selectTextField(); updateSearch();' onkeyup='updateSearch();'>"

    	//title + search bar
    	dat += {"

    		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable'>
    			<tr id='title_tr'>
    				<td align='center'>
    					<font size='5'><b>Player panel</b></font><br>
    					Hover over a line to see more information - <a href='?src=\ref[src];check_antagonist=1'>Check antagonists</a>
    					<p>
    				</td>
    			</tr>
    			<tr id='search_tr'>
    				<td align='center'>
    					<b>Search:</b> <input type='text' id='filter' value='' style='width:300px;'>
    				</td>
    			</tr>
    	</table>

    	"}

    	//player table header
    	dat += {"
    		<span id='maintable_data_archive'>
    		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable_data'>"}


        for(var/datum/money_account in all_money_accounts)
            
