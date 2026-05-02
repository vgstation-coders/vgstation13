var util = require('util');
var EventEmitter = require('events').EventEmitter;

function Score(game, gameMode) {
  
  EventEmitter.call(this);
  
  this._game = game;
  this._gameMode = gameMode;
  
  this._lines = 0;
  this._score = 0;
  this._dropScore = 0;
  
  this.initNormalScoring();
}

util.inherits(Score, EventEmitter);

Score.prototype.initNormalScoring = function() {
  
  var self = this;
  
  this._game.on('start', function() {
    self._lines = 0;
    self._score = 0;
    self.emit('update', 0);
  });
  
  var points = [40, 100, 300, 1200];
  
  this._game.on('collapse', function(collapses) {
    var lines = collapses.length;
    self._lines += lines;
    self.add(points[lines - 1] * self._gameMode.getLevel());
  });
  
  this._game.on('rotate', function() {
    self._dropScore = 0; 
  });
  
  this._game.on('move', function(x, y) {
    if (y > 0 && x == 0) {
      self._dropScore += y;
    }
    else if (x !== 0) {
      self._dropScore = 0;
    }
  });
  
  this._game.on('hit', function() {
    self.add(self._dropScore);
    self._dropScore = 0;
  });
  
  this._game.on('gameover', function() {
    self.emit('final', self.getStats());
  });
};

Score.prototype.getStats = function() {
  return {
    score: this._score,
    lines: this._lines,
    level: this._gameMode.getLevel()
  }  
};

Score.prototype.add = function(addition) {
  if (addition !== 0) {
    this._score += addition;
    this.emit('update', addition);
    submitScore(this._score);
  }
};

Score.prototype.getLines = function() {
  return this._lines;
};

Score.prototype.getScore = function() {
  return this._score;
};

Score.prototype.getLevel = function() {
  return this._gameMode.getLevel();  
};

module.exports = Score;
