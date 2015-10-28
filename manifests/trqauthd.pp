class torque::trqauthd (
    $build_dir = $torque::params::build_dir,
    $version   = $torque::params::version,
    $prefix    = $torque::params::prefix
) inherits torque::params {
    include stdlib

    $service_file = $::osfamily ? {
        'Debian' => 'debian.trqauthd',
        'Suse'   => 'suse.trqauthd',
        default  => 'trqauthd'
    }
    $full_service_file_path = "${build_dir}/torque-${version}/contrib/init.d/${service_file}"

    file {"/etc/ld.so.conf.d/torque.conf":
        content => "${prefix}/lib",
        mode => '0444',
    }
    file {"/etc/init.d/trqauthd":
        source => $full_service_file_path,
        require => [
            File['/etc/ld.so.conf.d/torque.conf'],
            Class["torque::client"]
        ],
        mode => "0755",
    }
    service {"trqauthd":
        ensure => "running",
        enable => true,
        require => File['/etc/init.d/trqauthd']
    }
}
