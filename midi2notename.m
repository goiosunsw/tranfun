function notename = midi2notename(midi)
    notes = {'A','A#','B','C','C#','D','D#','E','F','F#','G','G#'};
    
    octno = floor((midi-12)/12);
    octst = mod(midi-69,12);
    
    notename = [notes{octst+1} num2str(octno)];
end