#!/bin/bash

usage()
{
  echo "usage: $(basename $0) [-h] [in_bids_dirname] [out_dirname] [fs_license_fname] [qsiprep_singularity_fname] [work_dirname]"
  echo
  echo "Preprocess dMRI data using QSIprep."
  echo
  echo "positional arguments:"
  echo "  in_bids_dirname             Input BIDS-compliant, participant data dirname"
  echo "  out_dirname                 Output dirname"
  echo "  fs_license_fname            FreeSurfer license filename (*.txt)"
  echo "  qsiprep_singularity_fname   QSIprep singularity filename (*.sif)"
  echo "  work_dirname                Work dirname"
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

if test "${args[@]}" = "" || [ "$#" -lt 5 ]; then
  echo "Missing arguments."
  usage
fi

in_bids_dirname=$1
out_dirname=$2
fs_license_fname=$3
qsiprep_singularity_fname=$4
work_dirname=$5

mapped_fs_license_fname=/opt/freesurfer/license.txt 

output_resolution=1  ### Check this

#export SINGULARITY_BIND="/mnt/data/irb-2020P000573-2021P003667/out/psz006_spin_dwi_reproin/Investigators/JayminSZPain10820/:/data:ro"

singularity run --cleanenv \
  --bind ${in_bids_dirname} \
  --bind ${out_dirname} \
  --bind ${fs_license_fname}:${mapped_fs_license_fname} \
  --bind ${work_dirname} \
  ${qsiprep_singularity_fname} \
  ${in_bids_dirname} \
  ${out_dirname} \
  participant \
  --output-resolution ${output_resolution} \
  --fs-license-file ${mapped_fs_license_fname} \
  --w ${work_dirname} \
  --skip-bids-validation

