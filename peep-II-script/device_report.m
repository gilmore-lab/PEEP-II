function [ keyboardIndices, productNames ] = device_report()
% [ keyboardIndices, productNames ] = device_report
%   Reports on and prompts testing of keyboard devices
%
% This is localized for the PEEP-II MRI study. In this study, the
% experimenter may press the ESCAPE key to terminate the script. The
% program also accepts 't' characters from the scanner pulse converter (not
% tested here) and {'a', 'b', 'c', 'd'} characters from the Nordic
% Neurolabs response grips.

% 2015-11-13 Rick Gilmore

% 2015-11-13 rog wrote
% 2015-11-16 rog fixed Nordic NeuroLabs indexing.
% 2015-12-20 rog modified. 't' now detected by internal keyboard.
%--------------------------------------------------------------------------

[keyboardIndices, productNames, ~] = GetKeyboardIndices();

fprintf('There are %i keyboards attached.\n', length(keyboardIndices));
for k=1:length(keyboardIndices)
    fprintf('Keyboard %i of %i: index %i: name "%s"\n', k, length(keyboardIndices), keyboardIndices(k), char(productNames(k)));
end
fprintf('\n');

% Assigns 
for k = 1:length(keyboardIndices)
    switch char(productNames(k))
        case 'Apple Internal Keyboard / Trackpad'
            environment.internal_kbd_i = k;
            environment.internal_kbd_index = keyboardIndices(k);
            if length(keyboardIndices) == 1
                environment.external_kbd_i = k;
                environment.external_kbd_index = keyboardIndices(k);
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

% Assumes that with single keyboard, all relevant keys should be detected
% by the internal keyboard. Otherwise, the 't', and 'ESCAPE' keys are
% detected by the internal keyboard, and the 'a', 'b', 'c', 'd', and 't', keys
% are detected by the external keyboard.
if (length(keyboardIndices)==1)
    test_keys(keyboardIndices(environment.internal_kbd_i), char(productNames(environment.internal_kbd_i)), 'ESCAPE', 'ESCAPE');
    test_keys(keyboardIndices(environment.internal_kbd_i), char(productNames(environment.internal_kbd_i)), 'b', 'left index');
    test_keys(keyboardIndices(environment.internal_kbd_i), char(productNames(environment.internal_kbd_i)), 'a', 'left thumb');
    test_keys(keyboardIndices(environment.internal_kbd_i), char(productNames(environment.internal_kbd_i)), 'c', 'right index');
    test_keys(keyboardIndices(environment.internal_kbd_i), char(productNames(environment.internal_kbd_i)), 'd', 'right thumb');    
    test_keys(keyboardIndices(environment.internal_kbd_i), char(productNames(environment.internal_kbd_i)), 't', 'scanner trigger');
else
    test_keys(keyboardIndices(environment.internal_kbd_i), char(productNames(environment.internal_kbd_i)), 'ESCAPE', 'ESCAPE');    
    test_keys(keyboardIndices(environment.internal_kbd_i), char(productNames(environment.internal_kbd_i)), 't', 'manual start');
    
    test_keys(keyboardIndices(environment.external_kbd_i), char(productNames(environment.external_kbd_i)), 'b', 'left index');
    test_keys(keyboardIndices(environment.external_kbd_i), char(productNames(environment.external_kbd_i)), 'a', 'left thumb');
    test_keys(keyboardIndices(environment.external_kbd_i), char(productNames(environment.external_kbd_i)), 'c', 'right index');
    test_keys(keyboardIndices(environment.external_kbd_i), char(productNames(environment.external_kbd_i)), 'd', 'right thumb');    
    test_keys(keyboardIndices(environment.external_kbd_i), char(productNames(environment.external_kbd_i)), 't', 'scanner trigger');
end
clc;
end

function test_keys(kbdIndex, kbd_name, key_returned, key_label)
keysOfInterest=zeros(1,256);
keysOfInterest(KbName(key_returned))=1;
KbQueueCreate(kbdIndex, keysOfInterest);
fprintf('Press %s button on %s to print %s character.\n', key_label, kbd_name, key_returned);
startSecs = GetSecs;
KbQueueStart(kbdIndex);
timeSecs = KbQueueWait(kbdIndex);
fprintf('The %s button was pressed at time %.3f seconds\n\n', key_label, timeSecs - startSecs);
KbQueueRelease(kbdIndex);
end