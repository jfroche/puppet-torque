# Class to create nodes for server
#
#   class {'torque::server::nodes':
#       node_list => {
#           'node1.example.com': {
#               np: 1,
#               properties: ['prop1', 'prop2']
#           }
#       }
#   }
class torque::server::nodes (
    $node_list      = $torque::params::node_list,
    $hiera_merge    = $torque::params::hiera_merge
) inherits torque::params {
    
    validate_hash($node_list)
    validate_bool($hiera_merge)


    if empty($node_list) and $hiera_merge {
        $nodes = hiera_hash('torque::server::nodes::node_list')
    } else {
        $nodes = $node_list
    }
    create_resources('torque::node', $nodes)
}
