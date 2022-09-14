
class node_with_roles($roles = hiera("bigtop::roles")) {
  
  define deploy_module($roles) {
    class { "${name}::deploy":
      roles => $roles,
    }
  }

  $modules = [
    "mysql_deploy",
    "azkaban",  
  ]

  # $modules.each |$key, $value| {
  #   notice($value)
  #   class { "${value}::deploy":
  #     roles => $roles,
  #   }
  # }
  # above equal following
  node_with_roles::deploy_module { $modules:
    roles => $roles,
  }

  # relate to Puppet Resource Collectors and Relationships and ordering
  # Here is very useful to change the stage puppet actually execution.
  # Todo, here's stage organization is not good, I will tune it tomorrow.
  Mysql::Db<||> -> Archive<||>
  
}
