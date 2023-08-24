#!/bin/bash

usage()
{
  echo "usage: $(basename $0) [-h] [in_nifti_fname] [in_bval_fname] [in_bvec_fname] [out_nrrd_fname]"
  echo
  echo "Convert a NIfTI data format file to NRRD using 3D Slicer."
  echo
  echo "positional arguments:"
  echo "  in_nifti_fname   Input NIfTI filename (*.nii.gz)"
  echo "  in_bval_fname    Input bval filename (*.bval)"
  echo "  in_bvec_fname    Input bvec filename (*.bvec)"
  echo "  out_nrrd_fname   Output NRRD filename (*.nrrd)"
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

if test "${args[@]}" = "" || [ "$#" -lt 4 ]; then
  echo "Missing arguments."
  usage
fi

in_nifti_fname=$1
in_bval_fname=$2
in_bvec_fname=$3
out_nrrd_fname=$4

slicer_exec_fname=/opt/Slicer-5.2.2-linux-amd64/Slicer
slicer_dwiconvert_exec_fname=/opt/Slicer-5.2.2-linux-amd64/lib/Slicer-5.2/cli-modules/DWIConvert

small_gradient_thr=0.2

${slicer_exec_fname} \
  --launch ${slicer_dwiconvert_exec_fname} \
  --conversionMode FSLToNrrd \
  --fslNIFTIFile ${in_nifti_fname} \
  --inputBValues ${in_bval_fname} \
  --inputBVectors ${in_bvec_fname} \
  --outputVolume ${out_nrrd_fname} \
  --smallGradientThreshold ${small_gradient_thr} \
  --transposeInputBVectors \
  --allowLossyConversion

