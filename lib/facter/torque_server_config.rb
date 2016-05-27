# torque_server_config
Facter.add(:torque_server_config) do
	confine :osfamily => 'RedHat'
	confine :batchsystem => 'torque'
	setcode do
		tsc = %x[qmgr -c 'print server']
		if tsc.nil?
			nil
		else
			array_items = %w[acl_hosts acl_roots managers submit_hosts]
			result = {}
			tsc.gsub(/\+=/, '=').split("\n").select{|line| line.match(/^set server /)}.sort.each do |line|
				_set, _server, key, _is, value = line.split(" ")
				if array_items.include?(key)
					result[key] ||= []
					result[key] << value
				else
					result[key] = value
				end
			end

			result.to_json
		end
	end
end
