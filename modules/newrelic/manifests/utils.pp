class newrelic::utils {
	file { "${settings::vardir}/newrelic":
		ensure => directory,
	}
}
