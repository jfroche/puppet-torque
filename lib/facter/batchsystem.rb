# batchsystem.rb
Facter.add(:batchsystem) do
  confine :osfamily => 'RedHat'
  setcode do
  	Facter::Util::Resolution::exec('rpm -qa --qf "%{NAME}\n" | grep "^torque" | sort | head -n1')
  end
end
