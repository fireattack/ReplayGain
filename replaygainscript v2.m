% replaygainscript
% Asks user for name of wavefiles (or folders containing wavefiles)
% User gives null response to indicate all files entered
% Calculates replay gain of file using "replaygain" function

% To enter entire folder, append / or \ (i.e. "maskers/" processes all files in directory "maskers")

% David Robinson, July 2001. http://www.David.Robinson.org/

clear Vrms

% Get filter co-efs for 44100 kkHz Equal Loudness Filter
[a1,b1,a2,b2]=equalloudfilt(44100);

% Calculate perceived loudness of -20dB FS RMS pink noise
% This is the SMPTE reference signal. It calibrates to:
% 0dB on a studio meter / mixing desk
% 83dB SPL in a listening environment (THIS IS WHAT WE'RE USING HERE)
[ref_Vrms]=replaygain('ref_pink.wav',a1,b1,a2,b2);

filename='test.mp3';

Vrms=ref_Vrms-replaygain(filename,a1,b1,a2,b2);
% Output the result on screen
disp([filename ': ' num2str(Vrms) ' dB']);

disp(char(13));
disp('== ReplayGainScript complete ==');

