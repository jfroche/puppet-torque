# This manages the base config that happens on both server and node
class torque::config (
    $torque_server,
    $torque_home            = $torque::params::torque_home,
    $build                  = $torque::params::build,
    $pbs_environment        = $torque::params::pbs_environment,
) inherits torque::params {
    validate_bool($build)
    validate_bool($manage_repo)
    validate_string($torque_home)
    validate_array($pbs_environment)

    if $build == $manage_repo {
        fail('$build and $manage_repo are mutually exclusive')
    }

    file { $torque_home:
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
    }

    file { "${torque_home}/server_name":
        ensure  => 'present',
        content => template("${module_name}/server_name.erb"),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File[$torque_home]
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
