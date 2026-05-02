
var input = require('./input');

function PlayerController(game) {
  
  this._game = game;
  this._uninstallBindings = null;
  
  this._dropping = false;
}

PlayerController.prototype.move = function(x, y) {
  if (!this._dropping) {
    this._game.move(x, y); 
  }
};

PlayerController.prototype.rotate = function() {
  if (!this._dropping) {
    this._game.rotate();
  }
};

PlayerController.prototype.drop = function() {
  
  if (this._dropping || this._game.isPaused() || this._game.isGameover()) {
    return;
  }
  
  this._dropping = true;
  
  var self = this;
    
  this._droppingInterval = setInterval(function() {
    self._game.move(0, 1);
  }, 10);
  
  this._game.once('hit', function() {
    clearInterval(self._droppingInterval);
    self._dropping = false;
  });
};

PlayerController.prototype.togglePause = function() {
  if (!this._game.isPaused()) {
    this._game.pause();
  }
  else {
    this._game.resume();
  }
};

PlayerController.prototype.bindKeys = function(bindings) {
  
  var resolvedBindings = {};
  
  var actions = {
    'left': this.move.bind(this, -1, 0),
    'right': this.move.bind(this, 1, 0),
    'down': this.move.bind(this, 0, 1),
    'rotate': this.rotate.bind(this),
    'drop': this.drop.bind(this),
    'togglePause': this.togglePause.bind(this)
  };
  
  for(var code in bindings) {
    resolvedBindings[code] = {
      action: actions[bindings[code].action],
      delay: bindings[code].delay     
    };
  }
  
  if (this._uninstallBindings) {
    this._uninstallBindings();
  }
  
  this._uninstallBindings = input.bindKeys(resolvedBindings);
};

module.exports = PlayerController;
