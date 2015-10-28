#puppet-torque
[![Build Status](https://travis-ci.org/deric/puppet-torque.png?branch=master)](https://travis-ci.org/deric/puppet-torque)

This is a Puppet module for managing Torque resource manager and Maui scheduler.

## Usage

### profiles/torque.pp
```puppet
class fixresolve {
    file { "/etc/resolve.conf":
        content => "nameserver 10.0.2.3"
    }
}

class profile {
    include fixresolve

    class { "torque::config":
        torque_server => 'master'
    }
    class { "torque::build":
    }
    class { "torque::client":
        torque_server => 'master'
    }
    class { "torque::trqauthd":
    }
}

class profile::client inherits profile{
    class { "torque::mom":
        torque_server => 'master'
    }
    class { "torque::job_environment": }
}

class profile::master inherits profile{
    class { "torque::server":
    }
    class { "torque::server::config":
        qmgr_queues => {
            'test' => [
                'enabled = true',
                'started = true',
                'queue_type = Execution'
            ],
            'batch' => [
                'enabled = true',
                'started = true',
                'queue_type = Execution',
                'disallowed_types = interactive'
            ]
        }
    }
    class { "torque::sched":
    }
    class { "torque::server::nodes":
        node_list => {
            'client' => {
                np => 1,
                properties => ['prop1', 'prop2']
            }
        }
    }
}

node default {
}

node client {
    include profile::client
}

node master {
    include profile::master
}
```

By default `server_name` is the `$::fqdn` of the server node (we get it from Facter). You can choose to use other fact of some value

  * One can run both the server and client on the same box (Within server class is not included client)

client (a computing node):

```puppet
node default {
    include profiles::torque::client
} 
```

## Maui

In order to install Maui you have to have a binary package for your distribution.

 * [Debian/Ubuntu](https://github.com/deric/maui-deb-packaging)


## Hiera support

Hiera is supported out-of-the-box, you can set any class parameter from YAML config files.

```yaml
torque::auth::auth_allowed_users:
    - root
    - torque
torque::job_environment::environment_vars:
    WORKDIR: '/scratch/$USER'
    CENTER:  '/export/homes/$USER'
torque::client::torque_server: "master.example.com"
torque::mom::torque_server: "master.example.com
torque::mom::options:
    logevent: 255
    usecp: '*:/export/homes /export/homes'
    tmpdir: '/scratch/jobs'
torque::mom::pbs_environment:
    - 'PATH=/bin:/usr/bin'
    - 'LANG=en_us.UTF-8'
    - 'BASH_ENV=/etc/bashrc'
    - 'ENV=/etc/bashrc'
torque::mom::mom_epilogue_file: 'puppet:///modules/torque/epilogue'
torque::mom::mom_prologue_file: 'puppet:///modules/torque/prologue'
torque::mom::mom_epilogue_parallel_file: 'puppet:///modules/torque/epilogue'
torque::mom::mom_prologue_parallel_file: 'puppet:///modules/torque/prologue'
# qmgr server options
# see man pbs_server_attributes
torque::server::config::qmgr_server:
    - 'scheduling = True'
    - 'default_queue = batch'
    - 'log_events = 511'
    - 'mail_from = adm'
    - 'query_other_jobs = True'
    - 'scheduler_iteration = 60'
    - 'node_check_rate = 150'
    - 'tcp_timeout = 300'
    - 'job_stat_rate = 300'
    - 'poll_jobs = True'
    - 'mom_job_sync = True'
    - 'keep_completed = 300'
    - 'next_job_number = 1'
    - 'moab_array_compatible = True'
    - 'nppcu = 1'
# Available queues and their options
# See man pbs_queue_attributes
torque::server::config::qmgr_queues:
        batch:
            - 'queue_type = Execution'
            - 'Priority = 50'
            - 'resources_default.nodes = 1'
            - 'resources_default.walltime = 168:00:00'
            - 'disallowed_types = interactive'
            - 'keep_completed = 3600'
            - 'enabled = True'
            - 'started = True'
        interactive:
            - 'queue_type = Execution'
            - 'Priority = 50'
            - 'max_user_queuable = 1'
            - 'resources_max.nodes = 1'
            - 'resources_max.walltime = 24:00:00'
            - 'disallowed_types = batch'
            - 'keep_completed = 3600'
            - 'enabled = True'
            - 'started = True'
torque::server::nodes::node_list:
    'node1.example.com':
        np: 4
        properties:
            - testnode
```
## Dependencies

  * `puppetlabs/stdlib  >= 2.0.0`
  * `puppetlabs/apt >= 1.0.0`

## License

Apache License 2.0
