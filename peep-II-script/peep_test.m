function peep_test(n_snds)

cd('~/github/gilmore-lab/peep-II/peep-II-script/');
if nargin < 1
    n_snds = 4;
end
if n_snds > 33
    n_snds = 33;
end

fprintf('Planning to play %i sounds.\n', n_snds);

fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'), 'Starting peep_test\n');
fam_id = '9999';
nov_id = '9998';
run = '1';
order = '1';
escapeKey = KbName('ESCAPE');
sil_secs = 6;

% Read data and subset
run_orders = readtable('run-orders/run_orders.csv');
this_run_order = (run_orders.Run == str2num(run)) & (run_orders.Order == str2num(order));
this_run_data = run_orders(this_run_order, [1 2 3 6 7]);
fam = strcmp(this_run_data.Speaker, 'fam');
this_run_data(fam,1) = {fam_id};
this_run_data(~fam,1) = {nov_id};
this_run_data.File = strcat('wav/', this_run_data.Speaker, '/norm/', this_run_data.Speaker, '-', this_run_data.Emotion, '-', this_run_data.Script, '-', this_run_data.Version, '.wav');

% Load first sound file since there is no silent period to start
snd_index = 1;
fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
fprintf('Loading sound %i of %i sounds: %s.\n', snd_index, n_snds, char(this_run_data.File(snd_index)));
[this_snd, snd_freq, nrchannels] = load_sound(this_run_data.File(snd_index));

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
fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
fprintf('Press any key when ready to start\n');
KbStrokeWait;
start_secs = PsychPortAudio('Start', pahandle, 1, 0, 1);
start_this = start_secs;
sil_start = start_secs + 12;
fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
fprintf('Started sound 1 of %i: %s.\n', n_snds, char(this_run_data.File(snd_index)));
silence = 0;

while 1
    snd_status = PsychPortAudio('GetStatus', pahandle);
    if (~snd_status.Active)        
        if ~silence
            if snd_index == n_snds
                break
            end
            
            % Start silent period         
            sil_start = GetSecs();
            silence = 1;
            fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
            fprintf('Sound over after %3.3f s; starting silence.\n', sil_start-start_this);
           
            % Load next
            fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
            snd_index = snd_index + 1;
            fprintf('Loading sound %i of %i sounds: %s.\n', snd_index, n_snds, char(this_run_data.File(snd_index)));
            [this_snd, ~, ~] = load_sound(this_run_data.File(snd_index));
            PsychPortAudio('FillBuffer', pahandle, this_snd, [], 0);
        end
        
        if (GetSecs()-sil_start) > sil_secs
            silence = 0;
            start_this = PsychPortAudio('Start', pahandle, 1, 0, 1);
            fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
            fprintf('Ended silence with latency %3.3f s. Started sound %i of %i: %s.\n', start_this-sil_start, snd_index, n_snds, char(this_run_data.File(snd_index)));
            sil_start = GetSecs() + 12;
        end
        
        [ keyIsDown, keySecs, keyCode ] = KbCheck;
        if keyIsDown
            if keyCode(escapeKey)
                fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
                fprintf('Escape detected at %3.3f from start.\n', keySecs-start_secs);
                break;
            end
        end
    end
    
    [ keyIsDown, keySecs, keyCode ] = KbCheck;
    if keyIsDown
        if keyCode(escapeKey)
            fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
            fprintf('Escape detected at %3.3f from start.\n', keySecs-start_secs);
            break;
        end
    end
end

% % Clean-up
PsychPortAudio('Close', pahandle);
fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
fprintf('Played %i sounds in %3.3f s.\n', snd_index, GetSecs() - start_secs);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [this_snd, snd_freq, nrchannels] = load_sound(snd_fn)

[this_snd, snd_freq] = audioread(char(snd_fn));
nrchannels = size(this_snd,2);

% nrchannels must be 2 for some soundcards
if nrchannels < 2
    this_snd = [this_snd' ; this_snd'];
    nrchannels = 2;
end

return

