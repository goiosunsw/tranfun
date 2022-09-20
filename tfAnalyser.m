global pr
global hAxes
global sr
global calib
global winLen
global nFr


sr = 8000;
winLen = 512;

[inDevID, outDevID, sr, winLen, nFr, recTime] = deviceSelector

calib = ones(round(winLen/2+1),1);


hFig = figure('Name','Transfer Function Estimator','NumberTitle','off');
set(hFig,'CloseRequestFcn',@closeFigCallback);

hAxes3 = axes(hFig, 'Units', 'normalized', 'Position', [0.1,0.3,0.8,0.2]);
hAxes2 = axes(hFig, 'Units', 'normalized', 'Position', [0.1,0.5,0.8,0.2]);
hAxes1 = axes(hFig, 'Units', 'normalized', 'Position', [0.1,0.7,0.8,0.2]);
hAxes = [hAxes1,hAxes2,hAxes3];
hStartStop = uicontrol('Parent', hFig,...
                       'Style', 'pushbutton',...
                       'String', 'Start/Stop',...
                       'Units', 'normalized',...
                       'Position', [0.1,0.15,0.4,0.1],...
                       'Callback', @startStopCallback);

hCalib = uicontrol('Parent', hFig,...
                       'Style', 'pushbutton',...
                       'String', 'Use as calib',...
                       'Units', 'normalized',...
                       'Position', [0.1,0.05,0.4,0.1],...
                       'Callback', @calibCallback);

hDelay = uicontrol('Parent', hFig,...
                       'Style', 'slider',...
                       'Min', -1000,...
                       'Max', 1000,...
                       'SliderStep',[1/sr,0.05],...
                       'Units', 'normalized',...
                       'Position', [0.5,0.1,0.4,0.05],...
                       'Callback', @delayCallback);

y = rand(sr,1);
pr = playrec(y,inDevID,outDevID,sr,1,recTime*sr);
pr.setCallback(@plotCallback,winLen*nFr/sr);
pr.setDelay(120);

running=0;
function delayCallback(src, event)
    global pr
    global sr
    newdel=(get(src,'Value'))/1000*sr;
    pr.setDelay(round(newdel));
end

function startStopCallback(src, event)
    global running
    global pr

    disp(pr)
    if running
        pr.stop()
        running = 0;
    else
        pr.start()
        running = 1;
    end
end

function plotCallback(mypr)
    global hAxes
    global sr
    global calib
    global winLen
    global nFr
    hopLen = round(winLen/2);
    %x = mypr.getOutputDataSinceLastCall();
    %y = mypr.getInputDataSinceLastCall();
    % get n Frames of Data
    n = winLen*nFr;
    delay = mypr.delayOutputToInput;
    inPtr = mypr.inputDevice.CurrentSample-1;
    outPtr = inPtr+delay;
    x = mypr.outputData(outPtr-n:outPtr);
    inData = mypr.inputDevice.getaudiodata();
    y = inData(inPtr-n:inPtr);
    % calculate Transfer Function
    [h,f] = tfestimate(x,y,winLen,hopLen,winLen,sr);
    h=h./calib;
    plot(hAxes(1),f,20*log10(abs(h)));
    plot(hAxes(2),f,(angle(h)));
    [co,f] = mscohere(x,y,winLen,hopLen,winLen,sr);
    plot(hAxes(3),f,(co));
end

function calibCallback(src,event)
    global hAxes
    global sr
    global calib
    global winLen
    global pr
    hopLen=round(winLen/2);
    % use 1 second of data for calibration
    n = sr;
    delay = pr.delayOutputToInput;
    inPtr = pr.inputDevice.CurrentSample-1;
    outPtr = inPtr+delay;
    x = pr.outputData(outPtr-n:outPtr);
    inData = pr.inputDevice.getaudiodata();
    y = inData(inPtr-n:inPtr);
    disp([length(x),length(y)]);
    [h,f] = tfestimate(x,y,winLen,hopLen,winLen,sr);
    calib = h;
end

function closeFigCallback(src, event)
    global pr
    disp("Closing audio devices");
    delete(pr);
    closereq;
    clear pr;
end
