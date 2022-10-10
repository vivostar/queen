echo -e "\033[32mCreating network bigtop\033[0m"
docker network create --driver bridge bigtop

for MASTER in master{1..3} worker01; do 
  echo -e "\033[32mCreating docker cluster ${MASTER}\033[0m"
  docker run -d \
      --name $MASTER \
      --hostname $MASTER \
      --network bigtop \
      --privileged -e "container=docker" \
      -v `pwd`:/bigtop-home \
      -v /sys/fs/cgroup:/sys/fs/cgroup:ro bigtop/puppet:trunk-centos-7 /usr/sbin/init;
done 

echo -e "\033[32mConfiguring hosts file\033[0m"
MASTER1_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' master1`
MASTER2_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' master2`
MASTER3_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' master3`
WORKER01_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' worker01`

for MASTER in master{1..3} worker01; do 
  docker exec $MASTER bash -c "echo '$MASTER1_IP      master1' >> /etc/hosts"
  docker exec $MASTER bash -c "echo '$MASTER2_IP      master2' >> /etc/hosts"
  docker exec $MASTER bash -c "echo '$MASTER3_IP      master3' >> /etc/hosts"
  docker exec $MASTER bash -c "echo '$WORKER01_IP    worker01' >> /etc/hosts"
done

for MASTER in worker01 master3 master1 master2; do 
  echo -e "\033[32mStarting deploy bigtop cluster ${MASTER}\033[0m"
  docker exec $MASTER bash -c \
    "yum install -y rsync openssh-clients openssh-server"
  docker exec $MASTER bash -c \
    "systemctl start sshd"
  docker exec $MASTER bash -c \
    "puppet apply --detailed-exitcodes --parser future --hiera_config=/bigtop-home/bigtop-main/hiera.yaml --modulepath=/bigtop-home/bigtop-main/modules:/etc/puppet/modules:/usr/share/puppet/modules:/etc/puppetlabs/code/modules:/etc/puppet/code/modules /bigtop-home/bigtop-main/manifests"
done
