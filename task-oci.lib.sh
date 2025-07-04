# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_2583e35-false}" && return 0; sourced_2583e35=true

. ./task.sh
. ./task-python.lib.sh

oci() {
  uv tool run --from oci-cli oci "$@"
}

oci_config() {
  uv tool run --from oci python3 -c 'import os, oci, json; print(json.dumps(oci.config.from_file(profile_name=os.environ.get("OCI_PROFILE", "DEFAULT")), indent=2))'
}

subcmd_oci() { # Run OCI CLI command.
  oci "$@"
}

subcmd_oci__config() { # Print OCI client config considering OCI_PROFILE env var.
  oci_config
}
