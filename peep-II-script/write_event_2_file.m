function write_event_2_file(start_secs, curr_vis, curr_snd, curr_mri, evt_type, fid)
% write_2_event_file(curr_vis, curr_snd, curr_mri, evt_type, fid)
%   Writes events to event file specified by fid.
%   Event fields are comma-separated.

% 2015-11 Rick Gilmore wrote

% 2015-11-15 rog created
%--------------------------------------------------------------------------

ts = datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF');
secs_fr_start = GetSecs()-start_secs;
fprintf(fid, '%s,%07.3f,', ts, secs_fr_start);
fprintf(fid, '%s,%s,%s,%s\n', curr_vis, curr_snd, curr_mri, evt_type);

end

