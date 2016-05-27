module Puppet::Parser::Functions
	newfunction(:torque_config_diff, :type => :rvalue) do |args|
		req_presence = lookupvar('torque::params::qmgr_present') || []
		array_items = lookupvar('torque::params::qmgr_arrays') || []

		case args[0]
		when 'server'
			config = args[1]
			raise(Puppet::ParseError, "torque_config_diff(server), second argument has to be an hash") unless config.is_a?(Hash)
			clientconfig = JSON.load(lookupvar('torque_server_config')) || {}

			keys = (clientconfig.keys + config.keys).uniq.sort

			sconfig = []
			usconfig = []

			keys.each do |key|
				if array_items.include?(key)
					clientconfig[key] ||= []
					config[key] ||= []
					values = clientconfig[key] + config[key]
					values.uniq.sort.each do |item|
						case [config[key].include?(item), clientconfig[key].include?(item)]
						when [true, true], [false, false]
							# nothing to do
						when [true, false]
							sconfig << "set server #{key} += #{item}"
						when [false, true]
							sconfig << "set server #{key} -= #{item}" unless req_presence.include?(key)
						end
					end
				else
					case config[key]
					when clientconfig[key]
						# nothing to do
					when nil
						sconfig << "unset server #{key}" unless req_presence.include?(key)
					else
						sconfig << "set server #{key} = #{config[key]}"
					end
				end
			end

			# combine all commands
			sconfig | usconfig
		when 'queue'
			queues = args[1]
			qdefaults = args[2]
			raise(Puppet::ParseError, 'torque_config_diff(node), second argument has to be a hash') unless queues.is_a?(Hash)
			raise(Puppet::ParseError, 'torque_config_diff(node), third argument has to be an array') unless qdefaults.is_a?(Array)
			clientqueues = lookupvar('torque_queues')
			clientqueues = (clientqueues.nil? ? [] : clientqueues.split(','))
			queueconfig = {}
			# delete queues that are not configured
			clientqueues.each do |queue|
				queueconfig[queue] = [ "delete queue #{queue}" ] unless queues.include?(queue)
			end
			# configure queues
			queues.keys.each do |queue|
				config = queues[queue].nil? ? qdefaults : queues[queue]
				config.unshift("create queue #{queue}") unless config.include?("create queue #{queue}")
				if clientqueues.include?(queue)
					# get exiting configuration from client if queue exists
					clientconfig = lookupvar("torque_queue_config_#{queue}")
					clientconfig = (clientconfig.nil? ? [] : clientconfig.split(','))
					# get values that need to be set (present in config but not on server)
					qconfig = (config - clientconfig).map { |cfg| cfg =~ /^create / ? cfg : "set queue #{queue} #{cfg}" }
					# get values that need to be unset (present on server but not in config)
					uqconfig = (clientconfig.map { |cfg| cfg.gsub(/[\t =].*$/, '') } - config.map { |cfg| cfg.gsub(/[\t =].*$/, '') }).map { |cfg|
						#cfg.gsub!(/[\t =].*$/, '')
						"unset queue #{queue} #{cfg}"
					}
					# combine all commands
					queueconfig[queue] = qconfig | uqconfig
				else
					queueconfig[queue] = config.map { |cfg| cfg =~ /^create / ? cfg : "set queue #{queue} #{cfg}" }
				end
			end
			queueconfig
		when 'node'
			raise(Puppet::ParseError, 'torque_config_diff(): node configuration is not supported yet')
		else
			raise(Puppet::ParseError, "torque_config_diff(): Invalid first argument given (#{args[0]})")
		end
	end
end
