function peep_run(session, environment)
% peep_ratings(session, environment)
%   Controls a particular run of the PEEP-II ratings experiment.
%
%   Called by: peep_mri.m

% Rick Gilmore, 2015-11-13

% 2015-11-xx rog wrote
% 2015-11-16 rog added separate keyboard detection.
% 2015-11-18 rog added switch b/w keyboard detection modes
% 2015-12-03 add 10s sound at beginning, 6s at end, fix orders 3 and 4.
% 2015-12-10 rog fixed automatic mapping of USB inputs.
% 2015-12-20 rog tweaked console output, added internal kbd 't' detection.
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

% Load run and order data from file into cell array of filenames
peep_log_msg(sprintf('Non : Initializing run %s, order %s for participant %s. Unfamiliar family is %s.\n', run, order, fam, nov), GetSecs(), environment.log_fid);
this_run_data = create_run_file_list(environment, session);

% Load first sound file since there is no silent period to start
snd_index = 1;
n_snds = height(this_run_data);
peep_log_msg(sprintf('Non : Loading sound %i of %i sounds: %s.\n\n', snd_index, n_snds, char(this_run_data.File(snd_index))), GetSecs(), environment.log_fid);
[this_snd, snd_freq, nrchannels] = load_peep_sound(this_run_data.File(snd_index));

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
KbReleaseWait;
peep_log_msg(sprintf('Non : Press any key to switch study to scanner-triggered start mode.\n'), GetSecs(), environment.log_fid);
txt_2_screen('Ready to go!', win_ptr, environment);
KbStrokeWait;

% Wait for scanner trigger
peep_log_msg(sprintf('Non : Ready to run. Start scanner. Script will start automatically on first non-DISDAQ pulse.\n'), GetSecs(), environment.log_fid);
n_pulses_detected = 0;

% Create and start Kb queues
switch environment.kbds
    case 2 % Rick's office set-up
        keysOfInterest = environment.keysOfInterest(1,:);
        KbQueueCreate(environment.internal_kbd_index, keysOfInterest);
        KbQueueStart(environment.internal_kbd_index);
        
        keysOfInterest = sum(environment.keysOfInterest(2:3,:),1);
        KbQueueCreate(environment.external_kbd_index, keysOfInterest);
        KbQueueStart(environment.external_kbd_index);
    case 3 % SLEIC
        keysOfInterest = environment.keysOfInterest(1,:);
        KbQueueCreate(environment.internal_kbd_index, keysOfInterest);
        KbQueueStart(environment.internal_kbd_index);
        
        keysOfInterest = environment.keysOfInterest(2,:);
        KbQueueCreate(environment.external_kbd_index, keysOfInterest);
        KbQueueStart(environment.external_kbd_index);
        
        keysOfInterest = environment.keysOfInterest(3,:);
        KbQueueCreate(environment.trigger_kbd_index, keysOfInterest);
        KbQueueStart(environment.trigger_kbd_index);
    otherwise
        keysOfInterest = sum(environment.keysOfInterest,1); % by columns
        KbQueueCreate(environment.internal_kbd_index, keysOfInterest);
        KbQueueStart(environment.internal_kbd_index);        
end % switch

while 1
    [pressed, firstPress] = KbQueueCheck(environment.trigger_kbd_index);
    timeSecs = firstPress(find(firstPress));
    start_secs = timeSecs;
    if pressed
        if firstPress(environment.tKey)          
            n_pulses_detected = n_pulses_detected + 1;
            run_start_time = start_secs;
            peep_log_msg(sprintf('Non : Scanner pulse %i detected. Starting. \n', n_pulses_detected), start_secs, environment.log_fid);
            write_event_2_file(start_secs, 'none', 'silence', num2str(n_pulses_detected), 'new_mri_vol', environment.csv_fid); 
            break;
        end
    end
    
    [pressed, firstPress] = KbQueueCheck(environment.internal_kbd_index);
    timeSecs = firstPress(find(firstPress));
    if pressed
        if firstPress(environment.tKey)
            n_pulses_detected = n_pulses_detected + 1;
            run_start_time = start_secs;
            peep_log_msg(sprintf('Non : Manual start detected.\n', n_pulses_detected), start_secs, environment.log_fid);
            write_event_2_file(start_secs, 'none', 'silence', num2str(n_pulses_detected), 'new_mri_vol', environment.csv_fid); 
        end
        if firstPress(environment.escapeKey)            
            peep_log_msg(sprintf('Non : Escape detected at %07.3f from start.\n', timeSecs-start_secs), start_secs, environment.log_fid);
            break;
        end
    end    
end
KbEventFlush(environment.internal_kbd_index);
KbEventFlush(environment.trigger_kbd_index);

% Show fixation, prepare to enter trial loop
big_circle = 0;
silence = 0;
fix_2_screen(big_circle, win_ptr, environment);
change_secs = start_secs + environment.silence_secs + environment.extra_silence + rand(1)*(environment.circle_chg_max_secs-environment.circle_chg_min_secs) + environment.circle_chg_min_secs;
peep_log_msg(sprintf('Sil : Fix -. Change at %07.3f.\n', change_secs-start_secs), start_secs, environment.log_fid);
write_event_2_file(start_secs, num2str(big_circle), 'silence', num2str(n_pulses_detected), 'sound_off', environment.csv_fid);

% Then loop for other sounds
while 1
    snd_status = PsychPortAudio('GetStatus', pahandle);
    if snd_status.Active
        switch environment.kbds
            case 3 % SLEIC
                % Detect keypress from scanner pulse
                [pressed, ~] = KbQueueCheck(environment.trigger_kbd_index);
                if pressed
                    n_pulses_detected = n_pulses_detected + 1;
                    peep_log_msg(sprintf('Snd : Scanner pulse %i detected.\n', n_pulses_detected), start_secs, environment.log_fid);
                    write_event_2_file(start_secs, num2str(big_circle), char(this_run_data.File(snd_index)), num2str(n_pulses_detected), 'new_mri_vol', environment.csv_fid); 
                end

                % Detect keypress from participant
                [pressed, ~] = KbQueueCheck(environment.external_kbd_index);
                if pressed
                    peep_log_msg(sprintf('Snd : Participant press.\n'), start_secs, environment.log_fid);
                    write_event_2_file(start_secs, num2str(big_circle), char(this_run_data.File(snd_index)), num2str(n_pulses_detected), 'keypress',environment.csv_fid);
                end

                % Detect keypress from primary keyboard
                [pressed, firstPress] = KbQueueCheck(environment.internal_kbd_index);
                timeSecs = firstPress(find(firstPress));
                if pressed
                    peep_log_msg(sprintf('Snd : Escape detected at %07.3f from start.\n', timeSecs-start_secs), start_secs, environment.log_fid);
                    break;
                end
            case 2
                [pressed, firstPress] = KbQueueCheck(environment.external_kbd_index);
                if pressed
                    if firstPress(environment.tKey)
                        n_pulses_detected = n_pulses_detected + 1;
                        peep_log_msg(sprintf('Snd : Scanner pulse %i detected.\n', n_pulses_detected), start_secs, environment.log_fid);
                        write_event_2_file(start_secs, num2str(big_circle), char(this_run_data.File(snd_index)), num2str(n_pulses_detected), 'new_mri_vol', environment.csv_fid); 
                    else
                        peep_log_msg(sprintf('Snd : Participant press.\n'), start_secs, environment.log_fid);
                        write_event_2_file(start_secs, num2str(big_circle), char(this_run_data.File(snd_index)), num2str(n_pulses_detected), 'keypress',environment.csv_fid);
                    end
                end

                [pressed, firstPress] = KbQueueCheck(environment.internal_kbd_index);
                timeSecs = firstPress(find(firstPress));
                if pressed
                    if firstPress(environment.escapeKey)
                        peep_log_msg(sprintf('Snd : Escape detected at %07.3f from start.\n', timeSecs-start_secs), start_secs, environment.log_fid);
                        break;
                    end
                end % if pressed
            case 1
                % Detect keypress from primary keyboard
                [pressed, firstPress] = KbQueueCheck(environment.internal_kbd_index);
                timeSecs = firstPress(find(firstPress));
                if pressed
                    if firstPress(environment.escapeKey)
                        peep_log_msg(sprintf('Snd : Escape detected at %07.3f from start.\n', timeSecs-start_secs), start_secs, environment.log_fid);
                        break;
                    elseif firstPress(environment.tKey)
                        n_pulses_detected = n_pulses_detected + 1;
                        peep_log_msg(sprintf('Snd : Scanner pulse %i detected.\n', n_pulses_detected), start_secs, environment.log_fid);
                        write_event_2_file(start_secs, num2str(big_circle), char(this_run_data.File(snd_index)), num2str(n_pulses_detected), 'new_mri_vol', environment.csv_fid);
                        sprintf('\b\r');
                    else
                        peep_log_msg(sprintf('Snd : Participant press.\n'), start_secs, environment.log_fid);
                        write_event_2_file(start_secs, num2str(big_circle), char(this_run_data.File(snd_index)), num2str(n_pulses_detected), 'keypress',environment.csv_fid);
                        sprintf('\b\r');
                    end % if firstPress
                end % if pressed
        end % switch

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
        % process keypresses
        switch environment.kbds
            case 3 % SLEIC
                % Detect keypress from scanner pulse
                [pressed, ~] = KbQueueCheck(environment.trigger_kbd_index);
                if pressed
                    n_pulses_detected = n_pulses_detected + 1;
                    peep_log_msg(sprintf('Sil : Scanner pulse %i detected.\n', n_pulses_detected), start_secs, environment.log_fid);
                    write_event_2_file(start_secs, num2str(big_circle), 'silence', num2str(n_pulses_detected), 'new_mri_vol', environment.csv_fid); 
                end

                % Detect keypress from participant
                [pressed, ~] = KbQueueCheck(environment.external_kbd_index);
                if pressed
                    peep_log_msg(sprintf('Sil : Participant press.\n'), start_secs, environment.log_fid);
                    write_event_2_file(start_secs, num2str(big_circle), 'silence', num2str(n_pulses_detected), 'keypress',environment.csv_fid);
                end
        
                % Detect keypress from primary keyboard
                [pressed, firstPress] = KbQueueCheck(environment.internal_kbd_index);
                timeSecs = firstPress(find(firstPress));
                if pressed
                    peep_log_msg(sprintf('Sil: Escape detected at %07.3f from start.\n', timeSecs-start_secs), start_secs, environment.log_fid);
                    break;
                end
            case 2
                [pressed, firstPress] = KbQueueCheck(environment.external_kbd_index);
                if pressed
                    if firstPress(environment.tKey)
                        n_pulses_detected = n_pulses_detected + 1;
                        peep_log_msg(sprintf('Sil : Scanner pulse %i detected.\n', n_pulses_detected), start_secs, environment.log_fid);
                        write_event_2_file(start_secs, num2str(big_circle), 'silence', num2str(n_pulses_detected), 'new_mri_vol', environment.csv_fid); 
                    else
                        peep_log_msg(sprintf('Sil : Participant press.\n'), start_secs, environment.log_fid);
                        write_event_2_file(start_secs, num2str(big_circle), 'silence', num2str(n_pulses_detected), 'keypress',environment.csv_fid);
                    end
                end
        
                [pressed, firstPress] = KbQueueCheck(environment.internal_kbd_index);
                timeSecs = firstPress(find(firstPress));
                if pressed
                    if firstPress(environment.escapeKey)
                        peep_log_msg(sprintf('Sil : Escape detected at %07.3f from start.\n', timeSecs-start_secs), start_secs, environment.log_fid);
                        break;
                    end
                end % if pressed
            case 1
                % Detect keypress from primary keyboard
                [pressed, firstPress] = KbQueueCheck(environment.internal_kbd_index);
                timeSecs = firstPress(find(firstPress));
                if pressed
                    if firstPress(environment.escapeKey)
                        peep_log_msg(sprintf('Sil : Escape detected at %07.3f from start.\n', timeSecs-start_secs), start_secs, environment.log_fid);
                        break;
                    elseif firstPress(environment.tKey)
                        n_pulses_detected = n_pulses_detected + 1;
                        peep_log_msg(sprintf('Sil : Scanner pulse %i detected.\n', n_pulses_detected), start_secs, environment.log_fid);
                        write_event_2_file(start_secs, num2str(big_circle), 'silence', num2str(n_pulses_detected), 'new_mri_vol', environment.csv_fid); 
                    else
                        peep_log_msg(sprintf('Sil: Participant press.\n'), start_secs, environment.log_fid);
                        write_event_2_file(start_secs, num2str(big_circle), 'silence', num2str(n_pulses_detected), 'keypress',environment.csv_fid);
                    end % if firstPress
                end % if pressed
        end % switch

        % If not silence yet, start
        if ~silence
            % Start silent period
            sil_start = GetSecs();
            silence = 1;   
            if snd_index == 1 % first silence
                sil_end = sil_start + environment.silence_secs + environment.extra_silence;
                peep_log_msg(sprintf('Sil : Intro silence, end at %07.3f.\n', sil_end-start_secs), start_secs, environment.log_fid);
            else
                sil_end = sil_start + environment.silence_secs;
                peep_log_msg(sprintf('Sil : Sound duration %07.3f s.\n', sil_start-snd_start_time), start_secs, environment.log_fid);
            end            
            write_event_2_file(start_secs, num2str(big_circle), 'silence', num2str(n_pulses_detected), 'sound_off', environment.csv_fid);
            
            % Load next
            peep_log_msg(sprintf('Sil : Loading sound %i of %i : %s.\n', snd_index, n_snds, char(this_run_data.File(snd_index))), start_secs, environment.log_fid);
            [this_snd, ~, ~] = load_peep_sound(this_run_data.File(snd_index));
            PsychPortAudio('FillBuffer', pahandle, this_snd, [], 0);
            snd_index = snd_index + 1;
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
        if (GetSecs() > sil_end)
            silence = 0;
            snd_start_time = PsychPortAudio('Start', pahandle, 1, 0, 1);
            peep_log_msg(sprintf('Snd : Silence duration %07.3f s.\n', snd_start_time-sil_start), start_secs, environment.log_fid);
            peep_log_msg(sprintf('Snd : Started sound %i of %i: %s.\n',snd_index-1, n_snds, char(this_run_data.File(snd_index-1))), start_secs, environment.log_fid); 
            write_event_2_file(start_secs, num2str(big_circle), 'silence', num2str(n_pulses_detected), 'sound_on', environment.csv_fid);
            sil_start = GetSecs() + 12;
        end
        
    end % if snd_status.Active
    
    [pressed, firstPress] = KbQueueCheck(environment.internal_kbd_index);
    timeSecs = firstPress(find(firstPress));
    if pressed
        peep_log_msg(sprintf('Escape detected at %07.3f from start.\n', timeSecs-start_secs), start_secs, environment.log_fid);
        break;
    end    
end

% Clean-up
% Flush and release kbd event queues
switch environment.kbds
    case 3
        KbEventFlush(environment.trigger_kbd_index);
        KbQueueRelease(environment.internal_kbd_index);
    case 2
        KbEventFlush(environment.external_kbd_index);
        KbQueueRelease(environment.external_kbd_index);
end
KbEventFlush(environment.internal_kbd_index);
KbQueueRelease(environment.internal_kbd_index);

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

total_secs = GetSecs()-run_start_time;
[mins, secs] = secs2mins(total_secs);
peep_log_msg(sprintf('Played %i sounds in %6.3f seconds; %s:%s; detected %i scanner triggers.\n', snd_index, total_secs, mins, secs, n_pulses_detected), run_start_time, environment.log_fid);
end
