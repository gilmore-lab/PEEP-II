function localize_peep(peep_home)
% localize_peep(peep_home)
%   Localizes PEEP-II MRI script

% 2015-11-13 Rick Gilmore

% 2015-11-13 rog wrote

if nargin < 1
    peep_home = 'peep-II-script';
end

dir_peep_home = FindFolder(peep_home);
fprintf('Found PEEP-II home directory %s.\n', dir_peep_home);

fprintf('Changing to that directory.\n');
cd(dir_peep_home)

fprintf('Adding directory to path.\n');
PathListIsMember(FindFolder('peep-II-script'))
end
