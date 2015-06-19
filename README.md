# I'm watching You
[![Code Climate](https://codeclimate.com/github/basti1dr/imwatchingyou/badges/gpa.svg)](https://codeclimate.com/github/basti1dr/imwatchingyou) [![Dependency Status](https://gemnasium.com/basti1dr/imwatchingyou.svg)](https://gemnasium.com/basti1dr/imwatchingyou)
[![Stories in Ready](https://badge.waffle.io/basti1dr/imwatchingyou.svg?label=ready&title=Ready)](http://waffle.io/basti1dr/imwatchingyou)

## Install
### Gems
```bash
bundle install
```

### Node modules
```bash
npm install
```

## Configuration
Copy ```config.sample.yml``` as ```config.yml``` and fill the sections you want to use in dashboard

## Usage
```bash
bundle exec dashing start
```

## Code styling checkers
### Check syntax JS
GULP is using for check syntax of all files (some files are ignored by filesJSToIgnore variable)

```bash
node_modules/gulp/bin/gulp.js
```
One file :

```bash
node_modules/gulp/bin/gulp.js --js path_to_file
```

### Check syntax ruby
```bash
bundle exec rubocop
```
