wind = 64;
nTones = 5;
Fs = 8000;

[y,bins] = multiTone(Fs,nTones,wind,Fs);

delay= 0;
yr = zeros(length(y)+delay,1);
yr(end-length(y)+1:end) = y+max(y)*randn(size(y))/100;
figure()
spectrogram(yr,wind,wind/4*3,wind,'yaxis');

[m,n] = matchMultiTone(yr,bins,wind);

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

disp(polyfit(find(m>thr)/8,m(m>thr),1))
