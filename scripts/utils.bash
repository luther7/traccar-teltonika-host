_terraform() {
  terraform -chdir=terraform "$@"
}

_podman() {
  podman --connection=traccar "$@"
}

_ssh() {
  ssh -o StrictHostKeychecking=no ubuntu@traccar "$@"
}

_scp() {
  local source="$1"
  local destination="$2"
  scp -o StrictHostKeychecking=no "$source" "ubuntu@traccar:$destination"
}
