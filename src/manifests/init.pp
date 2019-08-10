Package { ensure => 'present' }
package {[
  'curl',
  'vim',
  'tmux',
  'htop',
  'unzip',
  'mtr',
  'dnsutils',
  'build-essential',
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

include git
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
ohmyzsh::plugins {'root': plugins => 'git github git-flow python ssh-agent autojump git-flow git-remote-branch tmux debian cp command-not-found last-working-dir docker kubectl helm' }
