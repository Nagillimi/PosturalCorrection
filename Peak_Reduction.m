function [PinputAvg,Poutput,PoutputSum] =  Peak_Reduction(Pinput,PinputSum)
    % Parameters                                % Working #s
    HighPressureScalingWeight = 0.1;            % 0.01
    EndingPressure_kPa = 11;                    % 90mmHg
    LocalMaximaBoundaries = [0.9,0.7,0.5];      % [0.99,0.85,0.50]

    % compute the max pressure (mmHg), length, and mean of input pressures
    PinputMax = max(max(Pinput));
    L = length(Pinput);
    PinputAvg = mean(mean(nonzeros(Pinput)));
    
    % initialize matrix for Poutput and maxima-boundary-based weights
    Poutput = Pinput;
    Pweights = zeros(size(Pinput));
    
    % assign maxima boundaries
    for i = 1:L
        for j = 1:L
            if Pinput(i,j) >= LocalMaximaBoundaries(1)*(PinputMax)
                Pweights(i,j) = LocalMaximaBoundaries(1);
            end
            if (Pinput(i,j) < LocalMaximaBoundaries(1)*(PinputMax)) &&...
               (Pinput(i,j) >= LocalMaximaBoundaries(2)*(PinputMax))
                Pweights(i,j) = LocalMaximaBoundaries(2);
            end
            if (Pinput(i,j) < LocalMaximaBoundaries(2)*(PinputMax)) &&...
               (Pinput(i,j) >= LocalMaximaBoundaries(3)*(PinputMax))
                Pweights(i,j) = LocalMaximaBoundaries(3);
            end                
        end
    end
    
    % reduce target pressures based on those weight-driven maxima
    for i = 1:L
        for j = 1:L
            for k = 1:length(LocalMaximaBoundaries)
                if Pweights(i,j) == LocalMaximaBoundaries(k)
                    Poutput(i,j) = round(Pinput(i,j) - (PinputMax-PinputAvg)...
                        *(1/k)*HighPressureScalingWeight*LocalMaximaBoundaries(k));
                end
            end
        end
    end
    
    % run recursion until an output is below a certain threshold
    if max(max(Poutput)) > EndingPressure_kPa
        [~,Poutput,~] = Peak_Reduction(Poutput,PinputSum);
    end
    
    % once model converges, return the output sum to confirm
    PoutputSum = sum(sum(Poutput));
end