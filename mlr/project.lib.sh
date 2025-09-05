# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_32308aa-false}" && return 0; sourced_32308aa=true

. ./miller.lib.sh

task_foo() {
  mlr --icsv --ocsv put -f process_ledger.mlr ledger.csv
}
