function pre_scan_check(fam_id, nov_id)
% pre_scan_check(fam_id, nov_id, laptop_only)
%   Checks status of localization, sound files, keyboards prior to scan.
%   Default (no input params) presumes user wants to test laptop keyboard
%   only.
%   To test specific sound files for a given study and the SLEIC scanner
%   trigger, grips, and laptop keyboard, enter parameters for fam_id,
%   nov_id and laptop only as in pre_scan_check('0001','0003', 0)

% 2015-11 Rick Gilmore

% 2015-11-05 rog modified.
% 2015-11-16 rog added localize_peep, keyboard check.
% 2015-12-01 rog added sound test loop.
% 2015-12-10 rog made test of single laptop keyboard the default.
% 2015-12-20 rog modified
%--------------------------------------------------------------------------

if nargin < 1
    fam_id = '9999';
    nov_id = '9998';
    fprintf('Familiar and novel IDs not specified. Using defaults: fam %s, nov %s.\n', fam_id, nov_id);
end

%--------------------------------------------------------------------------
test_snd = '-neu-chk-a.wav';

%--------------------------------------------------------------------------
% Check localization
localize_peep;

%--------------------------------------------------------------------------
% Check wav/ directories for this participant
n_files_expected = 32;
fam_dir = strcat('wav/', fam_id, '/norm');
nov_dir = strcat('wav/', nov_id, '/norm');

fam_dir_info = dir(fullfile(fam_dir, '*.wav'));
nov_dir_info = dir(fullfile(nov_dir, '*.wav'));

fam_sz = size(fam_dir_info);
nov_sz = size(nov_dir_info);

fprintf('Checking "familiar".\n');
fprintf('There are %i .wav files in %s. ', fam_sz(1), fam_dir);
if fam_sz(1) ~= n_files_expected
    fprintf('Incorrect number of files. Listing.\n');
    dir(fullfile(fam_dir, strcat(fam_id, '-ang-*.wav')))
    dir(fullfile(fam_dir, strcat(fam_id, '-hap-*.wav')))
    dir(fullfile(fam_dir, strcat(fam_id, '-neu-*.wav')))
    dir(fullfile(fam_dir, strcat(fam_id, '-sad-*.wav')))
else
    fprintf('Ok.\n');
end

fprintf('\nChecking "novel".\n');
fprintf('There are %i .wav files in %s. ', nov_sz(1), nov_dir);
if nov_sz(1) ~= n_files_expected
    fprintf('Incorrect number of files. Listing.\n');
    dir(fullfile(nov_dir, strcat(nov_id, '-ang-*.wav')))
    dir(fullfile(nov_dir, strcat(nov_id, '-hap-*.wav')))
    dir(fullfile(nov_dir, strcat(nov_id, '-neu-*.wav')))
    dir(fullfile(nov_dir, strcat(nov_id, '-sad-*.wav')))
else
    fprintf('Ok.\n');
end

%-------------------------------------------------------------------------
% Check keyboard(s)
fprintf('\nChecking keyboard(s).\n');
device_report;

%-------------------------------------------------------------------------
% Check sounds
InitializePsychSound;
snd_fn = fullfile(nov_dir, strcat(nov_id, test_snd));
[this_snd, snd_freq, nrchannels] = load_peep_sound(snd_fn);
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

% Start and stop playing test sound, loops until key press

[keyboardIndices, ~, ~] = GetKeyboardIndices();
try
    KbReleaseWait;
    fprintf('Press any key on laptop keyboard to START playing test sounds.\n');
    KbStrokeWait;
    fprintf('Sound starting.\n');
    PsychPortAudio('Start', pahandle, 1, 0, 1);
    snd_status = PsychPortAudio('GetStatus', pahandle);
    if snd_status.Active
        fprintf('Press any key to STOP playing sounds.\n');
    else
        fprintf('Sound did not start.\n');
        return;
    end
    while 1
        snd_status = PsychPortAudio('GetStatus', pahandle);
        if ~snd_status.Active
            PsychPortAudio('Start', pahandle, 1, 0, 1);
        end
        [keyIsDown, ~, ~, ~] = KbCheck(keyboardIndices(1));
        if keyIsDown
            break;
        end        
    end
    fprintf('Sound stopped.\n');
catch
    psychlasterror;
    psychlasterror('reset');
end

PsychPortAudio('Close', pahandle);
Screen('CloseAll');
clc;

end