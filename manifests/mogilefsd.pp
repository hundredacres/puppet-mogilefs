# Not meant to be used by it's own - but included by parent mogilefs class
class mogilefs::mogilefsd ($dbtype = 'SQLite', $dbname = 'mogilefs') inherits
mogilefs {
  $real_mogilefsd_config = $mogilefs::mogilefsd_config ? {
    ''      => template('mogilefs/mogilefsd.conf.erb'),
    default => $mogilefs::mogilefsd_config,

  }

  file { 'mogilefsd.conf':
    ensure  => $mogilefs::manage_file,
    path    => "${mogilefs::config_dir}/mogilefsd.conf",
    mode    => $mogilefs::config_file_mode,
    owner   => $mogilefs::config_file_owner,
    group   => $mogilefs::config_file_group,
    require => Package[$mogilefs::package],
    notify  => Service['mogilefsd'],
    content => $mogilefs::mogilefsd::real_mogilefsd_config,
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
    require => File['mogilefsd.init'],
    noop    => $mogilefs::noops,
  }

  # Set up database
  $databasepackage = $mogilefs::mogilefsd::dbtype ? {
    'Mysql'    => 'DBD::mysql',
    'Postgres' => 'DBD::Pg',
    'SQLite'   => 'DBD::SQLite',
    default    => fail("Dbtype must be one of: 'Mysql', 'Postgres' or \
      'SQLite'. Got: ${mogilefs::mogilefsd::dbtype}"),
  }

  package { $databasepackage:
    ensure   => $mogilefs::manage_package,
    noop     => $mogilefs::noops,
    provider => 'cpanm',
    require  => Package['cpanminus'],
    before   => Exec[mogdbsetup]
  }

  exec { 'mogdbsetup':
    command     => "mogdbsetup --type=${mogilefs::mogilefsd::dbtype} --yes \
            --dbname=${mogilefs::mogilefsd::dbname} --verbose",
    path        => ['/usr/bin', '/usr/sbin', '/usr/local/bin'],
    subscribe   => Package['MogileFS::Server'],
    refreshonly => true,
    audit       => $mogilefs::manage_audit,
    noop        => $mogilefs::noops,
    user        => $mogilefs::username,
  }
}