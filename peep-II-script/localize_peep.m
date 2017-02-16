function localize_peep(peep_home)
% localize_peep(peep_home)
%   Localizes PEEP-II MRI script

% 2015-11-13 Rick Gilmore, rick.o.gilmore@gmail.com

% 2015-11-13 rog wrote
% 2015-12-01 rog added fix for different starting directories.
% 2015-12-29 rog modified documentation, tweaked console reporting.
%--------------------------------------------------------------------------

if nargin < 1
    peep_home = 'peep-II-script';
end % if nargin
fprintf('PEEP home is: %s\n', peep_home);

% FindFolder must be run from ~/Documents/MATLAB
m_root = '~/Documents/MATLAB';
fprintf('Changing to: %s to run FindFolder.\n', m_root);
cd('~/Documents/MATLAB'); 

% Search for peep_home
dir_peep_home = FindFolder(peep_home);
if isempty(dir_peep_home)
    fprintf('Cannot find PEEP-II home directory: %s \n.', peep_home);
    return;
end % if isempty

% If found, change to and add to path
fprintf('Found PEEP-II home directory: %s\n', dir_peep_home);
fprintf('Changing to: %s\n', dir_peep_home);
cd(dir_peep_home);

fprintf('Adding directory to path.\n');
PathListIsMember(FindFolder('peep-II-script'));
end
