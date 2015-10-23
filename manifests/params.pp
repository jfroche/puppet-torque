class torque::params {
    # Global
    #  If true, then torque will be built from source
    $build                      = true
    # if true, then will use hiera_merge as much as possible
    $hiera_merge                = true

    $enable_maui                = false
    $enable_munge               = true

    # init.pp
    $server_name                = $::fqdn
    $manage_repo                = false
    $package_source             = 'hu-berlin'
    $torque_home                = '/var/spool/torque'
    $log_dir                    = '/var/log/torque'

    # build.pp
	$version 	                = '5.1.1.2-1_18e4a5f1'
    $build_dir                  = '/root/src'
    $torque_download_base_url   = 'http://wpfilebase.s3.amazonaws.com/torque'
    $configure_options          = [
        "--with-server-home=${torque::params::torque_home}"
    ]
    $prefix                     = '/usr/local'

    # server.pp
    $server_ensure              = 'present'
    $service_name               = 'torque-server'
    $service_ensure             = 'running'
    $service_enable             = true
    $server_package             = 'torque-server'
    $log_file                   = 'server.log'
    $use_logrotate              = true

    # server/nodes.pp
    $node_list                  = {}

    # server/config.pp
    # Options from pbs_server_attributes man page
    $qmgr_server                = [
        "acl_hosts = ${::fqdn}",
        'node_check_rate = 150',
        'tcp_timeout = 6',
        'next_job_number = 0',
        'scheduling = True',
        'acl_host_enable = False',
        "managers = root@${::fqdn}",
        "operators = root@${::fqdn}",
        'log_events = 511',
        'mail_from = adm',
        'mail_domain = never',
        'query_other_jobs = True',
        'scheduler_iteration = 600',
        'default_node = lcgpro',
        'node_pack = False',
        'kill_delay = 10',
        # attribute doesn't seem to be supported
        # in all versions
        #    "authorized_users = *@${::fqdn}"
    ]

    # the following options are protected from being unset
    # if they don't appear in torque_qmgr_server
    # I can't find where this is actually referenced
    $qmgr_present               = [
        'acl_hosts',
        'node_check_rate',
        'tcp_timeout',
        'next_job_number'
    ]
    # These are the defaults that will be assigned to each queue if not specified
    $qmgr_queue_defaults        = [
        'queue_type = Execution',
        'resources_max.cput = 48:00:00',
        'resources_max.walltime = 72:00:00',
        'enabled = True',
        'started = True',
        'acl_group_enable = True',
    ]
    # default queue definitions
    # empty, because queues are not set up by default
    # this is a hash with the queue name as key and an array of configuration options as value
    # if no value is specified then the default options array ($qmgr_qdefaults) is used
    # Look at man pbs_queue_attributes for details on what you can set
    $qmgr_queues                = {}
}
