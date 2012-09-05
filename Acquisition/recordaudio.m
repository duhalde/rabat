% Record your voice for 5 seconds.
recObj = audiorecorder(8000,16,2);
playObj = audiorecorder(8000,16,2);
disp('Start clapping.')
recordblocking(recObj, 3);
disp('End of Recording.');
 
record(playObj,6)
play(recObj);
pause(3)
play(recObj);
pause(5)
disp('End of Recording.');
 
% Play back the recording.
play(playObj);
