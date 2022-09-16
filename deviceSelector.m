function deviceSelector()

    devInfo = audiodevinfo();
    fig = uifigure;
    fig.Name="Device Selection";

    sampleRates = [8000,11025,16000,22050,32000,44100,48000,96000];
    windowLens = [64,128,256,512,1024,2048,4096,8192];

    gl = uigridlayout(fig, [7 2]);

    % Input selection
    inputNames = {};
    for i = 1:length(devInfo.input)
        inputNames{end+1} = devInfo.input(i).Name;
    end
    lblIn = uilabel(gl,'Text','Input Device');
    lblIn.Layout.Row=1;
    lblIn.Layout.Column=1;
    selIn = uidropdown(gl,'Items',inputNames);
    selIn.Layout.Row=1;
    selIn.Layout.Column=2;

    % Output Selection
    outputNames = {};
    for i = 1:length(devInfo.output)
        outputNames{end+1} = devInfo.output(i).Name;
    end
    lblOut = uilabel(gl,'Text','Output Device');
    lblOut.Layout.Row=2;
    lblOut.Layout.Column=1;
    selOut = uidropdown(gl,'Items',outputNames);
    selOut.Layout.Row=2;
    selOut.Layout.Column=2;
    
    % Sample rate
    srvals = arrayfun(@num2str,sampleRates,'UniformOutput',false);
    lblSR = uilabel(gl,'Text','Sample Rate');
    lblSR.Layout.Row=3;
    lblSR.Layout.Column=1;
    selSR = uidropdown(gl,'Items',{'8000','16000','22050','32000','44100','48000','96000'},'Value','8000');
    selSR.Layout.Row=3;
    selSR.Layout.Column=2;

    % Window length
    lblWinLen = uilabel(gl,'Text','Window Length (ms)');
    lblWinLen.Layout.Row=4;
    lblWinLen.Layout.Column=1;
    selWinLen = uidropdown(gl,'Enable',false);
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
    okBtn = uibutton(gl,'Text','Ok');
    okBtn.Layout.Row=7;
    okBtn.Layout.Column=1;
    cancelBtn = uibutton(gl,'Text','Cancel');
    cancelBtn.Layout.Row=7;
    cancelBtn.Layout.Column=2;


end

