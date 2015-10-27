# Manages the environment that jobs run it
# on moms
class torque::job_environment (
    $torque_home                = $torque::params::torque_home,
    $environment_vars           = $torque::params::environment_vars,
    $profile_file_path          = $torque::params::profile_file_path,
    $prologue_file              = $torque::params::prologue_file,
    $epilogue_file              = $torque::params::epilogue_file,
    $prologue_parallel_file     = $torque::params::prologue_file,
    $epilogue_parallel_file     = $torque::params::epilogue_file,
    $pbs_environment            = $torque::params::pbs_environment,
    $build                      = $torque::params::build,
    $logout_users_nojobs        = $torque::params::logout_users_nojobs
) {
    validate_hash($environment_vars)
    validate_string($profile_file_path)
    validate_string($prologue_file)
    validate_string($epilogue_file)
    validate_string($prologue_parallel_file)
    validate_string($epilogue_parallel_file)
    validate_array($pbs_environment)
    validate_bool($build)
    validate_bool($logout_users_nojobs)

    file {$profile_file_path:
        owner       => root,
        group       => root,
        mode        => '0755',
        content     => template("${module_name}/pbs.sh.erb")
    }

    if ( $prologue_file )  {
        file { "${torque_home}/mom_priv/prologue":
            ensure  => 'present',
            source  => $prologue_file,
            owner   => 'root',
            group   => 'root',
            mode    => '0755',
            require => [
                File["${torque_home}/mom_priv"],
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
    if ( $prologue_parallel_file )  {
        file { "${torque_home}/mom_priv/prologue.parallel":
            ensure  => 'present',
            source  => $prologue_parallel_file,
            owner   => 'root',
            group   => 'root',
            mode    => '0755',
            require => [
                File["${torque_home}/mom_priv"],
            ]
        }
    }

    if ( $epilogue_file )  {
        file { "${torque_home}/mom_priv/epilogue":
            ensure  => 'present',
            source  => $epilogue_file,
            owner   => 'root',
            group   => 'root',
            mode    => '0755',
            require => [
                File["${torque_home}/mom_priv"],
            ]
        }
        # This file needs to be better managed(more dynamic)
        file { "${torque_home}/mom_priv/epilogue.killproc.pl":
            ensure => present,
            content => template("${module_name}/epilogue.killproc.pl.erb"),
            owner => root,
            group => root,
            mode => '0755',
            require => File["${torque_home}/mom_priv/epilogue"]
        }
    }
    if ( $epilogue_parallel_file )  {
        file { "${torque_home}/mom_priv/epilogue.parallel":
            ensure  => 'present',
            source  => $epilogue_parallel_file,
            owner   => 'root',
            group   => 'root',
            mode    => '0755',
            require => [
                File["${torque_home}/mom_priv"],
            ]
        }
    }

    file { "${torque_home}/pbs_environment":
        ensure  => 'present',
        content => template("${module_name}/pbs_environment.erb"),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => [
            File[$torque_home]
        ],
    }

}
