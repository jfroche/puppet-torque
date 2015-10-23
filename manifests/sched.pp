class torque::sched (
    $sched_service_enable   = $torque::params::sched_service_enable,
    $sched_service_ensure   = $torque::params::sched_service_ensure,
    $sched_service_name     = $torque::params::sched_service_name,
    $build                  = $torque::params::build,
    $version                = $torque::params::version,
    $build_dir              = $torque::params::build_dir
) inherits torque::params {
    if $build {
        $full_build_path = "${build_dir}/torque-${version}"
        $service_file = $::osfamily ? {
            'Debian' => 'debian.pbs_sched',
            'Suse'   => 'suse.pbs_sched',
            default  => 'pbs_sched'
        }
        $full_service_file_path = "${build_dir}/torque-${version}/contrib/init.d/${service_file}"
        file {"/etc/init.d/pbs_sched":
            source => "${full_service_file_path}",
            mode => "0755",
            owner => root,
            group => root,
        }
        $actual_service_name = 'pbs_sched'
    }

    service { $actual_service_name:
        ensure => $sched_service_ensure,
        enable => $sched_service_enable,
        require => File["/etc/init.d/${actual_service_name}"]
    }
}
