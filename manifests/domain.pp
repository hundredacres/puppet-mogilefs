define mogilefs::domain (
  $trackers = mogilefs::real_trackers,
  $domain = '',
  $class = '',
) {
  # Add domain
  exec { "add_domain_${name}":
    path    => ['/bin', '/usr/local/bin', '/usr/bin'],
    command => "mogadm --trackers=${mogilefs::real_trackers} domain add ${domain}",
    unless  => "mogadm --trackers=${mogilefs::real_trackers} domain list | grep ${domain}",
    require => Service[mogilefsd],
    before  => Exec["add_class_${name}"],
  }
  exec { "add_class_${name}":
    path    => ['/bin', '/usr/local/bin', '/usr/bin'],
    command => "mogadm --trackers=${mogilefs::real_trackers} class add ${domain} ${class}",
    unless  => "mogadm --trackers=${mogilefs::real_trackers} class list | grep ${class}",
    require => Service[mogilefsd]
  }
}
