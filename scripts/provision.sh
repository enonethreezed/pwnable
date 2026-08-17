#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/provision.sh [--debug] [--disable-vagrant] <up|destroy|reload> [vagrant arguments...]

Commands:
  up       Create and provision the lab
  destroy  Destroy the selected machines without prompting
  reload   Restart and reprovision the selected machines

Options:
  --debug  Enable Vagrant debug logging and save output under logs/
  --disable-vagrant  Disable the /vagrant synced folder for this run
EOF
}

debug=0
disable_vagrant=0
command=
vagrant_args=()

while (($# > 0)); do
  case "$1" in
    --debug)
      debug=1
      ;;
    --disable-vagrant)
      disable_vagrant=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    up|destroy|reload)
      if [[ -n "$command" ]]; then
        echo "Only one command may be specified" >&2
        usage >&2
        exit 2
      fi
      command=$1
      ;;
    *)
      if [[ -z "$command" ]]; then
        echo "A command is required before Vagrant arguments" >&2
        usage >&2
        exit 2
      fi
      vagrant_args+=("$1")
      ;;
  esac
  shift
done

if [[ -z "$command" ]]; then
  echo "A command is required" >&2
  usage >&2
  exit 2
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(dirname -- "$script_dir")
vagrant_env=()
if ((disable_vagrant)); then
  vagrant_env+=(PWNABLE_DISABLE_VAGRANT=1)
fi

if ((debug)); then
  logs_dir="$repo_dir/logs"
  mkdir -p -- "$logs_dir"
  timestamp=$(date +%Y%m%d-%H%M%S)
  log_file="$logs_dir/vagrant-${command}-${timestamp}.log"
  printf 'Vagrant debug log: %s\n' "$log_file"
fi

run_vagrant() {
  if ((debug)); then
    set +e
    env "${vagrant_env[@]}" VAGRANT_LOG=debug vagrant "$@" 2>&1 | tee -a -- "$log_file"
    status=${PIPESTATUS[0]}
    set -e
    return "$status"
  fi

  env "${vagrant_env[@]}" vagrant "$@"
}

case "$command" in
  up)
    run_vagrant up --provision "${vagrant_args[@]}"
    ;;
  destroy)
    run_vagrant destroy -f "${vagrant_args[@]}"
    ;;
  reload)
    run_vagrant halt -f "${vagrant_args[@]}"
    run_vagrant up --provision "${vagrant_args[@]}"
    ;;
esac
