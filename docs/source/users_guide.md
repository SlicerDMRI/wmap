# User's guide

The following user's guide provides a detailed steps to be able to analyze
white matter tissue features from dMRI data using the White Matter Analysis
Pipeline (WMAP) tool.

## Introduction

The assumptions in this pipeline are as follows:
- All raw data is available in DICOM format.
- All participants are assumed to have AP/PA dMRI acquisitions.
- All participants are assumed to have field map acquisitions.
- All participants are assumed to have T1w acquisitions.
- All participants are assumed to have $b = 3000$ s/mm^2 dMRI data.
- The data layout is kept consistent across runs: the only change may be in
  the participant identifier in the folders and filenames.
- Generally, it is assumed that scripts are launched from a path where they
  are known.
- The only steps that can process all participant data at once are those in
  the [Data organization/standardization](#data-organizationstandardization)
  and [Preprocessing](#preprocessing) sections; the rest of the steps need to
  be run individually for each participant.

Note that:
- Data file paths may need to be adjusted.
- The path to the 3D Slicer executable and its extensions may need to be
  adjusted across scripts depending on the OS and installation path.

  As an example, for 3D Slicer version 5.2.2, on a Linux machine, the 3D
  Slicer executable path, if installed under `/opt`, it might be:

  ```
  /opt/Slicer-5.2.2-linux-amd64/Slicer
  ```

  On a macOS machine, the path may be:

  ```
  /Applications/Slicer.app/Contents/MacOS/Slicer
  ```

  Similarly, for the `UKFTractography` extension module, the path to the
  executable file would be:

  ```
  /opt/Slicer-5.2.2-linux-amd64/NA-MIC/Extensions-31382/UKFTractography/lib/Slicer-5.2/cli-modules/UKFTractography
  ```

  The same extension on a macOS machine could be located at:

  ```
  /Applications/Slicer.app/Contents/Extensions-31382/UKFTractography/lib/Slicer-5./cli-modules/UKFTractography

  ```

The help for all scripts provided can be retrieved by typing in a terminal:

```bash
$ [my_script] -h
```

where `[my_script]` corresponds to the name of the script.

## Pipeline description

### <a id="data-organizationstandardization"></a>Data organization/standardization

The purpose of this step is to produce a consistent layout and NIfTI-centered
data format from the DICOM data files obtained from the scanner. The [BIDS standard](https://bids.neuroimaging.io/)
is followed to accomplish this task.

The QSIprep preprocessing tool expects the input data to be BIDS-compliant.

Tools:
- heudiconv
  - Website: -
  - Documentation: [heudiconv documentation]
  - Code repository: [heudiconv code repository]
- BIDS validator
  - Website: [BIDS validator website]
  - Documentation: [BIDS validator documentation]
  - Code repository: [BIDS validator code repository]

Note that organizing and standardizing the data layout according to BIDS is
increasingly important for efficient work and collaboration, beyond the
requirement by QSIprep.

### <a id="preprocessing"></a>Preprocessing

Its purpose, among others, is denoise the T1w and dRMI data to correct for
different artifacts and prepare the data for downstream analysis.

Tools:
- Apptainer
  - Website: [Apptainer website]
  - Documentation: [Apptainer documentation]
  - Code repository: [Apptainer code repository]
- FreeSurfer
  - Website: [FreeSurfer website]
  - Documentation: [FreeSurfer documentation]
  - Code repository: [FreeSurfer code repository]
- QSIprep
  - Website: -
  - Documentation: [QSIprep documentation]
  - Code repository: [QSIprep code repository]

QSIprep uses a number of other software tools under the hood, transparently to
the user, such as DIPY, FreeSurfer, FSL or MRtrix, among others. The user is
not required to install them, except for FreeSurfer, if the installation using
containers is followed.

### Data format accommodation

This pipeline uses the UKF tractography reconstruction method. The input
dMRI data required corresponds to the $b = 3000$ s/mm^2 shell data, in
addition to the reference $b = 0$ s/mm^2 shell data.

All MRI data written by QSIprep is written using the NIfTI format. The dMRI
data analysis tools (tractography and white matter bundle identification)
require files to be in NRRD format, so the NIfTI files need to be converted to
NRRD files.

Finally, the brainmask data used to constrain the tractography method to the
brain tissue requires also a particular pixel type.

Tools:
- SCILPY (Scilus container)
  - Website: [Scilus container website]
  - Documentation: -
  - Code repository: [Scilus container code repository]
- DWIConvert
  - (see SlicerDMRI in [Analysis](#analysis))
- SimpleITK
  - Website: [SimpleITK website]
  - Documentation: [SimpleITK documentation]
  - Code repository: [SimpleITK code repository]

### <a id="analysis"></a> Analysis

Its purpose is to reconstruct the white matter fibers from the preprocessed
dRMI data.

Tools:
- 3D Slicer
  - Website: [3D Slicer website]
  - Documentation: [3D Slicer documentation]
  - Code repository: [3D Slicer code repository]
- SlicerDMRI
  - Website: [SlicerDMRI website]
  - Documentation: [SlicerDMRI documentation]
  - Code repository: [SlicerDMRI code repository]
- UKFTractography
  - Website: -
  - Documentation: -
  - Code repository: [UKFTractography code repository]
- White Matter Analysis (WMA)
  - Website: [WMA website]
  - Documentation: [WMA documentation]
  - Code repository: [WMA code repository]
- ORG Atlas
  - Website: -
  - Documentation: [ORG Atlas documentation]
  - Code repository: N/A

## Installation

The pipeline was developed on an Ubuntu 22.04.3 LTS machine using Python 3.10.

Although not shown below, advanced users are encouraged to install the Python
packages within a virtual environment. This minimizes the risk of
incompatibilities across different Python package versions required by the
tools used.

### Data organization/standardization

1. Install heudiconv following the [heudiconv installation instructions](https://heudiconv.readthedocs.io/en/latest/installation.html#installation)

   Although a local installation was used, Singularity would work in the same
   way; only the way the tool is called would need to be changed.

1. Install the BIDS validator tool following the [BIDS validator quickstart guide](https://github.com/bids-standard/bids-validator#quickstart)

   Note that the JavaScript version ("Command line version") has been used
   here; other versions should work equally well and should give the exact
   same result.

   It assumes [Node.js](https://nodejs.org/) is installed.

#### Versions

Versions used are:
- heudiconv: 1.3.1
- bids-validator: 1.15.0 (Node.js v20.5.1)

### Preprocessing

1. Install FreeSurfer (only required to point to a valid license file, as
   the software itself is used from the Apptainer container) following the
   [FreeSurfer Download and Install](https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall)
   instructions.

1. Install Apptainer (formerly known as Singularity) using their
   [Quick Installation guide](https://apptainer.org/docs/user/latest/quick_start.html#quick-installation).

   For macOS and Windows systems, Apptainer needs to be installed in a Virtual
   Machine (VM) or a Windows Subsystem for Linux ([WSL](https://learn.microsoft.com/en-ca/windows/wsl/install)).

   Apptainer is an open-source equivalent to Docker; these both container
   systems allow to ship all necessary dependencies.

> ℹ️ **Note**
>
> Apptainer containers have access only to a limited set of paths in the host
> machine (called "bind points"), so users may need to specify other paths
> so that the container obtains access to the data hosted on such paths. The
> relevant information can be found at the [Bind Paths and Mounts](https://apptainer.org/docs/user/main/bind_paths_and_mounts.html)
> section.

1. Build the [QSIprep Apptainer (Singularity) container](https://qsiprep.readthedocs.io/en/latest/installation.html#singularity-container)
   (output is a file with the extension `sif`).

   Pick an appropriate path (the folder must exist) to host the `*.sif` file, e.g.:

   ```bash
   $ singularity build /mnt/data/containers/qsiprep/qsiprep-1.0.0rc1.sif docker://pennbbl/qsiprep:1.0.0rc1
   ```

   If the following error appears when building the container:

   ```bash
   INFO:    Creating SIF file...
   FATAL:   While performing build: while creating squashfs: create command failed: exit status 1: Write failed because No space left on device
   FATAL ERROR: Failed to write to output filesystem
   ```

   it means that when building the container the filesystem has run out of
   disk space to store temporary data required in the build process. In order
   to solve the issue, we need to specify a temporary folder where we have
   sufficient disk space either by setting the `TMPDIR` environment variable
   or using the `--tmpdir` option. Pick an appropriate path for this purpose
   (the folder must exist), e.g.:

   ```bash
   $ singularity build --tmpdir /mnt/data/containers/.singularity /mnt/data/containers/qsiprep/qsiprep-1.0.0rc1.sif docker://pennbbl/qsiprep:1.0.0rc1
   ```

   The tested version corresponds to 1.0.0rc1.

#### Versions

Versions used are:
- Apptainer: 3.11.3 (Singularity)
- FreeSufer: freesurfer-linux-ubuntu22_x86_64-7.3.2-20220804-6354275
- QSIprep: 1.0.0rc1

> ℹ️ **Note**
>
> The scripts provided were developed Singularity instead of Apptainer. Users
> may need to change the `singularity` command to `apptainer` in the future.
> Scripts should work transparently.

### Data format accommodation

1. Install the Scilus Apptainer container following the
   [Singularity for TractoFlow](https://tractoflow-documentation.readthedocs.io/en/latest/installation/install.html#singularity-for-tractoflow)
   instructions.

   The SCILPY tools will be shipped inside this container, which requires
   Apptainer to be available on the system (see [Preprocessing](#preprocessing)).

> ℹ️ **Note**
>
> The Scilus containers were primarily developed to support [Tractoflow](https://tractoflow-documentation.readthedocs.io/en/latest/index.html).
> Tractoflow is a dMRI data processing pipeline in itself; Tractoflow is not
> used here, but some relevant documentation about the Scilus containers may
> be found on its website.

1. Install SlicerDMRI (see [Analysis-installation](#analysis-installation)):
   the diffusion data conversion tool (DWIConvert) is installed together with
   SlicerDMRI.

1. Install SimpleITK using the [Python wheels](https://simpleitk.readthedocs.io/en/master/gettingStarted.html#wheels-for-generic-python-distribution)

#### Versions

Versions used are:
- SCILPY (Scilus container): scilus 2.0.2
- DWIConvert: (see SlicerDMRI version in [Analysis-versions](#analysis-versions))
- SimpleITK: 2.4.1

### <a id="analysis-installation"></a>Analysis

1. Download and install 3D Slicer following the instructions in the
   [Installing 3D Slicer](https://slicer.readthedocs.io/en/latest/user_guide/getting_started.html#installing-3d-slicer)
   section.

   Older releases can be downloaded by using the offset parameter in the
   download page. For example, the download page from 7 days ago is [http://download.slicer.org/?offset=-7](http://download.slicer.org/?offset=-7)

1. Install SlicerDMRI following the instructions in the [Download section](https://dmri.slicer.org/download/)

1. Install UKFTractography from the [3D Slicer Extensions Manager](https://slicer.readthedocs.io/en/latest/user_guide/extensions_manager.html)
   following the [How to](https://slicer.readthedocs.io/en/latest/user_guide/extensions_manager.html#how-to) section

1. Install White Matter Analysis (WMA) following the instructions in the
   [WMA Installation and Usage](https://dmri.slicer.org/whitematteranalysis/) section

1. Download the version of the ORG Atlas that is intended to be used from the
   [8082481 Zenodo record](https://zenodo.org/records/8082481)

#### <a id="analysis-versions"></a>Versions

Versions used are:
- 3D Slicer: 5.2.2 r31382 / fb46bd1
- SlicerDMRI: commit 6207e52
- UKFTractography: commit fcf83e2
- White Matter Analysis (WMA): commit 173f241
- ORG Atlas: v1.2

## Instructions

## Data organization/standardization

1. Run the following command from a terminal:

   ```bash
   $ heudiconv -f [heuristic_name_or_path_to_file] --bids -o [path_to] --files [in_data_path]
   ```

   The `[heuristic_name_or_path_to_file]` is the name of a known heuristic or
   a file that contains some heuristics to be able to identify the relevant
   information in the study. The file used here is hosted in this repository.
   Note that if the study contains acquisitions whose naming contains
   different conventions, the file will need to be modified. One of the most
   crucial parts for a correct identification of the data is the
   `protocols2fix` dictionary in that file. Some documentation is provided
   [here](https://heudiconv.readthedocs.io/en/latest/heuristics.html).
   Additionally, the documentation in the file header should be read carefully.

   The input data path `[in_data_path]` must be set to the place where the
   raw DICOM data corresponding to all available participants exists, and pick
   an appropriate location for the output `[path_to]` directory, e.g.

  ```bash
  $ heudiconv \
      -f /mnt/data/study_name/bids_config/study_name_heuristic.py \
      --bids \
      -o /mnt/data/study_name_bids_data \
      --files /mnt/data/study_name_raw_data
  ```

   Note that all raw imaging data needs to be in DICOM format; heudiconv does
   not deal with raw imaging data in NIfTI format, and it will error if such
   data is found in the input data path.

### Checking BIDS compliance

As QSIprep expects the data to be BIDS-compliant, it is recommended that we
ensure that heudiconv has accomplished this by running a BIDS validator
tool.

1. Check that the data that has been written conforms to BIDS running:

   ```bash
   $ bids-validator [path_to]
   ```

   Set the input data path `[path_to]` to the place where the above step has
   written the data to, e.g.

   ```bash
   $ bids-validator /mnt/data/study_name_bids_data
   ```

   No warnings or errors should be present, e.g.:

   ```bash
   $ bids-validator /mnt/data/study_name_bids_data
   bids-validator@1.12.0
   This dataset appears to be BIDS compatible.
           Summary:                  Available Tasks:        Available Modalities:
           21 Files, 512.32MB                                MRI
           1 - Subject
           1 - Session

     If you have any questions, please post on https://neurostars.org/tags/bids.
   ```

## Preprocessing

1. Run the `qsiprep_preprocess.sh` script from a terminal:

   ```bash
   $ qsiprep_preprocess.sh [in_bids_dirname] [out_dirname] [fs_license_fname] [qsiprep_singularity_fname] [work_dirname]
   ```

   e.g.

   ```bash
   $ qsiprep_preprocess.sh \
       /mnt/data/study_name_bids_data/heudiconv \
       /mnt/data/study_name_bids_data/qsiprep \
       /usr/local/freesurfer/license.txt \
       /mnt/data/containers/qsiprep/qsiprep-1.0.0rc1.sif \
       /mnt/data/workdir
   ```

   The above command assumes that we have changed the directory to the path
   where the script lies, and that it has the appropriate permissions (most
   notably, execution permissions, which may be granted running
   `chmod +x [my_file]` from a terminal and providing the appropriate
   filename).

   The `[in_bids_path]` argument needs to point to the dirname where the BIDS
   `dataset_description.json` file lies.

   Some steps of the script may take a long time to complete even for a single
   participant.

> ℹ️ **Note**
>
> Apptainer uses an intermediate work directory (`--workdir`) where
> intermediate files are written as the processing take place, and before the
> final data gets written to the destination path. This work directory may
> grow considerably, even for a single participant. Similarly, if some jobs
> (e.g. processing some participant data) were terminated unexpectedly, and
> for some reason, dirnames (e.g. the root dirname) are manually changed
> between runs, since `qsiprep` will try to pick and re-run unfinished jobs
> (which are traced through the data stored in the work directory), this may
> give rise to exceptions derived from `FileNotFoundError: No such file or no
> access` errors, as previous filenames and dirnames will be present in the
> work directory.

> ℹ️ **Note**
>
> The brainmask may need to be adjusted manually (e.g. using 3D Slicer) if the
> result is not accurate enough.

> ℹ️ **Note**
>
> The denoising step in the preprocessing operation is chosen to be applied to
> all combined dMRI data. Further information related to this choice can be
> found in the [Merging multiple scans from a session](https://qsiprep.readthedocs.io/en/latest/preprocessing.html?highlight=separate_all_dwis#merging-multiple-scans-from-a-session)
> and [Denoising and Merging Images](https://qsiprep.readthedocs.io/en/latest/preprocessing.html#denoising-and-merging-images)
> sections of the QSIprep documentation.

## Data format accommodation

### b-value shell data extraction

1. Extract the $b = \{0, 3000\}$ s/mm^2 shell data from the preprocessed
   diffusion data. For the $b = 0$ s/mm^2 (_b0_) data, an average across all
   volumes that have no diffusion-weighting is computed. The computed mean
   _b0_ data is a 3D volume, as the _b0_ data has no diffusion-encoding
   direction; the fourth dimension is added back on the mean _b0_ data, and a
   pair of `bval` and `bvec` files are generated to accompany the mean _b0_
   volume data. Finally, the extracted data (mean _b0_ and _b3000_ shell) are
   concatenated and merged into a single file: tractography will be performed
   on the $b = 3000$ s/mm^2 shell data, the mean _b0_ serving as the
   reference.

   ```bash
   $ scilpy_prepare_shell_data.sh [in_qsiprep_dirname] [out_dirname] [work_dirname] [in_nifti_fname] [in_bval_fname] [in_bvec_fname] [scilus_singularity_fname]
   ```

   e.g.

   ```bash
   $ scilpy_prepare_shell_data.sh \
       /mnt/data/study_name_bids_data/qsiprep \
       /mnt/data/study_name_bids_data/prepare_shell_data \
       /mnt/data/workdir \
       /mnt/data/study_name_bids_data/qsiprep/sub-001/dwi/sub-001_acq-dir99_space-ACPC_desc-preproc_dwi.nii.gz \
       /mnt/data/study_name_bids_data/qsiprep/sub-001/dwi/sub-001_acq-dir99_space-ACPC_desc-preproc_dwi.bval \
       /mnt/data/study_name_bids_data/qsiprep/sub-001/dwi/sub-001_acq-dir99_space-ACPC_desc-preproc_dwi.bvec \
       /mnt/data/containers/scilus/scilus-2.0.2.sif
   ```

   **Note:** When executing the above script the shell data concatenation step
   may raise the following warning:

   ```
   /usr/local/lib/python3.10/dist-packages/dipy/io/gradients.py:72:
   UserWarning: Detected only 1 direction on your bvec file.
   For diffusion dataset, it is recommended to have at least 3 directions.
   You may have problems during the reconstruction step.
    warnings.warn(msg)
   ```

   The above warning is expected since the _b0_ data contains only one
   0-direction in the corresponding bvec file. No action is required following
   this warning in this case.

### Data format conversion

1. QSIprep uses a data format called NIfTI; UKF, however requires the data to
   be in NRRD (or NHDR) format. 3D Slicer's tool DWIConvert tool is used to
   perform the NIfTI to NRRD conversion:

   ```bash
   $ slicer_convert_nifti2nrrd.sh [in_nifti_fname] [in_bval_fname] [in_bvec_fname] [out_nrrd_fname]
   ```

   e.g.

   ```bash
   $ slicer_convert_nifti2nrrd.sh \
       /mnt/data/study_name_bids_data/prepare_shell_data/sub-001_acq-dir99_space-ACPC_desc-preproc_dwi_b0_mean-b3000.nii.gz \
       /mnt/data/study_name_bids_data/prepare_shell_data/sub-001_acq-dir99_space-ACPC_desc-preproc_dwi_b0_mean-b3000.bval \
       /mnt/data/study_name_bids_data/prepare_shell_data/sub-001_acq-dir99_space-ACPC_desc-preproc_dwi_b0_mean-b3000.bvec \
       /mnt/data/study_name_bids_data/nifti2nrrd/sub-001_acq-dir99_space-ACPC_desc-preproc_dwi_b0_mean-b3000.nrrd
   ```

1. Change the brainmask pixel type: the brainmask computed by QSIprep has to
   have its pixel type changed (to either `signed char`, `unsigned char`,
   `short`, and `unsigned short`) so that UKF can process it. SimpleITK is
   used for such purpose:

   ```bash
   $ sitk_convert_mask_nifti2nrrd.sh [in_fname] [out_fname]
   ```

   e.g.

   ```bash
   $ sitk_convert_mask_nifti2nrrd.sh \
       /mnt/data/study_name_bids_data/qsiprep/sub-001/dwi/sub-001_acq-dir99_space-ACPC_desc-brain_mask.nii.gz \
       /mnt/data/study_name_bids_data/nifti2nrrd/sub-001_acq-dir99_space-ACPC_desc-brain_mask.nrrd
   ```

   The script converts the source brainmask NIfTI data format file to an NRRD
   format file.

## Analysis

### Tractography

1. Compute the tractography from the preprocessed diffusion data:

   ```bash
   $ ukf_compute_tractography.sh [in_dmri_fname] [in_mask_fname] [out_tractography_fname]
   ```

   e.g.

   ```bash
   $ ukf_compute_tractography.sh \
       /mnt/data/study_name_bids_data/nifti2nrrd/sub-001_acq-dir99_space-ACPC_desc-preproc_dwi_b0_mean-b3000.nrrd \
       /mnt/data/study_name_bids_data/nifti2nrrd/sub-001_acq-dir99_space-ACPC_desc-brain_mask.nrrd \
       /mnt/data/study_name_bids_data/ukftractography/sub-001_acq-dir99_space-ACPC_desc-preproc_dwi_b0_mean-b3000.vtk
   ```

### Data accommodation

1. Limit the size of the computed tractogram by randomly subsampling the
   streamlines so that WMA can perform the bundle identification with a
   reasonably sized tractogram. The general recommendation is to set an upper
   bound of $500000$ streamlines:

   ```bash
   $ wma_subsample_tractogram.sh [in_dirname] [out_dirname]
   ```

   e.g.

   ```bash
   $ wma_subsample_tractogram.sh \
       /mnt/data/study_name_bids_data/ukftractography \
       /mnt/data/study_name_bids_data/tractography_subsample
   ```

### White matter bundle identification

1. Launch the bundle identification step using WMA:

   ```bash
   $ wma_identify_bundles.sh [in_tractography_fname] [atlas_dirname] [out_dirname]
   ```

   e.g.

   ```bash
   $ wma_identify_bundles.sh \
       /mnt/data/study_name_bids_data/tractography_subsample/sub-001_acq-dir99_space-T1w_desc-preproc_dwi_b0_mean-b3000_pp.vtp \
       /mnt/data/atlas/org_atlas/ORG-Atlases-1.2 \
       /mnt/data/study_name_bids_data/wma
   ```

   > ℹ️ **Note**
   >
   > If the bundle statistics computation step fails with the following error:
   >
   > ```bash
   > ERROR: Reporting diffusion measurements of fiber clusters. failed. No diffusion measurement (.csv) files generated.
   > ```
   >
   > the statistics can be computed from the 3D Slicer Graphical User Interface:
   > by selecting the `Diffusion/Quantify/Tractography Measurements` menu, the
   > folder that contains the identified bundles (typically names
   > `AnatomicalTracts` after WMA has run), can be selected, and an output
   > filename be given to obtain the statistics of interest. Selecting the
   > `Column_Hierarchy` option allows to lay out the statistics across columns.

## Relevant notes

### Space

By default, QSIprep output data are in subject space aligned to AC-PC: AC-PC
alignment changes the coordinates from the native scanner coordinates to a new
system where $0, 0, 0$ is where the midline intersects the anterior commissure.
This is the same $0, 0, 0$ as in MNI space, so the brains will look somewhat
aligned if you open the MNI template and the AC-PC image, as long as it is an
adult brain, and despite no (MNI) template warping taking place by default.

Further documentation can be found at the [Specifying outputs](https://qsiprep.readthedocs.io/en/latest/quickstart.html?highlight=AC-pc#specifying-outputs)
section of the QSIPrep documentation.

### Resolution

The data is currently set to be resampled to a resolution of $1 x 1 x 1$ mm at
the QSIPrep preprocessing step, in line with other notable dMRI processing
pipelines, such as Tractoflow.

The resampling step, added to the combination of the AP/PA data into a single
file, together with any multi-shell data, explain the dMRI data large file
size that it is seen at the output of the QSIPrep preprocessing workflow.

### Parameters

Not all parameters of the underlying tools are exposed by the scripts; some of
their parameters have fixed values in the scripts (e.g. the output data
resolution in the `qsiprep_preprocess.sh` script, or the tractography
parameters in the `ukf_compute_tractography.sh` script), and other parameters
are kept to their default values. The proposed values were found to be
appropriate for the data used during the development. Users are encouraged to
adjust the parameter values if results are suboptimal after visual inspection.

## Citations

Please cite appropriately each of the packages used in this pipeline.


[BIDS validator code repository]: https://github.com/bids-standard/bids-validator
[BIDS validator documentation]: https://bids-standard.github.io/bids-starter-kit/validator.html#verifying-a-bids-compliant-data-set
[BIDS validator website]: https://bids-specification.readthedocs.io/en/stable/

[3D Slicer code repository]: https://github.com/Slicer/Slicer
[3D Slicer documentation]: https://slicer.readthedocs.io/en/latest/
[3D Slicer website]: https://www.slicer.org/

[Apptainer code repository]: https://github.com/apptainer/apptainer
[Apptainer documentation]: https://apptainer.org/docs/user/latest/
[Apptainer website]: https://apptainer.org/

[FreeSurfer code repository]: https://github.com/freesurfer/freesurfer
[FreeSurfer documentation]: https://surfer.nmr.mgh.harvard.edu/fswiki
[FreeSurfer website]: https://surfer.nmr.mgh.harvard.edu/

[ORG Atlas documentation]: https://github.com/SlicerDMRI/ORG-Atlases

[QSIprep code repository]: https://github.com/PennLINC/qsiprep
[QSIprep documentation]: https://qsiprep.readthedocs.io/en/latest/

[Scilus container code repository]: https://github.com/scilus/containers-scilus
[Scilus container website]: https://scil.usherbrooke.ca/pages/containers/

[SimpleITK code repository]: https://github.com/SimpleITK/SimpleITK
[SimpleITK documentation]: https://simpleitk.readthedocs.io/en/master/gettingStarted.html
[SimpleITK website]: https://simpleitk.org/

[SlicerDMRI code repository]: https://github.com/SlicerDMRI/SlicerDMRI
[SlicerDMRI documentation]: https://dmri.slicer.org/docs/
[SlicerDMRI website]: https://dmri.slicer.org/

[UKFTractography code repository]: https://github.com/pnlbwh/ukftractography

[WMA code repository]: https://github.com/SlicerDMRI/whitematteranalysis
[WMA documentation]: https://whitematteranalysis.readthedocs.io/en/latest/
[WMA website]: https://dmri.slicer.org/whitematteranalysis/

[heudiconv code repository]: https://github.com/nipy/heudiconv
[heudiconv documentation]: https://heudiconv.readthedocs.io/en/latest/
