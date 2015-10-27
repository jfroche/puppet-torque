# Torque mom -- scheduler
#
class torque::mom(
    $torque_server,
    $restricted                     = $torque::params::restricted,
    $ideal_load_adj                 = $torque::params::ideal_load_adj,
    $max_load_adj                   = $torque::params::max_load_adj,
    $options                        = $torque::params::options,
    $usecp                          = $torque::params::usecp,
    $mom_ensure                     = $torque::params::mom_ensure,
    $mom_service_enable             = $torque::params::mom_service_enable,
    $mom_service_ensure             = $torque::params::mom_service_ensure,
    $mom_service_name               = $torque::params::mom_service_name,
    $torque_home                    = $torque::params::torque_home,
    $build                          = $torque::params::build,
    $version                        = $torque::params::version,
    $build_dir                      = $torque::params::build_dir,
) inherits torque {

  # job execution engine for Torque batch system
    if $build {
        $full_build_path = "${build_dir}/torque-${version}"
        exec {"install_torque_mom_${version}":
            command => "${full_build_path}/torque-package-mom-linux-x86_64.sh --install && touch ${full_build_path}/torque_mom_installed",
            creates => "${full_build_path}/torque_mom_installed",
            require => Exec["make_packages_${version}"]
        }
        $service_file = $::osfamily ? {
            'Debian' => 'debian.pbs_mom',
            'Suse'   => 'suse.pbs_mom',
            default  => 'pbs_mom'
        }
        $full_service_file_path = "${build_dir}/torque-${version}/contrib/init.d/${service_file}"
        file {"/etc/init.d/pbs_mom":
            source => "${full_service_file_path}",
            mode => "0755",
            owner => root,
            group => root
        }
        $actual_service_name = 'pbs_mom'
        $requirement = Exec["install_torque_docs_${version}"]
    } else {
        package { 'torque-mom':
            ensure => $mom_ensure,
        }
        $requirement = Package['torque-mom']
        $actual_service_name = $mom_service_name
    }

    file { "${torque_home}/mom":
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
    }

    file { "${torque_home}/mom_priv":
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File["${torque_home}/mom"]
    }

    file { "${torque_home}/mom_priv/config":
        ensure  => 'present',
        content => template('torque/pbs_config.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => [
            File["${torque_home}/mom_priv"],
            $requirement
        ],
    }

    file { "${torque_home}/undelivered":
        ensure => directory,
        owner => root,
        group => root,
        mode => '1777',
        require => $requirement
    }

    if $options['tmpdir'] {
        exec {"/bin/mkdir -p ${options[tmpdir]}": refreshonly => true}
        file {$options['tmpdir']:
            ensure => directory,
            owner => root,
            group => root,
            mode => '1733',
            require => Exec["/bin/mkdir -p ${options[tmpdir]}"]
        }
    }

    service { $actual_service_name:
        ensure     => $mom_service_ensure,
        enable     => $mom_service_enable,
        require    => [
            $requirement,
            File["${torque_home}/undelivered"]
        ],
        subscribe  => [
            File["${torque_home}/mom_priv/config"],
            File["${torque_home}/pbs_environment"]
        ]
    }
}
