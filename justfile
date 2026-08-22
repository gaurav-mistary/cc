# Delegate all 'just cc <subcommand>' commands to the cc.just module
mod cc

# Published image name (override: just IMAGE=my.registry/cc docker-build)
IMAGE := "ghcr.io/gaurav-mistary/cc"

# Build the Docker image. Defaults to prod.
# Usage: just docker-build
#        just docker-build dev
docker-build env="prod" *docker_args:
    docker build --build-arg BUILD={{env}} --progress=plain -t {{IMAGE}}:latest -t cc:latest {{docker_args}} .

# Push local image to GHCR (requires: docker login ghcr.io)
# Usage: just docker-push
#        just docker-push v0.1.0
docker-push tag="latest":
    docker push {{IMAGE}}:{{tag}}

# Pull published image
# Usage: just docker-pull
docker-pull tag="latest":
    docker pull {{IMAGE}}:{{tag}}

# Run the Docker image as the cc-cli executable.
# Usage: just docker-run <volume_path> <cc-cli-args...>
# Example: just docker-run ~/stacks template create dockhand -o /output
docker-run mount_path *args:
    #!/usr/bin/env bash
    if [ ! -d "{{mount_path}}" ]; then
        echo "Error: Directory '{{mount_path}}' does not exist. A valid path is required."
        exit 1
    fi
    ABS_PATH=$(cd "{{mount_path}}" && pwd)

    ENV_ARGS=""
    if [ -f "{{justfile_directory()}}/.env" ]; then
        ENV_ARGS="--env-file {{justfile_directory()}}/.env"
    fi

    # Mount host dir → /output; cookiecutter pulls cc-templates branch over the network
    docker run --rm -it $ENV_ARGS \
        -v "$HOME/.ssh:/root/.ssh:ro" \
        -v "$HOME/.gitconfig:/root/.gitconfig:ro" \
        -v "$ABS_PATH:/output" \
        {{IMAGE}}:latest {{args}}

mod tc
