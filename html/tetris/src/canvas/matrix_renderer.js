var $ = window.jQuery;

function RGB(r, g, b) {
  this.r = r;
  this.g = g;
  this.b = b;
}

RGB.prototype.toString = function() {
  return 'rgb(' + [
    Math.round(this.r), 
    Math.round(this.g), 
    Math.round(this.b)
  ].join(',') + ')';
};

RGB.prototype.blend = function(colour, alpha) {
  var ia = 1 - alpha;
  return new RGB(
    this.r * alpha + colour.r * ia,
    this.g * alpha + colour.g * ia,
    this.b * alpha + colour.b * ia
  );
};

RGB.prototype.darken = function(v) {
  return this.blend(new RGB(0, 0, 0), 1 - v);
};

RGB.prototype.lighten = function(v) {
  return this.blend(new RGB(255, 255, 255), 1 - v);
};

function fillRectangle(ctx, startX, startY, width, height, borderRadius) {
  
  borderRadius = Math.min(Math.min(borderRadius || 0, width / 2), height / 2);  
  
  ctx.beginPath();
  
  var x = startX;
  var y = startY;
  
  if (borderRadius === 0) {
    
    ctx.moveTo(x, y);
    
    ctx.lineTo(x + width, y);
    ctx.lineTo(x + width, y + height);
    ctx.lineTo(x, y + height);
  }
  else {
    
    var br = borderRadius;
    var hll = width - br * 2;
    var vll = height - br * 2;
    
    ctx.moveTo(x + br, y);
    
    ctx.lineTo(x + br + hll, y);
    ctx.arcTo(x + width, y, x + width, y + br, br);
    
    ctx.lineTo(x + width, y + br + vll);
    ctx.arcTo(x + width, y + height, x + br + hll, y + height, br);
    
    ctx.lineTo(x + br, y + height);
    ctx.arcTo(x, y + height, x, y + br + vll, br);
    
    ctx.lineTo(x, y + br);
    ctx.arcTo(x, y, x + br, y, br);
  }
  
  ctx.fill();
  
  ctx.closePath();
}

function paintTile(ctx, options) {
  
  var x = options.x;
  var y = options.y;
  
  var width = options.width;
  var height = options.height;
  
  var colour = options.colour;
  
  ctx.fillStyle = options.borderColour ? 
    options.borderColour.toString() : '#000';
  
  var borderRadius = options.borderRadius || 3;
  var borderWidth = options.borderWidth || 0;
  
  fillRectangle(
    ctx, 
    x, 
    y, 
    width + borderWidth, 
    height + borderWidth,
    borderRadius
  );
  
  var grad = ctx.createLinearGradient(
    x + borderWidth, 
    y + borderWidth, 
    x + width, 
    y + height
  );
  
  var lighten = colour.lighten(0.35);
  var darken = colour.darken(0.35);
  
  grad.addColorStop(0, lighten.toString());
  grad.addColorStop(0.48, lighten.toString());
  grad.addColorStop(0.52, darken.toString());
  grad.addColorStop(1, darken.toString());
  
  ctx.fillStyle = grad;
  
  fillRectangle(
    ctx, 
    x + borderWidth,
    y + borderWidth, 
    width - borderWidth, 
    height - borderWidth, 
    borderRadius
  );
  
  ctx.fillStyle = colour.toString();
  
  var xheight = Math.round(0.1 * width);
  var yheight = Math.round(0.1 * height);
  
  fillRectangle(
    ctx, 
    x + xheight + borderWidth, 
    y + yheight + borderWidth, 
    width - xheight * 2 - borderWidth, 
    height - yheight * 2 - borderWidth, 
    borderRadius
  );
}

function MatrixRenderer(container, matrix) {
  
  this._container = $(container);
  
  this._canvas = document.createElement('canvas');
  this._canvas.width = this._container.width();
  this._canvas.height = this._container.height();
  
  this._container.empty().append(this._canvas);
  
  this._ctx = this._canvas.getContext('2d');
  
  this._matrix = matrix;
   
  this._calculatePixelDimensions();
  
  this._createTileImages();
  
  this._tiles = [];
};

MatrixRenderer.prototype.setMatrix = function(matrix) {
  this._matrix = matrix;
};

MatrixRenderer.prototype._calculatePixelDimensions = function() {
  
  var matrix = this._matrix;
  
  this._tileWidth = Math.round(this._canvas.width / matrix.getWidth());
  this._tileHeight = Math.round(this._canvas.height / matrix.getHeight());
};

MatrixRenderer.prototype._createTileImages = function() {
  
  var ctx = this._ctx;
  
  var colours = [
    new RGB(0x36, 0xb3, 0xb3),
    new RGB(0x36, 0x36, 0xb3),
    new RGB(0xb3, 0x86, 0x36),
    new RGB(0xb3, 0xb3, 0x36),
    new RGB(0x36, 0xb3, 0x36),
    new RGB(0xb3, 0x36, 0xb3),
    new RGB(0xb3, 0x36, 0x36)
  ];
  
  var tiles = [null];
  
  var tileWidth = this._tileWidth;
  var tileHeight = this._tileHeight;
  var borderWidth = 2;
  
  for (var i = 0; i < colours.length; i++) {
    
    paintTile(ctx, {
      x: 0, y: 0, 
      width: tileWidth, height: tileHeight,
      borderWidth: borderWidth,
      borderRadius: 3,
      colour: colours[i]
    });
    
    tiles.push(ctx.getImageData(
      0, 0, 
      tileWidth + borderWidth, tileHeight + borderWidth
    ));
    
    ctx.clearRect(0, 0, tileWidth + borderWidth, tileHeight + borderWidth);
  }
  
  this._tileImages = tiles;
};

MatrixRenderer.prototype._paintTile = function(x, y, colour) {
  
  if (colour > 0) {
    this._ctx.putImageData(
      this._tileImages[colour],
      x * this._tileWidth, 
      y * this._tileHeight
    );
  }
};

MatrixRenderer.prototype.render = function() {
  
  var matrix = this._matrix;
  var ctx = this._ctx;
  
  ctx.clearRect(0, 0, this._canvas.width, this._canvas.height);
  
  var width = matrix.getWidth();
  var height = matrix.getHeight();
  
  var tileWidth = this._tileWidth;
  var tileHeight = this._tileHeight;
  
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      this._paintTile(x, y, matrix.get(x, y));
    }
  }
};

module.exports = MatrixRenderer;
