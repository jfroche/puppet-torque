# Torque server installation
#
class torque::server(
    $server_ensure                    = $torque::params::server_ensure,
    $service_name                     = $torque::params::service_name,
    $service_ensure                   = $torque::params::service_ensure,
    $service_enable                   = $torque::params::service_enable,
    $server_package                   = $torque::params::server_package,
    $torque_home                      = $torque::params::torque_home,
    $log_dir                          = $torque::params::log_dir,
    $log_file                         = $torque::params::log_file,
    $use_logrotate                    = $torque::params::use_logrotate,
    $version                          = $torque::params::version,
    $build_dir                        = $torque::params::build_dir,
    $configure_options                = $torque::params::configure_options,
    $prefix                           = $torque::params::prefix,
    $build                            = $torque::params::build
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
        $full_service_file_path = "${build_dir}/torque-${version}/contrib/init.d/${service_file}"
        file {"/etc/init.d/pbs_server":
            source => "${full_service_file_path}",
            mode => "0755",
            owner => root,
            group => root
        }
        $actual_service_name = 'pbs_server'
    } else {
        package { $server_package:
            ensure => $server_ensure
        }
        $actual_service_name = 'torque-server'
    }

    file {"${torque_home}/spool":
        ensure => directory,
        mode => '1777',
        owner => root,
        group => root
    }

    $server_default_file = $::osfamily ? {
        "Debian" => "/etc/default/${actual_service_name}",
        "RedHat" => "/etc/sysconfig/${actual_service_name}",
        default  => fail('Unsupported operating system')
    }

    service { $actual_service_name:
        ensure     => $service_ensure,
        enable     => $service_enable,
        require    => [
            File["/etc/init.d/${actual_service_name}"],
            Service["trqauthd"]
        ],
        subscribe  => [
            File["${torque_home}/server_name"]
        ],
    }

    file { $server_default_file:
        ensure  => present,
        content => template("${module_name}/${::osfamily}.server_default.erb"),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Service[$actual_service_name],
    }

    if( $use_logrotate and !empty($log_dir) ) {
        file { '/etc/logrotate.d/torque':
            ensure  => present,
            content => template("${module_name}/logrotate.erb"),
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
        }
    }
}
    #if($enable_maui){
        #class { 'torque::maui': }
    #}

    #if($enable_munge) {
    #class { 'torque::munge': }
    #}

