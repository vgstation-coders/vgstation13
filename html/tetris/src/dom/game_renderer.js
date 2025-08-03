var util = require('util');
var MatrixRenderer = require('./matrix_renderer');

function GameRenderer(container, game) {
  
  MatrixRenderer.call(this, container, game.getBackgroundMatrix());
  
  this._game = game;
  
  this._piece = null;
  
  var self = this;
  
  game.on('hit', function() {
    self.updateBackground();
  });
  
  game.on('collapse', function(collapses) {

    for (var i = 0; i < collapses.length; i++) {
      var y = collapses[i];
      $(self.getRowOfTiles(y)).addClass('tile-collapsing');
    }
    
    self.updateBackground();
  });
  
  game.on('new-piece', function() {
    self.renderMovingPiece();
  });
  
  game.on('move', function() {
    self.updateMovingPiece(); 
  });
  
  game.on('rotate', function() {
    self.rotateMovingPiece(); 
  });
  
  game.on('start', function() {
    self._container.empty();
    self.renderBackground();
    self.renderMovingPiece();
  });
};

util.inherits(GameRenderer, MatrixRenderer);

GameRenderer.prototype.renderBackground = function() {
  this.render();
};

GameRenderer.prototype.updateBackground = function() {
  this._update();
};

GameRenderer.prototype.renderMovingPiece = function() {
  
  if (this._piece) {
    $(this._piece).remove();
  }
  
  var pieceMatrix = this._game.getMovingPieceMatrix();
  var piecePosition = this._game.getMovingPiecePosition();
  
  var tileWidth = this._tileWidth;
  var tileHeight = this._tileHeight;
  
  var el = document.createElement("div");
  el.style.position = "absolute";
  el.style.width = pieceMatrix.getWidth() * tileWidth + "px";
  el.style.height = pieceMatrix.getHeight() * tileHeight + "px";
  el.style.left = piecePosition.x * tileWidth + "px";
  el.style.top = piecePosition.y * tileHeight + "px";
  
  el.className = "piece";
  
  var width = pieceMatrix.getWidth();
  var height = pieceMatrix.getHeight();
  
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      var tile = this.createTile();
      tile.style.left = x * tileWidth + "px";
      tile.style.top = y * tileHeight + "px";
      tile.className = "tile-" + pieceMatrix.get(x, y);
      el.appendChild(tile);
    }
  }
  
  this._container.append(el);
  
  this._piece = el;
};

GameRenderer.prototype.updateMovingPiece = function() {
  
  var pieceMatrix = this._game.getMovingPieceMatrix();
  var piecePosition = this._game.getMovingPiecePosition();
  
  var tileWidth = this._tileWidth;
  var tileHeight = this._tileHeight;
  
  this._piece.style.left = piecePosition.x * tileWidth + "px";
  this._piece.style.top = piecePosition.y * tileHeight + "px";
};

GameRenderer.prototype.rotateMovingPiece = function() {
  return this.renderMovingPiece();
};

module.exports = GameRenderer;