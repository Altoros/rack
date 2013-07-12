#/bin/bash

source "$(dirname $0)/common.sh"

juju-log 'Add chris-lea node.js ppa'
add-apt-repository -y ppa:chris-lea/node.js
apt-get update -qq

juju-log "Install dependencies"
apt-get install -y -qq build-essential libsqlite3-dev libmysql++-dev libpq-dev nodejs

juju-log "Install extra packages"
[[ -z $extra_packages ]] || apt-get -y install -qq $extra_packages

juju-log "install bundler"
gem install bundler --no-rdoc --no-ri

fetch_from_git() {
  apt-get -y install -qq git-core
  umask 022
  git clone $repo_url -b $repo_branch $root
}
fetch_from_bzr() {
  apt-get -y install -qq bzr
  umask 022
  bzr branch $repo_url $root
}
fetch_from_svn() {
  apt-get install -y -qq subversion
  umask 022
  if [[ ($repo_branch == 'trunk') || (-z $repo_branch) ]]; then
    svn co "$repo_url/trunk" $root
  else
    svn co "$repo_url/branches/$repo_branch" $root
  fi
}
install_app() {
  juju-log "Install rails app into $root"
  case $repo_type in
    git )
      fetch_from_git ;;
    bzr )
      fetch_from_bzr ;;
    svn )
      fetch_from_svn ;;
  esac

  mkdir -p $root/config
  mkdir -p $root/public
  mkdir -p $root/tmp
  #touch $root/log/production.log
  #chmod 0666 $root/log/production.log

  bundle_install
}

[ -d $root ] || install_app
