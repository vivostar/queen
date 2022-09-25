for MASTER in master{1..3} worker01; do 
  echo -e "\033[32mRemoving container ${MASTER}\033[0m"
  docker rm -f $MASTER
done

echo -e "\033[32mRemoving network bigtop\033[0m"
docker network rm bigtop

# echo -e "\033[32mRemoving image bigtop:3.1.0\033[0m"
# docker rmi bigtop:3.1.0

# echo -e "\033[32mRemoving image ambari-agent:2.7.5\033[0m"
# docker rmi ambari-agent:2.7.5