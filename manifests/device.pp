# Define:: mogilefs::device
#
# Configures mogilefs devices
#
# === Parameters
#
# [*status*]
#   Status of device
#
define mogilefs::device (
  $trackers = mogilefs::real_trackers,
  $status = '',
) {
  # Add domain
  exec { "add_device_${name}":
    path      => ['/bin', '/usr/local/bin', '/usr/bin'],
    command   => "mogadm --trackers=${mogilefs::real_trackers} device add ${::hostname} ${name} --status=alive",
    unless    => "mogadm --trackers=${mogilefs::real_trackers} device list | grep dev${name}",
    require   => [Service[mogilefsd],File["${mogilefs::datapath}/dev${name}"],Exec['mogilefs_enablehost']],
    tries     => 3,
    try_sleep => 5,
  }
  file { "${mogilefs::datapath}/dev${name}":
    ensure  => 'directory',
    owner   => $mogilefs::config_file_owner,
    group   => $mogilefs::config_file_group,
    mode    => '0664',
    require => Service[mogilefsd],
  }
}
