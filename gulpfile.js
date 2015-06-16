// gulp
var gulp = require('gulp');

// plugins
var jshint = require('gulp-jshint');
var jscs = require('gulp-jscs');
var argv   = require('yargs').argv;
var gulpIgnore = require('gulp-ignore');

var filesJSToScan =  (argv.js ? argv.js : 'src/**/*.js');
var filesJSToIgnore = [
];

gulp.task('jscs', function () {
    return gulp.src(filesJSToScan)
        .pipe(gulpIgnore.exclude(filesJSToIgnore))
        .pipe(jscs());
});

gulp.task('jshint', function () {
    gulp.src(filesJSToScan)
        .pipe(gulpIgnore.exclude(filesJSToIgnore))
        .pipe(jshint())
        .pipe(jshint.reporter('default'));
});

gulp.task('default',
    ['jshint', 'jscs']
);
