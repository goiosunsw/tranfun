function noteGrid(hax, fmin, fmax, staves)
%
% noteGrid(hax, fmin, fmax)
%

if nargin < 3
    flims = xlim(hax);
    fmin = flims(1);
    if nargin == 2
        fmax = flims(end);
    end
end

if nargin < 4
    staves = [1,1,0];
end

stmin = round(12*log2(fmin/440));
stmax = round(12*log2(fmax/440));

bassstave=[43,47,50,53,57]-69;
treblestave=[64,67,71,74,77]-69;

stavelist = {bassstave, treblestave, treblestave+24};
allstaves = [];
for ii = 1:length(staves)
    if staves(ii)>0
        allstaves = horzcat(allstaves, stavelist{ii});
    end
end

    
st = stmin:stmax;
gridtypes = zeros(size(st));
notenames = {};

for ii = 1:length(st)
    notename = midi2notename(st(ii));
    if length(notename)<3
        gridtypes(ii) = 1;
    end
    if sum(allstaves==st(ii))>0
        gridtypes(ii) = 2;
    end
end
disp(gridtypes);
whitekeys = arrayfun(@(x)(length(midi2notename(x))<3),st);
fminorgrid = 440*2.^(st/12);
fmajorgrid = fminorgrid(whitekeys);

%grid(hax,'on');
%set(hax,'XMinorTick','on');
%xticks(hax,fmajorgrid);
%hax.XRuler.MinorTickValues = fminorgrid;

colors = {[.9,.9,.9], [.75,.75,.75], [0,0,0]};
linewidth = [1,1,3];

for ii = 1:length(st)
    f = 440*2.^(st(ii)/12);
    xline(hax, f,'Color',colors{gridtypes(ii)+1},'LineWidth',linewidth((gridtypes(ii)+1))*sqrt(f/fmax));
end