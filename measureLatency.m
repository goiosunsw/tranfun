function [m,n] = measureLatency(inDev, outDev, Fs)
%
% measureLatency, measure latency of the playrecorder object
%

pr_delays = zeros(100,1);
pr_i = 1;

wind = 64
[y,bins] = multiTone(Fs,5,wind,Fs);
bins = sort(bins')';

pr = playrec(y,inDev,outDev,Fs,2,10);
pr.setCallback(@cb, .1);

pr.start();
pause(2);
pr.stop();

inputData = pr.inputDevice.getaudiodata();

pr.delete();

s = spectrogram(inputData(:,1),wind,round(3*wind/4),wind);
as = abs(s);

[m,n] = matchMultiTone(inputData(:,1),bins,wind);

figure();
imagesc(as);


thr=3
irec = find(m>0)/8;
p = polyfit(find(m>thr),m(m>thr),1);
 

figure()
subplot(211)

plot(irec,m(m>0));
hold all
%plot(irec,m(m>thr));
%plot(find(m>0),polyval(p,find(m>0)))
subplot(212)
plot(irec,n(m>0));


delay_tones = median(find(n>thr)/8-m(n>thr));
delay = (delay_tones+.5)*wind*2;

ff=figure();
plot(y);
hold all;
shiftInput = circshift(inputData(:,1),-delay);
plot(shiftInput)

% correlation
figure()
nc=1024;
[cc, lags] = xcorr(y(nc:nc+nc),shiftInput(nc:nc+nc));
plot(lags,cc);
[v,mc] = max(abs(cc));
delay = delay+lags(mc);
disp(delay)

figure(ff)
shiftInput = circshift(inputData(:,1),-delay);
plot(shiftInput)

disp(median(pr_delays(1:5)))

    function cb(obj)
        pr_delays(pr_i) = obj.currentOutSample-obj.currentInSample;
        pr_i = pr_i+1;
    end
end
