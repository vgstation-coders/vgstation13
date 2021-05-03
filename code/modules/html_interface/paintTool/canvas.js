/*
 * ### canvas.js ###
 * Scripts meant to handle canvas.html
 */

// Tab selector
var panelIdList = ["infoPanel", "templatePanel", "exportPanel"];
function panelSelect(panelId) {
	var panelClass;
	var buttonClass;
	for (id in panelIdList) {
		id = panelIdList[id];
		panelClass = document.getElementById(id).classList;
		buttonClass = document.getElementById(id + "Button").classList;
		if (id != panelId) {
			panelClass.add("hidden");
			buttonClass.remove("linkOn");
		} else {
			panelClass.remove("hidden");
			buttonClass.add("linkOn");
		}
	}
}

function toggleClass(id, className) {
	var classList = document.getElementById(id).classList;
	if (classList.contains(className)) {
		classList.remove(className);
	} else {
		classList.add(className);
	}
}

function toggleHelp(helpButton, helpPanel) {
	toggleClass(helpButton, "linkOn");
	toggleClass(helpPanel, "hidden");
}

// Template control
var currentTemplate = {};
/* A test template for 14x14 sized paintings
{
	"rgn":[
		{"clr":"#ffffff","txt":"Mask"},
		{"clr":"#ffdddd","txt":"Mask border"},
		{"clr":"#ff8800","txt":"Hair"},
		{"clr":"#ee6000","txt":"Hair shade"},
		{"clr":"#ffff00","txt":"Eyeliner"},
		{"clr":"#0000ff","txt":"Eyes"},
		{"clr":"#ff8888","txt":"Nose shade"},
		{"clr":"#ff0000","txt":"Nose"},
		{"clr":"#000000","txt":"Background"}
	],
	"bmp": [
		8,8,8,8,8,8,8,8,8,8,8,8,8,8,
		8,8,8,8,8,8,8,8,8,8,8,8,8,8,
		8,8,8,8,8,8,8,8,8,8,8,8,8,8,
		2,2,2,8,8,8,8,8,8,8,2,2,2,8,
		2,2,2,2,2,8,8,8,2,2,2,2,2,2,
		2,2,2,2,1,1,1,1,1,2,2,2,2,2,
		2,2,3,3,1,4,0,4,1,3,3,2,2,2,
		3,3,3,1,1,5,4,5,1,1,3,3,3,2,
		3,3,3,1,0,4,0,4,0,1,3,3,3,8,
		8,8,8,1,0,6,7,6,0,1,8,8,8,8,
		8,8,8,1,1,0,6,0,1,1,8,8,8,8,
		8,8,8,8,1,1,1,1,1,8,8,8,8,8,
		8,8,8,8,8,8,8,8,8,8,8,8,8,8,
		8,8,8,8,8,8,8,8,8,8,8,8,8,8
	]
}
*/

function templateMover(id, isTargetToDone) {
	var item = document.getElementById("tp-" + id);

	// "Disable" item's buttons (show disabled versions, hide enabled versions)
	var items = item.getElementsByClassName("tp-pending-class");
	for (i = 0; i < items.length; i++) {
		if (isTargetToDone)
			items[i].classList.add("hidden");
		else
			items[i].classList.remove("hidden");
	}

	items = item.getElementsByClassName("tp-done-class");
	for (i = 0; i < items.length; i++) {
		if (isTargetToDone)
			items[i].classList.remove("hidden");
		else
			items[i].classList.add("hidden");
	}

	// Move item to Done list
	var target = isTargetToDone ? "doneRegions" : "pendingRegions";
	item.parentElement.removeChild(item);
	items = document.getElementById(target).children;
	inserted = false;
	for (i = 0; i < items.length; i++) {
		if (items[i].id > ("tp-" + id)) {
			items[i].insertAdjacentElement("beforebegin", item);
			inserted = true;
			break;
		}
	}
	if (!inserted) document.getElementById(target).insertAdjacentElement("beforeend", item);
}


function templatePending(id) {
	templateMover(id, false);
}

function templateDone(id) {
	templateMover(id, true);
}

var colorRegex = /^#[0-9A-Fa-f]{6}$/;
function buildTemplateItem(id, colorHint, textHint) {
	// Create a new color region element
	var item = document.createElement("LI");
	item.id = "tp-" + id;
	item.classList.add("item");

	// Color hint. Invalid colors get a red cross over a white background instead
	var missingColorIcon = "";
	if (!colorRegex.test(colorHint)) {
		missingColorIcon = '<span style="color: #ff0000; font-weight: bold">X</span>';
		colorHint = "#ffffff";
	}
	item.innerHTML = '<a class="button colorHint" style="background: {color}">{icon}</a>'
		.replace("{color}", colorHint).replace("{icon}", missingColorIcon);

	// Paint button, and disabled button variant
	item.innerHTML +=
		  '<a class="tp-pending-class button" onclick="templatePaint(\'{id}\');">Paint Over</a>'
			.replace("{id}", id)
		+ '<a class="tp-done-class button linkOff hidden">Paint Over</a>';

	// Text hint toggle button
	item.innerHTML +=
		  '<a class="button" id="tp-{id}-infoButton" onclick="toggleHelp(\'tp-{id}-infoButton\', \'tp-{id}-help\');"><div class="uiIcon16 icon-info"></div></a>'
			.replace("{id}", id).replace("{id}", id).replace("{id}", id);

	// Done/Pending button
	item.innerHTML +=
		  '<a class="tp-pending-class button" onclick="templateDone(\'{id}\')"><div class="uiIcon16 icon-carat-1-s"></div></a>'
			.replace("{id}", id)
		+ '<a class="tp-done-class button hidden" onclick="templatePending(\'{id}\')"><div class="uiIcon16 icon-carat-1-n"></div></a>'
			.replace("{id}", id);

	// Text hint. Actual text added through innerText, lest players inject their own html
	var helpText = document.createElement("P");
	helpText.innerText = textHint;
	item.innerHTML +=
		  '<div id="tp-{id}-help" class="line hidden"></div>'
			.replace("{id}", id);
	item.lastChild.appendChild(helpText);

	return item;

}

function loadTemplate(template) {
	//Empty both Pending and Done lists
	var itemLister = document.getElementById("doneRegions");
	while (itemLister.childElementCount > 0) {
		itemLister.removeChild(itemLister.firstChild);
	}
	itemLister = document.getElementById("pendingRegions");
	while (itemLister.childElementCount > 0) {
		itemLister.removeChild(itemLister.firstChild);
	}

	// Fill Pending list with new color regions
	currentTemplate = JSON.parse(template);
	for (i = 0; i < currentTemplate.rgn.length; i++) {
		itemLister.appendChild(buildTemplateItem(i, currentTemplate.rgn[i].clr, currentTemplate.rgn[i].txt));
	}
}

function exportTemplate() {
	var output = document.getElementById("export-text");
	var template = {rgn: [], bmp: []};

	var colors = [];
	for (pixel in bitmap) {
		if (colors.indexOf(bitmap[pixel]) < 0) {
			colors.push(bitmap[pixel]);
			template.rgn.push({clr: bitmap[pixel], txt: ""});
		}
		template.bmp.push(colors.indexOf(bitmap[pixel]));
	}
	output.value = JSON.stringify(template);
}

function templatePaint(id) {
	for (i in currentTemplate.bmp) {
		if (currentTemplate.bmp[i] == id) {
			var x = i % width;
			var y = (i - x)/width;
			pixelDraw(x, y, paint_color, paint_strength);
		}
	}
	display_bitmap();
	document.getElementById("bitmap").value = bitmap;
}

var src;
function initCanvas(paintInitData, canvasInitData) {
	initPaint(paintInitData);
	document.getElementById("paintColumn").style.maxWidth = (document.getElementById("canvas").width + 40) +  "px";

	canvasInitData = JSON.parse(canvasInitData);

	src = canvasInitData.src;
	document.getElementById("title").value = canvasInitData.title;
	document.getElementById("author").value = canvasInitData.author;
	document.getElementById("description").value = canvasInitData.description;

	sanitizeLength("author", "authorLengthMeter");
	sanitizeLength("title", "titleLengthMeter");
	sanitizeLength("description", "descriptionLengthMeter");

	var paletteButtonPanel = document.getElementById("palette_buttons");
	var palette = canvasInitData.palette;
	while (paletteButtonPanel.childElementCount > 0) {
		paletteButtonPanel.removeChild(paletteButtonPanel.firstChild);
	}
	for (color in palette) {
		paletteButtonPanel.innerHTML +=
			  '<div onclick="setColor(\'{color}\');" style="background: {color}"></div>\n'
				.replace("{color}", palette[color]).replace("{color}", palette[color]);
	}
	setColor(palette[0]);
}

function sanitizeLength (inputId, meterId) {
	var input = document.getElementById(inputId);

	if (input.value.length > input.maxLength)
		input.value = slice(input.value, 0, input.maxLength);

	document.getElementById(meterId).innerHTML = "(" + input.value.length + "/" + input.maxLength + ")";
}

const MAX_AUTHOR_LENGTH = 52;
const MAX_TITLE_LENGTH = 52;
const MAX_DESCRIPTION_LENGTH = 1024;

function submitData() {
	var content = "bitmap=" + encodeURIComponent(bitmap) + ";";
	content += "author=" + encodeURIComponent(document.getElementById("author").value.slice(0, MAX_AUTHOR_LENGTH)) + ";";
	content += "title=" + encodeURIComponent(document.getElementById("title").value.slice(0, MAX_TITLE_LENGTH)) + ";";
	content += "description=" + encodeURIComponent(document.getElementById("description").value.slice(0, MAX_DESCRIPTION_LENGTH));

	HREFmultipartHandler(src, content);
}
