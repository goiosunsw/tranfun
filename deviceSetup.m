function pr=deviceSetup()

    [inDevID, outDevID, sr, winLen, nFr, recTime] = deviceSelector;

    y = zeros(2*sr,1);
    pr = playrec(y,inDev,outDev,sr,1,recTime);

    ret = questdlg('Do you want to calibrate your device now? This procedure takes a few seconds, it is recommended but will produce some sound','Initial calibration','Yes','No','Yes');
    if ret == 'Yes'
        [delay] = measureLatency();
    end
    
    pr.setDelay(delay);
    userData.winLen = winLen;
    userData.nFr = nFr;
    userData.inDevID = inDevID;
    userData.outDevID = outDevId;
    userData.measuredDelay = delay;
    
    pr.userData = userData;

end