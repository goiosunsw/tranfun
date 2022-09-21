function sx = sampleDist(x, n, mindist)
%SAMPLEDIST Sample n uniqwue elements of x
%   with a minimum distance

% indices
ix = zeros(1,n);
remainingMask = ones(size(x));

for i=1:n
    draw = randi(sum(remainingMask));
    remainingIdx = find(remainingMask);
    ix(i) = remainingIdx(draw);
    minidx = max(1,ix(i)-mindist);
    maxidx = min(length(x),ix(i)+mindist);
    remainingMask(minidx:maxidx) = 0;
end

sx = x(ix);
