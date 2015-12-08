function environment = set_peep_environment
% environment = set_peep_environment
%   Sets environment-level variables for PEEP-II study.

% 2015-11 Rick Gilmore wrote

% 2015-11-16 rog added locale switching.
%--------------------------------------------------------------------------

% Clear if already in workspace
if exist('environment', 'var')
    clear('environment')
end

% Scan parameters
environment.scanner = 'Siemens Prisma 3T';
environment.center = 'PSU SLEIC, University Park, PA';
environment.mri_TR = 2;
environment.sound_secs = 10;
environment.silence_secs = 6;
environment.extra_silence = 4; % extra silence at start of study

% Directories
environment.root_dir = 'peep-II-script';
environment.beh_dir = 'beh';
environment.run_orders_dir = 'run-orders';

% Keys
environment.tKey = KbName('t');
environment.escapeKey = KbName('ESCAPE');
environment.aKey = KbName('a');
environment.bKey = KbName('b');
environment.cKey = KbName('c');
environment.dKey = KbName('d');

% Timing parameters
environment.circle_chg_min_secs = 1.5; % 1.5 s from start of sound or silence
environment.circle_chg_max_secs = 8.5; % 1.5 s from end of sound or silence
environment.circle_chg_dur_secs = 1;   % 1 s duration

% Screen & keyboard parameters
try
    screenNumbers = Screen('Screens');
    for s=1:length(screenNumbers)
        environment.scrns(s).scrNum = screenNumbers(s);
        environment.scrns(s).hz = Screen('FrameRate', screenNumbers(s));
        environment.scrns(s).rect = Screen('Rect', screenNumbers(s));
    end
    environment.screenNumbers = screenNumbers;
    
    [keyboardIndices, productNames, ~] = GetKeyboardIndices();
    environment.keyboardIndices = keyboardIndices;
    
    kbds = length(keyboardIndices);
    fprintf('%s : Detected %i input devices.\n', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'), kbds);
    for k = 1:kbds
        switch char(productNames(k))
            case 'Apple Internal Keyboard / Trackpad'
                environment.internal_kbd_i = k;
                environment.internal_kbd_index = keyboardIndices(k);
                if length(keyboardIndices) == 1
                    environment.external_kbd_i = k;
                    environment.external_kbd_index = keyboardIndices(k);
                    environment.trigger_kbd_i = k;
                    environment.trigger_kbd_index = keyboardIndices(k);
                end
            case 'KeyWarrior8 Flex'
                environment.external_kbd_i = k;
                environment.external_kbd_index = keyboardIndices(k);
            case 'TRIGI-USB'
                environment.trigger_kbd_i = k;
                environment.trigger_kbd_index = keyboardIndices(k);
            case 'Apple External Keyboard'
                environment.external_kbd_i = k;
                environment.trigger_kbd_i = k;
                environment.external_kbd_index = keyboardIndices(k);
                environment.trigger_kbd_index = keyboardIndices(k);
        end
    end
    
    environment.kbds = kbds;
    keysOfInterest=zeros(kbds,256); % make kbds x 256 array, then index
    
    % internal keyboard
    keysOfInterest(environment.internal_kbd_i, KbName('ESCAPE'))=1; % internal
    
    % external keyboard or grips
    keysOfInterest(environment.external_kbd_i, KbName('a'))=1;
    keysOfInterest(environment.external_kbd_i, KbName('b'))=1;
    keysOfInterest(environment.external_kbd_i, KbName('c'))=1;
    keysOfInterest(environment.external_kbd_i, KbName('d'))=1;
    
    % trigger
    keysOfInterest(environment.trigger_kbd_i, KbName('t'))=1;
    
    environment.keysOfInterest = keysOfInterest;
    environment.productNames = productNames;
    white = WhiteIndex(max(screenNumbers));
    black = BlackIndex(max(screenNumbers));
    gray = round((white + black)/2);
    environment.color.white = [white white white];
    environment.color.black = [black black black];
    environment.color.gray = [gray gray gray];
    environment.color.midblue = [0 0 127];
catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end

% Stimulus parameters
environment.particip_text_color = environment.color.midblue;
environment.particip_text_size = 50;
environment.fix_color = environment.color.midblue;
environment.circle_rect = [0 0 300 300];
environment.circle_linewidth = 10;
environment.dot_rect = [0 0 50 50];

return