# TODO

* Merge in https://github.com/BeneDicere/puppet-torque so server
  subscribes to new nodes and adds them to hosts file
* Add similar functionality to nodes for firewall rules
* Fix epilogue and prologue scripts. Maybe part of pbs_environment.pp?
* Setup ${torque_home}/sched_priv/sched_config
* Setup /etc/sysconfig/pbs_sched so that logfiles can go to /var/log/torque
* Setup /etc/sysconfig/pbs_mom so that logfiles can go to /var/log/torque
* Include logrotate stuff for pbs_sched and pbs_mom
* Fix LANGUAGE and LC_whatever errors for perl
* qmgr_config file can have contents but not applied if server was not running during
last run and failed to apply qmgr