# Torque server installation
#
class torque::server(
    $server_ensure                    = $torque::params::server_ensure,
    $service_name                     = $torque::params::server_service_name,
    $service_ensure                   = $torque::params::server_service_ensure,
    $service_enable                   = $torque::params::server_service_enable,
    $server_package                   = $torque::params::server_package,
    $server_service_options           = $torque::params::server_service_options,
    $torque_home                      = $torque::params::torque_home,
    $use_logrotate                    = $torque::params::use_logrotate,
    $version                          = $torque::params::version,
    $build_dir                        = $torque::params::build_dir,
    $configure_options                = $torque::params::configure_options,
    $prefix                           = $torque::params::prefix,
    $build                            = $torque::params::build,
    $manage_service_file              = $torque::params::server_manage_service_file
) inherits torque::params {

    validate_bool($enable_maui)
    validate_bool($enable_munge)
    validate_bool($build)

    if $build {
        $full_build_path = "${build_dir}/torque-${version}"

        exec {"make_install_${version}":
            command => "/usr/bin/make install && /bin/touch ${full_build_path}/make_install_already_run",
            creates => "${full_build_path}/make_install_already_run",
            cwd => $full_build_path
        }
        $service_file = $::osfamily ? {
            'Debian' => 'debian.pbs_server',
            'Suse'   => 'suse.pbs_server',
            default  => 'pbs_server'
        }
        $service_file_source = "${build_dir}/torque-${version}/contrib/init.d/${service_file}"
        $actual_service_name = 'pbs_server'
        $requirement = Exec["make_install_${version}"]
    } else {
        package { $server_package:
            ensure => $server_ensure
        }
        $requirement = Package[$server_package]
        $actual_service_name = 'pbs_server'
        $service_file_source = undef
    }

    torque::service { $actual_service_name:
        ensure              => $service_ensure,
        enable              => $service_enable,
        service_options     => $server_service_options,
        service_file_source => $service_file_source,
        manage_service      => $manage_service_file,
        require             => $requirement,
    }

    file {"${torque_home}/spool":
        ensure => directory,
        mode => '1777',
        owner => root,
        group => root
    }

}
    #if($enable_maui){
        #class { 'torque::maui': }
    #}

    #if($enable_munge) {
    #class { 'torque::munge': }
    #}

