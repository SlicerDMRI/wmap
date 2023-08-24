#!/bin/bash

usage()
{
  echo "usage: $(basename $0) [-h] [in_dirname] [out_dirname]"
  echo
  echo "Subsample a tractogram by randmonly selecting a subset of streamlines using WMA. Selects 500000 streamlines."
  echo
  echo "positional arguments:"
  echo "  in_dirname    Input dirname"
  echo "  out_dirname   Output dirname"
  echo
  echo "optional arguments:"
  echo "  -h, --help  show this help message and exit"
  1>&2; exit 1;
}

# Parse input arguments
args=""

while (( "$#" )); do
  case "$1" in
    "-h"|"--help")
      usage
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      usage
      ;;
    *) # preserve positional arguments
      args="$args $1"
      shift
      ;;
  esac
done

# Set positional arguments in their proper place
eval set -- "$args"

if test "${args[@]}" = "" || [ "$#" -lt 2 ]; then
  echo "Missing arguments."
  usage
fi

in_dirname=$1
out_dirname=$2

process_count=$(lscpu -b -p=Core,Socket | grep -v '^#' | sort -u | wc -l)

strml_count=500000

wm_preprocess_all.py \
  ${in_dirname} \
  ${out_dirname} \
  -f ${strml_count} \
  -j ${process_count} \
  -retaindata

