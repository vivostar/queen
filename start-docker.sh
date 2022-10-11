for MASTER in worker01 master3 master1 master2; do 
  echo -e "\033[32mStarting deploy bigtop cluster ${MASTER}\033[0m"
  docker exec $MASTER bash -c \
    "yum install -y rsync openssh-clients openssh-server"
  docker exec $MASTER bash -c \
    "systemctl start sshd"
  docker exec $MASTER bash -c \
    "puppet apply --detailed-exitcodes --parser future --hiera_config=/bigtop-home/bigtop-main/hiera.yaml --modulepath=/bigtop-home/bigtop-main/modules:/etc/puppet/modules:/usr/share/puppet/modules:/etc/puppetlabs/code/modules:/etc/puppet/code/modules /bigtop-home/bigtop-main/manifests"
done
