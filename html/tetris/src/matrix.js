
function Matrix(width, height, originX, originY) {
  
  this._width = width;
  this._height = height;
  
  if (originX !== void 0) {
    this._originX = originX;
  }
  else {
    this._originX = width / 2;
  }
  
  if (originY !== void 0) {
    this._originY = originY;
  }
  else {
    this._originY = height / 2;
  }
  
  this._matrix = [];
  
  this.clear();
}

Matrix.prototype.clear = function() {
  var endIndex = this._width * this._height;
  for(var index = 0; index < endIndex; index++) {
    this._matrix[index] = 0;
  }
};

Matrix.prototype.getWidth = function() {
  return this._width;  
};

Matrix.prototype.getHeight = function() {
  return this._height;  
};

Matrix.prototype.getOriginX = function() {
  return this._originX;    
};

Matrix.prototype.getOriginY = function() {
  return this._originY;    
};

Matrix.prototype.index = function(x, y) {
  return y * this._width + x;
};

Matrix.prototype.get = function(x, y) {
  return this._matrix[this.index(x, y)];
};

Matrix.prototype.getAtIndex = function(index) {
  return this._matrix[index];
};

Matrix.prototype.isOpaque = function(colour) {
  return colour > 0;
};

Matrix.prototype.set = function(x, y, colour) {
  this._matrix[this.index(x, y)] = colour;
};

Matrix.prototype.isRowFilled = function(y) {
  
  var start = this.index(0, y);
  
  var end = start + this._width
    for(var index = start; index < end; index++) {
    if (!this.isOpaque(this._matrix[index])) {
      return false;
    }
  }
  
  return true;
};

Matrix.prototype.collapseRow = function(y) {
  
  var width = this._width;
  
  var destination = this.index(this._width - 1, y);
  var source = destination - width;
  
  if (y > 0) {
    for(; source >= 0; source--, destination--) {
      this._matrix[destination] = this._matrix[source];
    }
  }
  
  for(var index = 0; index < width; index++) {
    this._matrix[index] = 0;
  }
};

Matrix.prototype.rotate = function() {
  
  var width = this._width;
  var height = this._height;
  
  var originX = this._originX;
  var originY = this._originY;
  
  var result = new Matrix(width, height, originX, originY);
  
  this.forEachOpaque(function(x, y, value) {
    
    var newX = (-(y - originY)) + originX - 1;
    var newY = (x - originX) + originY;
    
    result.set(Math.floor(newX), Math.floor(newY), value);
    
    return true;
  });
  
  return result;
};

Matrix.prototype.forEachOpaque = function(callback) {
  
  var width = this._width;
  var matrix = this._matrix;
  var numElements = width * this._height;
  
  var x = -1;
  var y = -1;
  
  for(var index = 0; index < numElements; index++) {
    
    if (index % width == 0) {
      x = 0;
      y += 1;
    }else {
      x += 1;
    }
    
    var value = matrix[index];
    
    if (this.isOpaque(value)) {
      if (!callback(x, y, value)) {
        return;
      }
    }
  }
};

Matrix.prototype.collision = function(x, y, visitor) {
  
  var detected = false;
  
  var self = this;
  
  var width = this._width;
  var height = this._height;
    
  visitor.forEachOpaque(function(innerX, innerY) {
    
    var absX = x + innerX;
    var absY = y + innerY;
    
    detected = absY >= height || absX < 0 || absX >= width || self.isOpaque(self.get(absX, absY));
    
    return !detected;
  });
  
  return detected;
};

Matrix.prototype.copy = function(x, y, source) {  
  var self = this;
  source.forEachOpaque(function(innerX, innerY, value) {
    self.set(x + innerX, y + innerY, value);
    return true;
  });
};

module.exports = Matrix;
