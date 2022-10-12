## queen是用来生产模拟部署bigtop的项目模板，给一键式部署大数据组件提供样例，所有的样例，都运行在docker容器里，通过切换不同的分支来部署对应的功能

## 分支介绍
master分支是部署azkaban<br>
zk分支部署zookeeper<br>
hbase分支部署hbase集群， 依赖zk分支<br>
hbase-phoenix分支部署hbase-phoenix， 依赖zk分支<br>
ha-zk分支部署ha依赖的zookeeper<br>
ha分支部署hdfs ha手动模式（不依赖zookeeper)<br>
ha-auto分支部署ha auto (依赖zookeper，依赖ha-zk分支)<br>

## 如何使用
首先需要安装docker
```shell
yum install -y git yum-utils ruby java-1.8.0-openjdk-devel
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
systemctl start docker
```
clone queen的代码到本地,切换分支，部署相应的功能，然后
```shell
git clone https://github.com/vivostar/queen.git
cd queen
git checkout #切换到所需功能的分支
# 若不依赖zookeeper，就可以直接使用，若依赖zookeeper，相应处理后面会一一的介绍
./test_all.sh
```
