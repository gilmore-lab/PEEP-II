% 2015-12-20
% script fragment for more rational, flexible keyboard mapping.

[keyboardIndices, productNames, ~] = GetKeyboardIndices();
fprintf('There are %i keyboards attached.\n', length(keyboardIndices));
for k=1:length(keyboardIndices)
    fprintf('Keyboard %i of %i: index %i: name: "%s"\n', k, length(keyboardIndices), keyboardIndices(k), char(productNames(k)));
end
fprintf('\n');

keyboardFunctionsToMap = {'Experimenter Control', 'Participant Responses', 'Scanner Trigger'};
keyboardNames = {'Apple Internal Keyboard / Trackpad', 'KeyWarrior8 Flex', 'TRIGI-USB', 'Apple External Keyboard'};

for k=1:length(keyboardFunctionsToMap)
    for l = 1:length(productNames)
        prompt = sprintf('Map "%s" to keyboard "%s"? (0,1): ', keyboardFunctionsToMap{k}, productNames{l});
        kbd_map(k,l) = keyboardIndices(input(prompt));
    end
end
