# -*- mode: ruby -*-
# vi: set ft=ruby :


# Packages

package { "vim": }
package { "nodejs": }


# update bashrc based on template
file { "bashrc":
  path => "/home/${user}/.bashrc",
  content => template("bashrc.erb")
}


# Ruby & rbenv

rbenv::install { "${user}":
  group => "${user}",
  home  => "/home/${user}",
}

rbenv::compile { "${ruby_version}":
  user    => $user,
  home    => "/home/${user}",
  global  => true
}


# Required Gems

class gems {
  package { 'bundler':
    ensure   => 'installed',
    provider => 'gem'
  }
}

include gems
