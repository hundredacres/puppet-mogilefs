define mogilefs::device (
  $trackers = mogilefs::real_trackers,
  $status = '',
) {
  # Add domain
  exec { "add_device_${name}":
    path      => ['/bin', '/usr/local/bin', '/usr/bin'],
    command   => "mogadm --trackers=${mogilefs::real_trackers} device add ${::hostname} 1 --status=alive",
    unless    => "mogadm --trackers=${mogilefs::real_trackers} device list | grep \sdev${name}",
    require   => Service[mogilefsd],
    subscribe => Exec['mogilefs_enablehost'],
  }
}
