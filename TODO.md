# TODO

* Merge in https://github.com/BeneDicere/puppet-torque so server
  subscribes to new nodes and adds them to hosts file
* Add similar functionality to nodes for firewall rules
* Setup auth.pp to accept munge and pam
Configure /etc/security/access.conf so only users that have active job can ssh in

-:ALL EXCEPT root wrairredhatadmin torque:ALL

Configure /etc/pam.d/sshd with pbs access.

    Add following at the end of the account section(note that the torque docs say required but sufficient is correct)

    account sufficient pam_pbssimpleauth.so
    account required pam_access.so

Configure selinux such that pam:sshd can read job files to ensure user has a job running to log them in

    download torque.pp

    yum install policycoreutils
    semodule -i /media/VD_Research/Admin/PBS/Software/torque/torqueavc/torque.pp

* Fix epilogue and prologue scripts. Maybe part of pbs_environment.pp?
* Setup ${torque_home}/sched_priv/sched_config
* Setup /etc/sysconfig/pbs_sched so that logfiles can go to /var/log/torque
* Setup /etc/sysconfig/pbs_mom so that logfiles can go to /var/log/torque
* Include logrotate stuff for pbs_sched and pbs_mom
* Fix LANGUAGE and LC_whatever errors for perl
* Install torque docs executes always
* qmgr_config file can have contents but not applied if server was not running during
last run and failed to apply qmgr
