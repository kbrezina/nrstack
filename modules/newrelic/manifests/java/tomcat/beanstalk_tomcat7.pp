define newrelic::java::tomcat::beanstalk_tomcat7(
	$license_key,
	$generated_for_user = ''
) {
	newrelic::java::tomcat::generic { 'tomcat_beanstalk_tomcat7':
		container_home => '/opt/tomcat7',
		container_config_file => '/etc/sysconfig/tomcat7',
		license_key => "${license_key}",
		generated_for_user => "${generated_for_user}",
		notification_target => Exec['beanstalk-tomcat7-restart'],
	}

	exec { 'beanstalk-tomcat7-restart':
		command => '/opt/elasticbeanstalk/bin/bluepill restart tomcat7',
		refreshonly => true,
	}
}
