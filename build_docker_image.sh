docker build -t iccat/apps/catalogue:0.1.0 \
             --build-arg GITLAB_AUTH_TOKEN=$GITLAB_AUTH_TOKEN \
             --build-arg DOCKER_DB_USERNAME=$DOCKER_DB_USERNAME \
             --build-arg DOCKER_DB_PASSWORD=$DOCKER_DB_PASSWORD \
             --progress=plain \
             .
