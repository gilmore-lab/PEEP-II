function peep_run(session, environment)
% peep_run(session, environment)
%   Controls a particular run of the PEEP-II experiment
%
%   Called by: peep_mri.m

% Rick Gilmore, 2015-11-13

% 2015-11   rog wrote

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
catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end

% Load run and order data from file into cell array of filenames
peep_log_msg(sprintf('Initializing run %s, order %s for participant %s. Unfamiliar family is %s.\n', run, order, fam, nov), GetSecs(), environment.log_fid);
this_run_data = create_run_file_list(environment, session);

% Load first sound file since there is no silent period to start
snd_index = 1;
n_snds = height(this_run_data);
peep_log_msg(sprintf('Loading sound %i of %i sounds: %s.\n', snd_index, n_snds, char(this_run_data.File(snd_index))), GetSecs(), environment.log_fid);
[this_snd, snd_freq, nrchannels] = load_peep_sound(this_run_data.File(snd_index));

% Perform basic initialization of the sound driver:
InitializePsychSound;

% Open the default audio device [], with default mode [] (==Only playback),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of freq and nrchannels sound channels.
% This returns a handle to the audio device:
try
    % Try with the frequency we want
    pahandle = PsychPortAudio('Open', [], [], 0, snd_freq, nrchannels);
    PsychPortAudio('FillBuffer', pahandle, this_snd);
catch
    % Failed. Retry with default frequency as suggested by device:
    fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', snd_freq);
    fprintf('Sound may sound a bit out of tune, ...\n\n');
    psychlasterror('reset');
    pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
end

% Show ready to start run screen
KbReleaseWait;
peep_log_msg(sprintf('Press any key to switch study to scanner-triggered start mode.\n\n'), GetSecs(), environment.log_fid);
txt_2_screen('Ready to go!', win_ptr, environment);
KbStrokeWait;

% Wait for scanner trigger
peep_log_msg(sprintf('Ready to run. Start scanner. Script will start automatically on first non-DISDAQ pulse.\n'), GetSecs(), environment.log_fid);
n_pulses_detected = 0;

% Create and start Kb queues
KbQueueCreate(environment.external_kbd_index);
KbQueueStart(environment.external_kbd_index);
KbQueueCreate(environment.internal_kbd_index);
KbQueueStart(environment.internal_kbd_index);

while 1
    [pressed, firstPress] = KbQueueCheck(environment.external_kbd_index);
    timeSecs = firstPress(find(firstPress));
    start_secs = timeSecs;
    if pressed
        if firstPress(environment.tKey)            
            n_pulses_detected = n_pulses_detected + 1;
            peep_log_msg(sprintf('Scanner pulse %i detected. Starting.\n', n_pulses_detected), start_secs, environment.log_fid);
            write_event_2_file(start_secs, 'none', 'silence', num2str(n_pulses_detected), 'new_mri_vol', environment.csv_fid); 
            break;
        end
    end
    
    [pressed, firstPress] = KbQueueCheck(environment.internal_kbd_index);
    timeSecs = firstPress(find(firstPress));
    if pressed
        if firstPress(environment.escapeKey)            
            peep_log_msg(sprintf('Escape detected at %07.3f from start.\n', timeSecs-start_secs), start_secs, environment.log_fid);
            break;
        end
    end    
end
KbEventFlush(environment.internal_kbd_index);
KbEventFlush(environment.external_kbd_index);

% Play first sound
try
    snd_start_time = PsychPortAudio('Start', pahandle, 1, 0, 1);
    silence = 0;
    run_start_time = start_secs;
    peep_log_msg(sprintf('Snd : Started %i of %i: %s.\n', snd_index, n_snds, char(this_run_data.File(snd_index))), run_start_time,environment.log_fid);
    write_event_2_file(start_secs, 'none', char(this_run_data.File(snd_index)), num2str(n_pulses_detected), 'sound_on', environment.csv_fid);
catch
    peep_log_msg(sprintf('Failed to start sound %i of %i. Aborting.\n.', snd_index, n_snds), run_start_time, environment.log_fid);
    psychlasterror;
    psychlasterror('reset');
end

% Show fixation
big_circle = 0;
fix_2_screen(big_circle, win_ptr, environment);
write_event_2_file(start_secs, num2str(big_circle), char(this_run_data.File(snd_index)), num2str(n_pulses_detected), 'ring_off', environment.csv_fid);
change_secs = snd_start_time + rand(1)*(environment.circle_chg_max_secs-environment.circle_chg_min_secs) + environment.circle_chg_min_secs;
peep_log_msg(sprintf('Snd : Fix -. Change at %07.3f.\n', change_secs-snd_start_time), start_secs, environment.log_fid);

% Then loop for other sounds
while 1
    snd_status = PsychPortAudio('GetStatus', pahandle);
    if snd_status.Active
        % Detect keypresses from participant/scanner pulse
        [pressed, firstPress] = KbQueueCheck(environment.external_kbd_index);
%         timeSecs = firstPress(find(firstPress));
        if pressed
            if firstPress(environment.tKey)
                n_pulses_detected = n_pulses_detected + 1;
                peep_log_msg(sprintf('Scanner pulse %i detected. Starting.\n', n_pulses_detected), start_secs, environment.log_fid);
                break;
            end
            if (firstPress(environment.aKey)) || (firstPress(environment.bKey)) || (firstPress(environment.cKey)) || (firstPress(environment.dKey))
                peep_log_msg(sprintf('Participant press.\n'), start_secs, environment.log_fid);
                write_event_2_file(start_secs, num2str(big_circle), char(this_run_data.File(snd_index)), num2str(n_pulses_detected), 'keypress',environment.csv_fid);
            end
        end

        % Detect keypress from primary keyboard
        [pressed, firstPress] = KbQueueCheck(environment.internal_kbd_index);
        timeSecs = firstPress(find(firstPress));
        if pressed
            if firstPress(environment.escapeKey)
                peep_log_msg(sprintf('Escape detected at %07.3f from start.\n', timeSecs-start_secs), start_secs, environment.log_fid);
                break;
            end
        end

        % During sound, time to change fixation?
        if GetSecs() > change_secs
            if big_circle
                big_circle = 0;
                fix_2_screen(big_circle, win_ptr, environment);
                write_event_2_file(start_secs, num2str(big_circle), char(this_run_data.File(snd_index)), num2str(n_pulses_detected), 'ring_off', environment.csv_fid);
                % Compute change time in middle of next silent interval
                change_secs = GetSecs() + (10-snd_status.PositionSecs) + rand(1)*(3) + environment.circle_chg_min_secs;
                peep_log_msg(sprintf('Snd : Fix -. Change at %07.3f.\n', change_secs-start_secs), start_secs, environment.log_fid);
            else
                big_circle = 1;
                fix_2_screen(big_circle, win_ptr, environment);
                write_event_2_file(start_secs, num2str(big_circle), char(this_run_data.File(snd_index)), num2str(n_pulses_detected), 'ring_on', environment.csv_fid);
                change_secs = change_secs + environment.circle_chg_dur_secs;
                peep_log_msg(sprintf('Snd : Fix +. Change at %07.3f.\n', change_secs-start_secs), start_secs, environment.log_fid);
            end % if big_circle
        end % if GetSecs()
    else % Sound over
        % If not silence yet, start
        if ~silence
            % If prior sound was last, don't play silence.
            if snd_index == n_snds
                break;
            end
            
            % Start silent period
            sil_start = GetSecs();
            sil_end = sil_start + environment.silence_secs;
            silence = 1;
            peep_log_msg(sprintf('Sil : Sound duration %07.3f s.\n', sil_start-snd_start_time), start_secs, environment.log_fid);
            write_event_2_file(start_secs, num2str(big_circle), 'silence', num2str(n_pulses_detected), 'sound_off', environment.csv_fid);
            
            % Load next
            snd_index = snd_index + 1;
            peep_log_msg(sprintf('Sil : Loading sound %i of %i : %s.\n', snd_index, n_snds, char(this_run_data.File(snd_index))), start_secs, environment.log_fid);
            [this_snd, ~, ~] = load_peep_sound(this_run_data.File(snd_index));
            PsychPortAudio('FillBuffer', pahandle, this_snd, [], 0);
        end % if ~silence
        
        % Change circle?
        if (GetSecs() > change_secs)
            if big_circle
                big_circle = 0;
                fix_2_screen(big_circle, win_ptr, environment);
                write_event_2_file(start_secs, num2str(big_circle), char(this_run_data.File(snd_index)), num2str(n_pulses_detected), 'ring_off', environment.csv_fid);
                % Secs remaining in silence + random start in range
                change_secs = sil_end + rand(1)*(environment.circle_chg_max_secs-environment.circle_chg_min_secs) + environment.circle_chg_min_secs;
                %change_secs = environment.silence_secs - (GetSecs()-sil_start) + rand(1)*(environment.circle_chg_max_secs-environment.circle_chg_min_secs) + environment.circle_chg_min_secs;
                peep_log_msg(sprintf('Sil : Fix -. Change at %07.3f.\n', change_secs-start_secs), start_secs, environment.log_fid);
            else
                big_circle = 1;
                fix_2_screen(big_circle, win_ptr, environment);
                write_event_2_file(start_secs, num2str(big_circle), char(this_run_data.File(snd_index)), num2str(n_pulses_detected), 'ring_on', environment.csv_fid);
                change_secs = change_secs + environment.circle_chg_dur_secs;
                peep_log_msg(sprintf('Sil : Fix +. Change at %07.3f.\n', change_secs-start_secs), start_secs, environment.log_fid);
            end
        end % if (GetSecs()
        
        % Silence over? Then start new sound.
        if (GetSecs()-sil_start) > environment.silence_secs
            silence = 0;
            snd_start_time = PsychPortAudio('Start', pahandle, 1, 0, 1);
            peep_log_msg(sprintf('Snd : Silence duration %07.3f s. Started sound %i of %i: %s.\n', snd_start_time-sil_start, snd_index, n_snds, char(this_run_data.File(snd_index))), start_secs, environment.log_fid);
            write_event_2_file(start_secs, num2str(big_circle), 'silence', num2str(n_pulses_detected), 'sound_on', environment.csv_fid);
            sil_start = GetSecs() + 12;
        end
        
        % Detect keypresses from participant/scanner pulse
        [pressed, firstPress] = KbQueueCheck(environment.external_kbd_index);
%         timeSecs = firstPress(firstPress);
        if pressed
            if firstPress(environment.tKey)
                n_pulses_detected = n_pulses_detected + 1;
                peep_log_msg(sprintf('Scanner pulse %i detected. Starting.\n', n_pulses_detected), start_secs, environment.log_fid);
            end
            if (firstPress(environment.aKey)) || (firstPress(environment.bKey)) || (firstPress(environment.cKey)) || (firstPress(environment.dKey))
                peep_log_msg(sprintf('Participant press.\n'), start_secs, environment.log_fid);
                write_event_2_file(start_secs, num2str(big_circle), char(this_run_data.File(snd_index)), num2str(n_pulses_detected), 'keypress', environment.csv_fid);
            end
        end

        % Detect keypress from primary keyboard
        [pressed, firstPress] = KbQueueCheck(environment.internal_kbd_index);
        timeSecs = firstPress(find(firstPress));
        if pressed
            if firstPress(environment.escapeKey)
                peep_log_msg(sprintf('Escape detected at %07.3f from start.\n', timeSecs-start_secs), start_secs, environment.log_fid);
                break;
            end
        end
        
    end % if snd_status.Active
    
    [pressed, firstPress] = KbQueueCheck(environment.internal_kbd_index);
    timeSecs = firstPress(find(firstPress));
    if pressed
        if firstPress(environment.escapeKey)            
            peep_log_msg(sprintf('Escape detected at %07.3f from start.\n', timeSecs-start_secs), start_secs, environment.log_fid);
            break;
        end
    end    
end

% Clean-up
try
    txt_2_screen('All Finished!', win_ptr, environment);
catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end

KbQueueRelease(environment.external_kbd_index);
KbQueueRelease(environment.internal_kbd_index);
PsychPortAudio('Close', pahandle);
total_secs = GetSecs()-run_start_time;
[mins, secs] = secs2mins(total_secs);
peep_log_msg(sprintf('Played %i sounds in %6.3f seconds; %s:%s; detected %i scanner triggers.\n', snd_index, total_secs, mins, secs, n_pulses_detected), run_start_time, environment.log_fid);
return
