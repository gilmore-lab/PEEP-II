function environment = set_peep_environment

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

% Directories
environment.root_dir = 'peep-II-script';
environment.beh_dir = 'beh';
environment.sound_dir = 'wav/norm';
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
    environment.external_kbd_index = keyboardIndices(max(nkbds));
    environment.internal_kbd_index = keyboardIndices(1);
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