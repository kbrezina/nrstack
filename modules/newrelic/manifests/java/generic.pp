define newrelic::java::generic($container_home, $container_config_file, $variable, $license_key, $generated_for_user = '', $notification_target) {
	include newrelic::utils::java

	$newrelic_java_agent_root = "${container_home}/newrelic"
	$newrelic_java_agent_option = "\"$${variable} -javaagent:${newrelic_java_agent_root}/newrelic.jar\""

	package { 'curl':
		ensure => installed,
	}

	# download and unpack the newrelic java agent
	exec { "newrelic_java_agent_download-${newrelic_java_agent_root}":
		command => "curl -sS \"http://download.newrelic.com/newrelic/java-agent/newrelic-api/2.3.1/newrelic_agent2.3.1.zip\" | java -classpath \"${settings::vardir}/newrelic/java\" Unzip \"${container_home}\"; mv \"${newrelic_java_agent_root}/newrelic.yml\" \"${newrelic_java_agent_root}/newrelic.yml.erb\"",
		path => ['/usr/local/bin', '/bin', '/usr/bin'],
		creates => "${newrelic_java_agent_root}/newrelic.yml.erb",
		require => [Package['curl'], File["${settings::vardir}/newrelic/java/Unzip.class"]],
	}

	# expand the confguration file to include the license key
	exec { "newrelic_java_agent_expand_configuration-${newrelic_java_agent_root}":
		command => "ruby -rerb -e \"generated_for_user = ''; license_key = '${license_key}'; puts ERB.new(STDIN.read()).result()\" < \"${newrelic_java_agent_root}/newrelic.yml.erb\" > \"${newrelic_java_agent_root}/newrelic.yml.expanded\"",
		path => ['/usr/local/bin', '/bin', '/usr/bin'],
		require => Exec["newrelic_java_agent_download-${newrelic_java_agent_root}"],
	}

	file { "${newrelic_java_agent_root}/newrelic.yml":
		source => "${newrelic_java_agent_root}/newrelic.yml.expanded",
		require => Exec["newrelic_java_agent_expand_configuration-${newrelic_java_agent_root}"],
		notify => $notification_target,
	}

	# make sure there are no conflicting java agent options
	augeas { "newrelic_java_agent_remove_conflicting_option-${container_config_file}":
		incl => "${container_config_file}",
		lens => 'Shellvars.lns',
		context => "/files${container_config_file}",
		changes => [
			"remove ${variable}[. != '${newrelic_java_agent_option}' and . =~ regexp('\"$${variable} -javaagent:.*/newrelic\\.jar\"')]",
		],
		notify => $notification_target,
	}

	# add another assignment of the ${variable} if needed
	# (i.e. if there are already some assignments defined for the ${variable} and none of them is the desired one)
	augeas { "newrelic_java_agent_add_option-${container_config_file}":
		incl => "${container_config_file}",
		lens => 'Shellvars.lns',
		context => "/files${container_config_file}",
		onlyif => "match \"/files${container_config_file}[count(${variable}[. = '${newrelic_java_agent_option}']) = 0 and count(${variable}[. != '${newrelic_java_agent_option}']) > 0]\" != []",
		changes => [
			"insert ${variable} after ${variable}[last()]",
			"set ${variable}[last()] '${newrelic_java_agent_option}'",
		],
		require => Augeas["newrelic_java_agent_remove_conflicting_option-${container_config_file}"],
		notify => $notification_target,
	}

	# add assignment of the ${variable} (this only gets executed if there are no assignments of the ${variable} yet)
	augeas { "newrelic_java_agent_set_option-${container_config_file}":
		incl => "${container_config_file}",
		lens => 'Shellvars.lns',
		context => "/files${container_config_file}",
		onlyif => "match ${variable}[. = '${newrelic_java_agent_option}'] == []",
		changes => [
			"set ${variable} '${newrelic_java_agent_option}'",
		],
		require => Augeas["newrelic_java_agent_add_option-${container_config_file}"],
		notify => $notification_target,
	}
}
