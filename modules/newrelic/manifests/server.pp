class newrelic::server(
	$license_key = $::newrelic_license,
	$collector_host = '',
	$proxy = '',
	$ssl = '',
	$ssl_ca_bundle = '',
	$ssl_ca_path = '',
	$collector_timeout = '',
	$logfile = '/var/log/newrelic/nrsysmond.log',
	$loglvl = 'info',
	$pidfile = '/var/run/newrelic/nrsysmond.pid'
) {
	package { 'newrelic-repo':
		ensure => latest,
		source => 'http://download.newrelic.com/pub/newrelic/el5/i386/newrelic-repo-5-3.noarch.rpm',
		provider => rpm,
	}

	package { 'newrelic-sysmond':
		ensure => latest,
		require => Package['newrelic-repo'],
	}

	file { '/etc/newrelic/nrsysmond.cfg':
		content => template('newrelic/nrsysmond.cfg.erb'),
		owner => root,
		group => newrelic,
		mode => 0640,
		ensure => present,
		subscribe => Package['newrelic-sysmond'],
	}

	service { 'newrelic-sysmond':
		enable => true,
		ensure => running,
		subscribe => [Package['newrelic-sysmond'], File['/etc/newrelic/nrsysmond.cfg']],
	}
}
