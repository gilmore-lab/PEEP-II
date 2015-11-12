function txt_2_screen(msg_text, win_ptr, environment)
% txt_2_screen(msg_text, win_ptr)
%   Writes msg_text to participant screen

try
    Screen('FillRect', win_ptr, environment.color.gray);
    Screen('TextFont', win_ptr, 'Courier New');
    Screen('TextSize', win_ptr, environment.particip_text_size);
    Screen('TextStyle', win_ptr, 1+2);
    DrawFormattedText(win_ptr, msg_text, 'center', 'center', environment.particip_text_color);
    Screen('Flip', win_ptr);
catch
    Screen('CloseAll');
    fprintf('We''ve hit an error.\n');
    psychrethrow(psychlasterror);
end
return