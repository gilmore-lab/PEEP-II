# README.md

This is the MRI-study script for the PEEP-II study.

## Run-time instructions

### Equipment set-up

1. Connect white USB cable from USB hub to laptop.
2. Connect HDMI video cable from projector interface box via HDMI->DisplayPort converter to laptop. Ensure that screen mirroring is **off** on laptop via Apple Menu/System Preferences/Displays/Arrangement.
3. Connect sound cable to Input 1 on ResTech control box and to laptop audio out. Set laptop audio to maximum. Control audio level using ResTech control.

### Software set-up

1. Open Matlab.
2. Run `localize_peep`
3. Run `pre_scan_check` to ensure that audio files are in the path, grips work, etc.
4. Run `peep_mri` for each run.

## Components

### Matlab files

- ```create_run_file_list.m```
    + Creates a data table selecting the relevant conditions and file names for the current session.
- ```default_environment.mat```
	+ Matlab data structure containing environment variables
- ```default_session.mat```
    + Matlab data structure containing default session-level variables. This is usually overwritten at run-time.
- ```get_peep_session_data.m```
- `localize_peep.m`
    + Sets directories as needed.
- ```load_peep_sound.m```
    + Loads sound from given run list.
- ```peep_mri.m```
    + Master script to start MRI session.
- ```peep_run.m```
    + Run-time script for MRI session. Called by ```peep_mri.m```
- ```peep_test.m```
    + Test bed for timing routines prior to full implementation in ```peep_run.m```.
- ```pre_scan_check.m```
    + Checks number of .wav files in the directories needed for a given study, localization, and keyboards.
- ```qq.m```
    + Rick's convenience function to restore Matlab console and clear screen if a PsychToolbox function hangs.
    + Press command + period, command + 0, then qq <enter>.
- ```set_peep_defaults.m```
    + Edit/run to change default parameters in ```default_environment.mat``` and ```default_session.mat```.

### Directories

- ```planning/```
    + Planning documents for file formats, etc.
- ```csv/```
    + csv-formatted data files for subsequent MRI and behavioral analysis.
    + mri files named 'mri-9999-2016-01-15-0621-run-1-order-1.csv'
    + date_time, secs_from_start, vis_ring, snd_playing, mri_vol, event_type
- ```wav/```
    + Directory for .wav sound files. Contains subdirectories for each family <nnnn>/norm and <nnnn>/raw. The <nnnn>/norm directories contain the normalized sounds used in testing.
- ```diary/```
    + Directory for diary files (Matlab console output). These are useful in debugging visual displays on single monitor systems.
