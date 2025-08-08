
function PlayerGameMode(game) {
  
  this._game = game;
  this._timer = null;
  this._lines = 0;
  this._level = 1;
  
  var self = this;
  
  game.on('hit', function() {
    self._loadMovingPiece(); 
  });
  
  game.on('start', function() {
    self.start(); 
  });
  
  game.on('gameover', function() {
    self._stopTimer(); 
  });
  
  game.on('collapse', function(collapses) {
    self._lines += collapses.length;
    self._level = Math.floor(Math.min(self._lines, 200)/20) + 1;
  });
}

PlayerGameMode.prototype.getLevel = function() {
  return this._level;
};

PlayerGameMode.prototype._setNextPiece = function() {
  this._game.setNextPiece(this._game.getRandomPieceIndex());  
};

PlayerGameMode.prototype._loadMovingPiece = function() {
  this._game.loadNextMovingPiece();
  this._setNextPiece();
};

PlayerGameMode.prototype.update = function() {
  this._game.move(0, 1);  
};

PlayerGameMode.prototype._startTimer = function() {
  
  if (this._timer) {
    return;
  }
  
  var self = this;
  
  var update = function() {
    schedNextUpdate();
    self.update();
  };
  
  var schedNextUpdate = function() {
    self._timer = setTimeout(update, (10 - self._level) * 65 + 50);
  };
  
  schedNextUpdate();
};

PlayerGameMode.prototype._stopTimer = function() {
  
  if (!this._timer) {
    return;
  }
  
  clearTimeout(this._timer);
  
  this._timer = null;
};

PlayerGameMode.prototype.start = function() {
  
  this._level = 1;
  this._lines = 0;
  
  this._setNextPiece();
  this._loadMovingPiece();
  this._startTimer();
};

module.exports = PlayerGameMode;
