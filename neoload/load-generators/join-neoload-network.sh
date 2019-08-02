for container in $(docker ps -qf name=docker-lg*); do
	docker network connect neoload $container
done
