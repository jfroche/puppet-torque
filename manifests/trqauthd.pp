class torque::trqauthd inherits torque::build {
    include stdlib

    $service_file = "${torque::build::build_dir}/${torque::build::full_version}/contrib/init.d/trqauthd"
    file {"torque.conf_ldconfig":
        path => "/etc/ld.so.conf.d/torque.conf",
        content => "${torque::build::prefix}",
        mode => '0444',
    }
    file {"ensure_service_file":
        path => "/etc/init.d/trqauthd",
        source => $service_file,
        require => File["torque.conf_ldconfig"],
        mode => "0755"
    }
    service {"trqauthd":
        ensure => "running",
        enable => true,
        require => File['ensure_service_file']
    }
}
