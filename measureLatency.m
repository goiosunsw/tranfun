function [m,n] = measureLatency(inDev, outDev, Fs)
%
% measureLatency, measure latency of the playrecorder object
%

[y,bins] = multiTone(Fs,5,64,Fs);
bins = sort(bins')';

pr = playrec(y,inDev,outDev,Fs,2,10);

pr.start();
pause(2);
pr.stop();

inputData = pr.inputDevice.getaudiodata();

pr.delete();

s = spectrogram(inputData(:,1),64,48,64);
as = abs(s);

maxas=as==imdilate(as,ones(3,5));

[r,c]=ind2sub(size(maxas),find(maxas&(as>max(as')'/2)));

rad = 2;
m = zeros(size(s,2),1);
n = zeros(size(s,2),1);
for ii = rad:(size(s,2)-rad)
    pks = (r((c>=ii-rad)&(c<=ii+rad))');
    matches = zeros(size(bins,1),1);
    for pk = 1:length(pks)
        matches = matches + any((bins==pks(pk))');
    end
    [val,pos] = max(matches);
    m(ii) = pos(1);
    n(ii) = val(1);
end