[keyboardIndices, productNames, ~] = GetKeyboardIndices();
kbdIndex = keyboardIndices(1);

% fprintf('Listen 0.\n');
% keysOfInterest=zeros(1,256);
% keyOfInterest(KbName('a'))=1;
% KbQueueCreate(kbdIndex, keysOfInterest);
% fprintf('Press %s.\n', 'a');
% startSecs = GetSecs;
% KbQueueStart(kbdIndex);
% timeSecs = KbQueueWait(kbdIndex);
% fprintf('The %s button was pressed at time %.3f seconds\n\n', 'a', timeSecs - startSecs);
% KbQueueRelease(kbdIndex);

ListenChar(1);
fprintf('Listen 1.\n');
keyOfInterest=zeros(1,256);
keyOfInterest(KbName('a'))=1;
KbQueueCreate(kbdIndex, keyOfInterest);
fprintf('Press %s.\n', 'a');
startSecs = GetSecs;
KbQueueStart(kbdIndex);
timeSecs = KbQueueWait(kbdIndex);
fprintf('The %s button was pressed at time %.3f seconds\n\n', 'a', timeSecs - startSecs);
flushed = KbQueueFlush(kbdIndex, 1)
KbQueueRelease(kbdIndex);
ListenChar(0);

ListenChar(2);
fprintf('Listen 2.\n');
keyOfInterest=zeros(1,256);
keyOfInterest(KbName('a'))=1;
KbQueueCreate(kbdIndex, keyOfInterest);
fprintf('Press %s.\n', 'a');
startSecs = GetSecs;
KbQueueStart(kbdIndex);
timeSecs = KbQueueWait(kbdIndex);
fprintf('The %s button was pressed at time %.3f seconds\n\n', 'a', timeSecs - startSecs);
flushed = KbQueueFlush(kbdIndex, 1)
KbQueueRelease(kbdIndex);
ListenChar(0);