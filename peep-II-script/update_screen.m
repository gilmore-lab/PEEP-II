function update_screen(session, env, status)
% update_screen(session, env, status)
%   Updates PEEP ratings screen based on user input.

% 2015-11-18 Rick Gilmore, rick.o.gilmore@gmail.com

% Dependencies

% 2015-11-18 rog wrote.
% 2015-12-29 rog debugged to show instructions text, questions text.
%--------------------------------------------------------------------------

% Rating sound %i of %i.
try
    Screen('FillRect', env.win_ptr, [127 127 127]);
    Screen('TextFont', env.win_ptr, 'Courier New');
    Screen('TextSize', env.win_ptr, env.particip_text_size);
    Screen('TextStyle', env.win_ptr, 1+2);
    msg_text = sprintf('Rating sound %i of %i', status.snd_index, session.n_snds);
    DrawFormattedText(env.win_ptr, msg_text, 'center', 0, env.particip_text_color);
catch
    Screen('CloseAll');
    fprintf('We''ve hit an error.\n');
    psychrethrow(psychlasterror);
end

% Instructions to experimenter
try
    Screen('TextFont', env.win_ptr, 'Courier New');
    Screen('TextSize', env.win_ptr, env.particip_text_size*.5); % 50% smaller?
    Screen('TextStyle', env.win_ptr, 1+2);
    instructions_color = [127 0 0];
    msg_text = sprintf('SPACE to start sound; Left/Right switch between ratings; Up/Down switch sounds');
    DrawFormattedText(env.win_ptr, msg_text, 'center', 100, [127 0 0]);
catch
    Screen('CloseAll');
    fprintf('We''ve hit an error.\n');
    psychrethrow(psychlasterror);
end

wrect = env.scrns(1).rect;
[~, cy] = RectCenter(wrect);
rect_x = wrect(3);
face_x = 115;

% If rating happy, angry, sad, how make you feel, show faces
if (status.rating_index <= 4)
    wrect = env.scrns(1).rect;
    [~, cy] = RectCenter(wrect);
    rect_x = wrect(3);
    rect_y = wrect(4);
    face_x = 115;
    face_rect = [0 0 115 160];
    btw_pix = round((rect_x - 4*face_x)/5); % equal spacing b/w 115 pix wide images
    try
        Screen('DrawTexture', env.win_ptr, env.face(status.rating_index).intensity(1), [], CenterRectOnPoint(face_rect, 1*btw_pix + 0*face_x, cy));
        Screen('DrawTexture', env.win_ptr, env.face(status.rating_index).intensity(2), [], CenterRectOnPoint(face_rect, 2*btw_pix + 1*face_x, cy));
        Screen('DrawTexture', env.win_ptr, env.face(status.rating_index).intensity(3), [], CenterRectOnPoint(face_rect, 3*btw_pix + 2*face_x, cy));
        Screen('DrawTexture', env.win_ptr, env.face(status.rating_index).intensity(4), [], CenterRectOnPoint(face_rect, 4*btw_pix + 3*face_x, cy));
    catch
        Screen('CloseAll');
        fprintf('We''ve hit an error.\n');
        psychrethrow(psychlasterror);
    end
else % Show boxes for text response
end

% Show question to ask
switch status.rating_index
    case 1
        msg_text = 'How happy does this make you feel?';
    case 2
        msg_text = 'How angry does this make you feel?';
    case 3
        msg_text = 'How sad does this make you feel?';
    case 4
        msg_text = 'How did this make you feel?';
    case 5
        msg_text = 'Who is speaking?';
    case 6
        msg_text = 'Who is being spoken to?';
end
DrawFormattedText(env.win_ptr, msg_text, 'center', 200, env.particip_text_color);
% DrawFormattedText(env.win_ptr, msg_text, 'center', [], env.particip_text_color);
Screen('Flip', env.win_ptr);
end