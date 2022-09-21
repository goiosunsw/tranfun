function [m,n] = matchMultiTone(y,bins,wind)
% matchMultiTone matches a recorded sound y to a 
% multiTone figerprint BINS using a window legth wind
%
% Returns best match in BINS for each neighborhood of spectrogram frame
% and number of tones matched for best match.

    hop = round(3/4*wind);
    s = spectrogram(y,wind,hop,wind);
    as = abs(s);

    maxas = as==imdilate(as,ones(3,5));

    [r,c]=ind2sub(size(maxas),find(maxas&(as>max(as')'/2)));

    rad = 2;
    m = zeros(size(s,2),1);
    n = zeros(size(s,2),1);
    for ii = rad:(size(s,2)-rad)
        pks = (r((c>=ii-rad)&(c<=ii+rad))');
        matches = zeros(1,size(bins,1));
        for pk = 1:length(pks)
            matches = matches + any((bins==pks(pk))');
        end
        [val,pos] = max(matches);
        if val(1)>0
            m(ii) = pos(1);
            n(ii) = val(1);
        end
    end
end

