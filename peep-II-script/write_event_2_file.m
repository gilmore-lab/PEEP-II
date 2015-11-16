function write_2_event_file(start_secs, curr_vis, curr_snd, curr_mri, evt_type, fid)
% write_2_event_file(curr_vis, curr_snd, curr_mri, evt_type, fid)
%   Writes events to event file specified by fid.
%   Event fields are comma-separated.

ts = datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF');
secs_fr_start = GetSecs()-start_secs;
fprintf(fid, '%s,%07.3f,', ts, secs_fr_start);
fprintf(fid, '%s,%s,%s,%s\n', curr_vis, curr_snd, curr_mri, evt_type);

end

