function pre_scan_check(fam_id, nov_id)
% pre_scan_check(fam_id, nov_id)
%   Checks status of localization, sound files, keyboards prior to scan.

% 2015-11 Rick Gilmore

% 2015-11-05 rogilmore modified

if nargin < 2
    fprintf('Familiar and novel IDs not specified. Using defaults.\n');
    fam_id = '9999';
    nov_id = '9998';
end

%--------------------------------------------------------------------------
% Check localization
localize_peep;

%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Check wav/ directories for this participant
n_files_expected = 32;
fam_dir = strcat('wav/', fam_id, '/norm');
nov_dir = strcat('wav/', nov_id, '/norm');

fam_dir_info = dir(fullfile(fam_dir, '*.wav'));
nov_dir_info = dir(fullfile(nov_dir, '*.wav'));

fam_sz = size(fam_dir_info);
nov_sz = size(nov_dir_info);

fprintf('Checking "familiar".\n');
fprintf('There are %i .wav files in %s. ', fam_sz(1), fam_dir);
if fam_sz(1) ~= n_files_expected
    fprintf('Incorrect number of files. Listing.\n');
    dir(fullfile(fam_dir, strcat(fam_id, '-ang-*.wav')))
    dir(fullfile(fam_dir, strcat(fam_id, '-hap-*.wav')))
    dir(fullfile(fam_dir, strcat(fam_id, '-neu-*.wav')))
    dir(fullfile(fam_dir, strcat(fam_id, '-sad-*.wav')))
else
    fprintf('Ok.\n');
end

fprintf('\nChecking "novel".\n');
fprintf('There are %i .wav files in %s. ', nov_sz(1), nov_dir);
if nov_sz(1) ~= n_files_expected
    fprintf('Incorrect number of files. Listing.\n');
    dir(fullfile(fam_dir, strcat(nov_id, '-ang-*.wav')))
    dir(fullfile(fam_dir, strcat(nov_id, '-hap-*.wav')))
    dir(fullfile(fam_dir, strcat(nov_id, '-neu-*.wav')))
    dir(fullfile(fam_dir, strcat(nov_id, '-sad-*.wav')))
else
    fprintf('Ok.\n');
end

%-------------------------------------------------------------------------
% Check keyboard(s)
fprintf('\nChecking keyboard(s).\n');
device_report;
end