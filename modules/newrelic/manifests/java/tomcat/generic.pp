define newrelic::java::tomcat::generic(
	$container_home,
	$container_config_file,
	$license_key,
	$generated_for_user = '',
	$notification_target
) {
	newrelic::java::generic { 'tomcat-generic':
		container_home => "${container_home}",
		container_config_file => "${container_config_file}",
		variable => 'CATALINA_OPTS',
		license_key => "${license_key}",
		generated_for_user => "${generated_for_user}",
		notification_target => "${notification_target}",
	}
}
