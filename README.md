# I'm watching You
[![Build Status](https://travis-ci.org/basti1dr/imwatchingyou.svg?branch=master)](https://travis-ci.org/basti1dr/imwatchingyou)
[![Scrutinizer Code Quality](https://scrutinizer-ci.com/g/basti1dr/imwatchingyou/badges/quality-score.png?b=master)](https://scrutinizer-ci.com/g/basti1dr/imwatchingyou/?branch=master)
[![Dependency Status](https://gemnasium.com/basti1dr/imwatchingyou.svg)](https://gemnasium.com/basti1dr/imwatchingyou)
[![Code Climate](https://codeclimate.com/github/basti1dr/imwatchingyou/badges/gpa.svg)](https://codeclimate.com/github/basti1dr/imwatchingyou)


## Install
### Vagrant
You can build a virtual machine which will contain all required dependencies to ease development on your machine. You'll
need:
- [virtualbox](https://www.virtualbox.org/wiki/Downloads)
- [vagrant](http://www.vagrantup.com/downloads.html)

Then, you will just have to type `vagrant up` to install and initialize the machine the subsequent times.
You can also access the machine by typing `vagrant ssh` if you need an access to the generated virtual machine.

NB : The `Vagrantfile` is based on the official [jessie debian box](https://atlas.hashicorp.com/debian/boxes/jessie64).
It will load the configuration which can be found in `vagrantfiles/config.yaml`. Note that the application can be accessible over
`192.168.12.34:3030` by default.

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

### Countdown
In `config.yml`
```yaml
countdown:
  myCountDown:  #Id of countdown
    enable: true
    date: 'Jul 27, 2015 00:00:00'
```

In `dashboard.erb`
```ruby
<li data-row="1" data-col="5" data-sizex="1" data-sizey="1">
  <div data-id="idcountdown"  data-view="Countdown" data-title="Text to display" data-end=""></div>
</li>
```

In `infra.rb`
```ruby
#Init count down
config = ConfigApp.new
#We assume countdown hash in config is present
if config.params['countdown'].include? 'myCountDown'
  if config.params['countdown']['myCountDown']['enable']
    send_event(
      'idcountdown',
      title: 'myCountDown finish in',
      end: config.params['countdown']['myCountDown']['date']
    )
  else
    send_event(
      'idcountdown',
      title: 'myCountDown disable',
      end: ''
    )
  end
else
  send_event(
    'idcountdown',
    title: 'myCountDown have no parameters',
    end: ''
  )
end
```

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

## Credits
  * Engine : [Dashing](http://dashing.io/)
  * Countdown : https://gist.github.com/ioangogo/7b9208d0ef41c90ec322/