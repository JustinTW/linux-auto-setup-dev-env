Package { ensure => 'present' }
package {[
  'curl',
  'vim',
  'tmux',
  'htop',
  'unzip',
  'mtr',
  'autojump']:}

class { 'sudo':
  purge               => false,
  config_file_replace => false,
}

sudo::conf { 'admins':
  priority => 10,
  content  => '%admins ALL=(ALL) NOPASSWD: ALL',
}

sudo::conf { 'sudo':
  priority => 10,
  content  => '%sudo ALL=(ALL) NOPASSWD: ALL',
}


git::config { 'push.default':
  value => 'current',
}
git::config { 'branch.autosetuprebase':
  value => 'always',
}

ssh_keygen { 'root': }

class { 'ohmyzsh': }
ohmyzsh::install { ['root']: }
ohmyzsh::theme { ['root']: theme => 'dst' } # specific theme
ohmyzsh::plugins {'root': plugins => 'git github git-flow python ssh-agent autojump git-flow git-remote-branch tmux debian cp command-not-found last-working-dir docker kubectl helm npm' }

class { 'nvm':
  user => 'root',
  nvm_dir => '/opt/nvm',
  version => 'v0.34.0',
  profile_path => '/etc/profile.d/nvm.sh',
  install_node => '10',
}

# class { 'docker': } # not support for ubuntu
class {'docker::compose':
  ensure => present
}
