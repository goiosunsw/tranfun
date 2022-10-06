function [devInID, devOutID, Fs, winLen, nBlock, recTime,delay] = deviceSelector()

    delay = 0;
    devInfo = audiodevinfo();
    % screen size
    sz = get( 0, 'ScreenSize');

    % center position
    x = mean( sz( [1, 3]));
    y = mean( sz( [2, 4]));
    width=400;
    height=300;

    fig = uifigure( 'Position', [x - width/2, y - height/2, width, height]);

    fig.Name="Device Selection";

    sampleRates = [8000,11025,16000,22050,32000,44100,48000,96000];
    wLenList = [];
    wLenMSecList = [];


    gl = uigridlayout(fig, [7 2]);

    % Input selection
    inputNames = {};
    inputIDS = [];
    for i = 1:length(devInfo.input)
        inputNames{end+1} = devInfo.input(i).Name;
        inputIDS(end+1) = devInfo.input(i).ID;
    end
    lblIn = uilabel(gl,'Text','Input Device');
    lblIn.Layout.Row=1;
    lblIn.Layout.Column=1;
    selIn = uidropdown(gl,'Items',inputNames,'ItemsData',inputIDS);
    selIn.Layout.Row=1;
    selIn.Layout.Column=2;

    % Output Selection
    outputNames = {};
    outputIDS = [];
    for i = 1:length(devInfo.output)
        outputNames{end+1} = devInfo.output(i).Name;
        outputIDS(end+1) = devInfo.output(i).ID;
    end
    lblOut = uilabel(gl,'Text','Output Device');
    lblOut.Layout.Row=2;
    lblOut.Layout.Column=1;
    selOut = uidropdown(gl,'Items',outputNames,'ItemsData',outputIDS);
    selOut.Layout.Row=2;
    selOut.Layout.Column=2;
    
    % Sample rate
    srvals = arrayfun(@num2str,sampleRates,'UniformOutput',false);
    lblSR = uilabel(gl,'Text','Sample Rate');
    lblSR.Layout.Row=3;
    lblSR.Layout.Column=1;
    selSR = uidropdown(gl,'Items',srvals,...
                          'Value','8000',...
                          'ValueChangedFcn',@(src, ev) updateSR(str2num(ev.Value)));
    selSR.Layout.Row=3;
    selSR.Layout.Column=2;

    % Window length
    lblWinLen = uilabel(gl,'Text','Window Length (ms)');
    lblWinLen.Layout.Row=4;
    lblWinLen.Layout.Column=1;
    selWinLen = uidropdown(gl,'Enable',true,'ValueChangedFcn',@wLenCallback);
    selWinLen.Layout.Row=4;
    selWinLen.Layout.Column=2;

    % Bloc length
    lblBlockLen = uilabel(gl,'Text','Block Length (ms)');
    lblBlockLen.Layout.Row=5;
    lblBlockLen.Layout.Column=1;
    selBlockLen = uidropdown(gl);
    selBlockLen.Layout.Row=5;
    selBlockLen.Layout.Column=2;

    % Max rec time
    lblRecTime = uilabel(gl,'Text','Maximum recording time (sec)');
    lblRecTime.Layout.Row=6;
    lblRecTime.Layout.Column=1;
    selRecTime = uispinner(gl,'Value',180);
    selRecTime.Layout.Row=6;
    selRecTime.Layout.Column=2;

    % End
    okBtn = uibutton(gl,'Text','Ok','ButtonPushedFcn',@okCallback);
    okBtn.Layout.Row=7;
    okBtn.Layout.Column=1;
    cancelBtn = uibutton(gl,'Text','Cancel','ButtonPushedFcn',@(src,ev) close(fig));
    cancelBtn.Layout.Row=7;
    cancelBtn.Layout.Column=2;

    currentRate = 8000;
    currentWindow = 256;
    currentWinLenMSec = currentWindow/currentRate*1000;

    % calcWindowLens();
    updateSR(currentRate);
    updateBlockList();
    selBlockLen.set('Value',4);


    function okCallback(src,ev)
        devInID =  (selIn.Value);
        devOutID =  (selOut.Value);
        Fs =  (currentRate);
        winLen = (currentWindow);
        nBlock = ((selBlockLen.Value));
        recTime = selRecTime.Value;
        close(fig);
    end

    function wLenCallback(src, event)
        sel = str2num(selWinLen.Value);
        updateWLen(sel);
        
        updateBlockList();
    end

    function updateBlockList()
        sel = str2num(selWinLen.Value);

        nBlockList = (2:round(2000/sel));

        blockLenStr = arrayfun(@(x)(num2str(sel*x)), nBlockList, 'UniformOutput', false);
        selBlockLen.set('Items',blockLenStr,'ItemsData',nBlockList);
    end

    function updateWLen(sel)
        currentWindow = 2^round(log2(sel/1000*currentRate));
        currentWinLenMSec = currentWindow/currentRate*1000;
    end

    function updateSR(sr)
        % update window length list
        currentRate = str2num(selSR.Value);
        calcWindowLens();
        wLenStr = arrayfun(@num2str, wLenMSecList, 'UniformOutput', false);
        selWinLen.set('Items',wLenStr);
        % select length nearest to previous
        [dist,wIdx] = min(abs(wLenMSecList-currentWinLenMSec));
        selWinLen.set('Value',wLenStr{wIdx});
        updateWLen(str2num(selWinLen.Value));
    end

    function calcWindowLens()
        wLenMSec = 2;
        wLen = 2^nextpow2(wLenMSec/1000*currentRate);
        wLenList = [];
        wLenMSecList = [];
        while wLenMSec < 200;
            wLenMSec = round(wLen/currentRate*1000);
            wLenList(end+1) = wLen;
            wLenMSecList(end+1) = wLenMSec;
            wLen = wLen*2;
        end

    end

    uiwait(fig)



end

