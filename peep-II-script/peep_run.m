function peep_run(session, environment)

if (nargin < 2)
    load('default_session.mat');
    load('default_environment.mat');
end

if isempty(session)
    fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
    fprintf('Session is blank; loading default_session.mat.\n');
    session = load('default_session.mat');
    session.timestamp = datestr(now, 'yyyy-mm-dd-HH:MM:SS');
else
    run = session.run;
    order = session.order;
    fam = session.this_family;
    nov = session.nov_family;
    timestamp = session.timestamp;
end

% Load run and order data from file into cell array of filenames
fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
fprintf('Initializing run %s, order %s for participant %s. Unfamiliar family is %s.\n', run, order, fam, nov);
this_run_data = create_run_file_list(environment, session);

% Load first sound file since there is no silent period to start
snd_index = 1;
n_snds = height(this_run_data);
fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
fprintf('Loading sound %i of %i sounds: %s.\n', snd_index, n_snds, char(this_run_data.File(snd_index)));
[this_snd, snd_freq, nrchannels] = load_peep_sound(this_run_data.File(snd_index), environment, session);

% Perform basic initialization of the sound driver:
InitializePsychSound;

% Open the default audio device [], with default mode [] (==Only playback),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of freq and nrchannels sound channels.
% This returns a handle to the audio device:
try
    % Try with the 'freq'uency we wanted:
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
fprintf('%s : Initial sound loaded.\n', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
fprintf('Press any key when ready to switch study to scanner-triggered start mode.\n\n');
KbStrokeWait;

% Wait for scanner trigger
fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
fprintf('Ready to run. Start scanner. Script will start automatically on first non-DISDAQ pulse.\n');
n_pulses_detected = 0;
while 1
    [ keyIsDown, startSecs, keyCode ] = KbCheck;
    if keyIsDown
        if keyCode(environment.tKey)
            fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
            n_pulses_detected =+ 1;
            fprintf('Scanner pulse %i detected. Starting.\n', n_pulses_detected);
            break;
        end
        KbReleaseWait;
    end
end

% Play first sound
try
    snd_start_time = PsychPortAudio('Start', pahandle, 1, 0, 1);
    playing_snd = 1;
    snd_end_time = snd_start_time + environment.sound_secs; % for first loop
    run_start_time = snd_start_time;
    fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
    fprintf('Started sound %i of %i sounds: %s.\n', snd_index, n_snds, char(this_run_data.File(snd_index)));
catch
    fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
    fprintf('Failed to start sound %i of %i\n', snd_index, n_snds, snd_start_time-startSecs);
    fprintf('Aborting.\n');
    psychlasterror;
    psychlasterror('reset');
end

% then loop for other sounds
while 1
    % Get sound status
    snd_status = PsychPortAudio('GetStatus', pahandle);
    snd_elapsed_time = snd_status.CurrentStreamTime;

%     fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
%     fprintf('Active is %i; CPU Load is %3.3f; %3.3f elapsed time\n', snd_status.Active, snd_status.CPULoad, snd_elapsed_time);
    
    % Stop sound if > 10s, load new.
    if ((snd_elapsed_time - snd_start_time) > environment.sound_secs) && playing_snd
        PsychPortAudio('Stop', pahandle);
        snd_end_time = GetSecs();
        playing_snd = 0; 

        fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
        fprintf('Sound played for %3.3f secs, starting silent period.\n', snd_elapsed_time - snd_start_time);
        
        snd_index = snd_index + 1;
        
        if (snd_index < n_snds)
            fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
            fprintf('Loading sound %i of %i sounds: %s.\n', snd_index, n_snds, char(this_run_data.File(snd_index)));
            try
                [this_snd, ~] = load_peep_sound(this_run_data.File(snd_index), environment, session);              
                PsychPortAudio('FillBuffer', pahandle, this_snd, [], 0);
                
                fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
                fprintf('Buffer filled. Ready to play when scheduled.\n');
                snd_loaded = 1;
            catch
                fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
                fprintf('Failed to load sound %i of %i.\n', snd_index, n_snds);
                fprintf('Aborting.\n');
                psychlasterror;
                psychlasterror('reset');
            end
        else
            fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
            fprintf('Last sound played.\n')
            break;
        end
    end

    % If end of silence, start next sound
    if ((GetSecs - snd_end_time) > environment.silence_secs) && not(playing_snd)
        try
            fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
            fprintf('Starting sound %i of %i sounds: %s.\n', snd_index, n_snds, char(this_run_data.File(snd_index)));
            %s.\n', snd_index, n_snds, char(this_run_data.File(snd_index)))
            snd_start_time = PsychPortAudio('Start', pahandle, 1, 0, 1);
            playing_snd = 1;
        catch
            fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
            fprintf('Failed to start sound %i of %i.\n', snd_index, n_snds);
            fprintf('Aborting.\n');
            psychlasterror;
            psychlasterror('reset');
        end
    end
    
    % Detect keypress or trigger pulse events and handle
    [ keyIsDown, keySecs, keyCode ] = KbCheck;
    if keyIsDown
        if keyCode(environment.tKey)
            fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
            n_pulses_detected =+ 1;
            fprintf('Scanner pulse %i detected at %3.3f from start.\n', n_pulses_detected, keySecs-startSecs);
        end
        if keyCode(environment.escapeKey)
            fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
            fprintf('Escape detected at %3.3f from start.\n', keySecs-startSecs);
            break;
        end
    end
    WaitSecs('YieldSecs', 0.05);
end


% Clean-up
PsychPortAudio('Close', pahandle);
fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
fprintf('Played %i sounds in %3.3f seconds; detected %i scanner triggers.\n', snd_index, snd_end_time-run_start_time, n_pulses_detected);

return
