#!/bin/bash

usage()
{
  echo "usage: $(basename $0) [-h] [in_tractography_fname] [atlas_dirname] [out_dirname]"
  echo
  echo "Identify white matter bundles using WMA and 3D Slicer."
  echo
  echo "positional arguments:"
  echo "  in_tractography_fname   Input tractography filename (*.vtk|*.vtp)"
  echo "  atlas_dirname           Atlas dirname"
  echo "  out_dirname             Output dirname"
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

in_tractography_fname=$1
atlas_dirname=$2
out_dirname=$3

slicer_exec_fname=/opt/Slicer-5.2.2-linux-amd64/Slicer
slicer_fibertractmeas_exec_fname=/opt/Slicer-5.2.2-linux-amd64/NA-MIC/Extensions-31382/SlicerDMRI/lib/Slicer-5.2/cli-modules/FiberTractMeasurements

export_clusterwise_diffusion_tensor_data=1
clean_mode=2  # maximal removal (remove intermediate files)
process_count=$(lscpu -b -p=Core,Socket | grep -v '^#' | sort -u | wc -l)

wm_apply_ORG_atlas_to_subject.sh \
  -i ${in_tractography_fname} \
  -o ${out_dirname} \
  -a ${atlas_dirname} \
  -s ${slicer_exec_fname} \
  -d ${export_clusterwise_diffusion_tensor_data} \
  -m ${slicer_fibertractmeas_exec_fname} \
  -c ${clean_mode} \
  -n ${process_count}

