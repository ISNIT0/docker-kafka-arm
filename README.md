docker run -d -p 2181:2181 <IMAGE> zookeeper-server-start.sh zookeeper.properties
docker run -d -p 9092:9092 <IMAGE> kafka-server-start.sh config/server.properties
