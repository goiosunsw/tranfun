classdef playrec < handle
    properties
        NBits
        Fs
        NInputChans
        NOutputChans
        callback
        inputDevice
        outputDevice
        outputDeviceID
        outputData
        maxTime
        userCallback
        delayOutputToInput
        lastInSample
        lastOutSample
        currentInSample
        currentOutSample
    end
    methods
        function obj = playrec(y, inputDeviceID, outputDeviceID, Fs, NInputChans, maxTime);
            if nargin<6
                maxTime = length(y);
            end
            if nargin<5
                NInputChans = 1;
            end
            if nargin<4
                Fs = 8000;
            end

            obj.Fs = Fs;
            obj.NBits = 16;
            obj.NInputChans = NInputChans;
            obj.setInputDevice(inputDeviceID);
            devinfo = audiodevinfo;
            outputPresent = 0;
            for i=1:length(devinfo.output)
                if (devinfo.output(i).ID == outputDeviceID)
                    obj.outputDeviceID = outputDeviceID;
                    outputPresent = 1;
                end
            end
            if (~outputPresent)
                warn(sprintf("Output device %d not present",outputDeviceID))
            end
            if maxTime>length(y)
                nreps = ceil(maxTime/length(y));
                y = repmat(y,nreps,1);
            end
            obj.setOutput(y)
            obj.inputDevice.TimerFcn = @obj.timerFcn;
            obj.userCallback = [];
            obj.delayOutputToInput = 100;
        end
        function setOutput(obj, y)
            obj.outputData = y;
            obj.outputDevice = audioplayer(y, obj.Fs, obj.NBits, obj.outputDeviceID);
            obj.inputDevice.UserData = obj.outputDevice;
        end
        function setInputDevice(obj, inputID)
            obj.inputDevice = audiorecorder(obj.Fs, obj.NBits, obj.NInputChans, inputID);
        end
        function start(obj)
            %obj.outputDevice.stopFcn = @(src, event) play(obj.outputDevice);
            play(obj.outputDevice);
            %obj.inputDevice.startFcn = @(src, event) disp(["Player sample number at start: ", num2str(obj.outputDevice.CurrentSample)]);
            record(obj.inputDevice);
        end
        function stop(obj)
            %disp(["Sample numbers at end:"])
            %disp(["Rec :" num2str(obj.inputDevice.CurrentSample)])
            %disp(["Play:" num2str(obj.outputDevice.CurrentSample)])
            stop(obj.inputDevice);
            obj.outputDevice.stopFcn = [];
            stop(obj.outputDevice);
        end
        function timerFcn(obj, src, event)
            obj.lastInSample = obj.currentInSample;
            obj.lastOutSample = obj.currentOutSample;
            obj.currentInSample = obj.inputDevice.CurrentSample-1;
            obj.currentOutSample = obj.outputDevice.CurrentSample-1;
            if ~isempty(obj.userCallback)
                obj.userCallback(obj)
            end
        end
        function setDelay(obj,val)
            obj.delayOutputToInput = val;
        end
        function y = getOutputDataSinceLastCall(obj)
            y = obj.outputData(obj.lastInSample+obj.delayOutputToInput:obj.currentInSample+obj.delayOutputToInput);
        end
        function y = getInputDataSinceLastCall(obj)
            inputData = obj.inputDevice.getaudiodata();
            y = inputData(obj.lastInSample:obj.currentInSample);
        end

        function setCallback(obj, fcn, time)
            obj.userCallback = fcn;
            obj.inputDevice.TimerPeriod = time;
        end
        function delete(obj)
            delete(obj.inputDevice);
            delete(obj.outputDevice);
        end
    end
end




