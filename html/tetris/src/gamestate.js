var util = require('util');
var EventEmitter = require('events').EventEmitter;
var Matrix = require('./matrix');

function GameState(width, height) {
  
  EventEmitter.call(this);
  
  this._background = new Matrix(width, height);
  
  this._width = width;
  this._height = height;
  
  this._pieces = [];
  
  this._gameover = true;
  this._running = false;
  this._pauseCount = 0;
  
  this.clearBackground();
  this.clearMovingPiece();
}

util.inherits(GameState, EventEmitter);

GameState.prototype.clearBackground = function() {
  this._background.clear();
};

GameState.prototype.clearMovingPiece = function() {
  this._movingPieceMatrix = null;
  this._movingPiecePosition = {x: null, y: null};
};

GameState.prototype.start = function() {
  
  this.clearBackground();
  this.clearMovingPiece();
  
  this._nextPiece = null;
  
  this._gameover = false;
  this._running = true;
  this._pauseCount = 0;
  
  this.emit('start');
};

GameState.prototype.isGameover = function() {
  return this._gameover;
}

GameState.prototype.isPaused = function() {
  return !this._running;
};

GameState.prototype.pause = function() {
  
  this._pauseCount += 1;
  
  if (this._running && !this._gameover) {
    this._running = false;
    this.emit('pause');
  }
};

GameState.prototype.resume = function() {
  
  this._pauseCount -= 1;
  
  if (!this._running && !this._gameover && this._pauseCount <= 0) {
    this._running = true;
    this.emit('resume');
  }
};

GameState.prototype.loadPieceMatrix = function(matrix) {
  this._pieces.push(matrix);
};

GameState.prototype.getRandomPieceIndex = function() {
  return Math.round(Math.random() * 99999) % this._pieces.length;
};

GameState.prototype.setNextPiece = function(index) {
  this._nextPiece = this._pieces[index];
  this.emit('set-next-piece', index, this._nextPiece);
};

GameState.prototype.getStartingPosition = function(matrix) {
  return {
    x: Math.floor(this._background.getWidth() / 2 - matrix.getWidth() / 2), 
    y:0
  };
};

GameState.prototype.loadNextMovingPiece = function() {
  
  this._movingPieceMatrix = this._nextPiece;
  this._movingPiecePosition = this.getStartingPosition(this._movingPieceMatrix);
  
  if (this.hasCollision(0,0)) {
    
    this._gameover = true;
    this._running = false;
    
    this._movingPieceMatrix = new Matrix(0,0);
    
    this.emit('gameover');
  }
  else{
    this.emit('new-piece');
  }
};

GameState.prototype.createMatrixFromString = function(spec) {
  
  var string, originX, originY;
  
  if (typeof spec === "string") {
    string = spec;
  }
  else if (typeof spec === "array") {
    string = spec[0];
    originX = spec[1];
    originY = spec[2];
  }
  
  var maxX = 0;
  
  var x = -1;
  var y = 0;
  
  var sets = [];
  
  for(var i = 0; i < string.length; i++) {
    
    var c = string[i];
    
    if (c == '\n') {
      maxX = Math.max(maxX, x);
      x = -1;
      y += 1;
    }
    else{
      
      x += 1;
      
      var value = parseInt(c, 10);
      if (value > 0) {
        sets.push({x:x, y:y, colour:value});
      }
    }
  }
  
  maxX = Math.max(maxX, x); 
  
  var matrix = new Matrix(maxX + 1, y + 1, originX, originY);
  
  for(i = 0; i < sets.length; i++) {
    var fill = sets[i];
    matrix.set(fill.x, fill.y, fill.colour);
  }
  
  return matrix;
};

GameState.prototype.getBackgroundMatrix = function() {
  return this._background;
};

GameState.prototype.getMovingPieceMatrix = function() {
  return this._movingPieceMatrix;
};

GameState.prototype.getMovingPiecePosition = function() {
  return this._movingPiecePosition; 
};

GameState.prototype.hasCollision = function(x, y) {
  return this._background.collision(
    this._movingPiecePosition.x + x, 
    this._movingPiecePosition.y + y, 
    this._movingPieceMatrix
  );
};

GameState.prototype.collapse = function(minY, maxY) {
  
  var collapses = [];
  
  var width = this._width;
  
  for(var y = maxY, originalY = maxY; y >= minY; y--, originalY--) {
    
    if (this._background.isRowFilled(y)) {
      collapses.push(originalY);
      this._background.collapseRow(y);
      y = maxY + 1;
      originalY = y - collapses.length;
    }
  }
  
  if (collapses.length > 0) {
    this.emit('collapse', collapses);
  }
};

GameState.prototype.stopMovingPiece = function() {

  this._background.copy(
    this._movingPiecePosition.x, 
    this._movingPiecePosition.y, 
    this._movingPieceMatrix
  );
  
  this.emit('hit');
  
  this.collapse(0, this._background.getHeight() - 1);
};

GameState.prototype.getCompositeMatrix = function() {
  
  var width = this._background.getWidth();
  var height = this._background.getHeight();
  
  var result = new Matrix(width, height);
  
  result.copy(0, 0, this._background);
  
  result.copy(
    this._movingPiecePosition.x, 
    this._movingPiecePosition.y, 
    this._movingPieceMatrix
  );
  
  return result;
};

GameState.prototype.move = function(x, y) {
  
  if (!this._running) {
    return;
  }
  
  if (!this.hasCollision(x, y)) {
    this._movingPiecePosition.x += x;
    this._movingPiecePosition.y += y;
    this.emit('move', x, y);
  }
  else if (y > 0) {
    this.stopMovingPiece();
  }
};

GameState.prototype._applyRotate = function(rotated, x, y) {
  
  var collision = this._background.collision(x, y, rotated);
  
  if(!collision){
    
    this._movingPiecePosition.x = x;
    this._movingPiecePosition.y = y;
    
    this._movingPieceMatrix = rotated;
    
    this.emit('rotate');
    
    return true;
  }
  
  return false;
};

GameState.prototype.rotate = function() {
  
  if (!this._running) {
    return;
  }
  
  var rotated = this._movingPieceMatrix.rotate();
  
  var x = this._movingPiecePosition.x;
  var y = this._movingPiecePosition.y;
  
  if (this._applyRotate(rotated, x, y)) {
    return; 
  }
  
  var start = x;
  
  var background = this._background;
  var piece = this._movingPieceMatrix;
  
  var rightEnd = start + rotated.getWidth();
  
  for (x = start; x < rightEnd; x++) {
  
    if (background.collision(x, y, piece)) {
      break;
    }
    
    if (this._applyRotate(rotated, x, y)) {
      return;
    }
  }
  
  var leftEnd = start - rotated.getWidth();
  
  for (x = start; x > leftEnd; x--) {
    
    if (background.collision(x, y, piece)) {
      break;
    }
    
    if(this._applyRotate(rotated, x, y)){
      return;
    }
  }
};

module.exports = GameState;
