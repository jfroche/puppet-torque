# batchversion.rb
Facter.add(:batchversion) do
  confine :osfamily => 'RedHat'
  confine :batchsystem => /^torque/
  setcode do
  	Facter::Util::Resolution::exec("rpm -q --qf \"%{VERSION}\n\" #{Facter.value(:batchsystem)}")
  end
end
