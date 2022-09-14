class azkaban {
  class deploy ($roles) {

    if ('azkaban-db' in $roles) {
      include azkaban::db
    }
    
  }

  class db {
    file {'/tmp/azkaban-db-3.90.0.tar.gz':
      ensure        => present,
      source        => "puppet:///modules/azkaban/azkaban-db-3.90.0.tar.gz",
    }

    file {'/usr/lib/azkaban-db':
      ensure        => directory,
    }

    archive { '/tmp/azkaban-db.tar.gz':
      ensure          => present,
      source          => "/tmp/azkaban-db-3.90.0.tar.gz",
      extract         => true,
      extract_command => 'tar xfz %s --strip-components=1',
      extract_path    => '/usr/lib/azkaban-db',
      cleanup         => true,
      require         => [
        File['/tmp/azkaban-db-3.90.0.tar.gz'],
        File['/usr/lib/azkaban-db'],
      ],
    }

  }

}
