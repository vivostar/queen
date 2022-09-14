

class mysql_deploy {
  class deploy ($roles) {

    if ('mysql-server' in $roles) {
      include mysql_deploy::mysql_server
    }
    
  }

  class mysql_server{
    include mysql::server
    
    create_resources(yumrepo, hiera('yumrepo', {}))
    
    Yumrepo['repo.mysql.com'] -> Anchor['mysql::server::start']
    Yumrepo['repo.mysql.com'] -> Package['mysql_client']
    
    create_resources(mysql::db, hiera('mysql::server::db', {}))

  }
}

