/**
 * #### Painting tool ####
 *
 * A fairly simple painting tool, don't expect too many bells and whistles.
 *
 * === Requirements ===
 *
 * Your html document must contain the following:
 *
 *  - 'Width': An <input> with id="width". This will determine how many pixels wide our drawing will be
 *
 *  - 'Height': An <input> with id="width". This will determine how many pixels tall our drawing will be
 *
 *  - 'Bitmap': An <input> with id="bitmap". It's value must be a comma separated list of colors, with no
 *               spaces (eg: "#0000ff,#ff0000,#ff0000,#0000ff"). It must contain 'Width'x'Height' colors,
 *               as each color will be mapped to a pixel in our drawing. It's value will be updates as the
 *               user draws.
 *
 *	- 'Canvas': A <canvas> with id="canvas", and the events onmousedown="is_mouse_down = true;" and
 *               onmousemove="draw_on_bitmap();".
 *              This will be where the user will draw and see the result. It's width and height attributes
 *               should be a multiple of 'Width' and 'Height', or you'll get some visual artifacts.
 *
 *  - 'Tool Strength': An <input> with id="paint_strength". It's value must be between 1 and 0 inclusive, and
 *                      represents the color's "alpha value", aka how much of an effect it has in changing a
 *                      pixel's color.
 *
 *  - 'Min. Strength': An <input> with id="minPaintStrength". It's value must be between 1 and 0 inclusive,
 *                      and serves to limit 'Tool Strength'
 *
 *  - 'Max. Strength': An <input> with id="maxPaintStrength". It's value must be between 1 and 0 inclusive,
 *                      and serves to limit 'Tool Strength'
 *
 * Inputs may be of type="hidden" as needed: eg. 'Bitmap' should usually be a hidden input, unless you'd
 *  like for the user to import and export it's value freely.
 *
 * === Functions ===
 *
 * --- init() ---
 *
 * Must be called as soon as all data is loaded and in place. Will load the html data (all those <input>s in the
 *  requirements section) into the script.
 *
 *
 * --- setColor(color) ---
 *
 * There must be an element with id="current_color" for this function to be called.
 * Calling this function will change the color in use to the specified color, which must be a string in hex
 *  format (eg: "#ffaa22"), and will update the 'current_color' element's background to said color.
 * If you'd rather forego this, you may use 'paint_color = "#ffaa22";' instead, at your own peril.
 *
 *
 * --- setStrength() ---
 *
 * Updates the tool strenght to that of the 'Tool Strenght' input, sanitizing it's value in the process. Turns
 *  NaNs to 0, rounds the value to the second decimal and clamps it to the min. and max. values.
 * Useful if you wish to let the user modify the strength directly.
 *
 *
 * --- changeStrength(diff) ---
 *
 * Modifies the tool strenght by 'diff', sanitizes the result and updates the value of the 'Tool Strenght' input.
 * 'diff' should be no lower than 0.01, any values lower than that will end up ignored once the result's sanitized.
 * Useful if placing buttons to increase/decrease the tool strenght, rather than modifying it directly.
 *
 *
 * --- hexToRgb(hex), rgbToHex(r, g, b) ---
 *
 * Helper functions to deal with rgb/hex conversions.
 * 'hexToRgb(hex)' takes eg. an "#aa88ff" string and returns an {r:170, g:136, b:255} object.
 * 'rgbToHex(r, g, b)' takes three integers ranging from 0 to 255 and returns the corresponding string, eg. "#aa88ff"
 */

//Canvas and context for the player to draw in
var canvas;
var ctx;

//Define our "bitmap"
var width;
var height;
var bitmap;

//Keep track of how scaled up the canvas is vs the actual bitmap
var scaleX = 20;
var scaleY = 20;

//Keep track of what the mouse is up to
var previousX = -1;
var previousY = -1;
var is_mouse_down = false;

//Color and tool data
var paint_color = "#000000";
var paint_strength = 0.5;
var minPaintStrength = 0;
var maxPaintStrength = 1;

/**
 * Initialize the script
 */
function initPaint(initData) {
	initData = JSON.parse(initData);

	canvas = document.getElementById("canvas");
	ctx = canvas.getContext("2d");

	width = initData.width;
	height = initData.height;
	canvas.width = width * scaleX;
	canvas.height = height * scaleY;
	bitmap = initData.bitmap;

	minPaintStrength = initData.minPaintStrength;
	maxPaintStrength = initData.maxPaintStrength;
	setStrength();

	//No data? start with a blank canvas
	if (bitmap.length != width * height) {
		while (bitmap.length < width * height) {
			bitmap.push("#ffffff");
		}
	}

	// Listener to catch any mouseup events to stop drawing
	window.addEventListener('mouseup', function(event){
		end_path();
	})

	//Everything initialized, display the bitmap to the user for the first time.
	display_bitmap();
}

/**
 * Sets the current color to the specified color, updating the "selected color" display
 */
function setColor(color) {
	paint_color = color;
	document.getElementById("current_color").style["background"] = color;
}

/**
 * Sets the tool strength to the value on the id="paint_strength" input, and sanitizes the result
 */
function setStrength() {
	var strengthInput = document.getElementById("paint_strength");
	paint_strength = parseFloat(strengthInput.value, 10);
	sanitizeStrength();
	strengthInput.value = paint_strength;
}

/**
 * Changes the tool's strength by the specified amount, and sanitizes the result
 */
function changeStrength(diff) {
	var strengthInput = document.getElementById("paint_strength");
	paint_strength = parseFloat(strengthInput.value, 10);
	paint_strength += diff;
	sanitizeStrength();
	strengthInput.value = paint_strength;
}

/**
 * Convert hex to RGB objects.
 * Helper function, converts an hex string (eg: #AA88FF) to an {r:170, g:136, b:255} object.
 */
function hexToRgb(hex) {
	//Get rid of '#'
	hex = parseInt(hex.slice(1), 16);

	//Bitwise magic
	return {
		r: (hex >> 16) & 255,
		g: (hex >> 8) & 255,
		b: hex & 255
	};
}

/**
 * Convert RGB to hex.
 * Helper function, converts {r, g, b} objects (eg: {r:170, g:136, b:255}) to an hex string (eg: #AA88FF).
 */
function rgbToHex(rgb) {
	for (k in rgb) {
		//Convert to hex value
		rgb[k] = Math.round(rgb[k]).toString(16);

		//Pad with 0 if needed
		rgb[k] = rgb[k].length > 1 ? rgb[k] : "0" + rgb[k];
	}

	//Put it together
	return "#" + rgb.r + rgb.g + rgb.b
}

/*
 *--------------------------------------------------------------------------------------------------
 *
 */

/**
 * Sanitizes tool strength. Turns NaNs to 0, rounds the value to the second decimal and clamps it to
 *  the min and max values
 */
function sanitizeStrength() {
	paint_strength = isNaN(paint_strength) ? 0 : paint_strength;
	paint_strength = Math.round(paint_strength*100)/100;
	paint_strength =  Math.min(Math.max(paint_strength, minPaintStrength), maxPaintStrength);
}


var blendFunction = colorRybBlend;

/**
 * Draw a pixel into the bitmap.
 * Given 'rgb' as an hex string (eg: #AA88FF) and 'a' (alpha) as a 0-1 value, will mix said color
 *  with whatever's on the specified pixel on the bitmap.
 */
function pixelDraw(x, y, rgb, alpha) {
	//Figure out the pixel index off the x and y
	let pixel = y * width + x;

	//Convert to numeric values
	rgb = hexToRgb(rgb);
	let orgb = hexToRgb(bitmap[pixel]);

	//Mix both color values
	rgb = blendFunction(rgb, orgb, alpha);

	//Save result into bitmap
	bitmap[pixel] = rgbToHex(rgb);
}


/* -------------------------------------------------------------------
Color blends
Mostly based on:
	https://www.w3.org/TR/compositing-1/#valdef-blend-mode-hard-light
*/
function colorAlphaBlend(c1, c2, alpha) {
	var result = {};
	for (k in c1)
		result[k] = Math.round(Math.sqrt(alpha * Math.pow(c1[k], 2) + (1-alpha) * Math.pow(c2[k], 2)));
	return result;
}

function colorMultiplyBlend(c1, c2, alpha) {
	var result = {};
	for (k in c1)
		result[k] = Math.round(c1[k]*c2[k]/255);
	return colorAlphaBlend(result, c2, alpha);
}

function colorScreenBlend(c1, c2, alpha) {
	var result = {};
	for (k in c1)
		result[k] = Math.round(c1[k] + c2[k] - c1[k]*c2[k]/255);
	return colorAlphaBlend(result, c2, alpha);
}

function colorHardLightBlend(c1, c2, alpha) {
	var result = {r: c1.r * 2, g: c1.g * 2, b: c1.b * 2};
	for (var c in c1) {
		if (c1[c] <= 127.5) {
			result[c] = Math.round(result[c]*c2[c]/255);
		} else {
			result[c] -= 255;
			result[c] = Math.round((result[c] + c2[c] - result[c]*c2[c]/255));
		}
	}
	return colorAlphaBlend(result, c2, alpha);
}

function colorOverlayBlend(c1, c2, alpha) {
	return colorHardLightBlend(c2, c1, alpha);
}

function colorRybBlend(c1, c2, alpha) {
	var c1Ryb = rgbToRyb(c1);
	var c2Ryb = rgbToRyb(c2);
	var resultRyb = {r:0, y:0, b:0};
	resultRyb.r = Math.round(alpha * c1Ryb.r + (1-alpha) * c2Ryb.r);
	resultRyb.y = Math.round(alpha * c1Ryb.y + (1-alpha) * c2Ryb.y);
	resultRyb.b = Math.round(alpha * c1Ryb.b + (1-alpha) * c2Ryb.b);
	return rybToRgb(resultRyb);
}

/*---------------------------------------------
end color blends
*/

/**
 * RGB to RYB (red, yellow, blue) converter
 * Takes a RGB color object such as {r:40, g:15, b:90} and returns an RYB object such
 *  as {r:215, y:165, b:240}.
 * Formula based on the following papers:
 * - http://nishitalab.org/user/UEI/publication/Sugita_IWAIT2015.pdf
 * - http://nishitalab.org/user/UEI/publication/Sugita_SIG2015.pdf
 */
function rgbToRyb(rgb) {
	// Soon-to-be result
	var ryb = {r:0, y:0, b:0};

	// Make a copy of the input to work on
	var tmpRgb = {r: rgb.r, g: rgb.g, b: rgb.b};

	// Remove white component
	var i = Math.min(rgb.r, rgb.g, rgb.b);
	tmpRgb.r -= i;
	tmpRgb.g -= i;
	tmpRgb.b -= i;

	// Convert colors
	ryb.r = tmpRgb.r - Math.min(tmpRgb.r, tmpRgb.g);
	ryb.y = (tmpRgb.g + Math.min(tmpRgb.r, tmpRgb.g))/2;
	ryb.b = (tmpRgb.b + tmpRgb.g - Math.min(tmpRgb.r, tmpRgb.g))/2;

	// Normalize
	var n = Math.max(ryb.r, ryb.y, ryb.b)/Math.max(tmpRgb.r, tmpRgb.g, tmpRgb.b);
	if (n > 0.000001) { // Should be zero, but floating point error could be an issue
		ryb.r /= n;
		ryb.y /= n;
		ryb.b /= n;
	}

	// Add black component, and round floating point errors
	i = Math.min(255 - rgb.r, 255 - rgb.g, 255 - rgb.b);
	ryb.r = Math.round(ryb.r + i);
	ryb.y = Math.round(ryb.y + i);
	ryb.b = Math.round(ryb.b + i);

	return ryb;
}

/**
 * RYB (red, yellow, blue) to RGB converter
 * Takes a RYB color object such as {r:215, y:165, b:240} and returns an RGB object such
 *  as {r:40, g:15, b:90}.
 * Formula based on the following papers:
 * - http://nishitalab.org/user/UEI/publication/Sugita_IWAIT2015.pdf
 * - http://nishitalab.org/user/UEI/publication/Sugita_SIG2015.pdf
 */
function rybToRgb(ryb) {
	// Soon-to-be result
	var rgb = {r:0, g:0, b:0};

	// Make a copy of the input to work on
	var tmpRyb = {r: ryb.r, y: ryb.y, b: ryb.b};

	// Remove black component
	var i = Math.min(ryb.r, ryb.y, ryb.b);
	tmpRyb.r -= i;
	tmpRyb.y -= i;
	tmpRyb.b -= i;

	// Convert colors
	rgb.r = tmpRyb.r + tmpRyb.y - Math.min(tmpRyb.y, tmpRyb.b);
	rgb.g = tmpRyb.y + Math.min(tmpRyb.y, tmpRyb.b);
	rgb.b = 2*(tmpRyb.b - Math.min(tmpRyb.y, tmpRyb.b));
	/* According to the RYB papers linked, the formula for green should be
	 *	"g = y + 2*min(y, b)"
	 * But for whatever godforsaken reason that returns wrong values for colors where y < b
	 * (eg: cyan). Got rid of the '2*' on a hunch and sure it WORKS without breaking anything
	 * else, but WHY?????
	 */

	// Normalize
	var n = Math.max(rgb.r, rgb.g, rgb.b)/Math.max(tmpRyb.r, tmpRyb.y, tmpRyb.b);
	if (n > 0.000001) { // Should be zero, but floating point error could be an issue
		rgb.r /= n;
		rgb.g /= n;
		rgb.b /= n;
	}

	// Add white component, and round floating point errors
	i = Math.min(255 - ryb.r, 255 - ryb.y, 255 - ryb.b);
	rgb.r = Math.round(rgb.r + i);
	rgb.g = Math.round(rgb.g + i);
	rgb.b = Math.round(rgb.b + i);

	return rgb;
}


/**
 * Listen to mouse actions and draw.
 * Gets called whenever the mouse either moves within the canvas or is released from being
 *  pressed down (eg. single clicks)
 */
function draw_on_bitmap() {
	//If the mouse is pressed down and inside the canvas...
	if (is_mouse_down
		&& event.offsetX > 0 && event.offsetX < canvas.width
		&& event.offsetY > 0 && event.offsetY < canvas.height)
	{

		//Translate mouse position to bitmap position
		var x = Math.floor(width * event.offsetX/canvas.width);
		var y = Math.floor(height * event.offsetY/canvas.height);

		//If the mouse moves too fast, "skipping" pixels, fill the gap by drawing a line
		// between it and the last recorded position
		if (previousX > -1 && (Math.abs(previousX - x) > 1 || Math.abs(previousY - y) > 1 )) {
			lineDraw(previousX, previousY, x, y, paint_color, paint_strength);
		}

		//Draw a pixel wherever we're at
		pixelDraw(x, y, paint_color, paint_strength);

		//Record our current position as last recorded
		previousX = x;
		previousY = y;

		//Update the UI
		display_bitmap();
	}
}

/**
 * Act on mouse no longer being pressed down.
 * Draws a single pixel if we just did a single click. Clears the last recorded position so
 * future clicks aren't treated as incredibly fast movements.
 */
function end_path () {
	if (previousX == -1)
		draw_on_bitmap();
	is_mouse_down = false;
	previousX = -1;
	previousY = -1;
}

/**
 * Draws a line between two points, neither point included.
 * Sensitive both to mouse movement and the mouse button being released.
 */
function lineDraw(x1, y1, x2, y2, rgb, a) {
	//Difference in "steps" between both axes
	var sx = x2 - x1;
	var sy = y2 - y1;

	//Figure out how much to advance between steps, and how many steps to take (sx or sy, whichever is greater)
	var dx;
	var dy;
	var steps = 0;
	if (Math.abs(sx) > Math.abs(sy)) {
		steps = Math.abs(sx);
		dx = sx/Math.abs(sx);//Either 1 or -1
		dy = sy/Math.abs(sx);
	} else if (sy != 0){
		steps = Math.abs(sy);
		dx = sx/Math.abs(sy);
		dy = sy/Math.abs(sy);//Either 1 or -1
	}

	//Move however many steps we decided on, starting from x1 and y1 and increasing both by dx and dy each step
	//Skip the first and last step though, draw_on_bitmap() already handles those
	for (var i = 1; i < steps; i++) {
		//Result might look like x:0.1 y:1, x:0.2 y:2.. Decimals are not possible, so round it
		pixelDraw(x1 + Math.round(i*dx), y1 + Math.round(i*dy), rgb, a);
	}
}

/**
 * Display the bitmap to the player
 * Draws the bitmap's contents on screen, scaled up for visibility
 */
function display_bitmap() {
	//Go through our pixel data and draw scaled up squares with the corresponding color
	for (var x = 0; x < width; x++) {
		for(var y = 0; y < height; y++) {
			//Convert to pixel index
			var pixel = (y * width + x);

			//Grab the pixel's color
			ctx.fillStyle = bitmap[pixel];

			//Draw a square, scaled up as needed
			ctx.fillRect(x*scaleX, y*scaleY, scaleX, scaleY);
		}
	}
}
