function [delay] = measureLatency(pr)
%
% measureLatency(pr), 
% measure latency of the playrecorder object
% 

Fs = pr.Fs;

% number of simulatneous tones
ntones = 5;
% threshold for matching tones considered for delay estimation
nmatch = 3;
% Number of samples used for correlation calculation
nc = 1024;

% Multi-tone window (duration of each tone is 2xwindow)
wind = 64;

y = zeros(Fs,1);

% Generate a multitone signature
[y,bins] = multiTone(Fs, ntones, wind, Fs);
bins = sort(bins')';

% Emit and capture signature signal

pr.setOutput(y);
pr.start();
pause(2);
pr.stop();

inputData = pr.inputDevice.getaudiodata();

s = spectrogram(inputData(:,1),wind,round(3*wind/4),wind);
as = abs(s);
as = as./max(as')';

% Match recording to the designed multitones in signature signal
[m,n] = matchMultiTone(inputData(:,1),bins,wind);

thr = nmatch;

% delay between recorded tones and expected
% recorded tone positions are divided by 8:
% - hop size is 1/4 of window size
% - each generated tone spans 2 windows
delay_tones = median(find(n>thr)/8-m(n>thr));
delay = (delay_tones+.5)*wind*2;
fprintf("delay: %d\n",delay);

if delay > 0
    shiftInput = circshift(inputData(:,1),-delay);
    shifty = y;
else
    shiftInput = inputData(:,1);
    shifty = circshift(y,delay);
end

% correlation
[cc, lags] = xcorr(shifty(nc:nc+nc),shiftInput(nc:nc+nc));
[v,mc] = max(abs(cc));
delay = delay-lags(mc);

