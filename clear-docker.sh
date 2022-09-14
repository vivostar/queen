echo -e "\033[32mRemoving container mysql\033[0m"
docker rm -f mysql

echo -e "\033[32mRemoving container master\033[0m"
docker rm -f master

echo -e "\033[32mRemoving container worker01\033[0m"
docker rm -f worker01

echo -e "\033[32mRemoving container worker02\033[0m"
docker rm -f worker02

echo -e "\033[32mRemoving network bigtop\033[0m"
docker network rm bigtop

# echo -e "\033[32mRemoving image bigtop:3.1.0\033[0m"
# docker rmi bigtop:3.1.0

# echo -e "\033[32mRemoving image ambari-agent:2.7.5\033[0m"
# docker rmi ambari-agent:2.7.5