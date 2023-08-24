#!/bin/bash

usage()
{
  echo "usage: $(basename $0) [-h] [in_dmri_fname] [in_mask_fname] [out_tractography_fname]"
  echo
  echo "Compute UKF tractography using UKFTractography and 3D Slicer."
  echo
  echo "positional arguments:"
  echo "  in_dmri_fname            Input dMRI filename (*.nrrd)"
  echo "  in_mask_fname            Input brainmask filename (*.nrrd)"
  echo "  out_tractography_fname   Output tractography filename (*.vtk|*.vtp)"
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

if test "${args[@]}" = "" || [ "$#" -lt 3 ]; then
  echo "Missing arguments."
  usage
fi

in_dmri_fname=$1
in_mask_fname=$2
out_tractography_fname=$3

slicer_exec_fname=/opt/Slicer-5.2.2-linux-amd64/Slicer
slicer_ukftractography_exec_fname=/opt/Slicer-5.2.2-linux-amd64/NA-MIC/Extensions-31382/UKFTractography/lib/Slicer-5.2/cli-modules/UKFTractography

seeding_thr=0.1
stopping_fa=0.08
stopping_thr=0.06
tensor_count=2
seeds_pv=1

process_count=$(lscpu -b -p=Core,Socket | grep -v '^#' | sort -u | wc -l)

${slicer_exec_fname} \
  --launch ${slicer_ukftractography_exec_fname} \
  --dwiFile ${in_dmri_fname} \
  --maskFile ${in_mask_fname} \
  --tracts ${out_tractography_fname} \
  --numThreads ${process_count} \
  --seedingThreshold ${seeding_thr} \
  --stoppingFA ${stopping_fa} \
  --stoppingThreshold ${stopping_thr} \
  --numTensor ${tensor_count} \
  --seedsPerVoxel ${seeds_pv} \
  --recordFA \
  --recordTrace \
  --freeWater \
  --recordFreeWater

