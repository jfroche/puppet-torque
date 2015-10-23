# Manages the environment that jobs run it
# on moms
class torque::job_environment (
    $environment_vars         = $torque::params::environment_vars,
    $profile_file_path       = $torque::params::profile_file_path,
) {
    validate_hash($environment_vars)
    validate_string($profile_file_path)


    file {$profile_file_path:
        owner       => root,
        group       => root,
        mode        => '0755',
        content     => template('torque/pbs.sh.erb')
    }
}
