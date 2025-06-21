require('./polyfills');

var $ = window.jQuery;

var Matrix    = require('./matrix');
var GameState = require('./gamestate');

var PlayerGameMode  = require('./player_gamemode');
var PlayerController = require('./player_controller');

var Score     = require('./score');
var Scoreboard = require('./scoreboard');

var Menu = require('./menu');

var CanvasMatrixRenderer  = require('./canvas/matrix_renderer');
var CanvasGameRenderer    = require('./canvas/game_renderer');

var DomMatrixRenderer = require('./dom/matrix_renderer');
var DomGameRenderer = require('./dom/game_renderer');

var sound = require('./sound');

function createGame() {
  
  var game = new GameState(10, 20);
  
  var pieces = [
    '\n1111\n\n',
    '2\n222\n', 
    '003\n333\n',
    '0440\n0440\n',
    '055\n55\n',
    '06\n666\n',
    '77\n077\n'
  ];
  
  for(var i = 0; i < pieces.length; i++) {
    game.loadPieceMatrix(game.createMatrixFromString(pieces[i]));
  }
  
  return game;
}

function createPlayerController(game) {
  
  var player = new PlayerController(game);
  
  player.bindKeys({
    37: {action: 'left',            delay: 100},
    38: {action: 'rotate',          delay: 200},
    39: {action: 'right',           delay: 100},
    40: {action: 'down',            delay: 40},
    32: {action: 'drop',            delay: -1}
  });
  
  return player;
}

function initStartMenu(menu, game) {
  
  var el = document.createElement('div');
  
  $('#game-start').detach().appendTo(el);
  
  var hide;
  
  var playButton = menu.button('Play', function() {
    game.start();
  });
  
  el.appendChild(playButton);
  
  game.once('start', function() {
    hide(); 
  });
  
  hide = menu.show(el);
}

function initPauseMenu(menu, game) {
  
  var el = document.createElement('div');
  el.appendChild(menu.title('Paused'));
  
  var hide = null;
  
  var resumeButton = menu.button('Resume', function() {
    hide();
    hide = null;
    // Let the menu resume the game
  });
  
  el.appendChild(resumeButton);
  
  var show = function() {
    
    if (game.isGameover() || hide) {
       return;
    }
    
    hide = menu.show(el);
  };
  
  $(window).keydown(function(event) {
    if (event.keyCode === 80) {
      show();
    }
  });
  
  $(window).blur(function() {
    show();
  });
}

function initGameoverMenu(menu, game, scoreboard) {
  
  var el = document.createElement('div');
  
  el.appendChild(menu.title('Game Over'));
  
  var table = document.createElement('table');
  table.className = 'scoreboard';
  
  var thead = document.createElement('thead');
  thead.appendChild(menu.tablerow([
    'high scores'    
  ], 'th'));
  table.appendChild(thead);
  
  var tbody = document.createElement('tbody');
  table.appendChild(tbody);
  
  scoreboard.on('save', function() {
    
    var currentStats = scoreboard.getCurrentStats();
    
    $(tbody).empty();
    var stats = scoreboard.getBestStats();
    if (!stats) {
      return;
    }
    for(var i = 0; i < stats.length; i++) {
      
      var tr = menu.tablerow([
        stats[i].score
      ]);
      
      if (stats[i].score === currentStats.score) {
        tr.className = 'selected';
      }
      
      tbody.appendChild(tr);
    }
  });
  
  el.appendChild(table);
  
  var restartButton = menu.button('New game', function() {
    game.start();
  });
  
  el.appendChild(restartButton);
  
  var hide = $.noop;
  
  game.on('gameover', function() {
    hide = menu.show(el);
  });
  
  game.on('start', function() {
     hide();
  });
}

function initGameUI(game, gameMode, gameScoreboard, gameElement, menuElement) {
  
  var GameRenderer = getGameRenderer();
  
  var view = new GameRenderer(gameElement, game);
  
  var menu = new Menu(game, menuElement, gameElement);
  
  initStartMenu(menu, game);
  initPauseMenu(menu, game);
  initGameoverMenu(menu, game, gameScoreboard);
  
  var controller = createPlayerController(game);
}

function initStatusUI(score, scoreElement, linesElement, levelElement) {
  
  var update = function() {
    $(scoreElement).text(score.getScore());
    $(linesElement).text(score.getLines());
    $(levelElement).text(score.getLevel());
  };
  
  score.on('update', update);
  
  update();
}

function isCanvasSupported() {
  var el = document.createElement('canvas');
  return !!(el.getContext && el.getContext('2d'));
}

function getMatrixRenderer() {
  return isCanvasSupported() ? CanvasMatrixRenderer : DomMatrixRenderer;
}

function getGameRenderer() {
  return isCanvasSupported() ? CanvasGameRenderer : DomGameRenderer;  
}

function init(elementSelectors) {
  
  var game = createGame();
  var gameMode = new PlayerGameMode(game);
  var gameScore = new Score(game, gameMode);
  var gameScoreboard = new Scoreboard(gameScore, localStorage);
  
  initGameUI(game, gameMode, gameScoreboard, $('#game'), $('#menu'));

  initStatusUI(gameScore, $('#score'), $('#lines'), $('#level'));
  
  initNextPiecePreviewUI(game, $('#preview'));
  
  sound.initSounds(game, {
    collapses:[
      $("#collapse1-sound").get(0),
      $("#collapse2-sound").get(0),
      $("#collapse3-sound").get(0),
      $("#collapse4-sound").get(0),
    ] 
  });
}

function initNextPiecePreviewUI(game, element) {
  
  var MatrixRenderer = getMatrixRenderer();
  var previewRenderer = new MatrixRenderer(element, new Matrix(4, 4));
  
  game.on('set-next-piece', function(index, matrix) {
    
    previewRenderer.setMatrix(createPaddedMatrix(matrix, 4, 4));
    previewRenderer.render();
  });
}

function createPaddedMatrix(matrix, widthExtent, heightExtent) {
  
  var width = Math.max(matrix.getWidth(), widthExtent);
  var height = Math.max(matrix.getHeight(), heightExtent);
  
  var padded = new Matrix(width, height);
  
  padded.copy(0, 0, matrix);
  
  return padded;
}

$(document).ready(function() {
  
  $('#game-loading').remove();
  $('.status-container,.game-container').show();
  
  init({
    game:  '#game',
    menu:  '#menu',
    score: '#score',
    lines: '#lines',
    level: '#level'
  });
  
});
