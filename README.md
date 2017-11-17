```
> docker pull isnit0/docker-kafka-arm

> docker run -d -p 2181:2181 isnit0/docker-kafka-arm zookeeper-server-start.sh config/zookeeper.properties  

> docker run -d -p 9092:9092 isnit0/docker-kafka-arm kafka-server-start.sh config/server.properties


> # To build locally
> docker build -t kafka-arm . 
```
