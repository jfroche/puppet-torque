# TODO

* Setup ${torque_home}/sched_priv/sched_config
* Include logrotate stuff for pbs_sched and pbs_mom
* qmgr_config file can have contents but not applied if server was not running during
last run and failed to apply qmgr
* Merge in https://github.com/BeneDicere/puppet-torque so server
  subscribes to new nodes and adds them to hosts file
* Add similar functionality to nodes for firewall rules
