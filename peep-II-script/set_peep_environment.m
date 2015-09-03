function environment = set_peep_environment()

environment = [];

environment.sound_dir = '/wav';
environment.data_dir = '/mri-behavior';
enrironment.run_orders_dir = '/run-orders';

environment.mri_TR = 2;
environment.mri_DISDAQs = 3;

environment.sound_secs = 10;
environment.silence_secs = 6;

return