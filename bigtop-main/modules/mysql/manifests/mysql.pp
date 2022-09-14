class mysql_deploy {
  include mysql::server
  
  create_resources(yumrepo, hiera('yumrepo', {}))
  
  Yumrepo['repo.mysql.com'] -> Anchor['mysql::server::start']
  Yumrepo['repo.mysql.com'] -> Package['mysql_client']
  
  create_resources(mysql::db, hiera('mysql::server::db', {}))
}
