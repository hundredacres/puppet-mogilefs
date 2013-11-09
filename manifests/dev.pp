# Class to mimic Quickstart Guide at
# https://code.google.com/p/mogilefs/wiki/QuickStartGuide
#
# Mysql replaced with SQLite compared to Quickstart Guide
class mogilefs::dev (
  $options                = {
    'listen' => '127.0.1.5:7001'
  }
  ,
  $config_file_mode       = '0644',
  $config_file_owner      = 'mogilefs',
  $config_file_group      = 'mogilefs',
  $dbtype                 = 'SQLite',
  $dbname                 = 'mogilefs',
  $datapath               = '/var/mogdata',
  $mogstored_init_content = template('mogilefs/dev/mogstored.init.Debian.erb'))
{
  class { 'mogilefs':
    dbtype            => $mogilefs::dev::dbtype,
    dbname            => $mogilefs::dev::dbname,
    config_file_mode  => $config_file_mode,
    config_file_owner => $config_file_owner,
    config_file_group => $config_file_group,
    mogstored_service => false,
    trackers          => '127.0.1.5:7001',
    datapath          => $datapath,
    options           => $options,
  }

  # Mogstored for dev
  file { 'mogstored-cli-bug-workaround':
    ensure => 'absent',
    path   => '/etc/mogilefs/mogstored.conf',
  }

  # Service
  file { 'mogstored.init.dev':
    ensure  => $mogilefs::manage_file,
    path    => '/etc/init.d/mogstored.dev',
    mode    => '0755',
    owner   => $mogilefs::config_file_owner,
    group   => $mogilefs::config_file_group,
    require => Package[$mogilefs::package],
    content => $mogilefs::dev::mogstored_init_content,
    replace => $mogilefs::manage_file_replace,
    audit   => $mogilefs::manage_audit,
    noop    => $mogilefs::noops,
  }

  service { 'mogstored.dev':
    ensure  => 'running',
    enable  => true,
    require => [File['mogstored.init.dev']],
    noop    => $mogilefs::noops,
  }

  # Nearone
  exec { 'nearone_host':
    path    => ['/bin', '/usr/local/bin', '/usr/bin'],
    command => "mogadm --trackers=${mogilefs::real_trackers} \
      host add nearone --ip=127.0.0.20 --status=alive",
    unless  => "mogadm --trackers=${mogilefs::real_trackers} \
      host list | grep \snearone",
    require => Service[mogilefsd]
  }

  file { [$datapath, "${datapath}/127.0.0.20", "${datapath}/127.0.0.20/dev1"]:
    ensure => 'directory',
    mode   => '0644',
    owner  => 'mogilefs'
  }

  exec { 'nearone_dev1':
    path    => ['/bin', '/usr/local/bin', '/usr/bin'],
    command => "mogadm --trackers=${mogilefs::real_trackers} \
      device add nearone 1 --status=alive",
    unless  => "mogadm --trackers=${mogilefs::real_trackers} \
      device list | grep \sdev1",
    require => Service[mogilefsd]
  }

  file { ["${datapath}/127.0.0.20/dev2"]:
    ensure => 'directory',
    mode   => '0644',
    owner  => 'mogilefs'
  }

  exec { 'nearone_dev2':
    path    => ['/bin', '/usr/local/bin', '/usr/bin'],
    command => "mogadm --trackers=${mogilefs::real_trackers} \
      device add nearone 2 --status=alive",
    unless  => "mogadm --trackers=${mogilefs::real_trackers} \
      device list | grep \sdev2",
    require => Service[mogilefsd]
  }

  # Neartwo
  exec { 'neartwo_host':
    path    => ['/bin', '/usr/local/bin', '/usr/bin'],
    command => "mogadm --trackers=${mogilefs::real_trackers} \
      host add neartwo --ip=127.0.0.25 --status=alive",
    unless  => "mogadm --trackers=${mogilefs::real_trackers} \
      host list | grep \sneartwo",
    require => Service[mogilefsd]
  }

  file { ["${datapath}/127.0.0.25", "${datapath}/127.0.0.25/dev3"]:
    ensure => 'directory',
    mode   => '0644',
    owner  => 'mogilefs'
  }

  exec { 'neartwo_dev3':
    path    => ['/bin', '/usr/local/bin', '/usr/bin'],
    command => "mogadm --trackers=${mogilefs::real_trackers} \
      device add neartwo 3 --status=alive",
    unless  => "mogadm --trackers=${mogilefs::real_trackers} \
      device list | grep \sdev3",
    require => Service[mogilefsd]
  }

  file { ["${datapath}/127.0.0.25/dev4"]:
    ensure => 'directory',
    mode   => '0644',
    owner  => 'mogilefs'
  }

  exec { 'neartwo_dev4':
    path    => ['/bin', '/usr/local/bin', '/usr/bin'],
    command => "mogadm --trackers=${mogilefs::real_trackers} \
      device add neartwo 4 --status=alive",
    unless  => "mogadm --trackers=${mogilefs::real_trackers} \
      device list | grep \sdev4",
    require => Service[mogilefsd]
  }

  # Farone
  exec { 'farone_host':
    path    => ['/bin', '/usr/local/bin', '/usr/bin'],
    command => "mogadm --trackers=${mogilefs::real_trackers} \
      host add farone --ip=127.0.15.5 --status=alive",
    unless  => "mogadm --trackers=${mogilefs::real_trackers} \
      host list | grep \sfarone",
    require => Service[mogilefsd]
  }

  file { ["${datapath}/127.0.15.5", "${datapath}/127.0.15.5/dev5"]:
    ensure => 'directory',
    mode   => '0644',
    owner  => 'mogilefs'
  }

  exec { 'farone_dev5':
    path    => ['/bin', '/usr/local/bin', '/usr/bin'],
    command => "mogadm --trackers=${mogilefs::real_trackers} \
      device add farone 5 --status=alive",
    unless  => "mogadm --trackers=${mogilefs::real_trackers} \
      device list | grep \sdev5",
    require => Service[mogilefsd]
  }

  file { ["${datapath}/127.0.15.5/dev6"]:
    ensure => 'directory',
    mode   => '0644',
    owner  => 'mogilefs'
  }

  exec { 'farone_dev6':
    path    => ['/bin', '/usr/local/bin', '/usr/bin'],
    command => "mogadm --trackers=${mogilefs::real_trackers} \
      device add farone 6 --status=alive",
    unless  => "mogadm --trackers=${mogilefs::real_trackers} \
      device list | grep \sdev6",
    require => Service[mogilefsd]
  }

  # Fartwo
  exec { 'fartwo_host':
    path    => ['/bin', '/usr/local/bin', '/usr/bin'],
    command => "mogadm --trackers=${mogilefs::real_trackers} \
      host add fartwo --ip=127.0.15.10 --status=alive",
    unless  => "mogadm --trackers=${mogilefs::real_trackers} \
      host list | grep \sfartwo",
    require => Service[mogilefsd]
  }

  file { ["${datapath}/127.0.15.10", "${datapath}/127.0.15.10/dev7"]:
    ensure => 'directory',
    mode   => '0644',
    owner  => 'mogilefs'
  }

  exec { 'fartwo_dev7':
    path    => ['/bin', '/usr/local/bin', '/usr/bin'],
    command => "mogadm --trackers=${mogilefs::real_trackers} \
      device add fartwo 7 --status=alive",
    unless  => "mogadm --trackers=${mogilefs::real_trackers} \
      device list | grep \sdev7",
    require => Service[mogilefsd]
  }

  file { ["${datapath}/127.0.15.10/dev8"]:
    ensure => 'directory',
    mode   => '0644',
    owner  => 'mogilefs'
  }

  exec { 'fartwo_dev8':
    path    => ['/bin', '/usr/local/bin', '/usr/bin'],
    command => "mogadm --trackers=${mogilefs::real_trackers} \
      device add fartwo 8 --status=alive",
    unless  => "mogadm --trackers=${mogilefs::real_trackers} \
      device list | grep \sdev8",
    require => Service[mogilefsd]
  }

  # Add domain
  exec { 'add_domain':
    path    => ['/bin', '/usr/local/bin', '/usr/bin'],
    command => "mogadm --trackers=${mogilefs::real_trackers} domain add toast",
    unless  => "mogadm --trackers=${mogilefs::real_trackers} \
      domain list | grep toast",
    require => Service[mogilefsd]
  }
}