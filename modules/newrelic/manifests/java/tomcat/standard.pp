define newrelic::java::tomcat::standard(
	$container_home = '/usr/share/tomcat',
	$container_config_file = '/etc/sysconfig/tomcat',
	$license_key,
	$generated_for_user = ''
) {
	package { 'tomcat':
		ensure => latest,
	}

	newrelic::java::tomcat::generic { 'tomcat_standard':
		container_home => "${container_home}",
		container_config_file => "${container_config_file}",
		license_key => "${license_key}",
		generated_for_user => "${generated_for_user}",
		notification_target => Service['tomcat'],
	}

	service { 'tomcat':
		require => Package['tomcat'],
	}
}
