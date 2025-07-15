var $ = window.jQuery;

function Menu(game, foreground, background) {
  
  this._game = game;
  
  this._foreground = $(foreground);
  this._background = $(background);
  
  this._dialogs = [];
}

Menu.prototype.show = function(element) {
  
  var index = this._dialogs.length;
  
  this._dialogs.push(element);
  
  if (index === 0) {
    this._background.css({
      "-webkit-filter": "blur(2px) grayscale(100%)"
    });
    this._game.pause();
  }
  
  this._showElement(element);
  
  var self = this;
  
  return function() {
    self.hide(index);
  };
};

Menu.prototype._showElement = function(element, callback) {
  var foreground = this._foreground;
  foreground.fadeOut(200, function() {
    foreground.empty();
    if (element) {
      foreground.append(element).fadeIn(200, callback);
    }
    else {
      if (callback) {
        callback();
      }
    }
  });
};

Menu.prototype.getVisibleIndex = function() {
  for (var index = this._dialogs.length - 1; index >= 0; index--) {
    if (this._dialogs[index] !== null) {
      return index;
    }
    else {
      this._dialogs.pop();
    }
  }
  return -1;
};

Menu.prototype.hide = function(index) {
  
  if (index === void 0) {
    index = this._dialogs.length - 1;
  }
  
  if (index >= this._dialogs.length) {
    return;
  }
  
  var visibleIndex = this.getVisibleIndex();
  
  this._dialogs[index] = null;
  
  if (index === visibleIndex) {
    
    var nextVisibleIndex = this.getVisibleIndex();
    var nextVisible;
    
    if (nextVisibleIndex === -1) {
      this._dialogs = [];
      nextVisible = null;
    }
    else {
      nextVisible = this._dialogs[nextVisibleIndex];
    }
    
    var self = this;
    
    this._showElement(nextVisible, function() {
      if (self._dialogs.length === 0) {
        self._background.css({
          "-webkit-filter":"none"
        });
        self._game.resume();
      }
    });
  }
};

Menu.prototype.title = function(text) {
  var h1 = document.createElement("h1");
  h1.appendChild(document.createTextNode(text));
  return h1;
};

Menu.prototype.button = function(text, clickHandler) {
  var button = $('<button type="button" class="btn"></button>');
  button.text(text);
  if (clickHandler) {
    button.get(0).onclick = clickHandler;
  }
  return button.get(0);
};

Menu.prototype.tablerow = function(row, cellNodeName) {
  
  cellNodeName = cellNodeName || "td";
  
  var tr = document.createElement("tr");
  
  for (var i = 0; i < row.length; i++) {
    
    var td = document.createElement(cellNodeName);
    
    var element = row[i];
    
    switch(typeof element) {
      case "string":
      case "number":
        element = document.createTextNode(element);
        break;
      case "function":
        element = element();
        break;
    }
    
    td.appendChild(element);
    
    tr.appendChild(td);
  }
  
  return tr;
};

module.exports = Menu;
