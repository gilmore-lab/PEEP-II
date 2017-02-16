function update_screen(session, env, status)
% update_screen(session, env, status)
%   Updates PEEP ratings screen based on user input.

% 2015-11-18 Rick Gilmore, rick.o.gilmore@gmail.com

% Dependencies

% 2015-11-18 rog wrote.
% 2015-12-29 rog debugged to show instructions text, questions text.
% 2016-01-10 rog fixed detection of return key, advance to next sound.
% 2016-02-07 rog added scared faces.
%--------------------------------------------------------------------------

% Rating sound %i of %i.
try
    Screen('FillRect', env.win_ptr, env.color.gray);
    Screen('TextFont', env.win_ptr, 'Courier New');
    Screen('TextSize', env.win_ptr, 0.8*env.particip_text_size);
    Screen('TextStyle', env.win_ptr, 1+2);
    msg_text = sprintf('%s / %s : Run %s : Order %s : Snd %i of %i', char(session.this_family), char(session.nov_family), char(session.run), char(session.order), status.snd_index, session.n_snds);
    DrawFormattedText(env.win_ptr, msg_text, 'center', 0, env.particip_text_color);
catch
    Screen('CloseAll');
    fprintf('We''ve hit an error.\n');
    psychrethrow(psychlasterror);
end

% Instructions to experimenter
try
    Screen('TextFont', env.win_ptr, 'Courier New');
    Screen('TextSize', env.win_ptr, round(0.38*env.particip_text_size)); % 50% smaller?
    Screen('TextStyle', env.win_ptr, 1+2);
    msg_text = sprintf('SPACE to start sound; Left/Right switch between rating values; Up/Down switch questions; Return to record rating');
    DrawFormattedText(env.win_ptr, msg_text, 'center', 100, env.color.midred);
catch
    Screen('CloseAll');
    fprintf('We''ve hit an error.\n');
    psychrethrow(psychlasterror);
end

% Face/icons
wrect = env.scrns(1).rect;
[~, cy] = RectCenter(wrect);
rect_x = wrect(3);
face_x = 115;
face_msg_y = 250;

% If rating happy, angry, sad, how make you feel, show faces
if (status.rating_index <= 4) & (status.rating_index > 0)
    wrect = env.scrns(1).rect;
    [~, cy] = RectCenter(wrect);
    rect_x = wrect(3);
    rect_y = wrect(4);
    face_x = 192;
    face_y = 259;
    n_faces = 4;
    face_rect = [0 0 face_x face_y];  % rect of face image
    btw_pix = round((rect_x - n_faces*face_x)/(n_faces+1)); % equal spacing b/w 115 pix wide images
    frame_pix = 15;
    frame_rect = [0 0 face_x + frame_pix face_y + frame_pix];
    frame_color = [127 0 0];
    try
        Screen('DrawTexture', env.win_ptr, env.face(status.rating_index).intensity(1), [], CenterRectOnPoint(face_rect, 1*btw_pix + 0.5*face_x, cy));
        Screen('DrawTexture', env.win_ptr, env.face(status.rating_index).intensity(2), [], CenterRectOnPoint(face_rect, 2*btw_pix + 1.5*face_x, cy));
        Screen('DrawTexture', env.win_ptr, env.face(status.rating_index).intensity(3), [], CenterRectOnPoint(face_rect, 3*btw_pix + 2.5*face_x, cy));
        Screen('DrawTexture', env.win_ptr, env.face(status.rating_index).intensity(4), [], CenterRectOnPoint(face_rect, 4*btw_pix + 3.5*face_x, cy));        
        % Draw frame rect around currently highlighted face
        Screen('FrameRect', env.win_ptr, frame_color, CenterRectOnPoint(frame_rect, status.highlighted_index*btw_pix + (status.highlighted_index-1 + 0.5)*face_x, cy), frame_pix);
    catch
        Screen('CloseAll');
        fprintf('We''ve hit an error.\n');
        psychrethrow(psychlasterror);
    end
end

% If rating happy, angry, sad, how make you feel, show faces
if (status.rating_index == 5) & (status.rating_index > 0)
    wrect = env.scrns(1).rect;
    [~, cy] = RectCenter(wrect);
    rect_x = wrect(3);
    rect_y = wrect(4);
    face_x = 192;
    face_y = 259;
    n_faces = 5;
    face_rect = [0 0 face_x face_y];  % rect of face image
    btw_pix = round((rect_x - n_faces*face_x)/(n_faces+1)); % equal spacing b/w 115 pix wide images
    frame_pix = 15;
    frame_rect = [0 0 face_x + frame_pix face_y + frame_pix];
    frame_color = [127 0 0];
    try
        Screen('DrawTexture', env.win_ptr, env.face(status.rating_index).intensity(1), [], CenterRectOnPoint(face_rect, 1*btw_pix + 0.5*face_x, cy));
        Screen('DrawTexture', env.win_ptr, env.face(status.rating_index).intensity(2), [], CenterRectOnPoint(face_rect, 2*btw_pix + 1.5*face_x, cy));
        Screen('DrawTexture', env.win_ptr, env.face(status.rating_index).intensity(3), [], CenterRectOnPoint(face_rect, 3*btw_pix + 2.5*face_x, cy));
        Screen('DrawTexture', env.win_ptr, env.face(status.rating_index).intensity(4), [], CenterRectOnPoint(face_rect, 4*btw_pix + 3.5*face_x, cy));
        Screen('DrawTexture', env.win_ptr, env.face(status.rating_index).intensity(5), [], CenterRectOnPoint(face_rect, 5*btw_pix + 4.5*face_x, cy));
        % Draw frame rect around currently highlighted face
        Screen('FrameRect', env.win_ptr, frame_color, CenterRectOnPoint(frame_rect, status.highlighted_index*btw_pix + (status.highlighted_index-1 + 0.5)*face_x, cy), frame_pix);
    catch
        Screen('CloseAll');
        fprintf('We''ve hit an error.\n');
        psychrethrow(psychlasterror);
    end
end

% Yes/No check/X
if (status.rating_index == 6) || (status.rating_index == 7)
    wrect = env.scrns(1).rect;
    [~, cy] = RectCenter(wrect);
    rect_x = wrect(3);
    rect_y = wrect(4);
    face_x = 115;
    face_y = 160;  
    face_rect = [0 0 face_x face_y];  % rect of face image
    btw_pix = round((rect_x - 2*face_x)/3); % equal spacing b/w 115 pix wide images
    frame_pix = 15;
    frame_rect = [0 0 face_x + frame_pix face_y + frame_pix];
    frame_color = [127 0 0];
    try
        Screen('DrawTexture', env.win_ptr, env.yesImg, [], CenterRectOnPoint(face_rect, 1*btw_pix + 0.5*face_x, cy));
        Screen('DrawTexture', env.win_ptr, env.noImg, [], CenterRectOnPoint(face_rect, 2*btw_pix + 1.5*face_x, cy));
        
        % Draw frame rect around currently highlighted face
        Screen('FrameRect', env.win_ptr, frame_color, CenterRectOnPoint(frame_rect, status.highlighted_index*btw_pix + (status.highlighted_index-1 + 0.5)*face_x, cy), frame_pix);
    catch
        Screen('CloseAll');
        fprintf('We''ve hit an error.\n');
        psychrethrow(psychlasterror);
    end
end


% Show question to ask
switch status.rating_index
    case 0
        msg_text = 'Press SPACE to listen to the sound.';
    case 1
        msg_text = 'How HAPPY does this sound?';
    case 2
        msg_text = 'How ANGRY does this sound?';
    case 3
        msg_text = 'How SAD does this sound?';
    case 4
        msg_text = 'How SCARED does this sound?';
    case 5
        msg_text = 'How does this make you feel?';
    case 6
        msg_text = 'Do you know who is speaking?';
    case 7
        msg_text = 'Do you know who is being spoken to?';
end

% Write question to screen
Screen('TextFont', env.win_ptr, 'Courier New');
Screen('TextSize', env.win_ptr, round(env.particip_text_size));
Screen('TextStyle', env.win_ptr, 1);
DrawFormattedText(env.win_ptr, msg_text, 'center', 200, face_msg_y, env.particip_text_color);

% Flip to write
Screen('Flip', env.win_ptr);
end