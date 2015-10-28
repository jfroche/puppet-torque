class torque::params {
    # Global
    #  If true, then torque will be built from source
    $build                      = true
    # if true, then will use hiera_merge as much as possible
    $hiera_merge                = true
    # Maui scheduler
    $enable_maui                = false
    # Munge authentication services
    $enable_munge               = false

    # init.pp
    $server_name                = $::fqdn
    $manage_repo                = false
    $package_source             = 'hu-berlin'
    $torque_home                = '/var/spool/torque'

    # build.pp
	$version 	                = '5.1.1.2-1_18e4a5f1'
    $build_dir                  = '/root/src'
    $torque_download_base_url   = 'http://wpfilebase.s3.amazonaws.com/torque'
    $configure_options          = [
        "--with-server-home=${torque::params::torque_home}"
    ]
    $prefix                     = '/usr/local'

    # server.pp
    $server_server_ensure       = 'present'
    $server_service_name        = 'torque-server'
    $server_service_ensure      = 'running'
    $server_service_enable      = true
    $server_package             = 'torque-server'
    $log_file                   = 'server.log'
    $use_logrotate              = true
    $server_service_options = {
        pbs_home => $torque_home,
        pbs_args => [
            "-L ${torque_home}/server_logs/${server_service_name}.log",
        ]
    }

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

    # client.pp

    # mom.pp
    $restricted                 = []
    $ideal_load_adj             = 0.2
    $max_load_adj               = 1.2
    $options                    = { logevent => 255 }
    $usecp                      = []
    $mom_service_name           = 'torque-mom'
    $mom_ensure                 = 'installed'
    $mom_service_enable         = true
    $mom_service_ensure         = 'running'
    $mom_service_options = {
        pbs_home => $torque_home,
        pbs_args => [
            "-L ${torque_home}/mom_logs/${mom_service_name}.log",
        ]
    }

    # job_environment.pp
    # This is a hash of simple VAR=VAL that will be put in
    # profile_file_path so that jobs get the vars
    $environment_vars                 = {
    }
    $profile_file_path           = '/etc/profile.d/pbs.sh'
    $prologue_file          = 'puppet:///modules/torque/prologue'
    $epilogue_file          = 'puppet:///modules/torque/epilogue'
    $prologue_parallel_file = 'puppet:///modules/torque/prologue'
    $epilogue_parallel_file = 'puppet:///modules/torque/epilogue'
    # Kills all processes for users that have no jobs running
    # anymore
    $logout_users_nojobs    = true

    # sched.pp
    $sched_service_enable   = true
    $sched_service_ensure   = 'running'
    $sched_service_name     = 'torque-sched'
    $sched_service_options = {
        pbs_home => $torque_home,
        pbs_args => [
            "-L ${torque_home}/sched_logs/${sched_service_name}.log",
        ]
    }

    # auth.pp
    # List of users that will be always allowed to login to auth nodes
    $auth_allowed_users     = ['root','torque']

    # config.pp

    # list of vars to set for pbs_environment
    $pbs_environment        = [
        'PATH=/bin:/usr/bin',
        'LANG=en_us.UTF-8'
    ]
}
