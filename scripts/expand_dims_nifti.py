#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Expand a volume along the specified axis."""

import argparse
from pathlib import Path

import nibabel as nib
import numpy as np


def expand_dims(img, axis=-1):

    data = img.get_fdata()
    _data = np.expand_dims(data, axis=axis)
    _img = nib.Nifti1Image(_data, img.affine, header=img.header)

    return _img


def _build_arg_parser():

    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument(
        "in_fname", help="Input filename (*.nii.gz)", type=Path
    )
    parser.add_argument(
        "out_fname", help="Output filename (*.nii.gz)", type=Path
    )
    parser.add_argument(
        "-axis", help="Axis to be expanded", type=int,  default=-1,
    )

    return parser


def _parse_args(parser):

    args = parser.parse_args()

    return args


def main():

    parser = _build_arg_parser()
    args = _parse_args(parser)

    in_dwi = nib.load(args.in_fname)
    out_dwi = expand_dims(in_dwi)
    nib.save(out_dwi, args.out_fname)


if __name__ == "__main__":
    main()
