class azkaban::web_server {
  file {'/tmp/azkaban-web-server-3.90.0.tar.gz':
    ensure        => present,
    source        => "puppet:///modules/azkaban/azkaban-web-server-3.90.0.tar.gz",
  }

  file {'/usr/lib/azkaban-web-server':
    ensure        => directory,
  }
  archive { '/tmp/azkaban-web-server.tar.gz':
    ensure          => present,
    source          => "/tmp/azkaban-web-server-3.90.0.tar.gz",
    extract         => true,
    extract_command => 'tar xfz %s --strip-components=1',
    extract_path    => '/usr/lib/azkaban-web-server',
    cleanup         => true,
    require         => [
      File['/tmp/azkaban-web-server-3.90.0.tar.gz'],
      File['/usr/lib/azkaban-web-server'],
    ],
  }
  file {'/etc/azkaban-web-server':
    ensure => directory,
  }
  file { 'azkaban-web-server-conf': 
    path => '/etc/azkaban-web-server/conf',
    target => '/usr/lib/azkaban-web-server/conf',
    ensure => link,
    force => true,
    require => [
      Archive['/tmp/azkaban-web-server.tar.gz'],
      File['/etc/azkaban-web-server'],
    ],
  }
  service { 'azkaban-server':
    ensure => running,
    start  => '(cd /usr/lib/azkaban-web-server; bin/start-web.sh)',
    stop   => '(cd /usr/lib/azkaban-web-server; bin/shutdown-web.sh)',
    require => File['azkaban-web-server-conf'],
  }

}
