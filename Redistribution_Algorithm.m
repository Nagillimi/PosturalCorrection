% Calibration procedure to calculate the normal posture forces and BW
%
% params
%..Pin = the pressure matrix input
%..showfig = Boolean to show the result of calibration. Set to 'f' to see
%            the fine mesh interpolated from a cubic spline
%
% returns
%..Ptarget = final target matrix for main real time program
%..PSum = the history of sum of pressures to ensure interface was 
%         maintained
function [Ptarget,Psum] = Redistribution_Algorithm(Pin,showfig)
    % parameters
    PinSum = sum(sum(Pin));
    L = length(Pin);
    
    % runs recursive model to dampen the pressure peaks
    [Pmean,Pinterm,PintermSum] = Recursive_Model(Pin,PinSum);
    
    % fix the error in the sum, matches the output to the input
    [Ptarget,PtargetSum] = Fix_Sum(Pinterm,Pmean,PintermSum,PinSum);
    
    if showfig == 'f'
        % finer meshes (60x60) using cubic interpolation
        Pin_fine = interp2(Pin,45/L,'cubic');
        Pinterm_fine = interp2(Pinterm,45/L,'cubic');
        Ptarget_fine = interp2(Ptarget,45/L,'cubic');
        
        % plot results of calibration
        figure(1)
        subplot(311)
        surf(Pin_fine), axis([0,60,0,60,0,220]), hold on, text(0,55,175,string(PinSum))
        surf(Pmean*ones(size(Pin_fine)),'FaceAlpha',0.1,'FaceColor','m','LineStyle','none')
        title('60x60 Interpolated Initial Pressure Matrix')
        subplot(312)
        surf(Pinterm_fine), axis([0,60,0,60,0,220]), hold on, text(0,55,175,string(PintermSum))
        surf(Pmean*ones(size(Pin_fine)),'FaceAlpha',0.1,'FaceColor','m','LineStyle','none')
        title('60x60 Interpolated Intermediate Pressure Redistribution after Peak Scaling')
        subplot(313)
        surf(Ptarget_fine), axis([0,60,0,60,0,220]), hold on, text(0,55,175,string(PtargetSum))
        surf(Pmean*ones(size(Pin_fine)),'FaceAlpha',0.1,'FaceColor','m','LineStyle','none')
        title('60x60 Interpolated Final Pressure Redistribution after Sum Recovery')
        
    elseif showfig
        % plot results of calibration
        figure(1)
        subplot(311)
        surf(Pin), axis([0,L,0,L,0,220]), hold on, text(0,14,175,string(PinSum))
        surf(Pmean*ones(size(Pin)),'FaceAlpha',0.1,'FaceColor','m','LineStyle','none')
        title('Initial Pressure Matrix')
        subplot(312)
        surf(Pinterm), axis([0,L,0,L,0,220]), hold on, text(0,14,175,string(PintermSum))
        surf(Pmean*ones(size(Pin)),'FaceAlpha',0.1,'FaceColor','m','LineStyle','none')
        title('Intermediate Pressure Redistribution after Peak Scaling')
        subplot(313)
        surf(Ptarget), axis([0,L,0,L,0,220]), hold on, text(0,14,175,string(PtargetSum))
        surf(Pmean*ones(size(Pin)),'FaceAlpha',0.1,'FaceColor','m','LineStyle','none')
        title('Final Pressure Redistribution after Sum Recovery')
    end
    
    % Return sum history
    Psum = [PinSum,PintermSum,PtargetSum]';
end          