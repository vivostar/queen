echo -e "\033[32mCreating network bigtop\033[0m"
docker network create --driver bridge bigtop

echo -e "\033[32mCreating docker cluster mysql\033[0m"
docker run -d \
    --name hmaster \
    --hostname hmaster \
    --network bigtop \
    --privileged -e "container=docker" \
    -v `pwd`:/bigtop-home \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro bigtop/puppet:trunk-centos-7 /usr/sbin/init

echo -e "\033[32mCreating docker cluster master\033[0m"
docker run -d \
    --name rgserver01 \
    --hostname rgserver01 \
    --network bigtop \
    --privileged -e "container=docker" \
    -v `pwd`:/bigtop-home \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro bigtop/puppet:trunk-centos-7 /usr/sbin/init

echo -e "\033[32mCreating docker cluster worker01\033[0m"
docker run -d \
    --name rgserver02 \
    --hostname rgserver02 \
    --network bigtop \
    --privileged -e "container=docker" \
    -v `pwd`:/bigtop-home \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro bigtop/puppet:trunk-centos-7 /usr/sbin/init

echo -e "\033[32mCreating docker cluster worker02\033[0m"
docker run -d \
    --name hadoop \
    --hostname hadoop \
    --network bigtop \
    --privileged -e "container=docker" \
    -v `pwd`:/bigtop-home \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro bigtop/puppet:trunk-centos-7 /usr/sbin/init

# echo -e "\033[32mCreating docker cluster hue\033[0m"
# docker run -d --name hue -p 8888:8888 --hostname hue --network bigtop --privileged -e "container=docker" -v /sys/fs/cgroup:/sys/fs/cgroup:ro hue:4.10.1

echo -e "\033[32mConfiguring hosts file\033[0m"
HMASTER_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' hmaster`
RGSERVER01_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' rgserver01`
RGSERVER02_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' rgserver02`
HADOOP_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' hadoop`
docker exec hmaster bash -c "echo '$RGSERVER01_IP      rgserver01' >> /etc/hosts"
docker exec hmaster bash -c "echo '$RGSERVER02_IP      rgserver02' >> /etc/hosts"
docker exec hmaster bash -c "echo '$HADOOP_IP      hadoop' >> /etc/hosts"

docker exec rgserver01 bash -c "echo '$HMASTER_IP      hmaster' >> /etc/hosts"
docker exec rgserver01 bash -c "echo '$RGSERVER02_IP      rgserver02' >> /etc/hosts"
docker exec rgserver01 bash -c "echo '$HADOOP_IP      hadoop' >> /etc/hosts"

docker exec rgserver02 bash -c "echo '$HMASTER_IP      hmaster' >> /etc/hosts"
docker exec rgserver02 bash -c "echo '$RGSERVER01_IP      rgserver01' >> /etc/hosts"
docker exec rgserver02 bash -c "echo '$HADOOP_IP      hadoop' >> /etc/hosts"

docker exec hadoop bash -c "echo '$HMASTER_IP      hmaster' >> /etc/hosts"
docker exec hadoop bash -c "echo '$RGSERVER01_IP      rgserver01' >> /etc/hosts"
docker exec hadoop bash -c "echo '$RGSERVER02_IP      rgserver02' >> /etc/hosts"

# echo -e "\033[32mConfiguring hue hosts file\033[0m"
# docker exec --user root hue bash -c "echo '$MASTER_IP      master' >> /etc/hosts"
# docker exec --user root hue bash -c "echo '$WORKER01_IP      worker01' >> /etc/hosts"
# docker exec --user root hue bash -c "echo '$WORKER02_IP      worker02' >> /etc/hosts"

echo -e "\033[32mStarting deploy bigtop cluster hmaster\033[0m"
docker exec hmaster bash -c \
    "puppet apply --detailed-exitcodes --parser future --hiera_config=/bigtop-home/bigtop-main/hiera.yaml --modulepath=/bigtop-home/bigtop-main/modules:/etc/puppet/modules:/usr/share/puppet/modules:/etc/puppetlabs/code/modules:/etc/puppet/code/modules /bigtop-home/bigtop-main/manifests"


echo -e "\033[32mStarting deploy bigtop cluster rgserver01\033[0m"
docker exec rgserver01 bash -c \
    "puppet apply --detailed-exitcodes --parser future --hiera_config=/bigtop-home/bigtop-main/hiera.yaml --modulepath=/bigtop-home/bigtop-main/modules:/etc/puppet/modules:/usr/share/puppet/modules:/etc/puppetlabs/code/modules:/etc/puppet/code/modules /bigtop-home/bigtop-main/manifests"

echo -e "\033[32mStarting deploy bigtop cluster rgserver02\033[0m"
docker exec rgserver02 bash -c \
    "puppet apply --detailed-exitcodes --parser future --hiera_config=/bigtop-home/bigtop-main/hiera.yaml --modulepath=/bigtop-home/bigtop-main/modules:/etc/puppet/modules:/usr/share/puppet/modules:/etc/puppetlabs/code/modules:/etc/puppet/code/modules /bigtop-home/bigtop-main/manifests"

echo -e "\033[32mStarting deploy bigtop cluster hadoop\033[0m"
docker exec hadoop bash -c \
    "puppet apply --detailed-exitcodes --parser future --hiera_config=/bigtop-home/bigtop-main/hiera.yaml --modulepath=/bigtop-home/bigtop-main/modules:/etc/puppet/modules:/usr/share/puppet/modules:/etc/puppetlabs/code/modules:/etc/puppet/code/modules /bigtop-home/bigtop-main/manifests"
