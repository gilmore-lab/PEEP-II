function [this_snd, snd_freq, nrchannels] = load_peep_sound(snd_fn)
% [this_snd, snd_freq, nrchannels] = load_peep_sound(snd_fn)
%   Loads sound for PEEP-II study.
%
%   Called by: peep_run.m

% Rick Gilmore, 2015

% 2015-12-02 rog modified to deal with cell array to char str conversion.

snd_fn = char(snd_fn);
try
    [this_snd, snd_freq] = audioread(char(snd_fn));
    nrchannels = size(this_snd,2);
    
    % nrchannels must be 2 for some soundcards
    if nrchannels < 2
        this_snd = [this_snd' ; this_snd'];
        nrchannels = 2;
    end
catch
    fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
    fprintf('Failed to read sound %s. Aborting.\n', snd_fn);
    psychlasterror;
    psychlasterror('reset');
end

return

