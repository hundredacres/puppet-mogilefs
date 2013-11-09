# Not meant to be used by it's own - but included by parent mogilefs class
class mogilefs::mogilefsd ($dbtype = 'SQLite', $dbname = 'mogilefs')
  inherits mogilefs {
  file { 'mogilefsd.conf':
    ensure  => $mogilefs::manage_file,
    path    => "$mogilefs::config_dir/mogilefsd.conf",
    mode    => $mogilefs::config_file_mode,
    owner   => $mogilefs::config_file_owner,
    group   => $mogilefs::config_file_group,
    require => Package[$mogilefs::package],
    notify  => Service['mogilefsd'],
    content => template('mogilefs/mogilefsd.conf.erb'),
    replace => $mogilefs::manage_file_replace,
    audit   => $mogilefs::manage_audit,
    noop    => $mogilefs::noops,
  }

  # Service
  file { 'mogilefsd.init':
    ensure  => $mogilefs::manage_file,
    path    => '/etc/init.d/mogilefsd',
    mode    => '0755',
    owner   => $mogilefs::config_file_owner,
    group   => $mogilefs::config_file_group,
    require => Package[$mogilefs::package],
    content => template('mogilefs/mogilefsd.init.Debian.erb'),
    replace => $mogilefs::manage_file_replace,
    audit   => $mogilefs::manage_audit,
    noop    => $mogilefs::noops,
  }

  service { 'mogilefsd':
    ensure  => $mogilefs::manage_service_ensure,
    enable  => $mogilefs::manage_service_enable,
    require => [File['mogilefsd.init'], Exec['mogdbsetup']],
    noop    => $mogilefs::noops,
  }

  # Set up database
  $databasepackage = $mogilefs::mogilefsd::dbtype ? {
    'Mysql'    => 'DBD::Mysql',
    'Postgres' => 'DBD::Postgres',
    'SQLite'   => 'DBD::SQLite',
    default    => fail("Unsupported dbtype: $mogilefs::mogilefsd::dbtype"),
  }

  package { $databasepackage:
    ensure   => $mogilefs::manage_package,
    noop     => $mogilefs::noops,
    provider => 'cpanm',
    require  => Package['cpanminus'],
    before   => Exec['mogdbsetup']
  }

  exec { 'mogdbsetup':
    command     => "mogdbsetup --type=$mogilefs::mogilefsd::dbtype --yes --dbname=$mogilefs::mogilefsd::dbname --verbose",
    path        => ['/usr/bin', '/usr/sbin', '/usr/local/bin', '/bin'],
    subscribe   => Package['MogileFS::Server'],
    unless      => "ls $mogilefs::mogilefsd::dbname",
    audit       => $mogilefs::manage_audit,
    noop        => $mogilefs::noops,
    user        => $mogilefs::username,
  }
}