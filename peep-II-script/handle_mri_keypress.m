function [ status ] = handle_mri_keypress(environment, status)
% handle__mri_keypress(session, environment, status)
%   handles keypresses from peep_mri set of scripts

% 2015-01-15 Rick Gilmore, rick.o.gilmore@gmail.com

% Dependencies
%
%   Calls:
%       peep_log_msg.m
%       write_event_2_file.m
%
%   Called by:
%       peep_run.m

% 2015-01-15 rog created
%--------------------------------------------------------------------------

% Check keyboard(s) then handle
[pressed, timeSecs, firstPress, ~] = KbCheck(environment.keyboardIndices);
if pressed
    if firstPress(environment.escapeKey) % Escape
        peep_log_msg(sprintf('%s : Escape detected at %07.3f from start.\n', status.now_playing, timeSecs-status.start_secs), status.start_secs, environment.log_fid);
        status.continue = 0;
        return;
    end
    % Trigger pulse detection should not depend on last keypress from
    % experimenter or participant
    if firstPress(environment.tKey)
        if (timeSecs - status.last_pulse) > environment.secs_btw_pulses
            status.last_pulse = timeSecs;
            status.n_pulses_detected = status.n_pulses_detected + 1;
            peep_log_msg(sprintf('%s : Scanner pulse %i detected.\n', status.now_playing, status.n_pulses_detected), status.start_secs, environment.log_fid);
            write_event_2_file(status.start_secs, num2str(status.big_circle), status.curr_snd, num2str(status.n_pulses_detected), 'new_mri_vol', environment.csv_fid);
        end % if (timeSecs - status.last_pulse)
    end
    % Specify time between valid keypresses to eliminate multiple presses
    if (timeSecs-status.lastPress) > environment.secs_btw_presses
        if (firstPress(environment.aKey) || firstPress(environment.bKey) || firstPress(environment.cKey) || firstPress(environment.dKey))
            status.lastPress = timeSecs;
            peep_log_msg(sprintf('%s : Participant press.\n', status.now_playing), status.start_secs, environment.log_fid);
            write_event_2_file(status.start_secs, num2str(status.big_circle), status.curr_snd, num2str(status.n_pulses_detected), 'keypress', environment.csv_fid);
        end
    end % if (timeSecs-lastPress) > environment.secs_btw_presses
    KbReleaseWait;
end % if pressed