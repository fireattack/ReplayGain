function Vrms = replaygain(filename,a1,b1,a2,b2)
% Determine the perceived loudness of a file
% METHOD:
% 1) Calculate Vrms every 50ms
% 2) Sort in ascending order of loudness
% 3) Pick the 95% interval (i.e. go 95% up the list, and choose the value at this point)
% 4) Convert this value into dB
% 5) return this value.
% Back in the main program...
% 6) Subtract it from that calculated for -20dB FS RMS pink noise
% Result = required correction to replay gain (relative to 83dB reference)

% David Robinson, 10th July 2001. http://www.David.Robinson.org/


% Get information about file
lngth=size(audioread(filename));
samples=lngth(1);
channels=lngth(2);
disp(channels)
% Read sampling rate and No. of bits
[dummy, fs]=audioread(filename,[1 2]);

% The the file isn't CD sample rate, try to generate appropriate equal loudness filter
if fs~=44100 | nargin<2,
   [a1,b1,a2,b2]=equalloudfilt(fs);
end

% Set the Vrms window to 50ms
rms_window_length=round(50*(fs/1000));

% Set the interval to 95%
percentage=95;	% Which rms value to take as typical of whole file

% Set amount of data (in seconds) which Matlab on my PC happily copes with at once
block_length=2;	% chunk data in from wave file in 2 second blocks - file less than this length will cause an error

% Determine how many rms value to calculate per block of data
rms_per_block=fix((fs*block_length)/rms_window_length);

% Check that the file is long enough to process in block_length blocks
if lngth<(fs*block_length),
   warning(['skipping ' filename ' because it is too short']);
   Vrms=0;
   Vrms_all=0;
   return
end

% Display a Waitbar to show user how far into file we are
wbh=waitbar(0,'Processing...');

% Loop through all the file in blocks a defined above
for audio_block=0:fix(samples/(fs*block_length))-1,
   % Update the waitbar display to reflect progress
   waitbar(audio_block/(fix(samples/(fs*block_length))-1));
   % Grab a section of audio
   inaudio=audioread(filename,[(fs*block_length*audio_block)+1 fs*block_length*(audio_block+1)]);
   % Filter it using the equal loudness curve filter:
   inaudio=filter(b1,a1,inaudio);
   inaudio=filter(b2,a2,inaudio);
   % Calculate Vrms:
   for rms_block=0:rms_per_block-1,
      % Mono signal: just do the one channel
      if channels==1,
         Vrms_all((audio_block*rms_per_block)+rms_block+1)=mean(inaudio((rms_block*rms_window_length)+1:(rms_block+1)*rms_window_length).^2);
      % Stereo signal: take average Vrms of both channels   
      elseif channels==2,
         Vrms_left=mean(inaudio((rms_block*rms_window_length)+1:(rms_block+1)*rms_window_length,1).^2);
         Vrms_right=mean(inaudio((rms_block*rms_window_length)+1:(rms_block+1)*rms_window_length,2).^2);
         Vrms_all((audio_block*rms_per_block)+rms_block+1)=(Vrms_left+Vrms_right)/2;         
      end
   end
end

% Close the waitbar
close(wbh);

% Convert to dB
Vrms_all=10*log10(Vrms_all+10^-10);
% Sort the Vrms values into numerical order
Vrms_all=sort(Vrms_all);
% Pick the 95% value
Vrms=Vrms_all(round(length(Vrms_all)*percentage/100));

return
