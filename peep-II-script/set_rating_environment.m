function environment = set_rating_environment(save_default)
% environment = set_rating_environment
%   Sets environment-level variables for PEEP-II study.

% 2015-11-18 Rick Gilmore, rick.o.gilmore@gmail.com

% Dependencies
%
% Called by:
%   peep_ratings.m
%
% Calls:

% 2015-11-18 rog created.
% 2015-12-29 rog updated documentation.
%--------------------------------------------------------------------------

if nargin < 1
    save_default = 0;
end

% Clear if already in workspace
if exist('environment', 'var')
    clear('environment')
end

% Directories
environment.root_dir = 'peep-II-ratings';
environment.run_orders_dir = 'run-orders';

environment.interkey_secs = .1;

% Keys
environment.tKey = KbName('t');
environment.escapeKey = KbName('ESCAPE');
environment.aKey = KbName('a');
environment.bKey = KbName('b');
environment.cKey = KbName('c');
environment.dKey = KbName('d');
environment.spaceKey = KbName('SPACE');
environment.enterKey = 40;
environment.tabKey = KbName('TAB');
environment.leftArrowKey = KbName('LeftArrow');
environment.rightArrowKey = KbName('RightArrow');
environment.upArrowKey = KbName('UpArrow');
environment.downArrowKey = KbName('DownArrow');

% Screen & keyboard parameters
try    
    [keyboardIndices, productNames, ~] = GetKeyboardIndices();
    environment.keyboardIndices = keyboardIndices;    
    environment.productNames = productNames;
    nkbds = length(keyboardIndices);
    environment.external_kbd_index = keyboardIndices(nkbds);
    environment.internal_kbd_index = keyboardIndices(1);
    
    screenNumbers = Screen('Screens');
    for s=1:length(screenNumbers)
        environment.scrns(s).scrNum = screenNumbers(s);
        environment.scrns(s).hz = Screen('FrameRate', screenNumbers(s));
        environment.scrns(s).rect = Screen('Rect', screenNumbers(s));
    end
    environment.screenNumbers = screenNumbers;

    white = WhiteIndex(max(screenNumbers));
    black = BlackIndex(max(screenNumbers)); 
    gray = round((white + black)/2);
    environment.color.white = [white white white];
    environment.color.black = [black black black];
    environment.color.gray = [gray gray gray];
    environment.color.midblue = [0 0 127];
    environment.color.midred = [127 0 0];
catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end

% Stimulus parameters
environment.particip_text_color = environment.color.midblue;
environment.particip_text_size = 50;

if save_default
    save('default-environment.mat', 'environment');
end

end