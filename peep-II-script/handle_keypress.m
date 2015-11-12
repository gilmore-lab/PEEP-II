function handle_keypress(deviceIndex, environment)

deviceIndex = keyboardIndices(1);
fprintf('Testing keyboard %i of %i.\n', 1, length(keyboardIndices));
KbQueueCreate(deviceIndex);
KbQueueStart(deviceIndex);

while 1
    [pressed, firstPress]=KbQueueCheck(deviceIndex);
    timeSecs = firstPress(find(firstPress));
    if pressed
        % Again, fprintf will give an error if multiple keys have been pressed
        fprintf('"%s" typed at time %.3f seconds\n', KbName(min(find(firstPress))), timeSecs - startSecs);
        
        if firstPress(escapeKey)
            break;
        end
    end
end
KbQueueRelease(deviceIndex);

if length(keyboardIndices > 1)
    deviceIndex = keyboardIndices(2);
    fprintf('Testing keyboard %i of %i.\n', 2, length(keyboardIndices));
    KbQueueCreate(deviceIndex);
    KbQueueStart(deviceIndex);
    
    while 1
        [ pressed, firstPress]=KbQueueCheck(deviceIndex);
        timeSecs = firstPress(find(firstPress));
        if pressed
            % Again, fprintf will give an error if multiple keys have been pressed
            fprintf('"%s" typed at time %.3f seconds\n', KbName(min(find(firstPress))), timeSecs - startSecs);
            
            if firstPress(escapeKey)
                break;
            end
        end
    end
    KbQueueRelease(deviceIndex);
end
return