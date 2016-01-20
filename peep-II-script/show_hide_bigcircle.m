function [ status ] = show_hide_bigcircle( environment, status )
% show_hide_bigcircle( status, environment )
%   determines when to show and hide big circle

% 2015-01-15 Rick Gilmore, rick.o.gilmore@gmail.com

% Dependencies
%
%   Calls:
%       peep_log_msg.m
%       write_event_2_file.m
%
%   Called by:
%       peep_run.m

% 2015-01-20 rog created
%--------------------------------------------------------------------------

if status.snd_status.Active % Mostly just need to compute next status.change_secs time -- REFACTOR
    if GetSecs() > status.change_secs
        if status.big_circle
            status.big_circle = 0;
            fix_2_screen(status.big_circle, status.win_ptr, environment);
            write_event_2_file(status.start_secs, num2str(status.big_circle), status.curr_snd, num2str(status.n_pulses_detected), 'ring_off', environment.csv_fid);
            
            % Compute change time in middle of next silent interval
            status.change_secs = GetSecs() + (10-status.snd_status.PositionSecs) + rand(1)*(3) + environment.circle_chg_min_secs;
            peep_log_msg(sprintf('%s : Fix -. Change at %07.3f.\n', status.now_playing, status.change_secs-status.start_secs), status.start_secs, environment.log_fid);
        else
            status.big_circle = 1;
            fix_2_screen(status.big_circle, status.win_ptr, environment);
            write_event_2_file(status.start_secs, num2str(status.big_circle), status.curr_snd, num2str(status.n_pulses_detected), 'ring_on', environment.csv_fid);
            status.change_secs = status.change_secs + environment.circle_chg_dur_secs;
            peep_log_msg(sprintf('%s : Fix +. Change at %07.3f.\n', status.now_playing, status.change_secs-status.start_secs), status.start_secs, environment.log_fid);
        end % if status.big_circle
    end % if GetSecs()
else
    if (GetSecs() > status.change_secs)
        if status.big_circle
            status.big_circle = 0;
            fix_2_screen(status.big_circle, status.win_ptr, environment);
            write_event_2_file(status.start_secs, num2str(status.big_circle), status.curr_snd, num2str(status.n_pulses_detected), 'ring_off', environment.csv_fid);
            status.change_secs = status.sil_end + rand(1)*(environment.circle_chg_max_secs-environment.circle_chg_min_secs) + environment.circle_chg_min_secs;
            peep_log_msg(sprintf('%s : Fix -. Change at %07.3f.\n', status.now_playing, status.change_secs-status.start_secs), status.start_secs, environment.log_fid);
        else
            status.big_circle = 1;
            fix_2_screen(status.big_circle, status.win_ptr, environment);
            write_event_2_file(status.start_secs, num2str(status.big_circle), status.curr_snd, num2str(status.n_pulses_detected), 'ring_on', environment.csv_fid);
            status.change_secs = status.change_secs + environment.circle_chg_dur_secs;
            peep_log_msg(sprintf('%s : Fix +. Change at %07.3f.\n', status.now_playing, status.change_secs-status.start_secs), status.start_secs, environment.log_fid);
        end % if status.big_circle
    end % if (GetSecs()
end % if snd_status.Active
