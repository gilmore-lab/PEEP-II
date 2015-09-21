# PEEP-II-sound-file-prep.md

2015-09-11-11:15

## Record 'raw' sound files

### Background

There are four prosodies {angry, sad, neutral, happy}; four contexts {dinner, talk, checkbook, late}; and two versions for each script {a,b}. This means we want to create 4x4x2 = 32 'good' sound files for each participant. To get 32 'good' files we expect to need 3-5 exemplars.

### Recording sound files

Recordings will take place in 214 Moore. 

## Naming and saving 'raw' sound files

We have created a consistent file naming convention for the sound files that will make it easier for us to process them later. It is essential that we name files consistently. The 'raw' data files will go in a special file directory that is under the project. The research team will provide the family-id, a four digit numeric code. The directory for the raw sound files will be `b-peep-project Shared/stimuli/<family-id>/raw/`.

Each sound file should be named using the following convention:

`<family-id>-{hap,ang,sad,neu}-{din,tlk,chk,hlp}-{a,b}-{01..n}.wav`

Here, the {happy, angry, sad, neutral} prosodies map on to {happy,angry,sad,neutral}; the {din,tlk,chk,hlp} contexts map on to {dinner,talk,checkbook,help}. This keeps the file names reasonably short, but makes them both machine- and human readable.

So, a sample file might be `0001-hap-din-a-01.wav` and the full path would be
`b-peep-project Shared/stimuli/0001/raw/0001-hap-din-a-01.wav`

## Post-process/normalize recordings

There are several post-recording steps. Post-processing starts with the raw sound files and ends with the 32 'best' files for each condition.

### Select "best" exemplar from each affect by context by script

Note index {00-n} of the exemplar chosen for each prosody x context x version combination in a comma-separated value (CSV) text file formatted as follows:

    family-id,prosody,context,version,file-index
    0001,angry,dinner,a,02
    0001,angry,dinner,b,03
    0001,happy,dinner,a,01
    ...

Save this file as `<family-id>-selected-segments.csv` in

`b-peep-project Shared/stimuli/<family-id>/`

If it is convenient to do so, you may wish to create a working directory to normalize the sounds:

`b-peep-project Shared/stimuli/<family-id>/working`

### Normalize RMS amplitude across exemplars within speaker.

### Normalize RMS amplitude to other speakers

If normalization be scripted or semi-automated, that is better. For example, Praat can be scripted. See [here](http://www.fon.hum.uva.nl/praat/manual/Scripting.html).

### Save normalized files:

Save the 4x4x2 selected and normalized files in

`b-peep-project Shared/stimuli/family-id/norm/`, for example
`b-peep-project Shared/stimuli/0001/norm/0001-hap-tlk-b.wav`

### Copy normalized files to Box (b-peep-project Shared/stimuli/) for fMRI session

We may use an external USB drive to take to the scanner, but for now we will share these files using Box.

### Copy raw and normalized files to Databrary (optional)

* Note sharing permission level
