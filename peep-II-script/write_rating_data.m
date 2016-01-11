function write_rating_data(status, session, env)
% write_rating_data(session, env)
%   Writes PEEP-II sound rating data to file.

% 2016-01-11 Rick O. Gilmore rick.o.gilmore@gmail.com

% 2016-01-11 rog wrote.
%--------------------------------------------------------------------------

% Write fam, nov, run, order, snd_index, snd_file name
fprintf(env.csv_fid,'%s,%s,%s,%s,%i,%s,', char(session.this_family), char(session.nov_family), char(session.run), char(session.order), status.snd_index, char(session.this_run_data.File(status.snd_index)));

% Write ratings
fprintf(env.csv_fid,'%i,%i,%i,%i,%i\n', session.ratings(status.snd_index,1), session.ratings(status.snd_index,2), session.ratings(status.snd_index,3), session.ratings(status.snd_index,4), session.ratings(status.snd_index,5));