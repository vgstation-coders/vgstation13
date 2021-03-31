//Canvas and context for the player to draw in
var canvas;
var ctx;

//Define our "bitmap"
var width;
var height;
var bitmap;

//Keep track of how scaled up the canvas is vs the actual bitmap
var scaleX;
var scaleY;

//Keep track of what the mouse is up to
var previousX = -1;
var previousY = -1;
var is_mouse_down = false;

//Color data
var paint_color = "#000000";
var paint_strength = 1;

//Initialize
function init() {
	canvas = document.getElementById('canvas');
	ctx = document.getElementById('canvas').getContext('2d');

	width = parseInt(document.getElementById("width").value, 10);
	height = parseInt(document.getElementById("height").value, 10);
	bitmap = document.getElementById("bitmap").value.split(",");

	paint_strength = parseFloat(document.getElementById("paint_strength").value, 10);

	//No data? start with a blank canvas
	/*
	if (bitmap.length != width * height) {
		for (var i = 0; i < width * height; i++) {
			bitmap[i] = "#ffffff";
		}
	}
	*/

	// Listener to catch any mouseup events to stop drawing
	window.addEventListener('mouseup', function(event){
		end_path();
	})

	scaleX = canvas.width/width;
	scaleY = canvas.height/height;

	//Everything initialized, display the bitmap to the user for the first time.
	display_bitmap();
}

function setColor(color) {
	paint_color = color;
	document.getElementById("current_color").style["background"] = color;
}

/**
* Draw a pixel into the bitmap.
* Given 'rgb' as an hex string (eg: #AA88FF) and 'a' (alpha) as a 0-1 value, will mix said color
*  with whatever's on the specified pixel on the bitmap.
*/
function pixelDraw(x, y, rgb, alpha) {
	//Figure out the pixel index off the x and y
	let pixel = (y * width + x);

	//Convert to numeric values
	rgb = hexToRgb(rgb);
	let orgb = hexToRgb(bitmap[pixel]);

	//Mix both color values
	rgb.r = (1-alpha)*orgb.r + alpha*rgb.r;
	rgb.g = (1-alpha)*orgb.g + alpha*rgb.g;
	rgb.b = (1-alpha)*orgb.b + alpha*rgb.b;

	//Save result into bitmap
	bitmap[pixel] = rgbToHex(rgb.r, rgb.g, rgb.b);
}

/**
* Convert hex to RGB objects.
* Helper function, converts an hex string (eg: #AA88FF) to an {r:170, g:136, b:255} object.
* I hate it.
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
* Helper function, converts R G B values to an hex string (eg: #AA88FF).
* I hate it so much.
*/
function rgbToHex(r, g, b) {
	//Convert to hex values
	r = Math.round(r).toString(16);
	g = Math.round(g).toString(16);
	b = Math.round(b).toString(16);

	//Pad with 0 if needed
	r = r.length > 1 ? r : "0" + r;
	g = g.length > 1 ? g : "0" + g;
	b = b.length > 1 ? b : "0" + b;

	//Add '#'
	return "#" + r + g + b
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
			lineDraw(previousX, previousY, x, y, paint_color, paint_strength); //TODO get color off drawing tool
		}

		//Draw a pixel wherever we're at
		pixelDraw(x, y, paint_color, paint_strength); //TODO get color off drawing tool

		//Record our current position as last recorded
		previousX = x;
		previousY = y;

		//Update the UI
		display_bitmap();

		//Store the bitmap on the form for when we send it to BYOND
		document.getElementById("bitmap").value = bitmap;
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
