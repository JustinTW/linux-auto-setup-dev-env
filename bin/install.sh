#!/usr/bin/env bash

DIR=$HOME/.auto_setup_env

install_base_pkgs (){
  command -v wget >/dev/null && return 0

  # debian
  command -v apt-get >/dev/null && \
    apt-get update && \
    apt-get install -q -y --force-yes --fix-missing \
      wget && \
    # apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    return 0

  # centos
  command -v yum >/dev/null && \
    yum -y install \
      wget && \
    # yum clean all && \
    return 0

  # alpine
  command -v apk >/dev/null && \
    echo http://dl-4.alpinelinux.org/alpine/edge/testing/ >> /etc/apk/repositories && \
    apk --update add --no-cache --virtual \
    wget \
    bash && \
    # rm -rf /var/cache/apk/* && \
    return 0
}

install_pp (){
  command -v puppet >/dev/null && return 0

  # debian
  command -v apt-get >/dev/null &&
    source /etc/os-release && \
    [[ $ID = "debian" ]] && \
    echo "OS Version: Debian" && \
    mkdir -p .tmp && \
    wget -O .tmp/puppet.deb https://apt.puppetlabs.com/puppet-release-$VERSION_CODENAME.deb && \
    dpkg -i .tmp/*.deb && \
    apt-get update && \
    apt-get install -q -y --force-yes --fix-missing \
      puppet && \
    ln -sf /opt/puppetlabs/bin/puppet /usr/local/bin/puppet && \
    rm -rf .tmp && \
    # apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    return 0

  # ubuntu
  command -v apt-get >/dev/null &&
    source /etc/os-release && \
    [[ $ID = "ubuntu" ]] && \
    echo "OS Version: Ubuntu" && \
    mkdir -p .tmp && \
    wget -O .tmp/puppet.deb https://apt.puppetlabs.com/puppet-release-$VERSION_CODENAME.deb && \
    dpkg -i .tmp/*.deb && \
    apt-get update && \
    apt-get install -q -y --force-yes --fix-missing \
      puppet-agent && \
    ln -sf /opt/puppetlabs/bin/puppet /usr/local/bin/puppet && \
    rm -rf .tmp && \
    # apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    return 0

  # centos
  command -v yum >/dev/null && \
    rpm -Uvh https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm && \
    yum -y install \
      puppet && \
    ln -sf /opt/puppetlabs/bin/puppet /usr/local/bin/puppet && \
    # yum clean all && \
    return 0

  # alpine
  command -v apk >/dev/null && \
    echo http://dl-7e.alpinelinux.org/alpine/edge/testing/ >> /etc/apk/repositories && \
    apk --update add --no-cache --virtual shadow ruby less bash && \
    gem install puppet --no-rdoc --no-ri && \
    # rm -rf /var/cache/apk/* && \
    return 0
}

dl_pp_scripts (){
  if [ ! $ENV = "dev" ]; then
    mkdir -p $DIR/src/auto_setup_env/manifests
    mkdir -p $DIR/src/auto_setup_env/modules
    wget -O https://raw.github.com/JustinTW/linux-auto-setup-dev-env/developer/src/manifests/init.pp $DIR/src/manifests/init.pp
    wget -O https://raw.github.com/JustinTW/linux-auto-setup-dev-env/developer/src/requirements $DIR/src/requirements
  fi
}

pp_install_modules (){
  while read -r module; do
    if [ "$module" = "^\s*#" ]; then continue; fi
    puppet module install $module
  done < "$DIR/src/requirements"
}

pp_apply (){
  puppet apply $DIR/src/manifests/init.pp
}

main (){
  install_base_pkgs
  install_pp
  dl_pp_scripts
  pp_install_modules
  pp_apply
}

main
