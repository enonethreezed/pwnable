#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/provision.sh [--debug] <up|destroy|reload> [vagrant arguments...]

Commands:
  up       Create and provision the lab
  destroy  Destroy the selected machines without prompting
  reload   Restart and reprovision the selected machines

Options:
  --debug  Enable Vagrant debug logging and save output under logs/
EOF
}

debug=0
command=
vagrant_args=()

while (($# > 0)); do
  case "$1" in
    --debug)
      debug=1
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

case "$command" in
  up)
    vagrant_command=(up --provision "${vagrant_args[@]}")
    ;;
  destroy)
    vagrant_command=(destroy -f "${vagrant_args[@]}")
    ;;
  reload)
    vagrant_command=(reload --provision "${vagrant_args[@]}")
    ;;
esac

script_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(dirname -- "$script_dir")

if ((debug)); then
  logs_dir="$repo_dir/logs"
  mkdir -p -- "$logs_dir"
  timestamp=$(date +%Y%m%d-%H%M%S)
  log_file="$logs_dir/vagrant-${command}-${timestamp}.log"
  printf 'Vagrant debug log: %s\n' "$log_file"
  env VAGRANT_LOG=debug vagrant "${vagrant_command[@]}" 2>&1 | tee -- "$log_file"
  exit "${PIPESTATUS[0]}"
fi

exec vagrant "${vagrant_command[@]}"
