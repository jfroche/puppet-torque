class torque::sched (
    $sched_service_enable   = $torque::params::sched_service_enable,
    $sched_service_ensure   = $torque::params::sched_service_ensure,
    $sched_service_name     = $torque::params::sched_service_name,
    $build                  = $torque::params::build,
    $version                = $torque::params::version,
    $build_dir              = $torque::params::build_dir,
    $service_options        = $torque::params::sched_service_options
) inherits torque::params {
    if $build {
        $full_build_path = "${build_dir}/torque-${version}"
        $service_file = $::osfamily ? {
            'Debian' => 'debian.pbs_sched',
            'Suse'   => 'suse.pbs_sched',
            default  => 'pbs_sched'
        }
        $service_file_source = "${build_dir}/torque-${version}/contrib/init.d/${service_file}"
        $actual_service_name = 'pbs_sched'
    } else {
        $actual_service_name = $service_name
    }

    torque::service { $actual_service_name:
        ensure => $sched_service_ensure,
        enable => $sched_service_enable,
        service_options => $sched_service_options,
        service_file_source => $service_file_source
    }
}
