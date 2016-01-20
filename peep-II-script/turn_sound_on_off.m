function status = turn_sound_on_off( environment, session, status )
% status = turn_sound_on_off( status, environment )
%   determines when to show and hide big circle in PEEP-II MRI study.

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

% If not silence, then 
if ~status.silence
    status.sil_start = GetSecs();
    status.silence = 1;
    status.now_playing = char(environment.now_playing_msgs(1));
    status.curr_snd = 'silence';
    
    % Specify different ending duration for first silence period.
    if status.snd_index == 0 % first silence
        status.sil_end = status.sil_start + environment.silence_secs + environment.extra_silence;
        peep_log_msg(sprintf('%s : Intro silence, end at %07.3f.\n', status.now_playing, status.sil_end-status.start_secs), status.start_secs, environment.log_fid);
    else
        status.sil_end = status.sil_start + environment.silence_secs;
        peep_log_msg(sprintf('%s : Sound duration %07.3f s.\n', status.now_playing, status.sil_start-status.snd_start_time), status.start_secs, environment.log_fid);
    end % if status.snd_index
    write_event_2_file(status.start_secs, num2str(status.big_circle), status.curr_snd, num2str(status.n_pulses_detected), 'sound_off', environment.csv_fid);
    
    % if not end, load next sound
    status.next_snd = status.snd_index + 1;
    if status.next_snd <= session.n_snds
        peep_log_msg(sprintf('%s : Loading sound %i of %i : %s.\n', status.now_playing, status.next_snd, session.n_snds, char(session.this_run_data.File(status.next_snd))), status.start_secs, environment.log_fid);
        [this_snd, ~, ~] = load_peep_sound(session.this_run_data.File(status.next_snd));
        PsychPortAudio('FillBuffer', session.pahandle, this_snd, [], 0);
        status.snd_index = status.next_snd;
    else
        status.now_playing = char(environment.now_playing_msgs(1));
        peep_log_msg(sprintf('%s : Last sound finished.\n', status.now_playing), status.start_secs, environment.log_fid);
        peep_log_msg(sprintf('%s : Last silent period starting.\n', status.now_playing), status.start_secs, environment.log_fid);
        status.last_silence = 1;
    end % if status.next_snd
end % if ~silence

% Silence over? Then start new sound if not at end
if (GetSecs() > status.sil_end)
    if status.last_silence
        status.continue = 0;
        return;
    else
        status.silence = 0;
        status.snd_start_time = PsychPortAudio('Start', session.pahandle, 1, 0, 1);
        peep_log_msg(sprintf('%s : Silence duration %07.3f s.\n', status.now_playing, status.snd_start_time-status.sil_start), status.start_secs, environment.log_fid);
        status.now_playing = char(environment.now_playing_msgs(2));
        status.curr_snd = char(session.this_run_data.File(status.snd_index));
        status.snd_index = status.next_snd;
        peep_log_msg(sprintf('%s : Started sound %i of %i: %s.\n', status.now_playing, status.snd_index, session.n_snds, char(session.this_run_data.File(status.snd_index))), status.start_secs, environment.log_fid);
        write_event_2_file(status.start_secs, num2str(status.big_circle), status.curr_snd, num2str(status.n_pulses_detected), 'sound_on', environment.csv_fid);
        status.sil_start = GetSecs() + 12; % 10 s sound + 2 s buffer from start
    end % if status.last_silence
end % if (GetSecs()
