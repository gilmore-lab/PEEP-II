function [ keyboardIndices, productNames ] = device_report()
% [ keyboardIndices, productNames ] = device_report
%   Reports on and prompts testing of keyboard devices
%
% This is localized for the PEEP-II MRI study. In this study, the
% experimenter may press the ESCAPE key to terminate the script. The
% program also accepts 't' characters from the scanner pulse converter (not
% tested here) and {'a', 'b', 'c', 'd'} characters from the Nordic
% Neurolabs response grips.
%
% See planning/mri-script-use-scenarios.md for details about devices,
% keypresses.

% 2015-11-13 Rick Gilmore, rick.o.gilmore@gmail.com

% 2015-11-13 rog wrote
% 2015-11-16 rog fixed Nordic NeuroLabs indexing.
% 2015-12-20 rog modified. 't' now detected by internal keyboard.
% 2015-12-29 rog modularized key testing.
%--------------------------------------------------------------------------

[keyboardIndices, productNames, ~] = GetKeyboardIndices();

fprintf('Testing USB keyboard devices.\n');
fprintf('Hit CTRL-C to abort.\n');

fprintf('%i keyboard(s) detected.\n', length(keyboardIndices));
fprintf('-------------------------------------------------------------\n');
for k=1:length(keyboardIndices)
    fprintf('Keyboard %i of %i: Index %i: name "%s"\n', k, length(keyboardIndices), keyboardIndices(k), char(productNames(k)));
end
% Assigns 
for k = 1:length(keyboardIndices)
    kbd_index = keyboardIndices(k);
    prod_name = char(productNames(k));
    switch prod_name
        case 'Apple Internal Keyboard / Trackpad'
            keys_to_test = {'t', 'a', 'b', 'c', 'd', 'ESCAPE'};
            key_names = keys_to_test;
            test_keys(kbd_index, prod_name, keys_to_test, key_names)
        case 'KeyWarrior8 Flex'
            keys_to_test = {'a', 'b', 'c', 'd'};
            key_names = {'left thumb', 'left index', 'right index', 'right thumb'};       
            test_keys(kbd_index, prod_name, keys_to_test, key_names)
        case 'TRIGI-USB'
            fprintf('Cannot test scanner trigger. Continuing.\n');
        case 'Apple External Keyboard'
            keys_to_test = {'t', 'a', 'b', 'c', 'd', 'ESCAPE'};
            key_names = keys_to_test;
            test_keys(kbd_index, prod_name, keys_to_test, key_names)
%         case 'Dell xxx' % may not be needed, but fragment here in case
%             keys_to_test = {'t', 'a', 'b', 'c', 'd', 'ESCAPE'};
%             key_names = keys_to_test;
%             test_keys(kbd_index, prod_name, keys_to_test, key_names)
    end % switch
end % for k

fprintf('All keys on all valid keyboards tested.\n\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function test_keys(kbdIndex, kbd_name, keys_to_test, key_names)
% test_keys(kbdIndex, kbd_name, keys_to_test, key_names)
%   Tests all keys in specified keyboard identified by kbdIndex and
%   kbd_name. The keys to test are specified in keys_to_test and their
%   associated names in key_names.

% 2015-12-29 Rick Gilmore, rick.o.gilmore.gmail.com

% 2015-12-29 rog created.
%--------------------------------------------------------------------------
fprintf('There are %i keys to test.\n', length(keys_to_test));
for l = 1:length(keys_to_test)
    test_a_key(kbdIndex, kbd_name, char(keys_to_test(l)), char(key_names(l)));
end % for l
fprintf('-------------------------------------------------------------\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function test_a_key(kbdIndex, kbd_name, key_returned, key_label)
% test_a_key(kbdIndex, kbd_name, key_returned, key_label)
%   Queries user to press selected key on identified keyboard.
%

% 2015-11-xx Rick Gilmore, rick.o.gilmore@gmail.com

% 2015-12-29 rog edited documentation, modified for use with test_keys.
%--------------------------------------------------------------------------

% Create keyboard queue for this key
keysOfInterest=zeros(1,256);
keysOfInterest(KbName(key_returned))=1;
KbQueueCreate(kbdIndex, keysOfInterest);

% Prompt user to press key
fprintf('>> Press "%s" button on %s to print "%s" character.\n', key_label, kbd_name, key_returned);
startSecs = GetSecs;
KbQueueStart(kbdIndex);
timeSecs = KbQueueWait(kbdIndex);

% Report on keypress, release queue, and return
fprintf('The "%s" button was pressed at time %.3f seconds\n\n', key_label, timeSecs - startSecs);
KbQueueRelease(kbdIndex);
end