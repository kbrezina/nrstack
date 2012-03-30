class role {
	include 'newrelic' class {
		'newrelic::server' :
			collector_host => 'staging-collector.newrelic.com'
	}
}