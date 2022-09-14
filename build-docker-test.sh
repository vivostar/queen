echo -e "\033[32mCreating network bigtop\033[0m"
docker network create --driver bridge bigtop

echo -e "\033[32mCreating docker cluster mysql\033[0m"
docker run -d -p 3306:3306 \
    --name mysql \
    --hostname mysql \
    --network bigtop \
    --privileged -e "container=docker" \
    -v `pwd`:/bigtop-home \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro bigtop/puppet:trunk-centos-7 /usr/sbin/init

echo -e "\033[32mCreating docker cluster master\033[0m"
docker run -d -p 8081:8081 \
    --name master \
    --hostname master \
    --network bigtop \
    --privileged -e "container=docker" \
    -v `pwd`:/bigtop-home \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro bigtop/puppet:trunk-centos-7 /usr/sbin/init

echo -e "\033[32mCreating docker cluster worker01\033[0m"
docker run -d \
    --name worker01 \
    --hostname worker01 \
    --network bigtop \
    --privileged -e "container=docker" \
    -v `pwd`:/bigtop-home \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro bigtop/puppet:trunk-centos-7 /usr/sbin/init

echo -e "\033[32mCreating docker cluster worker02\033[0m"
docker run -d \
    --name worker02 \
    --hostname worker02 \
    --network bigtop \
    --privileged -e "container=docker" \
    -v `pwd`:/bigtop-home \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro bigtop/puppet:trunk-centos-7 /usr/sbin/init

# echo -e "\033[32mCreating docker cluster hue\033[0m"
# docker run -d --name hue -p 8888:8888 --hostname hue --network bigtop --privileged -e "container=docker" -v /sys/fs/cgroup:/sys/fs/cgroup:ro hue:4.10.1

echo -e "\033[32mConfiguring hosts file\033[0m"
MYSQL_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mysql`
MASTER_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' master`
WORKER01_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' worker01`
WORKER02_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' worker02`
docker exec master bash -c "echo '$WORKER01_IP      worker01' >> /etc/hosts"
docker exec master bash -c "echo '$WORKER02_IP      worker02' >> /etc/hosts"
docker exec master bash -c "echo '$MYSQL_IP      mysql' >> /etc/hosts"

docker exec worker01 bash -c "echo '$MASTER_IP      master' >> /etc/hosts"
docker exec worker01 bash -c "echo '$WORKER02_IP      worker02' >> /etc/hosts"
docker exec worker01 bash -c "echo '$MYSQL_IP      mysql' >> /etc/hosts"

docker exec worker02 bash -c "echo '$MASTER_IP      master' >> /etc/hosts"
docker exec worker02 bash -c "echo '$WORKER01_IP      worker01' >> /etc/hosts"
docker exec worker02 bash -c "echo '$MYSQL_IP      mysql' >> /etc/hosts"

# echo -e "\033[32mConfiguring hue hosts file\033[0m"
# docker exec --user root hue bash -c "echo '$MASTER_IP      master' >> /etc/hosts"
# docker exec --user root hue bash -c "echo '$WORKER01_IP      worker01' >> /etc/hosts"
# docker exec --user root hue bash -c "echo '$WORKER02_IP      worker02' >> /etc/hosts"

echo -e "\033[32mStarting deploy bigtop cluster mysql\033[0m"
docker exec mysql bash -c \
    "puppet apply --detailed-exitcodes --parser future --hiera_config=/bigtop-home/bigtop-mysql/hiera.yaml --modulepath=/bigtop-home/bigtop-mysql/modules:/etc/puppet/modules:/usr/share/puppet/modules:/etc/puppetlabs/code/modules:/etc/puppet/code/modules /bigtop-home/bigtop-mysql/manifests"

echo -e "\033[32mStarting deploy bigtop cluster worker01\033[0m"
docker exec worker01 bash -c \
    "puppet apply --detailed-exitcodes --parser future --hiera_config=/bigtop-home/bigtop-main/hiera.yaml --modulepath=/bigtop-home/bigtop-main/modules:/etc/puppet/modules:/usr/share/puppet/modules:/etc/puppetlabs/code/modules:/etc/puppet/code/modules /bigtop-home/bigtop-main/manifests"

echo -e "\033[32mStarting deploy bigtop cluster worker02\033[0m"
docker exec worker02 bash -c \
    "puppet apply --detailed-exitcodes --parser future --hiera_config=/bigtop-home/bigtop-main/hiera.yaml --modulepath=/bigtop-home/bigtop-main/modules:/etc/puppet/modules:/usr/share/puppet/modules:/etc/puppetlabs/code/modules:/etc/puppet/code/modules /bigtop-home/bigtop-main/manifests"

echo -e "\033[32mStarting deploy bigtop cluster master\033[0m"
docker exec master bash -c \
    "puppet apply --detailed-exitcodes --parser future --hiera_config=/bigtop-home/bigtop-main/hiera.yaml --modulepath=/bigtop-home/bigtop-main/modules:/etc/puppet/modules:/usr/share/puppet/modules:/etc/puppetlabs/code/modules:/etc/puppet/code/modules /bigtop-home/bigtop-main/manifests"
