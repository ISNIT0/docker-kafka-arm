```
Docker build -t kafka-arm . 

docker run -d -p 2181:2181 kafka-arm zookeeper-server-start.sh config/zookeeper.properties  

docker run -d -p 9092:9092 kafka-arm kafka-server-start.sh config/server.properties
```