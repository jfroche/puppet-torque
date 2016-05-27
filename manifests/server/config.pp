# Manages torque server configuration
#
class torque::server::config (
  $qmgr_server              = $torque::params::qmgr_server,
  $qmgr_queue_defaults      = $torque::params::qmgr_queue_defaults,
  $qmgr_queues              = $torque::params::qmgr_queues,
  $torque_home              = $torque::params::torque_home,
) {

  validate_hash($qmgr_server)
  validate_array($qmgr_queue_defaults)
  validate_hash($qmgr_queues)

  $sconfig = torque_config_diff('server', $qmgr_server)
  $qconfig = torque_config_diff('queue', $qmgr_queues, $qmgr_queue_defaults)

  file { "${torque_home}/qmgr_config":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('torque/qmgr_config.erb'),
    require => File[$torque_home],
  }

  exec { 'qmgr update':
    path        => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
    command     => "cat ${torque_home}/qmgr_config | qmgr",
    onlyif      => "grep -vq \"^[[:space:]]*\\(#\\|$\\)\" ${torque_home}/qmgr_config",
    refreshonly => true,
    subscribe   => File["${torque_home}/qmgr_config"],
    logoutput   => true,
  }
}
