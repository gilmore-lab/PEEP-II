function [this_snd, snd_freq, nrchannels] = load_peep_sound(snd_fn, environment, session)

if isempty(snd_fn)
    fprintf('snd_fn misspecified. Quitting');
    return
end

[this_snd, snd_freq] = wavread(snd_fn);
nrchannels = size(this_snd,1);

% nrchannels must be 2 for some soundcards
if nrchannels < 2
    this_snd = [this_snd ; this_snd];
    nrchannels = 2;
end

