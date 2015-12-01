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

% Where are we running? Useful for parsing keyboard data.
kbds = input('Keyboards (1), (2), or (3)?: ');

% Scan parameters
environment.scanner = 'Siemens Prisma 3T';
environment.center = 'PSU SLEIC, University Park, PA';
environment.mri_TR = 2;
environment.sound_secs = 10;
environment.silence_secs = 6;

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
    nkbds = length(keyboardIndices);
    
    % Keyboards at SLEIC using USB HUB
    % Keyboard 1 of 4: index 3: name "Apple Internal Keyboard / Trackpad"
    % Keyboard 2 of 4: index 6: name "932"
    % Keyboard 3 of 4: index 7: name "KeyWarrior8 Flex"
    % Keyboard 4 of 4: index 10: name "TRIGI-USB" -- scanner trigger
    
    environment.kbds = kbds;
    keysOfInterest=zeros(3,256); % make kbds x 256 array, then index
    keysOfInterest(1, KbName('ESCAPE'))=1;   
    keysOfInterest(2, KbName('a'))=1;
    keysOfInterest(2, KbName('b'))=1;
    keysOfInterest(2, KbName('c'))=1;
    keysOfInterest(2, KbName('d'))=1;
    keysOfInterest(3, KbName('t'))=1;
    environment.keysOfInterest = keysOfInterest;

    switch kbds
        case 2 % laptop + external keyboard (Rick's set-up)
            environment.internal_kbd_index = keyboardIndices(1);
            environment.external_kbd_index = keyboardIndices(2);
            environment.trigger_kbd_index = environment.external_kbd_index;
        case 3 % laptop + grips + trigger (at SLEIC)
            environment.internal_kbd_index = keyboardIndices(1);
            environment.external_kbd_index = keyboardIndices(3);
            environment.trigger_kbd_index = keyboardIndices(4);
        otherwise
            environment.internal_kbd_index = keyboardIndices(1);
            environment.external_kbd_index = keyboardIndices(1);
            environment.trigger_kbd_index = keyboardIndices(1);
    end % switch
    
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