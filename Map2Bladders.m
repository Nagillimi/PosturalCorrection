% Maps the pressure difference matrix to avg bladder values towards a
% repositioning criterion
function [Pmap,Prepos] = Map2Bladders(Pdiff,showMap)
    % parameters
    numBladders = 28;
    Lsensor = 60;
    
    % resize the pressure difference data to be 60x60
    Pdiff_resized = imresize(Pdiff,[Lsensor,Lsensor]);

    % load the sensor mapping grid with the same orientation
    Pmap = rot90(readmatrix('Sensor2Bladder.csv'),2);
    
    % plot the contour of the pressure map if requested
    if showMap
        figure(55)
        contour(Pmap,50)
    end
    
    % collecting the sum of each difference pressure per bladder
    PbladderSum = zeros(numBladders,1);
    elementsPerBladder = zeros(numBladders,1);
    for i = 1:Lsensor
        for j = 1:Lsensor
            for k = 1:numBladders
                % search for the correct bladder
                if Pmap(i,j) == k
                    % get the sum of pressure per bladder
                    PbladderSum(k) = PbladderSum(k) + Pdiff_resized(i,j);
                    % iterate the number of elements in each bladder
                    elementsPerBladder(k) = elementsPerBladder(k) + 1;
                end
            end
        end
    end

    % compute the avg pressure per bladder
    PbladderAvg = PbladderSum./elementsPerBladder;
    
    % initialize the reposition pressure matrix
    Prepos = zeros(size(Pdiff_resized));
    for i = 1:Lsensor
        for j = 1:Lsensor
            for k = 1:numBladders
                % search for the correct bladder
                if Pmap(i,j) == k
                    % assign that bladders avg repositioning pressure
                    Prepos(i,j) = PbladderAvg(k);
                end
            end
        end
    end
    
    Prepos = ((Prepos));
end