function localize_peep(peep_home)
% localize_peep(peep_home)
%   Localizes PEEP-II MRI script

% 2015-11-13 Rick Gilmore

% 2015-11-13 rog wrote
% 2015-12-01 rog added fix for different starting directories.
%--------------------------------------------------------------------------

if nargin < 1
    peep_home = 'peep-II-script';
end

% FindFolder must be run from ~/Documents/MATLAB
cd('~/Documents/MATLAB'); 

dir_peep_home = FindFolder(peep_home);
if isempty(dir_peep_home)
    fprintf('Cannot find PEEP-II home directory: %s \n.', peep_home);
    return;
end

fprintf('Found PEEP-II home directory %s\n', dir_peep_home);
fprintf('Changing to that directory.\n');
cd(dir_peep_home);

fprintf('Adding directory to path.\n');
PathListIsMember(FindFolder('peep-II-script'))
end
