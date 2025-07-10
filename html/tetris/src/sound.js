function initSounds(game, audio) {
  
  if(!window.Audio) {
    return;
  }
  
  var schedPlay = function(audio, timeout) {
    setTimeout(function() {
      audio.currentTime = 0;
      audio.play();
    }, timeout);
  };
  
  game.on('collapse', function(collapses) {
    
    for(var i = 0; i < collapses.length; i++) {
      var sound = audio.collapses[i];
      if(sound){
        schedPlay(sound, i * 150);
      }
    }
  });
};

module.exports = {
  initSounds: initSounds  
};
