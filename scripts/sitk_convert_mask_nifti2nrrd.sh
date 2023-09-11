#!/bin/bash

usage()
{
  ./sitk_convert_mask_nifti2nrrd.py -h
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

in_nifti_fname=$1
out_nrrd_fname=$2

python ./sitk_convert_mask_nifti2nrrd.py \
  ${in_nifti_fname} \
  ${out_nrrd_fname}

