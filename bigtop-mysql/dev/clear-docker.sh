echo -e "\033[32mRemoving container master\033[0m"
docker rm -f master

echo -e "\033[32mRemoving image bigtop:3.1.0\033[0m"
docker rmi bigtop/puppet:b-centos-7

# echo -e "\033[32mRemoving image ambari-agent:2.7.5\033[0m"
# docker rmi ambari-agent:2.7.5