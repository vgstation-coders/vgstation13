var util = require('util');
var MatrixRenderer = require('./matrix_renderer');

function GameRenderer(container, game) {
  
  MatrixRenderer.call(this, container, game.getBackgroundMatrix());
  
  this._game = game;
  this._piece = null;
  this._renderUpdate = true;
  
  var self = this;
  
  game.on('hit', function() {
    self.createBackgroundImage();
  });
  
  game.on('collapse', function(collapses) {
    
    game.pause();
    
    var normalRender = self.render;
    
    var flashCount = 0;
    
    var flashInterval = setInterval(function() {
      flashCount += 60;
      self._renderUpdate = true;
    }, 16);
    
    var background = self._background;
    
    self.render = function() {
      
      var ctx = self._ctx;
      
      var width = self._canvas.width;
      var height = self._canvas.height;
      
      ctx.clearRect(0, 0, width, height);
      
      ctx.putImageData(background, 0, 0);
      
      var alpha = 0.3 * 
        (Math.cos(flashCount * 0.017453292519943295 + Math.PI) + 1) / 2
        + 0.4;
      
      ctx.fillStyle = 'rgba(255, 255, 255, ' + alpha + ')';
      
      var tileHeight = self._tileHeight;
      
      for (var i = 0; i < collapses.length; i++) {
        var y = collapses[i];
        ctx.fillRect(0, y * tileHeight, width, tileHeight);   
      }
    };
    
    setTimeout(function() {
      
      clearInterval(flashInterval);
      
      self.render = normalRender;
      
      self.createBackgroundImage();
      
      self._renderUpdate = true;
      
      game.resume();
      
    }, 200);
  });
  
  game.on('new-piece', function() {
    self._renderUpdate = true;
  });
  
  game.on('move', function() {
    self._renderUpdate = true;
  });
  
  game.on('rotate', function() {
    self._renderUpdate = true;
  });
  
  game.on('start', function() {
    self.createBackgroundImage();
    self._renderUpdate = true;
  });
  
  var renderLoop = function() {
    
    if(self._renderUpdate){
      self._renderUpdate = false;
      self.render();
    }
    
    window.requestAnimationFrame(renderLoop);
  };
  
  renderLoop();
};

util.inherits(GameRenderer, MatrixRenderer);

GameRenderer.prototype.renderGrid = function() {
  
  var tileWidth = this._tileWidth;
  var tileHeight = this._tileHeight;
  
  var width = this._canvas.width;
  var height = this._canvas.height;
  
  var cols = width / tileWidth;
  var rows = height / tileHeight;
  
  var ctx = this._ctx;
  
  ctx.strokeStyle = 'rgba(255, 255, 255, 0.07)';
  
  for (var y = 0; y < rows; y++) {
    for (var x = 0; x < cols; x++) {
      
      ctx.beginPath();
      ctx.moveTo(x * tileWidth + tileWidth + 1.5, y * tileHeight + 1.5);
      ctx.lineTo(x * tileWidth + tileWidth + 1.5, y * tileHeight + tileHeight + 1.5);
      ctx.stroke();
      ctx.closePath();
      
      ctx.beginPath();
      ctx.moveTo(x * tileWidth + 1.5, y * tileHeight + tileHeight + 1.5);
      ctx.lineTo(x * tileWidth + tileWidth + 1.5, y * tileHeight + tileHeight + 1.5);
      ctx.stroke();
      ctx.closePath();
    }
  }
};

GameRenderer.prototype.renderMovingPiece = function() {
  
  var pieceMatrix = this._game.getMovingPieceMatrix();
  var piecePosition = this._game.getMovingPiecePosition();
  
  if (pieceMatrix) {
    
    var tileWidth = this._tileWidth;
    var tileHeight = this._tileHeight;
    
    var width = pieceMatrix.getWidth();
    var height = pieceMatrix.getHeight();
    
    var worldX = piecePosition.x;
    var worldY = piecePosition.y;
    
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        this._paintTile(worldX + x, worldY + y, pieceMatrix.get(x, y));
      }
    }
  }
};

GameRenderer.prototype.createBackgroundImage = function() {
  
  var matrix = this._matrix;
  var ctx = this._ctx;
  
  ctx.clearRect(0, 0, this._canvas.width, this._canvas.height);
  
  this.renderGrid();
  
  var width = matrix.getWidth();
  var height = matrix.getHeight();
  
  var tileWidth = this._tileWidth;
  var tileHeight = this._tileHeight;
  
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      this._paintTile(x, y, matrix.get(x, y));
    }
  }
  
  this._background = this._ctx.getImageData(
    0, 0, 
    this._canvas.width, this._canvas.height
  );
};

GameRenderer.prototype.render = function() {
  
  var self = this;
  
  var ctx = this._ctx;
  
  if(this._background) {
    ctx.putImageData(this._background, 0, 0);
  }
  
  this.renderMovingPiece();
};

module.exports = GameRenderer;
