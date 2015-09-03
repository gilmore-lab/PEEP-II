function speaker_id = create_speaker_id(speaker, this_family, nov_family)

if strcmp(speaker, 'fam')
    speaker_id = this_family;
else
    speaker_id = nov_family;
end