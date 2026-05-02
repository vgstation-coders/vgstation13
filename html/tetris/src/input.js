var $ = window.jQuery;

function onKeyDown(callback) {
  
  var keydowns = {};
  
  var repeat = function(event) {
    var delay = callback(event);
    scheduleRepeat(delay, event);
  };
  
  var scheduleRepeat = function(delay, event) {
    
    var keydown = keydowns[event.which];
    
    if(delay >= 0){
      
      var timeout = setTimeout(function() {
        repeat(keydown.event);
      }, delay);
      
      keydown.timeout = timeout;
    }
    else{
      keydown.timeout = null;
    }
  };
  
  var onKeydown = function(event) {
    
    var keydown = keydowns[event.which];
    
    if (keydown) {
      
      if(keydown.timeout === null){
        repeat(event);
      }
      
      if (keydown.isDefaultPrevented) {
        event.preventDefault();
      }
    }
    else{
      
      keydowns[event.which] = {
        timeout: null,
        isDefaultPrevented: false,
        event: {
          which: event.which,
          preventDefault: function(){},
          isDefaultPrevented: function(){return false;}
        }
      };
      
      repeat(event);
      
      keydowns[event.which].isDefaultPrevented = event.isDefaultPrevented();
    }
  };
  
  var onKeyup = function(event) {
    var keydown = keydowns[event.which];
    if (keydown) {
      clearTimeout(keydown.timeout);
      delete keydowns[event.which];
    }
  };
  
  $(document).keydown(onKeydown);
  $(document).keyup(onKeyup);
  
  var uninstall = function() {
    $(document).unbind("keydown", onKeydown);
    $(document).unbind("keyup", onKeyup);
    for (var code in keydowns) {
      clearTimeout(keydowns[code].timeout);
    }
  };
  
  return uninstall;
}

function bindKeys(bindings) {
  return onKeyDown(function(event) {
    var binding = bindings[event.which];
    if (binding) {
      event.preventDefault();
      binding.action();
      return binding.delay;
    }
  });
}

module.exports = {
  bindKeys: bindKeys
};
