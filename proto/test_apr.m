%% Parameters
Device = 'MOTU 896HD'; % Put the device you want, it should be available in the list.
SampleRate = 44100; % Hz
BitDepth = '16-bit integer'; % Or: '8-bit integer' , '32-bit float' , '24-bit integer'
SamplesPerFrame = 512;
outputChannel = 1;
inputChannel = 1;

%% Signal
signal = sweeptone(1,0.5,SampleRate,'SweepFrequencyRange',[20,8000]); % Exponential sweep tone

%% Audio object to play and record
% Buffers to read and write blocks (frames) of input and output samples,
% respectively
toOutBuffer = dsp.AsyncBuffer(length(signal));
toInBuffer = dsp.AsyncBuffer(length(signal));
write(toOutBuffer,signal);

% Sound card interface for synchronous playback and recording
aPR = audioPlayerRecorder('Device',Device,...
    'SampleRate',SampleRate,...
    'BitDepth',BitDepth,...
    'PlayerChannelMapping',outputChannel,...
    'RecorderChannelMapping',inputChannel);

% Streaming playback and acquisition
% Loop ensures internal queues are never saturated
nUnderruns = 0;
nOverruns = 0;
while toOutBuffer.NumUnreadSamples >= SamplesPerFrame
    % Get a block of input samples
    frameOut = read(toOutBuffer,SamplesPerFrame);
    
    % Playback and record
    [frameIn,nUnderrunsaux,nOverrunsaux] = aPR(frameOut);
    
    % Store a block of output samples
    write(toInBuffer,frameIn);
    
    % Check no blocks were dropped in either direction
    if nUnderrunsaux > 0
        nUnderruns = nUnderruns + nUnderrunsaux;
    end
    if nOverrunsaux > 0
        nOverruns = nOverruns + nOverrunsaux;
    end
end
release(aPR)

if nUnderruns > 0
    fprintf('Audio player queue was underrun by %d samples.\n',nUnderruns);
end
if nOverruns > 0
    fprintf('Audio recorder queue was overrun by %d samples.\n',nOverruns);
end

% Re-align full input and output sequences
In = read(toInBuffer,toInBuffer.NumUnreadSamples);
Out = signal(1:size(In,1),:);


%% Calculate impulse response
IR = impzest(Out,In); 
t = (0:length(IR)-1)'/SampleRate;

%% Calculate frequency response
nfft = 2^15;
[H,f] = freqz(IR,1,nfft,SampleRate);

%% Graphics
figure('Color',[1 1 1])

subplot(2,1,1)
plot(t,IR./max(IR),'k')
xlabel('Time [s]')
ylabel('Amplitude [normalized]')
ylim([-1,1]);

subplot(2,1,2)
semilogx(f,20*log10(abs(H)/2e-5),'k')
xlabel('Frequency [Hz]')
ylabel('SPL [dB]')
xlim([10,25000])
