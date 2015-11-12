# README.md

This is the MRI-study script for the PEEP-II study.

## Components

### Matlab files

- ```create_run_file_list.m```
    + Creates a data table selecting the relevant conditions and file names for the current session.
- ```default_environment.mat```
	+ Matlab data structure containing environment variables
- ```default_session.mat```
    + Matlab data structure containing default session-level variables. This is usually overwritten at run-time.
- ```get_peep_session_data.m```
- ```load_peep_sound.m```
    + Loads sound from given run list.
- ```peep_mri.m```
    + Master script to start MRI session.
- ```peep_run.m```
    + Run-time script for MRI session. Called by ```peep_mri.m```
- ```peep_test.m```
    + Test bed for timing routines prior to full implementation in ```peep_run.m```.
- ```pre_scan_check.m```
    + Checks number of .wav files in the directories needed for a given study.
- ```qq.m```
    + Rick's convenience function to restore Matlab console and clear screen if a PsychToolbox function hangs.
    + Press command + period, command + 0, then qq <enter>.
- ```set_peep_defaults.m```
    + Edit/run to change default parameters in ```default_environment.mat``` and ```default_session.mat```.

### Directories

- ```planning/```
    + Planning documents for file formats, etc.
- ```beh/```
    + Future home for key presses during MRI and other measures (script ratings?). nnnn-mri-sess-{1,2}.csv, etc.
- ```wav/```
    + Directory for *.wav sound files. Contains subdirectories for each family <nnnn>/norm and <nnnn>/raw. The <nnnn>/norm directories contain the normalized sounds used in testing.
- ```diary/```
    + Directory for diary files (Matlab console output). These are useful in debugging visual displays on single monitor systems.
 