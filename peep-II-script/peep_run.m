function peep_run(session, environment)
% peep_ratings(session, environment)
%   Controls a particular run of the PEEP-II ratings experiment.

% Rick Gilmore, 2015-11-13

% Dependencies
%   Calls:
%       create_run_file_list.m
%       load_peep_sound.m
%       txt_2_screen.m
%       peep_log_msg.m
%       write_event_2_file.m
%       handle_mri_keypress.m
%       fix_2_screen.m
%   Called by:
%       peep_mri.m

% 2015-11-xx rog wrote
% 2015-11-16 rog added separate keyboard detection.
% 2015-11-18 rog added switch b/w keyboard detection modes
% 2015-12-03 add 10s sound at beginning, 6s at end, fix orders 3 and 4.
% 2015-12-10 rog fixed automatic mapping of USB inputs.
% 2015-12-20 rog tweaked console output, added internal kbd 't' detection.
% 2016-01-13 rog streamlined while looping, added next_snd
% 2016-01-15 rog refactored, adding handle_mri_keypress, better messaging.
% 2015-01-21 rog refactored, adding show_hide_bigcircle, turn_sound_on_off
%--------------------------------------------------------------------------

if (nargin < 2)
    load('default_session.mat');
    load('default_environment.mat');
end

if isempty(session)
    peep_log_msg(sprintf('Session is blank; loading default_session.mat.'), GetSecs, environment.log_fid);
    session = load('default_session.mat');
else
    run = session.run;
    order = session.order;
    fam = session.this_family;
    nov = session.nov_family;
end

% Open window for participant
try
    Screen('Preference', 'SkipSyncTests', 1);
    win_ptr = Screen('OpenWindow', max(environment.screenNumbers));
    txt_2_screen('Welcome to PEEP', win_ptr, environment);
    HideCursor;
    win_ptr = win_ptr;
catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    ShowCursor;
end

% Initialize status data structure
status = [];
status.now_playing = char(environment.now_playing_msgs(1));
status.curr_snd = 'silence';
status.win_ptr = win_ptr;

% Load run and order data from file into cell array of filenames
peep_log_msg(sprintf('%s : Initializing run %s, order %s for participant %s. Unfamiliar family is %s.\n', status.now_playing, run, order, fam, nov), GetSecs(), environment.log_fid);
session.this_run_data = create_run_file_list(environment, session);

% Load first sound file since there is no silent period to start
% snd_index = 1;
snd_index = 1;
next_snd = 1;
session.n_snds = height(session.this_run_data);
peep_log_msg(sprintf('%s : Loading sound %i of %i sounds: %s.\n\n', status.now_playing, snd_index, session.n_snds, char(session.this_run_data.File(snd_index))), GetSecs(), environment.log_fid);
[~, snd_freq, nrchannels] = load_peep_sound(session.this_run_data.File(snd_index));

% Perform basic initialization of the sound driver:
InitializePsychSound;

% Open the default audio device [], with default mode [] (==Only playback),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
try
    % Try with the frequency we want
    session.pahandle = PsychPortAudio('Open', [], [], 0, snd_freq, nrchannels);
catch
    % Failed. Retry with default frequency as suggested by device:
    fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', snd_freq);
    fprintf('Sound may sound a bit out of tune, ...\n\n');
    psychlasterror('reset');
    session.pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
end

% Show ready to start run screen
[keyboardIndices, ~, ~] = GetKeyboardIndices();
peep_log_msg(sprintf('%s : Press TAB key to switch study to scanner-triggered start mode.\n', status.now_playing), GetSecs(), environment.log_fid);
txt_2_screen('Ready to go!', status.win_ptr, environment);
while 1
    [ keyIsDown, ~, keyCode ] = KbCheck(keyboardIndices);
    if keyIsDown
        if keyCode(environment.tabKey)
            break;
        end
        KbReleaseWait;
    end
end

% Wait for scanner trigger
peep_log_msg(sprintf('%s : Ready to run. Start scanner. Script will start automatically on first non-DISDAQ pulse.\n', status.now_playing), GetSecs(), environment.log_fid);
status.n_pulses_detected = 0;
while 1
    [ keyIsDown, timeSecs, keyCode ] = KbCheck(keyboardIndices);
    status.start_secs = timeSecs;
    if keyIsDown
        if keyCode(environment.tKey)
            status.n_pulses_detected = status.n_pulses_detected + 1;
            status.last_pulse = timeSecs;
            peep_log_msg(sprintf('%s : Scanner pulse %i detected. Starting. \n', status.now_playing, status.n_pulses_detected), status.start_secs, environment.log_fid);
            write_event_2_file(status.start_secs, 'none', status.curr_snd, num2str(status.n_pulses_detected), 'new_mri_vol', environment.csv_fid);
            break;
        end % if keyCode
        KbReleaseWait;
        if keyCode(environment.escapeKey)
            peep_log_msg(sprintf('%s : Escape detected at %07.3f from start.\n', status.now_playing, timeSecs-status.start_secs), status.start_secs, environment.log_fid);
            break;
        end
    end % keyIsDown
end

% Show fixation, prepare to enter trial loop
status.big_circle = 0;
status.continue = 1;
status.last_silence = 0;
status.lastPress = status.start_secs;
% status.snd_status = 0;

status.silence = 0;
status.snd_index = 0;

% Show initial fixation
fix_2_screen(status.big_circle, win_ptr, environment);
status.change_secs = status.start_secs + environment.silence_secs + environment.extra_silence + rand(1)*(environment.circle_chg_max_secs-environment.circle_chg_min_secs) + environment.circle_chg_min_secs;
peep_log_msg(sprintf('%s : Fix -. Change at %07.3f.\n', status.now_playing, status.change_secs-status.start_secs), status.start_secs, environment.log_fid);
write_event_2_file(status.start_secs, num2str(status.big_circle), 'silence', num2str(status.n_pulses_detected), 'ring_off', environment.csv_fid);

% Start sound loop
while status.continue
    status = handle_mri_keypress(environment, status);
    status.snd_status = PsychPortAudio('GetStatus', session.pahandle);
    
    % If no sound playing, do a bunch of stuff
    if ~status.snd_status.Active
        status = turn_sound_on_off(environment, session, status);
    end
    status = show_hide_bigcircle(environment, status);
end % while status.continue

% All done screen
try
    txt_2_screen('Relax.', status.win_ptr, environment);
catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    diary off;
    fclose('all');
    Screen('CloseAll');
    ShowCursor;
end

PsychPortAudio('Close', session.pahandle);

total_secs = GetSecs()-status.start_secs;
[mins, secs] = secs2mins(total_secs);
peep_log_msg(sprintf('Sil : Played %i sounds in %6.3f seconds; %s:%s; detected %i scanner triggers.\n', status.snd_index, total_secs, mins, secs, status.n_pulses_detected), status.start_secs, environment.log_fid);
clear;