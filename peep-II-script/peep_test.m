function peep_test(n_snds)
% peep_test(n_snds)
%   Simplified test script for ensuring that sounds play, images display.

% 2015-11-04 rogilmore created.
% 2015-11-05 rogilmore modified.

% Wish list:
% 1. Add visual display of a) instructions, b) fixation/big circle.
% 3. Write behavioral data, including pulse timing to file.

%-------------------------------------------------------------------------


cd('~/github/gilmore-lab/peep-II/peep-II-script/');

if nargin < 1
    n_snds = 4;
end
if n_snds > 33
    n_snds = 33;
end

fam_id = '9999';
nov_id = '9998';
run = '1';
order = '1';

log_fn = strcat('log/', fam_id, '-', datestr(now, 'yyyy-mm-dd-HHMM'), '-run-', run, '-order-', order, '.log');
[log_fid, message] = fopen(log_fn, 'w'); 

log_msg(sprintf('Planning to play %i sounds.\n', n_snds), GetSecs(), log_fid);
log_msg('Starting peep_test.\n', GetSecs(), log_fid);

escapeKey = KbName('ESCAPE');
tKey = KbName('t');
aKey = KbName('a');
bKey = KbName('b');
cKey = KbName('c');
dKey = KbName('d');

sil_secs = 6;
circle_chg_min_secs = 1.5; % 1.5 s from start of sound or silence
circle_chg_max_secs = 8.5; % 1.5 s from end of sound or silence
circle_chg_dur_secs = 1;   % 1 s duration

% Read data and subset
run_orders = readtable('run-orders/run_orders.csv');
this_run_order = (run_orders.Run == str2double(run)) & (run_orders.Order == str2double(order));
this_run_data = run_orders(this_run_order, [1 2 3 6 7]);
fam = strcmp(this_run_data.Speaker, 'fam');
this_run_data(fam,1) = {fam_id};
this_run_data(~fam,1) = {nov_id};
this_run_data.File = strcat('wav/', this_run_data.Speaker, '/norm/', this_run_data.Speaker, '-', this_run_data.Emotion, '-', this_run_data.Script, '-', this_run_data.Version, '.wav');

% Load first sound file since there is no silent period to start
snd_index = 1;
log_msg(sprintf('Loading sound %i of %i sounds: %s.\n', snd_index, n_snds, char(this_run_data.File(snd_index))), GetSecs(), log_fid);

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
% fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
% fprintf('Press any key when ready to start\n');
% fprintf(log_fid, '%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
% fprintf(log_fid, 'Press any key when ready to start\n');
log_msg(sprintf('Press any key when ready to start\n'), GetSecs(), log_fid);

KbStrokeWait;
start_secs = PsychPortAudio('Start', pahandle, 1, 0, 1);
start_this = start_secs;
sil_start = start_secs + 12; % Made bigger than 10 s so the interval doesn't start early.
% fprintf('%s : %07.3f s: ', ts, secs_fr_start);
% fprintf('Started sound 1 of %i: %s.\n', n_snds, char(this_run_data.File(snd_index)));
% fprintf(log_fid, '%s : %07.3f s: ', ts, secs_fr_start);
% fprintf('Started sound 1 of %i: %s.\n', n_snds, char(this_run_data.File(snd_index)));
log_msg(sprintf('Started sound 1 of %i: %s.\n', n_snds, char(this_run_data.File(snd_index))), start_secs, log_fid);
silence = 0;

% Show circle
big_circle = 0;
change_secs = start_secs + rand(1)*(circle_chg_max_secs-circle_chg_min_secs) + circle_chg_min_secs;
% fprintf('%s : %07.3f s: ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'), GetSecs()-start_secs);
% fprintf('Showing fixation. Change at %07.3f.\n', change_secs-start_secs);
log_msg(sprintf('Showing fixation. Change at %07.3f.\n', change_secs-start_secs), start_secs, log_fid);

while 1
    snd_status = PsychPortAudio('GetStatus', pahandle);
    
    if GetSecs() > change_secs
        if big_circle
            big_circle = 0;
            change_secs = GetSecs() + (10-snd_status.PositionSecs) + rand(1)*(3) + circle_chg_min_secs;
%             fprintf('%s : %07.3f s: ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'), GetSecs()-start_secs);
%             fprintf('Showing fixation. Change at %07.3f.\n', change_secs-start_secs);
            log_msg(sprintf('Showing fixation. Change at %07.3f.\n', change_secs-start_secs), start_secs, log_fid);
        else
            big_circle = 1;
            change_secs = change_secs + circle_chg_dur_secs;
%             fprintf('%s : %07.3f s: ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'), GetSecs()-start_secs);
%             fprintf('Showing fixation + big circle. Change at %07.3f.\n', change_secs-start_secs);
            log_msg(sprintf('Showing fixation + big circle. Change at %07.3f.\n', change_secs-start_secs), start_secs, log_fid);
        end
    end
    
    if (~snd_status.Active)
        
        % If not silence yet, start
        if ~silence
            if snd_index == n_snds
                break
            end
            
            % Start silent period
            sil_start = GetSecs();
            silence = 1;
%             fprintf('%s : %07.3f s: ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'), GetSecs()-start_secs);
%             fprintf('Sound over after %07.3f s; starting silence.\n', sil_start-start_this);
            log_msg(sprintf('Sound over after %07.3f s; starting silence.\n', sil_start-start_this), start_secs, log_fid);
            
            % Load next
            snd_index = snd_index + 1;            
%             fprintf('%s : %07.3f s: ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'), GetSecs()-start_secs);
%             fprintf('Loading sound %i of %i sounds: %s.\n', snd_index, n_snds, char(this_run_data.File(snd_index)));
            log_msg(sprintf('Loading sound %i of %i sounds: %s.\n', snd_index, n_snds, char(this_run_data.File(snd_index))), start_secs, log_fid);
            [this_snd, ~, ~] = load_sound(this_run_data.File(snd_index));
            PsychPortAudio('FillBuffer', pahandle, this_snd, [], 0);
        end
        
        % Change circle?
        if (GetSecs() > change_secs)
            if big_circle
                big_circle = 0;
                % Secs remaining in silence + random start in range
                change_secs = sil_secs - (GetSecs()-sil_start) + rand(1)*(circle_chg_max_secs-circle_chg_min_secs) + circle_chg_min_secs;
%                 fprintf('%s : %07.3f s: ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'), GetSecs()-start_secs);
%                 fprintf('Showing fixation. Change at %07.3f.\n', change_secs-start_secs);
                log_msg(sprintf('Showing fixation. Change at %07.3f.\n', change_secs-start_secs), start_secs, log_fid);
           else
                big_circle = 1;
                change_secs = change_secs + circle_chg_dur_secs;
%                 fprintf('%s : %07.3f s: ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'), GetSecs()-start_secs);
%                 fprintf('Showing fixation + big circle. Change at %07.3f.\n', change_secs-start_secs);
                log_msg(sprintf('Showing fixation + big circle. Change at %07.3f.\n', change_secs-start_secs), start_secs, log_fid);
            end
        end

        % Silence over? Then start new sound.
        if (GetSecs()-sil_start) > sil_secs
            silence = 0;
            start_this = PsychPortAudio('Start', pahandle, 1, 0, 1);
%             fprintf('%s : %07.3f s: ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'), GetSecs()-start_secs);
%             fprintf('Ended silence with latency %07.3f s. Started sound %i of %i: %s.\n', start_this-sil_start, snd_index, n_snds, char(this_run_data.File(snd_index)));
            log_msg(sprintf('Ended silence with latency %07.3f s. Started sound %i of %i: %s.\n', start_this-sil_start, snd_index, n_snds, char(this_run_data.File(snd_index))), start_secs, log_fid);
            sil_start = GetSecs() + 12;
        end
        
        % Process key presses
        [ keyIsDown, keySecs, keyCode ] = KbCheck;
        if keyIsDown
            if keyCode(tKey) % Scanner pulse detected
%                 fprintf('%s : %07.3f s: ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'), GetSecs()-start_secs);
%                 fprintf('Scanner pulse detected.\n');
                log_msg(sprintf('Scanner pulse detected.\n'), start_secs, log_fid);
            end
            
            % Participant press
            if ( keyCode(aKey) || keyCode(bKey) || keyCode(cKey) || keyCode(dKey) )
%                 fprintf('%s : %07.3f s: ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'), GetSecs()-start_secs);
%                 fprintf('Participant press detected.\n');
                log_msg(sprintf('Participant press detected.\n'), start_secs, log_fid);
            end
            
            % Escape/terminate
            if keyCode(escapeKey)
%                 fprintf('%s : %07.3f s: ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'), GetSecs()-start_secs);
%                 fprintf('Escape detected at %07.3f from start.\n', keySecs-start_secs);
                log_msg(sprintf('Escape detected at %07.3f from start.\n', keySecs-start_secs), start_secs, log_fid);
                break;
            end
        end
    end
    
    [ keyIsDown, keySecs, keyCode ] = KbCheck;
    if keyIsDown
        if keyCode(escapeKey)
            fprintf('%s : %07.3f s: ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'), GetSecs()-start_secs);
            fprintf('Escape detected at %07.3f from start.\n', keySecs-start_secs);
            log_msg(sprintf('Escape detected at %07.3f from start.\n', keySecs-start_secs), start_secs, log_fid);
            break;
        end
    end
end

% % Clean-up
PsychPortAudio('Close', pahandle);
fprintf('%s : %07.3f s: ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'), GetSecs()-start_secs);
fprintf('Played %i sounds in %07.3f s.\n', snd_index, GetSecs() - start_secs);
log_msg(sprintf('Played %i sounds in %07.3f s.\n', snd_index, GetSecs() - start_secs), start_secs, log_fid);
fclose('all');

return


%-------------------------------------------------------------------------
function [this_snd, snd_freq, nrchannels] = load_sound(snd_fn)

[this_snd, snd_freq] = audioread(char(snd_fn));
nrchannels = size(this_snd,2);

% nrchannels must be 2 for some soundcards
if nrchannels < 2
    this_snd = [this_snd' ; this_snd'];
    nrchannels = 2;
end

return


%-------------------------------------------------------------------------
function log_msg(msg_text, start_secs, fid)
ts = datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF');
secs_fr_start = GetSecs()-start_secs;
fprintf('%s : %07.3f s: ', ts, secs_fr_start);
fprintf(msg_text);
fprintf(fid, '%s : %07.3f s: ', ts, secs_fr_start);
fprintf(fid, msg_text);
return



