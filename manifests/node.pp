# Create a node entry via qmgr -c "create node"
# only if it doesn't already exist in server_priv/nodes
define torque::node(
    $np             = 0,
    $gpus           = 0,
    $properties     = [],
    $torque_home    = '/var/spool/torque',
    $prefix         = '/usr/local'
) {
    validate_integer($np)
    validate_integer($gpus)
    validate_array($properties)

    $np_ = $np ? {
        0 => '',
        default => "np=$np,"
    }
    $gpus_ = $gpus ? {
        0 => '',
        default => "gpus=$gpus,"
    }
    if !empty($properties) {
        $p = join($properties, ',properties+=')
        $properties_ = "properties+=${p}"
    } else {
        $properties_ = ''
    }

    $node_def = "${title} ${np_}${gpus_}${properties_}"
    exec { "add_node_${title}":
        path        => "${prefix}/sbin:${prefix}/bin:/bin:/usr/bin",
        command     => "qmgr -c 'create node ${node_def}'",
        unless      => "grep -q ${title} ${torque_home}/server_priv/nodes",
        require     => Class['torque::server']
    }
}
