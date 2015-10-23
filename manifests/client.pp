# Torque client -- mom
#   should be install on computing nodes
#
class torque::client(
    $torque_server,
    $torque_home        = $torque::params::torque_home,
    $bulid_dir          = $torque::params::build_dir,
    $build              = $torque::params::build,
    $version            = $torque::params::version
) inherits torque::params {
    # command line interface to Torque server
    if $build {
        $full_build_path = "${build_dir}/torque-${version}"
        exec {"install_torque_client_${version}":
            command => "${full_build_path}/torque-package-clients-linux-x86_64.sh --install && touch ${full_build_path}/torque_client_installed",
            creates => "${full_build_path}/torque_client_installed",
            require => Exec["make_packages_${version}"]
        }
    } else {
        package { 'torque-client':
            ensure => $package_ensure,
        }
    }

    file { "${torque_home}/aux":
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
    }
}
