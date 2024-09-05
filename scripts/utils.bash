podman_traccar() {
  podman --connection=traccar "$@"
}

ssh_traccar() {
  ssh \
    -o StrictHostKeychecking=no \
    ubuntu@traccar "$@"
}

scp_traccar() {
  local source="$1"
  local destination="$2"
  scp \
    -o StrictHostKeychecking=no \
    "$source" "ubuntu@traccar:$destination"
}
