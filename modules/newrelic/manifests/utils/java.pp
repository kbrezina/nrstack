class newrelic::utils::java {
	include newrelic::utils

	file { "${settings::vardir}/newrelic/java":
		ensure => directory,
		require => File["${settings::vardir}/newrelic"],
	}

	file { "${settings::vardir}/newrelic/java/Unzip.class":
		source => 'puppet:///modules/newrelic/java/Unzip.class',
		require => File["${settings::vardir}/newrelic/java"],
	}
}
