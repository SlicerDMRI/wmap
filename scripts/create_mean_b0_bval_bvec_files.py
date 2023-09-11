#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Create a pair of ``bval`` and ``bvec`` files with non-diffusion-encoding
data to accompany a mean _b0_ NIfTI file. The  ``bval`` file will contain a
single $b = 0 s/mm^2$-value row, and the ``bvec`` will contain a 0-valued
gradient encoding direction laid out following the FSL convention.
"""

import argparse
from pathlib import Path


def create_b0_bval_data():
  return 0


def create_b0_bvec_data():
  return list([0, 0, 0])


def create_b0_diffusion_encoding_data():

    return create_b0_bval_data(), create_b0_bvec_data()


def _build_arg_parser():

    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument(
        "out_bval_fname",
        help="Output bval filename.",
        type=Path,
    )
    parser.add_argument(
        "out_bvec_fname",
        help="Output bvec filename.",
        type=Path,
    )

    return parser


def _parse_args(parser):

    args = parser.parse_args()

    return args


def main():

    parser = _build_arg_parser()
    args = _parse_args(parser)

    bval, bvec = create_b0_diffusion_encoding_data()

    with open(args.out_bval_fname, "w") as f:
        f.write(str(bval))

    with open(args.out_bvec_fname, "w") as f:
        f.write("\n".join([str(x) for x in bvec]))


if __name__ == "__main__":
    main()
