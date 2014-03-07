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
    content => template("mogilefs/mogilefsd.init.${::osfamily}.erb"),
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
    'Mysql' => $::operatingsystem ? {
      /(?i:Debian|Ubuntu|Mint)/       => 'DBD::mysql',
      /(?i:RedHat|Centos|Scientific)/ => 'perl-DBD-MySQL',
      default                         => '',
    },
    'Postgres' => $::operatingsystem ? {
      /(?i:Debian|Ubuntu|Mint)/       => 'DBD::Pg',
      /(?i:RedHat|Centos|Scientific)/ => 'perl-DBD-Pg',
      default                         => '',
    },
    'SQLite'   => $::operatingsystem ? {
      /(?i:Debian|Ubuntu|Mint)/       => 'DBD::SQLite',
      /(?i:RedHat|Centos|Scientific)/ => 'perl-DBD-SQLite',
      default                         => '',
    },
    default    => fail("Dbtype must be one of: 'Mysql', 'Postgres' or \
      'SQLite'. Got: ${mogilefs::mogilefsd::dbtype}"),
  }

  case $::osfamily {
    'debian': {
      package { $databasepackage:
        ensure   => $mogilefs::manage_package,
        noop     => $mogilefs::noops,
        provider => 'cpanm',
        require  => Package[$cpan_package],
        before   => Exec[mogdbsetup]
      }
    }
    'redhat': {
      package { $databasepackage:
        ensure   => $mogilefs::manage_package,
        noop     => $mogilefs::noops,
        require  => Package[$cpan_package],
        before   => Exec[mogdbsetup]
      }
    }
    default: {}
  }
  exec { 'mogdbsetup':
    command     => "mogdbsetup --type=${mogilefs::mogilefsd::dbtype} --yes \
            --dbname=${mogilefs::mogilefsd::dbname} --verbose",
    path        => ['/usr/bin', '/usr/sbin', '/usr/local/bin'],
    subscribe   => Package[$mogilefs::package],
    refreshonly => true,
    audit       => $mogilefs::manage_audit,
    noop        => $mogilefs::noops,
    user        => $mogilefs::username,
  }
}
