var util = require('util');
var EventEmitter = require('events').EventEmitter;

function Scoreboard(scoring, storage) {
  
  this._scoring = scoring;
  this._storage = storage;
  
  this._bestStats = [];
  
  this._load();
  
  var self = this;
  
  scoring.on('final', function(stats) {
    
    if (ga) {
      ga('send', 'event', 'game', 'gameover', 'score', stats.score);
      ga('send', 'event', 'game', 'gameover', 'lines', stats.lines);
      ga('send', 'event', 'game', 'gameover', 'level', stats.level);
    }
    
    self._insertStats(stats);
    self._save();
  });
}

util.inherits(Scoreboard, EventEmitter);

Scoreboard.prototype.getCurrentStats = function() {
  return this._scoring.getStats();
};

Scoreboard.prototype.getBestStats = function() {
  return this._bestStats;
};

Scoreboard.prototype._load = function() {

  var bestStats = JSON.parse(this._storage.getItem('bestStats'));
  
  if (bestStats && bestStats.length) {
    this._bestStats = bestStats;
  }
};

Scoreboard.prototype._save = function() {
  this._storage.setItem('bestStats', JSON.stringify(this._bestStats));
  this.emit('save');
};

Scoreboard.prototype._insertStats = function(stats) {
  
  this._bestStats.push(stats);
  
  this._bestStats.sort(function(a, b) {
    if (a.score > b.score) {
      return -1;
    }
    else if (a.score < b.score) {
      return 1;
    }
    return 0;
  });
  
  var size = 3;
  
  if (this._bestStats.length > size) {
    this._bestStats = this._bestStats.slice(0, size);
  }
};

module.exports = Scoreboard;
