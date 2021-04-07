% Simple single nodal system for deflation/inflation
% REVISION 3 - March 28
%
% Notes:
% - Can take in any input where #rows = #cols
%
% Changes from last revision:
% - maintains the pressure interface sum
% - made all functions recursive
% - put it into kPa
% - maps to bladder geometry

clear
close all
clc

%--PARAMETERS--------------------------------------------------------------
nodeArea = 0.000025; % m2

% Anatomical threshold pressure (converted from kPa2mmHg) for PU 
% development: 4.16kPa = 31.2mmHg
PU_threshold = 4.16;

% Threshold for pressure recognition (mmHg)
NoP_threshold = 5;

%--INPUT-------------------------------------------------------------------
% Load pressure data --> in kPa!!
Pin = mmHg2kPa(readmatrix('HighPressure.csv'));
% Pin = rot90(readmatrix('PublicData - Clipped.csv'));

L = length(Pin);
Psum = sum(sum(Pin));
numNodes = L^2;

%--ALGORITHM---------------------------------------------------------------
[Ptarget,PSums] = Redistribution_Algorithm(Pin,0);

% calculate the pressure difference matrix
Pdiff = -(Pin - Ptarget);

%--BLADDER MAPPING---------------------------------------------------------
[Pmap,Prepos] = Map2Bladders(Pdiff,1);

%--CONTROLLER--------------------------------------------------------------
Pin_resized = imresize(Pin,[60,60]);
Ptarget_resized = imresize(Ptarget,[60,60]);

% plot input through to output
figure(2)
subplot(121)
surf(Pin_resized), axis([0,60,0,60,-3,30])
title('Initial Pressure Input'), zlabel('Interface Pressure (kPa)')
xlabel({'Sensor','Row Index'}), ylabel({'Sensor','Column Index'})
set(gca,'FontName','Times New Roman','FontSize',14)
subplot(122)
surf(Ptarget_resized), axis([0,60,0,60,-3,30])
title('Target Pressure after Redistribution'), zlabel('Interface Pressure (kPa)')
xlabel({'Sensor','Row Index'}), ylabel({'Sensor','Column Index'})
set(gca,'FontName','Times New Roman','FontSize',14)
% subplot(413)
% surf(Prepos), axis([0,length(Prepos),0,length(Prepos),-20,5])
% title('Mapped Bladder Pressure Redistribution')
% set(gca,'FontName','Times New Roman','FontSize',14)
% subplot(414)
% surf(Pdiff), axis([0,length(Pdiff),0,length(Pdiff),-20,5])
% title('Actual Difference Pressures')
% set(gca,'FontName','Times New Roman','FontSize',14)

% sort all Pdiffs by lowest to largest. This inflates first.
[neg_C,neg_C_idx] = sort(Pdiff);

% vector for valve control. Should end up opposite to C
Valve = zeros(size(Pdiff));

%--ACTUATOR----------------------------------------------------------------
% calculate the deltas for each ith x jth element
% +ve = current node is higher than the next node
for i = 1:L
   if Pdiff(neg_C_idx(i)) < 0
       % INFLATION
       Valve(neg_C_idx(i)) = -Pdiff(neg_C_idx(i));
       fprintf('Inflating bladder at index: %i by: %i\n',...
           neg_C_idx(i),Valve(neg_C_idx(i)))
       
       % code to inflate with electronic valve
       % CONTROL SYS
       
   elseif Pdiff(neg_C_idx(i)) > 0
       % DEFLATION
       Valve(neg_C_idx(i)) = -Pdiff(neg_C_idx(i));
       fprintf('Deflating bladder at index: %i by: %i\n',...
           neg_C_idx(i),Valve(neg_C_idx(i)))
       
       % code to deflate with electronic valve
       % CONTROL SYS
       
   end
end

%--RESULTS-----------------------------------------------------------------
% Results(PU_threshold,NoP_threshold,Pin,Ptarget)
