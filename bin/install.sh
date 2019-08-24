#!/usr/bin/env bash

DIR=$HOME/.auto_setup_env

install_base_pkgs (){
  command -v wget >/dev/null && return 0

  # debian
  command -v apt-get >/dev/null && \
    apt-get update && \
    apt-get install -q -y --force-yes --fix-missing \
      wget \
      dnsutils
      build-essential && \
    return 0

  # centos
  command -v yum >/dev/null && \
    yum -y install \
      wget \
      epel-release \
      bind-utils \
      gcc \
      g++ \
      kernel-devel && \
    yum -y groupinstall \
      "Development Tools" && \
    return 0

  # alpine
  command -v apk >/dev/null && \
    echo http://dl-4.alpinelinux.org/alpine/edge/testing/ >> /etc/apk/repositories && \
    apk --update add --no-cache --virtual \
    wget \
    bash \
    drill && \
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
    return 0

  # centos
  command -v yum >/dev/null && \
    rpm -Uvh https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm && \
    yum -y install \
      puppet && \
    ln -sf /opt/puppetlabs/bin/puppet /usr/local/bin/puppet && \
    return 0

  # alpine
  command -v apk >/dev/null && \
    apk --update add --no-cache --virtual shadow ruby less && \
    gem install puppet --no-rdoc --no-ri && \
    return 0
}

dl_pp_scripts (){
  if [ "$ENV" != "dev" ]; then
    mkdir -p $DIR/src/manifests
    mkdir -p $DIR/src/modules
    wget https://raw.github.com/JustinTW/linux-auto-setup-dev-env/develop/src/manifests/init.pp -O $DIR/src/manifests/init.pp
    wget https://raw.github.com/JustinTW/linux-auto-setup-dev-env/develop/src/requirements -O $DIR/src/requirements
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

clean_cache (){
  # debian
  command -v apt-get >/dev/null &&
    source /etc/os-release && \
    [[ $ID = "debian" ]] && \
    echo "OS Version: Debian" && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    return 0

  # ubuntu
  command -v apt-get >/dev/null &&
    source /etc/os-release && \
    [[ $ID = "ubuntu" ]] && \
    echo "OS Version: Ubuntu" && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    return 0

  # centos
  command -v yum >/dev/null && \
    yum clean all && \
    return 0

  # alpine
  command -v apk >/dev/null && \
    rm -rf /var/cache/apk/* && \
    return 0
}

main (){
  install_base_pkgs
  install_pp
  dl_pp_scripts
  pp_install_modules
  pp_apply
  #clean_cache
}

main
