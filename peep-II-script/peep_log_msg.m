function peep_log_msg(msg_text, start_secs, fid)
% peep_log_msg(msg_text, start_secs, fid)
%   Writes msg_text to log file and to console.

ts = datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF');
secs_fr_start = GetSecs()-start_secs;
fprintf('%s : %07.3f s : ', ts, secs_fr_start);
fprintf(msg_text);
fprintf(fid, '%s : %07.3f s : ', ts, secs_fr_start);
fprintf(fid, msg_text);
return
