function [row,col,pks] = decodeMultiTone(y, nFFT)
%
% 
%
% decode a multitone file, finding spectrogram peak positions

nHop = nFFT/4;
s = spectrogram(y,nFFT,nFFT-nHop);
s = abs(s);

sT = s';

% find peaks in flattened s and sT
[pks,locs] = findpeaks(s(:));
[pksT, locsT] = findpeaks(sT(:));

sz = size(s);
% convert flattened index of transpose into original flatetned
[colT, rowT] = ind2sub(sz,locsT);
locsT = sub2ind(fliplr(sz), rowT, colT);

ind = intersect(locs, locsT);
[row, col] = ind2sub(sz,ind);

pks = pks(ismember(locs,ind));

