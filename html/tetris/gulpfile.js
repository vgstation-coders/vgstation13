var gulp = require('gulp');
var uglify = require('gulp-uglify');
var browserify = require('gulp-browserify');
var jade = require('gulp-jade');
var minifyCSS = require('gulp-minify-css');
var gzip = require('gulp-gzip');
var crypto = require('crypto');
var fs = require('fs');

function generateCacheTag(filename) {
  var contents = fs.readFileSync(filename);
  var hash = crypto.createHash('md5');
  hash.update(contents);
  return hash.digest('hex').substring(0, 7);
}

function getApplicationMeta() {
  
  if(fs.existsSync('./app.json')){
    return JSON.parse(fs.readFileSync('./app.json'));
  }
  
  return {
    name: 'Untitled game'
  };
}

gulp.task('compile_js_bundle', function() {
  return gulp.src('src/main.js')
    .pipe(browserify())
    .pipe(uglify())
    .pipe(gulp.dest('public/js'));
});

gulp.task('compile_html', ['compile_js_bundle'], function() {
  return gulp.src('index.jade')
    .pipe(jade({
      locals: {
        cache_tag: generateCacheTag,
        app: getApplicationMeta()
      }
    }))
    .pipe(gulp.dest('public'));
});

gulp.task('compress_js_bundle', ['compile_js_bundle'], function() {
  return gulp.src('public/js/main.js')
    .pipe(gzip())
    .pipe(gulp.dest('public/js/'));
});

gulp.task('default', [
  'compile_html',
  'compress_js_bundle'
]);
