function ok = check_snd_dir(fam_id, nov_id)
% check_snd_dir(fam_id, nov_id)
%   Checks PEEP-II directories to confirm that they have all the sounds
%   needed.

% 2016-01-11 Rick O. Gilmore rick.o.gilmore@gmail.com

% 2016-01-11 rog created
%--------------------------------------------------------------------------

% Check wav/ directories for this participant
ok = 0;
n_files_expected = 32;
fam_dir = strcat('wav/', fam_id, '/norm');
nov_dir = strcat('wav/', nov_id, '/norm');

fam_dir_info = dir(fullfile(fam_dir, '*.wav'));
nov_dir_info = dir(fullfile(nov_dir, '*.wav'));

fam_sz = size(fam_dir_info);
nov_sz = size(nov_dir_info);

fprintf('Checking "familiar": %s.\n', fam_id);
fprintf('There are %i .wav files in %s. ', fam_sz(1), fam_dir);
if fam_sz(1) ~= n_files_expected
    fprintf('Incorrect number of files. Listing.\n');
    dir(fullfile(fam_dir, strcat(fam_id, '-ang-*.wav')))
    dir(fullfile(fam_dir, strcat(fam_id, '-hap-*.wav')))
    dir(fullfile(fam_dir, strcat(fam_id, '-neu-*.wav')))
    dir(fullfile(fam_dir, strcat(fam_id, '-sad-*.wav')))
    ok = 0;
    return;
else
    fprintf('Ok.\n');
    ok = 1;
end

fprintf('\nChecking "novel": %s.\n', nov_id);
fprintf('There are %i .wav files in %s. ', nov_sz(1), nov_dir);
if nov_sz(1) ~= n_files_expected
    fprintf('Incorrect number of files. Listing.\n');
    dir(fullfile(nov_dir, strcat(nov_id, '-ang-*.wav')))
    dir(fullfile(nov_dir, strcat(nov_id, '-hap-*.wav')))
    dir(fullfile(nov_dir, strcat(nov_id, '-neu-*.wav')))
    dir(fullfile(nov_dir, strcat(nov_id, '-sad-*.wav')))
    ok = 0;
    return;
else
    fprintf('Ok.\n');
    ok = 1;
end