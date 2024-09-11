_podman() {
  podman --connection=traccar "$@"
}

_ssh() {
  ssh -o StrictHostKeychecking=no ubuntu@traccar "$@"
}
