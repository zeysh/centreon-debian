#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get install -y lsb-release debian-archive-keyring
apt-get update
DISTRO=`lsb_release -i -s | tr '[:upper:]' '[:lower:]'`
RELEASE=`lsb_release -c -s`

# Add MariaDB repo
MIRROR_DOMAIN='ftp.igh.cnrs.fr'
MARIADB_VER='10.0'
MYSQL_PASSWORD="password"

apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
echo "deb http://${MIRROR_DOMAIN}/pub/mariadb/repo/${MARIADB_VER}/${DISTRO} ${RELEASE} main" > /etc/apt/sources.list.d/mariadb.list

# Pin repository in order to avoid conflicts with MySQL from distribution
# repository. See https://mariadb.com/kb/en/installing-mariadb-deb-files
# section "Version Mismatch Between MariaDB and Ubuntu/Debian Repositories"
echo "
Package: *
Pin: origin ${MIRROR_DOMAIN}
Pin-Priority: 1000
" | tee /etc/apt/preferences.d/mariadb

debconf-set-selections <<< "mariadb-server-${MARIADB_VER} mysql-server/root_password password ${MYSQL_PASSWORD}"
debconf-set-selections <<< "mariadb-server-${MARIADB_VER} mysql-server/root_password_again password ${MYSQL_PASSWORD}"
apt-get install --force-yes -y mariadb-server

# Add Sugarbug repo for Centreon
echo "deb http://mirror.sugarbug.web4me.fr/centreon/ ${RELEASE} main" > /etc/apt/sources.list.d/sugarbug.list
curl http://mirror.sugarbug.web4me.fr/centreon/sugarbug.gpg | apt-key add -
apt-get update

apt-get install -y centreon-engine centreon-connector-perl centreon-connector-ssh \
        centreon-broker centreon-poller-centreon-engine centreon-connector-perl \
        centreon-connector-ssh
