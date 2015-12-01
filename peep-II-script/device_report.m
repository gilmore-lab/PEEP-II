function [ keyboardIndices, productNames ] = device_report
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
%--------------------------------------------------------------------------

[keyboardIndices, productNames, ~] = GetKeyboardIndices();

fprintf('There are %i keyboards attached.\n', length(keyboardIndices));
for k=1:length(keyboardIndices)
    fprintf('Keyboard %i of %i: index %i: name "%s"\n', k, length(keyboardIndices), keyboardIndices(k), char(productNames(k)));
end
fprintf('\n');

internal_kbd = 1;
switch length(keyboardIndices)
    case 1
        external_kbd = 1;
    case 2
        external_kbd = 2;
    otherwise
        external_kbd = 3;
end

% if length(keyboardIndices) <= 1
%     external_kbd = 1;
% else
%     external_kbd = 3;
% end

test_keys(keyboardIndices(internal_kbd), char(productNames(internal_kbd)), 'ESCAPE', 'ESCAPE');

test_keys(keyboardIndices(external_kbd), char(productNames(external_kbd)), 'b', 'left index');
test_keys(keyboardIndices(external_kbd), char(productNames(external_kbd)), 'a', 'left thumb');
test_keys(keyboardIndices(external_kbd), char(productNames(external_kbd)), 'c', 'right index');
test_keys(keyboardIndices(external_kbd), char(productNames(external_kbd)), 'd', 'right thumb');
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