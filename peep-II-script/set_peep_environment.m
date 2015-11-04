function environment = set_peep_environment()

environment = [];

environment.sound_dir = '/wav';
environment.data_dir = '/mri-behavior';
environment.run_orders_dir = '/run-orders';

environment.mri_TR = 2;
environment.mri_DISDAQs = 3;

environment.sound_secs = 10;
environment.silence_secs = 6;

environment.tKey = KbName('t');
environment.escapeKey = KbName('ESCAPE');

screenNumbers = Screen('Screens');
for s = 1:length(screenNumbers)
    environment.scrns(s).scrNum = screenNumbers(s);
    environment.scrns(s).hz = Screen('FrameRate', screenNumbers(s));
    environment.scrns(s).rect = Screen('Rect', screenNumbers(s));
end

return