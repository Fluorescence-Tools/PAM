PAM change log
========================

v1.3
------

This update brings a lot of bugfixes that we have gathered over the past year. Thanks to all who contributed to the project by reporting issues or squashing bugs! Many of these relate to newer versions of MATLAB (2018a and beyond) that saw some changes to the behavior of GUI elements such as toolbars and tables.

In addition, we have worked on a number of features for the different modules:

*  *Three-color Photon Distribution Analysis* has arrived following our recent [publication](https://pubs.acs.org/doi/abs/10.1021/acs.jpcb.9b02967).
*  *Spectrally-resolved image correlation analysis* is now implemented following last years [publication](https://www.sciencedirect.com/science/article/pii/S1046202317302657) on crosstalk-free RICS using spectral weighting.
*  *Phasor-FLIM* can now be calculate per PIE channel, instead of being restricted to detection channels.
*  New module *ParticleDetection* allows you to perform particle-averaged and tracking-based Phasor-FLIM analysis.
*  *PAM* now supports the read-in of continuous wave microsecond ALEX experiments saved in the [PhotonHDF5 ](http://photon-hdf5.github.io/) file format, with full support for burst analysis.
*  *BurstBrowser*
   *  [Burst Variance Analysis](https://www.sciencedirect.com/science/article/pii/S0006349511001858) is now available in *PAM* to detect dynamics if no lifetime information is available, or if you don't trust the *E*-$`\tau_{D(A)}`$ plot.
   *  You can now resample your burst data based on a specific kinetic scheme using two or three dynamic states. We call this "kinetic consistency check" as it allows you to test your kinetic model against the data set.
   *  Burst-wise lifetimes can now also be calculated using the phasor approach.
* *PDAFit*: Together with the additional kinetic analysis available in BurstBrowser, we have added support for fitting of three-state kinetic networks to PDAFit.
* *TauFit*: We now support global fitting of fluorescence decays of donor-acceptor and donor-only samples using inter-dye distance distributions.
* Segmented image analysis is now possible for RICS, TICS and Number&Brightness analyses.
* Support for the Zeiss CZI file type.

v1.2
------

Release 1.2 of PAM contains bug fixes to many modules and some new features:

New features:

*  FCSFit:
    *  Added new "Save session" function that allows to save the analysis state including fitted parameters, selected model, loaded files and visualization state.
    *  The name and description of the loaded model is now shown in the GUI.
*  TauFit:
    *  Added option to fit the instrument response function to a gamma-distribution

Improvements and bugfixes:

* PAM:
    *  Bugfix to CalculateImage routine for Start/Stop type data
    *  Image display now uses kHz for intensity.
    *  Mean arrival time image displays in nanoseconds when 'Use time in ns' is checked
    *  Export to PhotonHDF
        *  Updated for use with version 0.5dev of PhotonHDF file format
        *  Added option to export non-polarization FRET data to PhotonHDF
        *  Fixed error on saving when using filename with spaces
    *  Added option to extract raw FRET efficiency trace from intensity traces
*  BurstBrowser:
    *  Option to hide the sum of all population in multiselection mode
    *  Fixed calculation of three-color static FRET line
    *  Reworked the way the species list works:
        *  Top level species (filenames) can not be selected any more
        *  The "Add species" button will now add a species on the same level as the selected species (previously, it would add a child species)
        *  To remove a loaded file, a new entry in the right-click menu is available
    *  Figure export
        *  Bugfixes to figure export to .eps files
        *  Added option to export to .fig file
    *  Gaussian fitting
        *  Fixed an issue where LSQ fitting was not working when different number of bins were selected for x- and y-dimension
*  PDAFit:
    *  Changed the look of exported plots
    *  Exporting fit results now saves the parameters for every loaded file individually
    *  Fixed Angstrom symbol not being displayed in distance distribution plots
    *  Added mex files for maximum likelihood estimator based PDA
    *  Added code for Metropolis-Hastings type sampling of confidence intervals
    *  Fixed numerous bugs for error estimation:
        *  Now works over multiple files
        *  Now works for global fitting
    *  Fixed an issue where, when the "sigma at fraction of R" parameter was used as a fit parameter, it was not globally optimized over all loaded files 
    *  Histograms are now area-normalized in the All-tab
*  MIA:
    *  Fixed bug that occurred when not correlating all frames
*  FCSFit:
    *  Fixed bug when reading in FRET efficiency histograms from BurstBrowser
*  TauFit:
    *  Added option to set x-scale to log
*  Custom read-ins:
    *  Bugfix to Leuven_PTU read-in routine
*  Sim:
    *  Fixed FRET calculation in camera simulations
    *  Added option to input concentration of particles (linked to particle number and box size)
*  ParticleDetection:
    *  Added frame-wise particle tracking


v1.1
------

Release 1.1 of PAM containing numerous bug fixes.

Release notes:

*  bugfixes to multiple modules

*  spectral image correlation support

*  spectral phasor support

*  All-in-one plots for BurstBrowser

*  Read-in routines for Zeiss CZI data

v1.0
-----

Initial release.