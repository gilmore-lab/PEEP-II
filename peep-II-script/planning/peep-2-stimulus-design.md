# peep2-stimulus-design-data-structures.md

This document sketches out some of the design parameters and data file structures for the PEEP-2 study.

## Data file structure

- Check-out [BIDS](http://bids.neuroimaging.io/)
- session-type: {home-consent,mock-record,mri,home-ear} so data path is
    + data/family-id/YYYY-MM-DD-HHMMSS-{session-type}
- data/family-id/201n-MM-DD-HHMMSS-mock-record/wav/raw
- data/family-id/201n-MM-DD-HHMMSS-home-ear/
- data/family-id/201n-MM-DD-HHMMSS-mri/
    + sess/ # session-level metadata
    + mri/  # mri data
    + log/  # log files from behavioral script
    + beh/  # behavioral files from post-processing script

## fMRI parameters

- TR: 2 s
- TE:
- FOV:
- Slices:
- Slice-acquisition-order: {descending, ascending, interleaved}
- Voxel-size-mm: {3x3x3}
- n-volumes:
- acquisition-time-s: TR x n-volumes
- disdaq-vols:
- disdaq-s:

## Behavioral Conditions

1. Affect
	- Angry (Ang)
	- Sad (Sad)
	- Neutral (Neut)
	- Happy (Happy)
2. Speaker
	- Mom (Mom)
	- Unfamiliar (Unf)
3. Speaker-ID
	- 0001...nnnn
4. Script
	- {1-4} x {a,b}
    - Scripts vary by context/content
    - {dinner, talk, checkbook, late} 
5. t-onset
6. duration-s (10) 
4. Circle onset
    - Not in [0,1] or [9,10] sec
    - Up to 2, inter-circle interval is at least 2 s.
    - Duration of circle: 800 ms.
    - What is response period: 2 s.
    - Which response keys to monitor?
        + All: {a,b,c,d}
5. Scripts fully crossed within participant (after 2 runs)
6. Orders
    - 1...6
6. Run
    - 1..2
7. Mom-stimulus-file-name
    - wav/speaker0001/hap-4-a.wav or
    - wav/speaker0001/hap-dinner-a.wav
8. Unf-stimulus-file-name
    - wav/speaker0002/hap-4-a.wav
    - So, if participant-id ≠ speaker-id then speaker is unfamiliar.
9. 10 s on/6 s silence, TR of 2 s

## Stimulus order files

- Have n files, 1 for each order: stimulus-order-{1..n}.csv
- Format of stimulus order files
    + t-onset,duration,prosody,context,script,speaker
    + Where speaker: {fam,unf}
- Stimulus order files are generic with respect to speaker {fam,unf}, run-time script converts `fam` and `unf` into appropriate speaker-ids and file references, e.g.
    + wav/speaker-id/norm/angry-dinner-a.wav or
    + wave/silence-wav

## Pre-scan procedures

- Record sound files
    + Context: {dinner, talk, checkbook, late}
    + Script: {a,b}
    + Prosody: {Angry, Sad, Neutral, Happy}
    + n-exemplars
    + Save as: wav/family-id/raw/happy-dinner-a-{01..0n}.wav
- Post-process recordings
    + Select "best" exemplar from each affect by context by script.
    + Normalize RMS amplitude across exemplars within speaker.
    + Normalize RMS amplitude to other speakers...(how?)
    + Can normalization be scripted or semi-automated?
        * Praat can be scripted. See [here](http://www.fon.hum.uva.nl/praat/manual/Scripting.html).
    + Save normalized files as:
        - wav/family-id/norm/happy-dinner-a.wav 
    + Copy normalized files to USB drive for fMRI session
    + Copy raw and normalized files to Box as back-up
    + Copy raw and normalized files to Databrary?
        * Note sharing permission level
- Prepare for scan session
    + Choose stimulus order for each run condition. 

## Event log

- Detect trigger pulses
- Write stimulus onsets, durations
- Write silence onsets, durations
- Write participant, run, order information
- Write circle onsets, durations
- Write subject responses, RTs
- Here is a sample [.csv file](peep-2-sample-log-file.csv)
- Write log to data/family-id/session-date-time/log on USB drive or write to SLEIC PC and copy?

## fMRI data analysis file(s)

### BrainVoyager

- [Background/documentation from BV site](http://download.brainvoyager.com/doc/BVQXGettingStartedGuide_v2.12.pdf)
- Format of [.FMR files](http://support.brainvoyager.com/automation-aamp-development/23-file-formats/383-developer-guide-26-the-format-of-fmr-files.html)
    + Get sample .FMR file from Suzy?
- [Scripting BV from Matlab](http://support.brainvoyager.com/documents/Automation_Development/Writing_Scripts/ScriptingBrainVoyagerQX284fromMatlab.pdf)

### FSL for OpenFMRI archive?

1. Log file -> Event files by run and condition (confirm design)
    - {participantID}-{angry, happy, sad, neutral}.tsv
    - {participantID}-{speakerID}.tsv
    - {participantID}-{dinner, talk, checkbook, late}.tsv
    - {participantID}-{a,b}.tsv
    - Format of the explanatory variable files
        * {t-onset}\t{duration-s}\t1
        * tab-separated value (.tsv) text files

## Behavioral data file

1. Log file -> Behavioral data file, [sample](peep-2-sample-behavioral-log.csv)
    - file name: 0001-behavior-log.csv
    - Example assumes one log file for all runs since run number is in master log. Create separate log files and merge using cat?
2. Behavioral data file -> Data file for analysis
    - Extract response/no-response.
    - Compute RT
    - Keep actual key pressed {a,b,c,d} in case we want to analyze this later?
    - Analyze p(correct) and RT, false alarms? as function of stimulus type.
    - file name: data/family-id/session-date-time/beh/0001-behavior-data.csv
3. To prepare for group analyses, grab individual data files and merge into
    - analysis/peep-2-all-sessions.csv

