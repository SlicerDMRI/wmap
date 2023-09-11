#!/usr/bin/env python

"""Convert a NIfTI data format file that (typically) contains mask data to
NRRD using SimpleITK. Automatically performs a pixel conversion to unsigned 8
bit integer."""

import argparse
from pathlib import Path

import SimpleITK as sitk


def read_convert_pixel_type(in_fname, out_pixel_type):

    return sitk.ReadImage(in_fname, out_pixel_type)


def _build_arg_parser():

    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument(
        "in_fname", help="Input filename (*.nii.gz)", type=Path
    )
    parser.add_argument(
        "out_fname", help="Output filename (*.nrrd)", type=Path
    )
    return parser


def _parse_args(parser):

    args = parser.parse_args()

    return args


def main():

    parser = _build_arg_parser()
    args = _parse_args(parser)
    
    out_pixel_type = sitk.sitkUInt8

    img = read_convert_pixel_type(args.in_fname, out_pixel_type)

    sitk.WriteImage(img, args.out_fname)
 

if __name__ == "__main__":
    main()

