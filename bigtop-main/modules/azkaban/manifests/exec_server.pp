class azkaban::exec_server(
  $azkaben_name = 'Test',
  $azkaben_label = 'My Local Azkaban',
  $azkaben_timezone = 'Asia/Shanghai',
  $azkaban_webserver_host = 'localhost',
  $azkaban_webserver_port = 8081,
  $mysql_port = 3306,
  $mysql_host = 'localhost',
  $mysql_database = 'azkaban',
  $mysql_user = 'azkaban',
  $mysql_password = 'azkaban',
) {
  file {'/tmp/azkaban-exec-server-3.90.0.tar.gz':
    ensure        => present,
    source        => "puppet:///modules/azkaban/azkaban-exec-server-3.90.0.tar.gz",
  }

  file {'/usr/lib/azkaban-exec-server':
    ensure        => directory,
  }
  archive { '/tmp/azkaban-exec-server.tar.gz':
    ensure          => present,
    source          => "/tmp/azkaban-exec-server-3.90.0.tar.gz",
    extract         => true,
    extract_command => 'tar xfz %s --strip-components=1',
    extract_path    => '/usr/lib/azkaban-exec-server',
    cleanup         => true,
    require         => [
      File['/tmp/azkaban-exec-server-3.90.0.tar.gz'],
      File['/usr/lib/azkaban-exec-server'],
    ],
  }
  file {'/etc/azkaban-exec-server':
    ensure => directory,
  }
  file { 'azkaban-exec-server-conf': 
    path => '/etc/azkaban-exec-server/conf',
    target => '/usr/lib/azkaban-exec-server/conf',
    ensure => link,
    force => true,
    require => [
      Archive['/tmp/azkaban-exec-server.tar.gz'],
      File['/etc/azkaban-exec-server'],
    ],
  }

  file { 'exec-conf-properties':
    path    => '/etc/azkaban-exec-server/conf/azkaban.properties',
    content => template('azkaban/exec-server/azkaban.properties'),
    require => File['azkaban-exec-server-conf'],
  }


  service { 'azkaban-server':
    ensure => running,
    start  => '(cd /usr/lib/azkaban-exec-server; bin/start-exec.sh)',
    stop   => '(cd /usr/lib/azkaban-exec-server; bin/shutdown-exec.sh)',
    require => File['exec-conf-properties'],
  }

}
