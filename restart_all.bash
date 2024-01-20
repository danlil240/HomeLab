#!/bin/bash
ROOT_DIR=/home/daniel/projects/docker

docker stop $(docker ps -a -q) 2>/dev/null

docker rm $(docker ps -a -q) 2>/dev/null

docker network rm --force frontend

docker network create frontend \
  --driver=bridge \
  --subnet=10.5.0.0/24 \
  --gateway=10.5.0.1


# Array of Docker Compose directories and their corresponding container names
compose_directories=("cloudflare-tunnel" "homeassistant" "pihole" "portainer" "nginx-proxy-manager" "wetty")
container_names=("cloudflared-tunnel" "homeassistant" "pihole" "portainer" "npm" "wetty")

# Function to check if a container is running
is_container_running() {
    local container_name="$1"
    docker inspect -f '{{.State.Running}}' "$container_name" 2>/dev/null
}

# Iterate through the Docker Compose directories
for ((i=0; i<${#compose_directories[@]}; i++)); do
    compose_directory="${compose_directories[i]}"
    container_name="${container_names[i]}"

    # Run Docker Compose for the current directory
    cd "$ROOT_DIR/$compose_directory" && docker compose up -d

    # Wait for the container to be running*
    while ! is_container_running "$container_name"; do
        echo "Waiting for the $compose_directory container to start..."
        sleep 5
    done

    echo "The $compose_directory container is running. Proceeding to the next Docker Compose file."
done

echo "All Docker Compose files executed successfully."
