/*!
 * Advanced Security Camera script
 */

$(window).on("onUpdateContent", function(){
	$("#textbased").html("<table><colgroup><col id=\"name\" span = \"2\" style=\"min-width: 40px; width: 30%;\" /><col id=\"pos\" style=\"min-width:150px; width: 30%;\" /></colgroup><thead><tr><td><h3>Name</h3></td><td><h3>&nbsp;</h3></td><td><h3>Position</h3></td></tr></thead><tbody id=\"textbased-tbody\"></tbody></table>");

	$("#uiMap").append("<img src=\"" + mapname + z + ".png\" id=\"uiMapImage\" width=\"256\" height=\"256\" unselectable=\"on\"/><div id=\"uiMapContent\" unselectable=\"on\"></div>");
	$("#uiMapContainer").append("<div id=\"uiMapTooltip\"></div>");
	if(!html5compat){
		var i = document.createElement("input");
		i.setAttribute("type", "range");
		html5compat = i.type !== "text";
	}
	if(html5compat){
	$("#switches").append("<div id='zoomcontainer' style='position: static; z-index: 9999; margin-bottom: -75px;'>Zoom: <div id='zoomslider' style='width: 75px; position: relative; top: -31px; right: -50px; z-index: 9999;'><input type=\"range\" onchange=\"setzoom(value);\" value=\"4\" step=\"0.5\" max=\"16\" min=\"0.5\" id=\"zoom\" style='border-style:none; background-color:transparent;'></div><div id=\"zoomval\" style='position:relative; z-index: 9999; right: -135px; top: -80px; color: white;'>100%</div></div>");
	}
	else{
			$("#switches").append(" Zoom: <a href='javascript:changeZoom(-2);'>--</a> <a href='javascript:changeZoom(2);'>++</a> <span id=\"zoomval\" style='color: white;'>100%</span>");

	}

	var width = $("#uiMap").width();

	scale_x = width / (maxx * tile_size);
	scale_y = width / (maxy * tile_size); // height is assumed to be the same
	$("#uiMap").css({	position: 'absolute',
						top: '50%',
						left: '50%',
						margin: '-512px 0 0 -512px',
						width: '256px',
						height: '256px',
						overflow: 'hidden',
						zoom: '4'
					});
	$('#uiMap').drags({handle : '#uiMapImage'});
	$('#uiMapTooltip')
		.off('click')
		.on('click', function (event) {
			event.preventDefault();
			$(this).fadeOut(400);
		});
	$('#uiMap').click(function(ev) {
		var el = document.getElementById('uiMap');
		var rect = el.getBoundingClientRect();
		var tileX = (((ev.clientX - rect.left - el.clientLeft + el.scrollLeft)) / defaultzoom + 7).toFixed(0);
		var tileY = (maxy-((ev.clientY - rect.top - el.clientTop + el.scrollTop)) / defaultzoom).toFixed(0);
		var xx = ((ev.clientX - rect.left - el.clientLeft + el.scrollLeft) / defaultzoom).toFixed(0);
		var yy = ((ev.clientY - rect.top - el.clientTop + el.scrollTop) / defaultzoom).toFixed(0);
		//var dot = document.createElement('div');
		//dot.setAttribute('style', 'position:absolute; width: 2px; height: 2px; top: '+top+'px; left: '+left+'px; background: red; z-index: 99999999;');
		//el.appendChild(dot);
		//alert(tileX + ' ' + tileY);
		window.location.href = "byond://?src=" + hSrc + "&action=crewclick&x=" + tileX + "&y=" + tileY + "&z=" + z;
	});
}
)
function deleteCamera(ID)
{
	var existingCamera = document.getElementById(ID);
	if(existingCamera && existingCamera.parentNode)
	{
		existingCamera.parentNode.removeChild(existingCamera);
	}
}

function updateCamera(ID, status, name, area, icon, pos_x, pos_y, pos_z, see_pos_x, see_pos_y, removing)
{
	deleteCamera(ID)//rather than updating all of this shit just delete it and draw a new one

	if(pos_x && pos_y)
	{
		var translated = tileToMapCoords(pos_x,pos_y);
		var href = "byond://?src="+hSrc+"&view="+ID;
		var dotElem				= $("<div id=\""+ID+"\" class=\"mapIcon mapIcon16 " + icon + " " +  (status == 1 ? "average" : "good") + "\" style =\"top:" + translated.yy +"px; left: " + translated.xx + "px; z-index: 2;\" unselectable=\"off\"><div class=\"tooltip hidden\">" + name  + (status == 1 ? " <span class='average'>Alarming</span>" : "") + " (" + area + ": "+see_pos_x+", "+see_pos_y+")</div></div>");
		//$("#uiMap").append("<div class=\"dot\" style=\"top: " + ty + "px; left: " + tx + "px; background-color: " + color + "; z-index: " + 999 + ";\"></div>");
		dotElem.data("href",href);
		$("#uiMap").append(dotElem);
		//$("#uiMapContainer").append(dotElem);
		//$("minimapImage").append(dotElem);
		//alert($("#uiMap").html());
		//$("#textbased").html(dotElem);


		function enable()
		{
			dotElem.addClass("active").css({ "border-color": color });
		}

		function disable()
		{
			dotElem.removeClass("active").css({ "border-color": "transparent" });
		}

		function click(e)
		{
			e.preventDefault();
			e.stopPropagation();

			window.location.href = "byond://?src=" + hSrc + "&action=select_person&name=" + encodeURIComponent(name);
		}

		$('.mapIcon')
			.off('mouseenter mouseleave')
			.on('mouseenter',
				function (event) {
					var self = this;
					$('#uiMapTooltip')
						.html($(this).children('.tooltip').html())
						.show()
						.stopTime()
						.oneTime(5000, 'hideTooltip', function () {
							$(this).fadeOut(500);
						});
				}
			);
		dotElem.on('click', function (event) {
			//event.preventDefault();
			var href = $(this).data('href');
			//alert(href);
			if (href != null)
			{
				window.location.href = href;
			}
		});

	}


}
