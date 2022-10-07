global pr
global hAxes
global sr
global calib
global winLen
global nFr
global useCalibration
global hDelayLbl


sr = 8000;
winLen = 512;
% calculate delay every X seconds
resyncEvery = 2;
useCalibration = 1;


%% Setup window
hFig = uifigure('Name','Transfer Function Estimator','NumberTitle','off');
set(hFig,'CloseRequestFcn',@closeFigCallback);

hGrid1 = uigridlayout(hFig);
hGrid1.RowHeight = {'1x','1x','1x',32,32};
hGrid1.ColumnWidth = {'1x','1x','2x'};

hAxes1 = uiaxes(hGrid1);
hAxes1.Layout.Row = 1;
hAxes1.Layout.Column = [1,3];
hAxes2 = uiaxes(hGrid1);
hAxes2.Layout.Row = 2;
hAxes2.Layout.Column = [1,3];
hAxes3 = uiaxes(hGrid1);
hAxes3.Layout.Row = 3;
hAxes3.Layout.Column = [1,3];

hAxes = [hAxes1,hAxes2,hAxes3];

hStartStop = uibutton(hGrid1, 'push', ...
                       'Text', 'Start/Stop',...
                       'ButtonPushedFcn', @startStopCallback);
hStartStop.Layout.Row = 4;
hStartStop.Layout.Column = 1;

hCalib = uibutton(hGrid1, 'push', ...
                       'Text', 'Use as calib',...
                       'ButtonPushedFcn', @calibCallback);
hCalib.Layout.Row = 4;
hCalib.Layout.Column = 2;
                   
hGrid2 = uigridlayout(hGrid1, [1,2]);
hGrid2.RowHeight = {32};
hGrid2.ColumnWidth = {'1x',30};
hGrid2.Layout.Row = 4;
hGrid2.Layout.Column = 3;

hDelay = uislider(hGrid2,...
                       'Limits', [-1000, 1000],...
                       'ValueChangedFcn', @delayCallback,...
                       'ValueChangingFcn', @delayChgCallback);

hDelayLbl = uilabel(hGrid2,...
                       'Text', '0')

hUseCalib = uicheckbox( hGrid1,...
                       'Text', 'Use Calibration',...
                       'Value', 1,...
                       'ValueChangedFcn', @useCalibCallback);
hUseCalib.Layout.Row = 5;
hUseCalib.Layout.Column = 1;

%% Run calibration setup
pr = deviceSetup();
sr = pr.Fs;
winLen = pr.userData.winLen;
nFr = pr.userData.nFr;
pr.userData.resyncEverySamples = resyncEvery*sr;
pr.userData.lastResync = 0;

%% Generate noise
y = rand(sr,1);
pr.setOutput(y);

calib = ones(round(winLen/2+1),1);

pr.setCallback(@plotCallback,winLen*nFr/sr);
delay = pr.delayOutputToInput;
set(hDelay,'Value',delay/sr*1000);
set(hDelayLbl,'Text',sprintf('%d',delay/sr*1000));

running=0;

function delayCallback(src, ~)
    global pr
    global sr
    
    newdel=(get(src,'Value'))/1000*sr;
    pr.setDelay(round(newdel));
end

function delayChgCallback(src, ~)
    global hDelayLbl
    
    newdel=round(get(src,'Value'));
    set(hDelayLbl,'Text',sprintf('%d',newdel));
end


function startStopCallback(~, ~)
    global running
    global pr

    disp(pr)
    if running
        pr.stop()
        running = 0;
    else
        pr.start()
        running = 1;
        pr.userData.lastResync = 0;
    end
end

function plotCallback(mypr)
    global hAxes
    global sr
    global calib
    global winLen
    global nFr
    global useCalibration
    
    hopLen = round(winLen/2);
    %x = mypr.getOutputDataSinceLastCall();
    %y = mypr.getInputDataSinceLastCall();
    % get n Frames of Data
    
    n = winLen*nFr;
    delay = mypr.delayOutputToInput;
    inPtr = mypr.inputDevice.CurrentSample-1;
    outPtr = inPtr+delay;
    
    if mypr.userData.lastResync < mypr.currentOutSample - mypr.userData.resyncEverySamples
        ndelay = 1024;
        x = mypr.outputData(outPtr-ndelay:outPtr);
        inData = mypr.inputDevice.getaudiodata();
        y = inData(inPtr-ndelay:inPtr);
        
        [cc, lags] = xcorr(y,x);
        [v,mc] = max(abs(cc));
        fprintf("Out of sync by %d samples\n",lags(mc));
        mypr.userData.lastResync = mypr.currentOutSample;
    end
    
    x = mypr.outputData(outPtr-n:outPtr);
    inData = mypr.inputDevice.getaudiodata();
    y = inData(inPtr-n:inPtr);
    % calculate Transfer Function
    [h,f] = tfestimate(x,y,winLen,hopLen,winLen,sr);
    % divide by calibration if requested
    if useCalibration
        h=h./calib;
    end
    % plot transfer function -- module
    plot(hAxes(1),f,20*log10(abs(h)));
    % phase
    plot(hAxes(2),f,(angle(h)));
    % coherence
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

function useCalibCallback(src, event)
    global useCalibration
    useCalibration = get(src,'Value');
end

function closeFigCallback(src, event)
    global pr
    disp("Closing audio devices");
    delete(pr);
    closereq;
    clear pr;
end
