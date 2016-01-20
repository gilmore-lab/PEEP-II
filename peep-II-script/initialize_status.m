status.continue = 1;

status.n_pulses_detected = 0;   

status.silence = 0;     % Flag indicating start of timed silent period
status.sil_start = 0;   % Time of silent period start
status.sil_end = 0;     % Time of silent period end
status.last_silence = 0;    % Flag indicating whether this is the last silent period 

status.curr_snd = '';   % Name of sound or silence
status.snd_index = 0;   % Index for current sound in queue
status.next_snd = 0;    % Index for next sound in queue
status.snd_start_time;  % Start time of current sound
status.snd_status = []; % Data structure holding results of call to PsychPortAudio('GetStatus', pahandle);

status.start_secs = 0;  % Start time of study
    
status.change_secs = 0; % Time for next on/off big circle
status.big_circle = 0;  % Flag indicating whether big circle is on or off

status.lastPress = 0;   % Time of last keypress

