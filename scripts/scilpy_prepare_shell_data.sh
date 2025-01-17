#!/bin/bash

usage()
{
  echo "usage: $(basename $0) [-h] [in_qsiprep_dirname] [out_dirname] [work_dirname] [in_nifti_fname] [in_bval_fname] [in_bvec_fname] [scilus_singularity_fname]"
  echo
  echo "Prepare preprocessed dMRI shell data for UKF tractography using SCILPY."
  echo
  echo "positional arguments:"
  echo "  in_qsiprep_dirname         Input data dirname"
  echo "  out_dirname                Output dirname"
  echo "  work_dirname               Singularity work dirname"
  echo "  in_nifti_fname             Input NIfTI filename (*.nii.gz)"
  echo "  in_bval_fname              Input bval filename (*.bval)"
  echo "  in_bvec_fname              Input bvec filename (*.bvec)"
  echo "  scilus_singularity_fname   Scilus singularity filename (*.sif)"
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

if test "${args[@]}" = "" || [ "$#" -lt 7 ]; then
  echo "Missing arguments."
  usage
fi

in_qsiprep_dirname=$1
out_dirname=$2
work_dirname=$3
in_nifti_fname=$4
in_bval_fname=$5
in_bvec_fname=$6
scilus_singularity_fname=$7

dash="-"
ext_sep="."
bval_ext="bval"
bvec_ext="bvec"
nii_gz_ext="nii.gz"
underscore="_"

fourd_label="4d"
bval_label="b"
b0_mean_label="b0_mean"


function compose_filename_from_basename() {
  local in_fname="$1"
  local out_dirname="$2"
  local label="$3"
  local ext="$4"

  # Get the basename without external command by stripping out longest leading
  # match of anything followed by /
  local base_fname=${in_fname##*/}

  # Strip all extensions by stripping out longest trailing match of dot
  # followed by anything
  local root_fname=${base_fname%%.*}

  echo ${out_dirname}/${root_fname}${underscore}${label}${ext_sep}${ext}
}

# Extract mean b0

# https://scilpy.readthedocs.io/en/stable/scripts/scil_extract_b0.html

b0_thr=20

out_b0_mean_fname=$(compose_filename_from_basename ${in_nifti_fname} ${out_dirname} ${b0_mean_label} ${nii_gz_ext})

singularity exec \
  --bind ${in_qsiprep_dirname} \
  --bind ${out_dirname} \
  --bind ${work_dirname} \
  --workdir ${work_dirname} \
  ${scilus_singularity_fname} \
  scil_extract_b0.py \
  ${in_nifti_fname} \
  ${in_bval_fname} \
  ${in_bvec_fname} \
  ${out_b0_mean_fname} \
  --b0_thr ${b0_thr} \
  --mean

echo "Mean b0 written to:"
echo ${out_b0_mean_fname}

# Expand dimension to mean b0 data

out_b0_mean_4d_nifti_fname=$(compose_filename_from_basename ${out_b0_mean_fname} ${out_dirname} ${fourd_label} ${nii_gz_ext})

python expand_dims_nifti.py \
  ${out_b0_mean_fname} \
  ${out_b0_mean_4d_nifti_fname}

echo "Mean b0 as 4D volume written to:"
echo ${out_b0_mean_4d_nifti_fname}

# Create empty b0 bval and bvec

out_b0_mean_4d_bval_fname=$(compose_filename_from_basename ${out_b0_mean_fname} ${out_dirname} ${fourd_label} ${bval_ext})
out_b0_mean_4d_bvec_fname=$(compose_filename_from_basename ${out_b0_mean_fname} ${out_dirname} ${fourd_label} ${bvec_ext})

python create_mean_b0_bval_bvec_files.py \
  ${out_b0_mean_4d_bval_fname} \
  ${out_b0_mean_4d_bvec_fname}

echo "Mean b0 bval and bvec files written to:"
echo ${out_b0_mean_4d_bval_fname}
echo ${out_b0_mean_4d_bvec_fname}

# Extract b-value

# https://scilpy.readthedocs.io/en/stable/scripts/scil_extract_dwi_shell.html

bval=3000
bval_tol=100

bval_shell_label=${bval_label}${bval}

out_bval_shell_nifti_fname=$(compose_filename_from_basename ${in_nifti_fname} ${out_dirname} ${bval_shell_label} ${nii_gz_ext})
out_bval_shell_bval_fname=$(compose_filename_from_basename ${in_nifti_fname} ${out_dirname} ${bval_shell_label} ${bval_ext})
out_bval_shell_bvec_fname=$(compose_filename_from_basename ${in_nifti_fname} ${out_dirname} ${bval_shell_label} ${bvec_ext})

singularity exec \
  --bind ${in_qsiprep_dirname} \
  --bind ${out_dirname} \
  --bind ${work_dirname} \
  --workdir ${work_dirname} \
  ${scilus_singularity_fname} \
  scil_extract_dwi_shell.py \
  ${in_nifti_fname} \
  ${in_bval_fname} \
  ${in_bvec_fname} \
  ${bval} \
  ${out_bval_shell_nifti_fname} \
  ${out_bval_shell_bval_fname} \
  ${out_bval_shell_bvec_fname} \
  --tolerance ${bval_tol}

echo "b${bval} files written to:"
echo ${out_bval_shell_nifti_fname}
echo ${out_bval_shell_bval_fname}
echo ${out_bval_shell_bvec_fname}

# Concatenate mean b0 and b-value data

# https://scilpy.readthedocs.io/en/stable/scripts/scil_concatenate_dwi.html

b0_mean_bval_shell_label=${b0_mean_label}${dash}${bval_label}${bval}

out_b0_mean_bval_shell_nifti_fname=$(compose_filename_from_basename ${in_nifti_fname} ${out_dirname} ${b0_mean_bval_shell_label} ${nii_gz_ext})
out_b0_mean_bval_shell_bval_fname=$(compose_filename_from_basename ${in_nifti_fname} ${out_dirname} ${b0_mean_bval_shell_label} ${bval_ext})
out_b0_mean_bval_shell_bvec_fname=$(compose_filename_from_basename ${in_nifti_fname} ${out_dirname} ${b0_mean_bval_shell_label} ${bvec_ext})

singularity exec \
  --bind ${in_qsiprep_dirname} \
  --bind ${out_dirname} \
  --bind ${work_dirname} \
  --workdir ${work_dirname} \
  ${scilus_singularity_fname} \
  scil_concatenate_dwi.py \
  ${out_b0_mean_bval_shell_nifti_fname} \
  ${out_b0_mean_bval_shell_bval_fname} \
  ${out_b0_mean_bval_shell_bvec_fname} \
  --in_dwis \
  ${out_b0_mean_4d_nifti_fname} \
  ${out_bval_shell_nifti_fname} \
  --in_bvals \
  ${out_b0_mean_4d_bval_fname} \
  ${out_bval_shell_bval_fname} \
  --in_bvecs \
  ${out_b0_mean_4d_bvec_fname} \
  ${out_bval_shell_bvec_fname}

echo "Concatenated b0 and b${bval} files written to:"
echo ${out_b0_mean_bval_shell_nifti_fname}
echo ${out_b0_mean_bval_shell_bval_fname}
echo ${out_b0_mean_bval_shell_bvec_fname}
