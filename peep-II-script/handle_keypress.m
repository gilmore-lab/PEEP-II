function [ status, session ] = handle_keypress(session, environment, status)
% handle_keypress(session, environment, status)
%   handles keypresses from peep_ratings set of scripts

% 2015-11-18 Rick Gilmore, rick.o.gilmore@gmail.com

% Dependencies

% 2015-12-23 rog modified
% 2015-12-29 rog debugged up/down arrow, left/right keypress, ESCAPE, SPACE
%--------------------------------------------------------------------------

[pressed, ~, firstPress, ~] = KbCheck(environment.internal_kbd_index);
if pressed
    if firstPress(environment.escapeKey) % Escape from ratings
        status.continue = 0;
        PsychPortAudio('Close', session.pahandle);
        return;
    end
    if firstPress(environment.spaceKey) % Play/stop sound
        snd_status = PsychPortAudio('GetStatus', session.pahandle);
        if snd_status.Active
            fprintf('Stop sound.\n');
            status.play = 0;
            PsychPortAudio('Stop', session.pahandle, 1, 0, 1);
        else
            fprintf('Start sound.\n');
            status.play = 1;
            PsychPortAudio('Start', session.pahandle, 1, 0, 1);
        end % if snd_status
    end % if firstPress
    if firstPress(environment.leftArrowKey) % Move rating lower
        if (status.highlighted_index - 1)
            status.highlighted_index = status.highlighted_index - 1;
        else
            status.highlighted_index = 1;
        end
    end
    if firstPress(environment.rightArrowKey) % Move rating lower
        if status.rating_index <= 4
            if (status.highlighted_index + 1 < 4)
                status.highlighted_index = status.highlighted_index + 1;
            else
                status.highlighted_index = 4;
            end
        else % for yes/no judgment
             if (status.highlighted_index + 1 < 3)
                status.highlighted_index = status.highlighted_index + 1;
            else
                status.highlighted_index = 2;
            end
        end 
    end
    if firstPress(environment.enterKey) % Enter and save rating
        % Save rating
        if (status.rating_index > 0)
            session.rating(status.snd_index, status.rating_index) = status.highlighted_index;
            status.highlighted_index = 1; % return to default rating
        end
        if (status.rating_index + 1 > 6)
            % Load next sound, should indicate change somehow
            if (status.snd_index + 1 <= session.n_snds)
                fprintf('Switching to sound %i.\n', status.snd_index);
                status.snd_index = status.snd_index + 1;
                [this_snd, ~, ~] = load_peep_sound(session.this_run_data.File(status.snd_index));
                PsychPortAudio('FillBuffer', session.pahandle, this_snd, [], 0);
                status.highlighted_index = 1;
                status.rating_index = 0;
            else
                status.ratings_finished = 1;
            end % if (status.snd_index
        else
            status.rating_index = status.rating_index + 1;
        end % if (status.rating_index
    end % if firstPress(environment.enterKey)
    if firstPress(environment.tabKey)
        fprintf('Rating index %i.\n', status.rating_index);
        if (status.rating_index + 1 > 6)
            status.rating_index = 6;
        else
            status.rating_index = status.rating_index + 1;
        end
        status.highlighted_index = 1; % return to default rating
    end
    if firstPress(environment.upArrowKey) % Go back to previous rating
        fprintf('Rating index %i.\n', status.rating_index);
        if (status.rating_index - 1 <= 0)
            status.rating_index = 1;
        else
            status.rating_index = status.rating_index - 1;
        end
        status.highlighted_index = 1; % return to default
    end
    if firstPress(environment.downArrowKey) % Go forward to next rating
        fprintf('Rating index %i.\n', status.rating_index);
        if (status.rating_index + 1 > 6)
            status.rating_index = 6;
        else
            status.rating_index = status.rating_index + 1;
        end
        status.highlighted_index = 1; % return to default
    end
end