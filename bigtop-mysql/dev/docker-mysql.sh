# echo -e "\033[32mBuilding image bigtop:3.1.0\033[0m"
# docker build -t bigtop:3.1.0.

echo -e "\033[32mCreating network bigtop\033[0m"
docker network create --driver bridge bigtop

echo -e "\033[32mCreating docker cluster master\033[0m"
docker run -d -p 3306:3306 --name master --hostname master --network bigtop --privileged -e "container=docker" -v /sys/fs/cgroup:/sys/fs/cgroup:ro bigtop/puppet:b-centos-7 /usr/sbin/init
docker exec master bash -c "puppet apply --detailed-exitcodes --parser future --hiera_config=/bigtop-mysql/hiera.yaml --modulepath=/bigtop-mysql/modules:/etc/puppet/modules:/usr/share/puppet/modules:/etc/puppetlabs/code/modules:/etc/puppet/code/modules /bigtop-mysql/manifests"
