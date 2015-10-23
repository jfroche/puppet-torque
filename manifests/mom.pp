# Torque mom -- scheduler
#
class torque::mom(
    $torque_server,
    $restricted                     = $torque::params::restricted,
    $ideal_load_adj                 = $torque::params::ideal_load_adj,
    $max_load_adj                   = $torque::params::max_load_adj,
    $options                        = $torque::params::options,
    $usecp                          = $torque::params::usecp,
    $mom_prologue_file              = $torque::params::mom_prologue_file,
    $mom_epilogue_file              = $torque::params::mom_epilogue_file,
    $mom_prologue_parallel_file     = $torque::params::mom_prologue_file,
    $mom_epilogue_parallel_file     = $torque::params::mom_epilogue_file,
    $mom_ensure                     = $torque::params::mom_ensure,
    $mom_service_enable             = $torque::params::mom_service_enable,
    $mom_service_ensure             = $torque::params::mom_service_ensure,
    $pbs_environment                = $torque::params::pbs_environment,
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
        $actual_service_name = $service_name
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

    file { "${torque_home}/pbs_environment":
        ensure  => 'present',
        content => template('torque/pbs_environment.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => [
            $requirement
        ],
    }

    if ( $mom_prologue_file )  {
        file { "${torque_home}/mom_priv/prologue":
            ensure  => 'present',
            source  => $mom_prologue_file,
            owner   => 'root',
            group   => 'root',
            mode    => '0755',
            require => [
                File["${torque_home}/mom_priv"],
                $requirement
            ]
        }
        # This file needs to be better managed(more dynamic)
        file { "${torque_home}/mom_priv/prologue.killproc.pl":
            ensure => present,
            source => 'puppet:///modules/torque/prologue.killproc.pl',
            owner => root,
            group => root,
            mode => '0755',
            require => File["${torque_home}/mom_priv/prologue"]
        }
    }
    if ( $mom_prologue_parallel_file )  {
        file { "${torque_home}/mom_priv/prologue.parallel":
            ensure  => 'present',
            source  => $mom_prologue_parallel_file,
            owner   => 'root',
            group   => 'root',
            mode    => '0755',
            require => [
                File["${torque_home}/mom_priv"],
                $requirement
            ]
        }
    }

    if ( $mom_epilogue_file )  {
        file { "${torque_home}/mom_priv/epilogue":
            ensure  => 'present',
            source  => $mom_epilogue_file,
            owner   => 'root',
            group   => 'root',
            mode    => '0755',
            require => [
                File["${torque_home}/mom_priv"],
                $requirement
            ]
        }
        # This file needs to be better managed(more dynamic)
        file { "${torque_home}/mom_priv/epilogue.killproc.pl":
            ensure => present,
            source => 'puppet:///modules/torque/epilogue.killproc.pl',
            owner => root,
            group => root,
            mode => '0755',
            require => File["${torque_home}/mom_priv/epilogue"]
        }
    }
    if ( $mom_epilogue_parallel_file )  {
        file { "${torque_home}/mom_priv/epilogue.parallel":
            ensure  => 'present',
            source  => $mom_epilogue_parallel_file,
            owner   => 'root',
            group   => 'root',
            mode    => '0755',
            require => [
                File["${torque_home}/mom_priv"],
                $requirement
            ]
        }
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
        subscribe  => File["${torque_home}/mom_priv/config"]
    }
}
