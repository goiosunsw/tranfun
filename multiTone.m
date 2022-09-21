function [y, bins] = multiTone(n, nTones, nFFT, sr)
% 
% [y, bins] = multiTone(n, nTones, nFFT, sr) 
%
% Generate a sequence of simultaneous n-tones 
% to be analysed in a nFFT fft

nFrame = 2*nFFT;

y = zeros(n,1);

envelope = (1:nFrame)/nFrame*2;
envelope(end/2:end) = (nFrame/2:-1:0)/nFrame*2;

iStart = 1;
iEnd = iStart + nFrame-1;

binFreqs = ((1:nFFT)-1)/nFFT*sr;

bins = zeros(round(n/nFrame),nTones);

frNo = 1;
while (iEnd<=n)
  thisFrame = zeros(1,nFrame);
  bins(frNo,:) = sampleDist((1:nFFT/2),nTones,1);
  for i = (1:nTones)
    f = binFreqs(bins(frNo,i));
    thisFrame = thisFrame + sin(2*pi*f/sr*(0:nFrame-1));
  end
  thisFrame = thisFrame .* envelope/nTones;
  y(iStart:iEnd) = thisFrame;
  frNo = frNo + 1;
  iStart = iStart + nFrame;
  iEnd = iStart+nFrame-1;
end
