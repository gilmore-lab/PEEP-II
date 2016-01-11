try
    screens=Screen('Screens');
    screenNumber=max(screens);
    
    % Open window with default settings:
    w=Screen('OpenWindow', screenNumber);
    
    % Select specific text font, style and size:
    Screen('TextFont',w, 'Courier New');
    Screen('TextSize',w, 30);
    Screen('TextStyle', w, 1+2);
    
    escapeKey = KbName('ESCAPE');
    
    % mytext contains the content of the first 48 lines of the text file.
    % Let's print it: Start at (x,y)=(10,10), break lines after 40
    % characters:
    
    keys = [];
    n = 0;
    while 1
        [ keyIsDown, ~, keyCode ] = KbCheck;
        if keyIsDown
            if keyCode(escapeKey)
                break;
            else
                n = n+1;
                keys(n) = KbName(keyCode);
                DrawFormattedText(w, keys, 10, 20, 0, 40);
                Screen('Flip', w);
            end
        end
        WaitSecs(.05);    
    end
catch
    Screen('CloseAll');
    fprintf('We''ve hit an error.\n');
    psychrethrow(psychlasterror);
end
