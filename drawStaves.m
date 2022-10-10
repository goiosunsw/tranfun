function drawStaves(hax, fmin, fmax)
    [~,~,imgbass] = imread("BassClef.png");
    [~,~,imgtreb] = imread("TrebleClef.png");
    imgdt = horzcat(imgtreb,imgtreb);
    % image, midi_center, midi_staff_bottom, midi_staff_top,
    % center_on-image (px), scale (x staff size)
    cfg = {imgbass, 53, 43, 57, 200, .8;...
           imgtreb, 67, 64, 77, 600, 1.7;...
           imgdt, 91, 88, 101, 600, 1.7};
    for ii = 1:size(cfg,1)
        ima = cfg{ii,1};
        img = 255-repmat(ima,[1,1,3]);
        fref = 440*2^((cfg{ii,2}-69)/12);
        fb = 440*2^((cfg{ii,3}-69)/12);
        ft = 440*2^((cfg{ii,4}-69)/12);
        %df = ft-fb;
        %fact = df*cfg{ii,6}
        %xmin = 
        image(hax,'Xdata',[fb,ft],'Ydata',ylim(hax),'CData',flipud(imrotate(img,-90)));
    end
end

