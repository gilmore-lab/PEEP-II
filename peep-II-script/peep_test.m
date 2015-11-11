function peep_test(n_snds)
% peep_test(n_snds)
%   Simplified test script for ensuring that sounds play, images display.

% 2015-11-04 rogilmore created.
% 2015-11-05 rogilmore modified.
% 2015-11-11 rogilmore modified. Added visual displays.

% Wish list:
% 3. Write behavioral data, including pulse timing to file.

%-------------------------------------------------------------------------

cd('~/github/gilmore-lab/peep-II/peep-II-script/');
diary(sprintf('diary/%s-diary.txt', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));

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
[log_fid, ~] = fopen(log_fn, 'w'); 

log_msg(sprintf('Planning to play %i sounds.\n', n_snds), GetSecs(), log_fid);
log_msg('Starting peep_test.\n', GetSecs(), log_fid);

try
    Screen('Preference', 'SkipSyncTests', 1);
    win_ptr = Screen('OpenWindow', max(Screen('Screens')));
    txt_2_screen('Welcome to PEEP', win_ptr);
catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end

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
    pahandle = PsychPortAudio('Open', [], [], 0, snd_freq, nrchannels);
    PsychPortAudio('FillBuffer', pahandle, this_snd);
catch
    fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', snd_freq);
    fprintf('Sound may sound a bit out of tune, ...\n\n');
    psychlasterror('reset');
    pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
end

% Show ready to start run screen and wait for keypress
KbReleaseWait;
log_msg(sprintf('Press any key when ready to start\n'), GetSecs(), log_fid);
txt_2_screen('Ready to go!', win_ptr);
KbStrokeWait;

% When keypressed, start sound
start_secs = PsychPortAudio('Start', pahandle, 1, 0, 1);
start_this = start_secs;
sil_start = start_secs + 12; % Made bigger than 10 s so the interval doesn't start early.
log_msg(sprintf('Snd: Started sound 1 of %i: %s.\n', n_snds, char(this_run_data.File(snd_index))), start_secs, log_fid);
silence = 0;

% Show circle
big_circle = 0;
fix_2_screen(big_circle, win_ptr)
change_secs = start_secs + rand(1)*(circle_chg_max_secs-circle_chg_min_secs) + circle_chg_min_secs;
log_msg(sprintf('Snd: Fix -. Change at %07.3f.\n', change_secs-start_secs), start_secs, log_fid);

while 1
    snd_status = PsychPortAudio('GetStatus', pahandle);
    if snd_status.Active        
        % During sound, time to change fixation?
        if GetSecs() > change_secs
            if big_circle
                big_circle = 0;
                fix_2_screen(big_circle, win_ptr);
                
                % Compute change time in middle of next silent interval
                change_secs = GetSecs() + (10-snd_status.PositionSecs) + rand(1)*(3) + circle_chg_min_secs;
                log_msg(sprintf('Snd : Fix -. Change at %07.3f.\n', change_secs-start_secs), start_secs, log_fid);
            else
                big_circle = 1;
                fix_2_screen(big_circle, win_ptr);
                change_secs = change_secs + circle_chg_dur_secs;
                log_msg(sprintf('Snd : Fix +. Change at %07.3f.\n', change_secs-start_secs), start_secs, log_fid);
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
            sil_end = sil_start + sil_secs;
            silence = 1;
            log_msg(sprintf('Sil : Sound duration %07.3f s.\n', sil_start-start_this), start_secs, log_fid);
            
            % Load next
            snd_index = snd_index + 1;            
            log_msg(sprintf('Sil : Loading sound %i of %i sounds: %s.\n', snd_index, n_snds, char(this_run_data.File(snd_index))), start_secs, log_fid);
            [this_snd, ~, ~] = load_sound(this_run_data.File(snd_index));
            PsychPortAudio('FillBuffer', pahandle, this_snd, [], 0);
        end % if ~silence
        
        % Change circle?
        if (GetSecs() > change_secs)
            if big_circle
                big_circle = 0;
                fix_2_screen(big_circle, win_ptr);
                
                % Secs remaining in silence + random start in range
                change_secs = sil_end + rand(1)*(circle_chg_max_secs-circle_chg_min_secs) + circle_chg_min_secs;
                %change_secs = sil_secs - (GetSecs()-sil_start) + rand(1)*(circle_chg_max_secs-circle_chg_min_secs) + circle_chg_min_secs;
                log_msg(sprintf('Sil : Fix -. Change at %07.3f.\n', change_secs-start_secs), start_secs, log_fid);
           else
                big_circle = 1;
                fix_2_screen(big_circle, win_ptr);
                change_secs = change_secs + circle_chg_dur_secs;
                log_msg(sprintf('Sil : Fix +. Change at %07.3f.\n', change_secs-start_secs), start_secs, log_fid);
            end
        end % if (GetSecs()

        % Silence over? Then start new sound.
        if (GetSecs()-sil_start) > sil_secs
            silence = 0;
            start_this = PsychPortAudio('Start', pahandle, 1, 0, 1);
            log_msg(sprintf('Snd : Silence duration %07.3f s. Started sound %i of %i: %s.\n', start_this-sil_start, snd_index, n_snds, char(this_run_data.File(snd_index))), start_secs, log_fid);
            sil_start = GetSecs() + 12;
        end
        
        % Process key presses
        [ keyIsDown, keySecs, keyCode ] = KbCheck;
        if keyIsDown
            if keyCode(tKey) % Scanner pulse detected
                log_msg(sprintf('Scanner pulse detected.\n'), start_secs, log_fid);
            end
            
            % Participant press
            if ( keyCode(aKey) || keyCode(bKey) || keyCode(cKey) || keyCode(dKey) )
                log_msg(sprintf('Participant press detected.\n'), start_secs, log_fid);
            end
            
            % Escape/terminate
            if keyCode(escapeKey)
                log_msg(sprintf('Escape detected at %07.3f from start.\n', keySecs-start_secs), start_secs, log_fid);
                break;
            end
        end
    end % if snd_status.Active
    
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

txt_2_screen('All done!', win_ptr)
PsychPortAudio('Close', pahandle);
log_msg(sprintf('Played %i sounds in %07.3f s.\n', snd_index, GetSecs() - start_secs), start_secs, log_fid);
fclose('all');

fprintf('Hit any key to terminate.\n');
KbStrokeWait;

Screen('CloseAll');
diary off;

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

%-------------------------------------------------------------------------
function txt_2_screen(msg_text, win_ptr)
Screen('FillRect', win_ptr, [127 127 127]);
Screen('TextFont', win_ptr, 'Courier New');
Screen('TextSize', win_ptr, 50);
Screen('TextStyle', win_ptr, 1+2);
DrawFormattedText(win_ptr, msg_text, 'center', 'center', [0 0 127]);
Screen('Flip', win_ptr);
return

%-------------------------------------------------------------------------
function fix_2_screen(big_circle, win_ptr)
% fix_2_screen(big_circle, win_ptr)
%
Screen('FillRect', win_ptr, [127 127 127]);
scr_rect=Screen('Rect', win_ptr, 1);
circle_rect = CenterRect([0 0 300 300], scr_rect);
dot_rect = CenterRect([0 0 50 50], circle_rect);
if big_circle
    Screen('FrameOval', win_ptr, [0 0 255], circle_rect, 10, 10);
    Screen('FillOval', win_ptr, [0 0 255], dot_rect);
else
    Screen('TextSize', win_ptr, 100);
    Screen('FillOval', win_ptr, [0 0 255], dot_rect);
end
Screen('Flip', win_ptr);
return
