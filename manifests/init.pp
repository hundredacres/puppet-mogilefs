# = Class: mogilefs
#
# This is the main mogilefs class
#
# Installs both Tracker (mogilefsd) and Mogstored services by default.
# Nodes with Mogstored service, added to tracker on setup
#
# [*options*]
#   An hash of custom options to be used in templates for arbitrary settings.
#
class mogilefs (
  $options           = {
  }
  ,
  $trackers          = '',
  $add_to_tracker    = true,
  $mogilefsd_service = true,
  $mogilefsd_config  = '',
  $mogstored_service = true,
  $mogstored_config  = '',
  $config_dir        = '/etc/mogilefs',
  $config_file_mode  = '0644',
  $config_file_owner = 'mogilefs',
  $config_file_group = 'mogilefs',
  $package           = 'MogileFS::Server',
  $dbtype            = 'SQLite',
  $dbname            = 'mogilefs',
  $dbuser            = '',
  $dbpass            = '',
  $datapath          = '/var/mogdata',
  $version           = 'present',
  $absent            = false,
  $disable           = false,
  $audit_only        = false,
  $noops             = false) {
  $real_trackers = $trackers ? {
    ''      => "${::fqdn}:7001,${::hostname}:7001",
    default => $trackers
  }

  # Core parameters
  $username = 'mogilefs'

  if !inline_template('<%= options.class == Hash %>') {
    fail('Option parameter must be hash, or empty')
  }

  $manage_mogstored_init_content = template('mogilefs/mogstored.init.Debian.erb'
  )

  # Variables that apply parameters behaviours
  $manage_package = $mogilefs::absent ? {
    true  => 'absent',
    false => $mogilefs::version,
  }

  $manage_package_dependencies = $mogilefs::absent ? {
    true  => 'absent',
    false => 'present',
  }

  $manage_service_enable = $mogilefs::disable ? {
    true    => false,
    default => $mogilefs::absent ? {
      true  => false,
      false => true,
    },
  }

  $manage_service_ensure = $mogilefs::disable ? {
    true    => 'stopped',
    default => $mogilefs::absent ? {
      true    => 'stopped',
      default => 'running',
    },
  }

  $manage_file = $mogilefs::absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_audit = $mogilefs::audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_file_replace = $mogilefs::audit_only ? {
    true  => false,
    false => true,
  }

  #######################################
  #   Resourced managed by the module   #
  #######################################
  # MogileFS user
  user { $mogilefs::username:
    ensure     => 'present',
    comment    => 'MogileFS user',
    shell      => '/bin/false',
    home       => $mogilefs::datapath,
    managehome => false,
  }

  # Configuration dir
  file { $mogilefs::config_dir:
    ensure => 'directory',
    path   => $mogilefs::config_dir,
    mode   => '0644',
    owner  => $mogilefs::config_file_owner,
    group  => $mogilefs::config_file_group,
  }

  # Package
  if !defined(Package['cpanminus']) {
    package { 'cpanminus': ensure => installed }
  }

  if !defined(Package['perl-doc']) {
    package { 'perl-doc': ensure => installed }
  }

  package { $mogilefs::package:
    ensure   => $mogilefs::manage_package,
    noop     => $mogilefs::noops,
    provider => 'cpanm',
    require  => Package['cpanminus'],
  }

  # Client
  package { 'MogileFS::Utils':
    ensure   => $mogilefs::manage_package_dependencies,
    noop     => $mogilefs::noops,
    provider => 'cpanm',
    require  => Package['cpanminus'],
  }

  # Mogstored
  if ($mogstored_service == true) {
    include mogilefs::mogstored
  }

  # Mogilefsd (tracker)
  if ($mogilefsd_service == true) {
    $real_dbname = $mogilefs::dbtype ? {
      'SQLite' => $dbname ? {
        /^\//   => $dbname,
        default => "/tmp/${dbname}.sqlite3"
      },
      default  => $dbname
    }

    class { 'mogilefs::mogilefsd':
      dbtype => $mogilefs::dbtype,
      dbname => $mogilefs::real_dbname
    }
  }
}
