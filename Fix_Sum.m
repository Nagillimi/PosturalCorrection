function [Poutput,PoutputSum] = Fix_Sum(Pinterm,PinputAvg,PintermSum,PinputSum)
    % parameters
    L = length(Pinterm);
    
    % initialize the Poutput
    Poutput = Pinterm;
    PoutputSum = PintermSum;
    
    % find the current sum difference
    SumDifference = PinputSum - PoutputSum;

    % find the number of nodes below the mean
    num = 0;
    for i = 1:L
        for j = 1:L
            if Pinterm(i,j) < PinputAvg
                num = num + 1;
            end
        end
    end

    % apply changes evenly to each node below the mean
    for i = 1:L
        for j = 1:L
            if Pinterm(i,j) < PinputAvg && Pinterm(i,j)
                Poutput(i,j) = Poutput(i,j) + SumDifference/num;
            end
        end
    end
            
    % return the equal output sum
    PoutputSum = sum(sum(Poutput));
    
    % run recursion until outputSum is equal to inputSum
    if PoutputSum < PinputSum
        [Poutput,PoutputSum] = Fix_Sum(Poutput,PinputAvg,PoutputSum,PinputSum);
    end
end