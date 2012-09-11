classdef RABAT_SIGNAL < handle
    %RABAT_SIGNAL Signal representation in the RaBaT Toolbox
    %   To aquire the signal to hold information on the given measurement,
    %   such as sampling rate, position number (from measurement) and more
    
    % Author: David Duhalde Rahbæk & Mathias Immanuel Nielsen & Oliver Lylloff
    % Created: sep 5 2012
    % Copyright RaBaT Toolbox, DTU 2012
    
    properties
        signal      % the actual data
        fs          % sampling frequency
        N           % bitrate
        positionNumber  % for reference when doing measurements
    end
    
    methods
    end
    
end

