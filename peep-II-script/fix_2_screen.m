function fix_2_screen(big_circle, win_ptr, environment)
% fix_2_screen(big_circle, win_ptr, environment)
%   Writes fixation stimulus to participant screen.
%   Switches between circle (fixation) and circle + ring, based on
%   value of the big_circle flag.

try
    Screen('FillRect', win_ptr, environment.color.gray);
    scr_rect=Screen('Rect', win_ptr, 1);
    circle_rect = CenterRect(environment.circle_rect, scr_rect);
    dot_rect = CenterRect(environment.dot_rect, circle_rect);
    if big_circle
        Screen('FrameOval', win_ptr, environment.fix_color, circle_rect, environment.circle_linewidth, environment.circle_linewidth);
        Screen('FillOval', win_ptr, environment.fix_color, dot_rect);
    else
        Screen('FillOval', win_ptr, environment.fix_color, dot_rect);
    end
    Screen('Flip', win_ptr);
catch
    Screen('CloseAll');
    fprintf('We''ve hit an error.\n');
    psychrethrow(psychlasterror);
end
return
