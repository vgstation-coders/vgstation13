/*
 * ### canvas.js ###
 * Scripts meant to handle canvas.html
 */

//--------------------------------
// Buttons, tabs, UI and misc.
//--------------------------------
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

function toggleGrid() {
	grid_enabled = !grid_enabled;
	display_bitmap();
	toggleClass("grid_button", "linkOn");
}

//--------------------------------
// Template control
//--------------------------------
var currentTemplate = {ox:0, oy:0};
/* A test template for 14x14 sized paintings
{
	"w":14,
	"h":14,
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

// Moves template color regions from/to "pending" and "done" lists
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

// Shorthand for templateMover()
function templatePending(id) { templateMover(id, false); }
function templateDone(id) { templateMover(id, true); }

// Builds color region items for the pending/done region list in the templates tab
var colorRegex = /^#[0-9A-Fa-f]{6}$/;
function buildTemplateItem(id, colorHint, textHint) {
	// Create a new color region element
	var item = document.createElement("LI");
	item.id = "tp-" + id;
	item.classList.add("item");

	// Color hint. Invalid colors get a red cross over a white background instead
	var missingColorIcon = "";
	if (!colorHint || !colorRegex.test(colorHint)) {
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

// Paints the specified color region with the current color and opacity
function templatePaint(id) {
	for (i in currentTemplate.bmp) {
		if (currentTemplate.bmp[i] == id) {
			var x = i % currentTemplate.w;
			var y = (i - x)/currentTemplate.w;
			x += currentTemplate.ox;
			y -= currentTemplate.oy;
			if (x >= 0 && x < width && y >= 0 && y < height)
				pixelDraw(x, y, getPaintColor(), getOpacity());
		}
	}
	display_bitmap();
	document.getElementById("bitmap").value = bitmap;
}

// Manipulate template offset along the X axis
function setTemplateOffsetX() {
	var input = document.getElementById("template_offset_X");
	currentTemplate.ox = parseInt(input.value);
	currentTemplate.ox = isNaN(currentTemplate.ox) ? 0 : currentTemplate.ox;
	input.value = currentTemplate.ox;
}

function changeTemplateOffsetX(diff) {
	var input = document.getElementById("template_offset_X");
	currentTemplate.ox += diff ? diff : 0;
	input.value = currentTemplate.ox;
}

// Manipulate template offset along the Y axis
function setTemplateOffsetY() {
	var input = document.getElementById("template_offset_Y");
	currentTemplate.oy = parseInt(input.value);
	currentTemplate.oy = isNaN(currentTemplate.oy) ? 0 : currentTemplate.oy;
	input.value = currentTemplate.oy;
}

function changeTemplateOffsetY(diff) {
	var input = document.getElementById("template_offset_Y");
	currentTemplate.oy += diff ? diff : 0;
	input.value = currentTemplate.oy;
}

//--------------------------------
// Template import
//--------------------------------


// Returns the parsed template if succesful, throws an error message otherwise
function parseTemplate(template) {
	// Check the template contains anything resembling a JSON
	var tmpTemplate = template.slice(template.indexOf('{'), template.lastIndexOf('}')+1);
	if (!tmpTemplate) throw "Input is gibberish and not a template";
	
	// Attempt to parse the template
	try {
		tmpTemplate = JSON.parse(tmpTemplate);
	} catch(e) {
		throw "Template could not be parsed:<span style=\"font-style:italic\">" + e.message.slice(e.message.indexOf(':')+1)+"</span>";
	}
	
	// Check template contains a valid "rgn"
	if (!tmpTemplate.rgn) throw "Template is missing <code>\"rgn\"</code> parameter.";
	if (!Array.isArray(tmpTemplate.rgn) || !tmpTemplate.rgn.length) throw "<code>\"rgn\"</code> parameter is empty or not an array.";
	
	// Check template contains a valid "bmp"
	if (!tmpTemplate.bmp) throw "Template is missing <code>\"bmp\"</code> parameter.";
	if (!Array.isArray(tmpTemplate.bmp) || !tmpTemplate.bmp.length) throw "<code>\"bmp\"</code> parameter is empty or not an array.";
	return tmpTemplate;
}

// Detects any potential issues with the template and returns the appropiate message, returns an empty string if no issues are found
function lintTemplate(template) {
	if (!template.w && (template.bmp.length % width) != 0)
		return "Note: Template bitmap (" + template.bmp.length + "px) does not match canvas width (" + width + "px), deformation is likely. ";
	if (!template.w && template.bmp.length != (height * width))
		return "Note: Template bitmap (" + template.bmp.length + "px) does not match canvas size (" + width + "x" + height + " = "+ width * height + "px)";
	if (template.w && (template.bmp.length % template.w) != 0)
		return "Note: Template bitmap (" + template.bmp.length + "px) does not match template width (" + template.w + "px), deformation is likely";
	if (template.w && template.h && template.bmp.length != (template.w * template.h))
		return "Note: Template bitmap (" + template.bmp.length + "px) does not match template size (" + template.w + "x" + template.h + " = "+ template.w * template.h + "px), height may be incorrect";
	if (template.w && template.w > width || template.h && template.h > height)
		return "Note: Template (" + (template.w ? template.w : "??") + "x" + (template.h ? template.h : "??") + ") will not fit canvas (" + width + "x" + height + ")";
}

// Loads a template
function loadTemplate(template) {
	// Hide error messages
	document.getElementById("template_import_errors").style.display = "none";
	document.getElementById("template_import_warnings").style.display = "none";
	
	// Parse template
	if (!template) return;
	var tmpTemplate;
	try {
		tmpTemplate	= parseTemplate(template);
	} catch (msg) {
		// Display error message
		document.getElementById("template_import_errors").style.display = "block";
		document.getElementById("template_import_errors").innerHTML = msg;
		return;
	}
	currentTemplate = tmpTemplate;
	
	// Warn the user of any potential issues
	var warning = lintTemplate(currentTemplate);
	if (warning) {
		document.getElementById("template_import_warnings").style.display = "block";
		document.getElementById("template_import_warnings").innerHTML = warning;
	}

	// Empty both Pending and Done lists
	var itemLister = document.getElementById("doneRegions");
	while (itemLister.childElementCount > 0) {
		itemLister.removeChild(itemLister.firstChild);
	}
	itemLister = document.getElementById("pendingRegions");
	while (itemLister.childElementCount > 0) {
		itemLister.removeChild(itemLister.firstChild);
	}

	// Fill Pending list with new color regions
	for (i = 0; i < currentTemplate.rgn.length; i++) {
		itemLister.appendChild(buildTemplateItem(i, currentTemplate.rgn[i].clr, currentTemplate.rgn[i].txt));
	}
	
	// Set up template size display
	if (currentTemplate.w || currentTemplate.h) {
		document.getElementById("template_size").style.display = "block";
		document.getElementById("template_width").innerHTML = currentTemplate.w ? currentTemplate.w : "??";
		document.getElementById("template_height").innerHTML = currentTemplate.h ? currentTemplate.h : "??";
	} else {
		document.getElementById("template_size").style.display = "none";
	}
	
	// Set up default template width to canvas width if missing
	currentTemplate.w = currentTemplate.w ? currentTemplate.w : width;
	
	// Set up initial template offset, if missing
	currentTemplate.ox = currentTemplate.ox ? currentTemplate.ox : 0;
	currentTemplate.oy = currentTemplate.oy ? currentTemplate.oy : 0;
	
	changeTemplateOffsetX();
	changeTemplateOffsetY();
	
	// Open up the template tab and save the user that extra click
	panelSelect('templatePanel');
}

//--------------------------------
// Template export
//--------------------------------

// Exports the current bitmap as a template
function exportTemplate() {
	var output = document.getElementById("export-text");
	
	// Build basic template
	var template = {w: width, h: height, rgn: [], bmp: []};
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

//--------------------------------
// INIT
//--------------------------------
var src;
function initCanvas(paintInitData, canvasInitData) {
	initPaint(paintInitData);
	document.getElementById("paintColumn").style.maxWidth = (document.getElementById("canvas").width + 40) +  "px";
	document.getElementById("paint_strength").value = getOpacity()

	canvasInitData = JSON.parse(canvasInitData);

	src = canvasInitData.src;
	document.getElementById("canvas_width").innerHTML = width;
	document.getElementById("canvas_height").innerHTML = height;
	
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
			'<div class="paletteColor" onclick="setColor(\'' + palette[color] + '\');" style="background-image:' +  generateColorPaletteBackgroundStyle(palette[color]) + '; background-image:' +  generateColorPaletteBackgroundStyle(palette[color], true) + '"></div>\n';
	}
	setColor(palette[0]);

	//no errors initializing canvas stuff thus far, hide the error message
	document.getElementById("canvas-error").style.display = "none";
}

//--------------------------------
// COLORS & PALETTE
//--------------------------------
function generateColorPaletteBackgroundStyle (color, ieMode) {
	let colorOpaque = hexToRgba(color);
	colorOpaque.a = 255;
	colorOpaque = rgbaToHex(colorOpaque);
	
	// Stupid IE has to use this
	if (ieMode) {
		let ocolor = hexToRgba(color);
		return "-ms-linear-gradient(-45deg, " + colorOpaque + " 0%, " + colorOpaque + " 25%, rgba(" + ocolor.r + "," + ocolor.g + "," + ocolor.b + "," + ocolor.a/255.0 + ") 26%), url(checkerboard.png)";
	} else {
		// Sane browsers use this line
		return "linear-gradient(135deg, " + colorOpaque + " 0%, 25%, " + color + " 26%), url(checkerboard.png)";
	}
}

function setColor(color){
	setPaintColor(color);
	updateSelectedColorDisplay(color, getOpacity())
}

function updateSelectedColorDisplay (color, alpha) {
	color = hexToRgba(color);
	color.a = ((color.a/255.0) * alpha) * 255
	color = rgbaToHex(color)
	document.getElementById("current_color").style["background-image"] = generateColorPaletteBackgroundStyle(color);
	document.getElementById("current_color").style["background-image"] = generateColorPaletteBackgroundStyle(color, true);
}


function changeStrength(diff) {
	var strengthInput = document.getElementById("paint_strength");
	paint_strength = parseFloat(strengthInput.value, 10);
	paint_strength += diff;
	strengthInput.value = setOpacity(paint_strength);
	updateSelectedColorDisplay(getPaintColor(), strengthInput.value);
}

function setStrength() {
	var strengthInput = document.getElementById("paint_strength");
	strengthInput.value = setOpacity(parseFloat(strengthInput.value, 10));
	updateSelectedColorDisplay(getPaintColor(), strengthInput.value);
}

//--------------------------------
// SUBMIT
//--------------------------------
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
