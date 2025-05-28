var $ = window.jQuery;


function MatrixRenderer(container, matrix) {
  
  this._container = $(container);
  this._matrix = matrix;
  
  this._tiles = [];
  
  this._tileWidth = 0;
  this._tilHeight = 0;
  
  this._container.css({
    position: 'relative',
    overflow: 'hidden'
  });
  
  this._calculatePixelDimensions();
};

MatrixRenderer.prototype.createTile = function() {
  var tile = document.createElement('div');
  tile.style.position = 'absolute';
  tile.style.width = this._tileWidth + 'px';
  tile.style.height = this._tileHeight + 'px';
  return tile;
};

MatrixRenderer.prototype._calculatePixelDimensions = function() {
  var matrix = this._matrix;
  this._tileWidth = Math.round(this._container.width() / matrix.getWidth());
  this._tileHeight = Math.round(this._container.height() / matrix.getHeight());
};

MatrixRenderer.prototype.render = function() {
  
  this._container.empty();
  
  var matrix = this._matrix;
  
  this._tiles = [];
  
  var width = matrix.getWidth();
  var height = matrix.getHeight();
  
  var tileWidth = this._tileWidth;
  var tileHeight = this._tileHeight;
  
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      
      var tile = this.createTile();
      
      tile.style.left = x * tileWidth + 'px';
      tile.style.top = y * tileHeight + 'px';
      
      tile.className = 'tile-' + matrix.get(x, y);
      
      this._container.append(tile);
      
      this._tiles.push(tile);
    }
  }
};

MatrixRenderer.prototype.getRowOfTiles = function(y) {
  var width = this._matrix.getWidth();
  var start = y * width;
  var end = start + width;
  var tiles = [];
  for (var i = start; i < end; i++) {
    tiles.push(this._tiles[i]);
  }
  return tiles;
};

MatrixRenderer.prototype._update = function() {
  
  var matrix = this._matrix;
  
  var tiles = this._tiles;
  var numTiles = tiles.length;
  
  for (var index = 0; index < numTiles; index++) {
    var value = matrix.getAtIndex(index);
    tiles[index].className = 'tile-' + value;
  }
};

MatrixRenderer.prototype.setMatrix = function(matrix) {
  this._matrix = matrix;
};

module.exports = MatrixRenderer;
