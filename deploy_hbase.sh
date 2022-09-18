echo -e "\033[32mStarting deploy bigtop cluster hmaster\033[0m"
docker exec hmaster bash -c \
    "puppet apply --detailed-exitcodes --parser future --hiera_config=/bigtop-home/bigtop-main/hiera.yaml --modulepath=/bigtop-home/bigtop-main/modules:/etc/puppet/modules:/usr/share/puppet/modules:/etc/puppetlabs/code/modules:/etc/puppet/code/modules /bigtop-home/bigtop-main/manifests"


echo -e "\033[32mStarting deploy bigtop cluster rgserver01\033[0m"
docker exec rgserver01 bash -c \
    "puppet apply --detailed-exitcodes --parser future --hiera_config=/bigtop-home/bigtop-main/hiera.yaml --modulepath=/bigtop-home/bigtop-main/modules:/etc/puppet/modules:/usr/share/puppet/modules:/etc/puppetlabs/code/modules:/etc/puppet/code/modules /bigtop-home/bigtop-main/manifests"

echo -e "\033[32mStarting deploy bigtop cluster rgserver02\033[0m"
docker exec rgserver02 bash -c \
    "puppet apply --detailed-exitcodes --parser future --hiera_config=/bigtop-home/bigtop-main/hiera.yaml --modulepath=/bigtop-home/bigtop-main/modules:/etc/puppet/modules:/usr/share/puppet/modules:/etc/puppetlabs/code/modules:/etc/puppet/code/modules /bigtop-home/bigtop-main/manifests"
