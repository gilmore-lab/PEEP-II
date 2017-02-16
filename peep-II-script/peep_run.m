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
catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    ShowCursor;
end

% Initialize status data structure
status = [];
status.now_playing = char(environment.now_playing_msgs(1));
status.curr_snd = 'silence';

% Load run and order data from file into cell array of filenames
peep_log_msg(sprintf('%s : Initializing run %s, order %s for participant %s. Unfamiliar family is %s.\n', status.now_playing, run, order, fam, nov), GetSecs(), environment.log_fid);
this_run_data = create_run_file_list(environment, session);

% Load first sound file since there is no silent period to start
% snd_index = 1;
snd_index = 1;
next_snd = 1;
n_snds = height(this_run_data);
peep_log_msg(sprintf('%s : Loading sound %i of %i sounds: %s.\n\n', status.now_playing, snd_index, n_snds, char(this_run_data.File(snd_index))), GetSecs(), environment.log_fid);
[~, snd_freq, nrchannels] = load_peep_sound(this_run_data.File(snd_index));

% Perform basic initialization of the sound driver:
InitializePsychSound;

% Open the default audio device [], with default mode [] (==Only playback),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
try
    % Try with the frequency we want
    pahandle = PsychPortAudio('Open', [], [], 0, snd_freq, nrchannels);
catch
    % Failed. Retry with default frequency as suggested by device:
    fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', snd_freq);
    fprintf('Sound may sound a bit out of tune, ...\n\n');
    psychlasterror('reset');
    pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
end

% Show ready to start run screen
[keyboardIndices, ~, ~] = GetKeyboardIndices();
peep_log_msg(sprintf('%s : Press TAB key to switch study to scanner-triggered start mode.\n', status.now_playing), GetSecs(), environment.log_fid);
txt_2_screen('Ready to go!', win_ptr, environment);
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

silence = 0;
snd_index = 0;

% Show initial fixation
fix_2_screen(status.big_circle, win_ptr, environment);
change_secs = status.start_secs + environment.silence_secs + environment.extra_silence + rand(1)*(environment.circle_chg_max_secs-environment.circle_chg_min_secs) + environment.circle_chg_min_secs;
peep_log_msg(sprintf('%s : Fix -. Change at %07.3f.\n', status.now_playing, change_secs-status.start_secs), status.start_secs, environment.log_fid);
write_event_2_file(status.start_secs, num2str(status.big_circle), 'silence', num2str(status.n_pulses_detected), 'ring_off', environment.csv_fid);

% Start sound loop
while status.continue
    snd_status = PsychPortAudio('GetStatus', pahandle);
    [ status ] = handle_mri_keypress(environment, status);
    if snd_status.Active        
        % During sound, time to change fixation?
        if GetSecs() > change_secs
            if status.big_circle
                status.big_circle = 0;
                fix_2_screen(status.big_circle, win_ptr, environment);
                write_event_2_file(status.start_secs, num2str(status.big_circle), status.curr_snd, num2str(status.n_pulses_detected), 'ring_off', environment.csv_fid);
                % Compute change time in middle of next silent interval
                change_secs = GetSecs() + (10-snd_status.PositionSecs) + rand(1)*(3) + environment.circle_chg_min_secs;
                peep_log_msg(sprintf('%s : Fix -. Change at %07.3f.\n', status.now_playing, change_secs-status.start_secs), status.start_secs, environment.log_fid);
            else
                status.big_circle = 1;
                fix_2_screen(status.big_circle, win_ptr, environment);
                write_event_2_file(status.start_secs, num2str(status.big_circle), status.curr_snd, num2str(status.n_pulses_detected), 'ring_on', environment.csv_fid);
                change_secs = change_secs + environment.circle_chg_dur_secs;
                peep_log_msg(sprintf('%s : Fix +. Change at %07.3f.\n', status.now_playing, change_secs-status.start_secs), status.start_secs, environment.log_fid);
            end % if status.big_circle
        end % if GetSecs()
    else % Sound over/not playing yet
%         status.now_playing = char(environment.now_playing_msgs(1));
%         status.curr_snd = 'silence';
       
        % If not silence yet, start
        if ~silence
            % Start silent period
            sil_start = GetSecs();
            silence = 1;
            status.now_playing = char(environment.now_playing_msgs(1));
            status.curr_snd = 'silence';
            if snd_index == 0 % first silence
                sil_end = sil_start + environment.silence_secs + environment.extra_silence;
                peep_log_msg(sprintf('%s : Intro silence, end at %07.3f.\n', status.now_playing, sil_end-status.start_secs), status.start_secs, environment.log_fid);               
            else
                sil_end = sil_start + environment.silence_secs;
                peep_log_msg(sprintf('%s : Sound duration %07.3f s.\n', status.now_playing, sil_start-snd_start_time), status.start_secs, environment.log_fid);
            end % if snd_index
            write_event_2_file(status.start_secs, num2str(status.big_circle), status.curr_snd, num2str(status.n_pulses_detected), 'sound_off', environment.csv_fid);

            % if not end, load next sound
            next_snd = snd_index + 1;
            if next_snd <= n_snds
                peep_log_msg(sprintf('%s : Loading sound %i of %i : %s.\n', status.now_playing, next_snd, n_snds, char(this_run_data.File(next_snd))), status.start_secs, environment.log_fid);
                [this_snd, ~, ~] = load_peep_sound(this_run_data.File(next_snd));
                PsychPortAudio('FillBuffer', pahandle, this_snd, [], 0);
                snd_index = next_snd;
            else
                status.now_playing = char(environment.now_playing_msgs(1));
                peep_log_msg(sprintf('%s : Last sound finished.\n', status.now_playing), status.start_secs, environment.log_fid);
                peep_log_msg(sprintf('%s : Last silent period starting.\n', status.now_playing), status.start_secs, environment.log_fid);
                status.last_silence = 1;
            end % if next_snd 
        end % if ~silence
        
        % Change circle?
        if (GetSecs() > change_secs)
            if status.big_circle
                status.big_circle = 0;
                fix_2_screen(status.big_circle, win_ptr, environment);
                write_event_2_file(status.start_secs, num2str(status.big_circle), status.curr_snd, num2str(status.n_pulses_detected), 'ring_off', environment.csv_fid);
                change_secs = sil_end + rand(1)*(environment.circle_chg_max_secs-environment.circle_chg_min_secs) + environment.circle_chg_min_secs;
                peep_log_msg(sprintf('%s : Fix -. Change at %07.3f.\n', status.now_playing, change_secs-status.start_secs), status.start_secs, environment.log_fid);
            else
                status.big_circle = 1;
                fix_2_screen(status.big_circle, win_ptr, environment);
                write_event_2_file(status.start_secs, num2str(status.big_circle), status.curr_snd, num2str(status.n_pulses_detected), 'ring_on', environment.csv_fid);
                change_secs = change_secs + environment.circle_chg_dur_secs;
                peep_log_msg(sprintf('%s : Fix +. Change at %07.3f.\n', status.now_playing, change_secs-status.start_secs), status.start_secs, environment.log_fid);
            end
        end % if (GetSecs()
        
        % Silence over? Then start new sound if not at end
        if (GetSecs() > sil_end)
            if status.last_silence
                break;
            else
                silence = 0;
                snd_start_time = PsychPortAudio('Start', pahandle, 1, 0, 1);
                peep_log_msg(sprintf('%s : Silence duration %07.3f s.\n', status.now_playing, snd_start_time-sil_start), status.start_secs, environment.log_fid);
                status.now_playing = char(environment.now_playing_msgs(2));
                status.curr_snd = char(this_run_data.File(snd_index));
                snd_index = next_snd;
                peep_log_msg(sprintf('%s : Started sound %i of %i: %s.\n', status.now_playing, snd_index, n_snds, char(this_run_data.File(snd_index))), status.start_secs, environment.log_fid);
                write_event_2_file(status.start_secs, num2str(status.big_circle), status.curr_snd, num2str(status.n_pulses_detected), 'sound_on', environment.csv_fid);
                sil_start = GetSecs() + 12; % 10 s sound + 2 s buffer from start
            end % if status.last_silence
        end % if (GetSecs()
    end % if snd_status.Active
end % while status.continue

% All done screen
try
    txt_2_screen('Relax.', win_ptr, environment);
catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    diary off;
    fclose('all');
    Screen('CloseAll');
    ShowCursor;
end

PsychPortAudio('Close', pahandle);

total_secs = GetSecs()-status.start_secs;
[mins, secs] = secs2mins(total_secs);
peep_log_msg(sprintf('Sil : Played %i sounds in %6.3f seconds; %s:%s; detected %i scanner triggers.\n', snd_index, total_secs, mins, secs, status.n_pulses_detected), status.start_secs, environment.log_fid);
