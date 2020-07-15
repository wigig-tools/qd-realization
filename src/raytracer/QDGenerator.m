function [output, count1, switch_QD] = QDGenerator(order_of_R,output,...
    array_of_materials, number, MaterialLibrary, distance, freq, count1,...
    dod, doa, vtx, v_temp, count, indexReference)
%INPUT -
%order_of_R -  Order of reflection
%output - multipath parameters
%array_of_materials - material properties of every triangle as described in
%array of plane
%number - row number of array_of_materials that is being used
%Array_of_planes - Similar to Array of points. Each triangle occupies 4
%columns (plane equation). The first column has the order of reflection
%(o/p of treetraversal)
%Material_library - Similar to Array of points. Each triangle occupies 1
%triangle. The data is the row number of material from Material library
%array_of_materials - Similar to Array of points. Each triangle occupies 1
%triangle. The data is the row number of material from Material library
%distance is the total length of multipath
%freq - frequency of operation (center frequency of carrier wave)
%count1 - number of rows in output/ multipath
%dod - direction of departure vector
%doa - direction of arrival vector
%vtx is velocity of tx
%v_temp is relative velocity of rx wrt tx
%count - number of rows in output/ multipath
%
%OUTPUT -
%output - multipath parameters
%count - number of rows in output/ multipath
%switch_QD - whether QD output exists
%
% This part of code generates QD parameters of a select multipath


% -------------Software Disclaimer---------------
%
% NIST-developed software is provided by NIST as a public service. You may use, copy
% and distribute copies of the software in any medium, provided that you keep intact this
% entire notice. You may improve, modify and create derivative works of the software or
% any portion of the software, and you may copy and distribute such modifications or
% works. Modified works should carry a notice stating that you changed the software
% and should note the date and nature of any such change. Please explicitly
% acknowledge the National Institute of Standards and Technology as the source of the
% software.
%
% NIST-developed software is expressly provided "AS IS." NIST MAKES NO
% WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY
% OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
% WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
% NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS
% NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE
% UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE
% CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS
% REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF,
% INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY,
% RELIABILITY, OR USEFULNESS OF THE SOFTWARE.
%
% You are solely responsible for determining the appropriateness of using
% and distributing the software and you assume all risks associated with its use, including
% but not limited to the risks and costs of program errors, compliance with applicable
% laws, damage to or loss of data, programs or equipment, and the unavailability or
% interruption of operation. This software is not intended to be used in any situation
% where a failure could cause risk of injury or damage to property. The software
% developed by NIST employees is not subject to copyright protection within the United
% States.
%
% Modified by: Mattia Lecci <leccimat@dei.unipd.it>, Improved access to MaterialLibrary
% Modified by: Neeraj Varshney <neeraj.varshney@nist.gov>, Included residual
% error in QD model

c = 3e8;
% if  switch_material==1 && QD_gen==1
% To demonstrate that even higher order reflections can be taken care of
% but for accurate results higer order reflections are not valid i.e.,
% above first order. For higher order reflections the physical measurements
% are in progress.
%  if  switch_material==1 && order_of_R==1
Pathloss1 = 0;
switch_QD = 0;
for order_of_R_temp = 1:order_of_R
    
    
    Material = array_of_materials(number,order_of_R_temp);
    if order_of_R_temp == order_of_R
        output(count1-1,21) = Material;
    end
    
    [Pathloss] = PathlossQD(MaterialLibrary,...
        array_of_materials(number,:),1);
    Pathloss1=Pathloss1+Pathloss;
end
output(count1-1,9) = output(count1-1,9)-(Pathloss1);
pathGain = output(count1-1,9);

% i1 is for generating precursors and i2 is for generating postcursors.
for i1 = 1:2
    % In this step the material properties are extracted from material library
    % and different parameters are generated.
    
    if i1 == 1
        muk = MaterialLibrary.mu_k_Precursor(Material);
        sigmak = MaterialLibrary.sigma_k_Precursor(Material);
        muy = MaterialLibrary.mu_Y_Precursor(Material);
        sigmay = MaterialLibrary.sigma_Y_Precursor(Material);
        mul = MaterialLibrary.mu_lambda_Precursor(Material);
        sigmal = MaterialLibrary.sigma_lambda_Precursor(Material);
        muSigmas = MaterialLibrary.mu_SigmaS_Precursor(Material);
        sigmaSigmas = MaterialLibrary.sigma_SigmaS_Precursor(Material);
        % A total of 3 precursors are generated. they can be adjusted by
        % changing n
        n = 3;
        
    else
        muk = MaterialLibrary.mu_k_Postcursor(Material);
        sigmak = MaterialLibrary.sigma_k_Postcursor(Material);
        muy = MaterialLibrary.mu_Y_Postcursor(Material);
        sigmay = MaterialLibrary.sigma_Y_Postcursor(Material);
        mul = MaterialLibrary.mu_lambda_Postcursor(Material);
        sigmal = MaterialLibrary.sigma_lambda_Postcursor(Material);
        muSigmas = MaterialLibrary.mu_SigmaS_Postcursor(Material);
        sigmaSigmas = MaterialLibrary.sigma_SigmaS_Postcursor(Material);
        % A total of 16 post cursors are genearted
        n = 16;
        
    end
    
    muTheta = MaterialLibrary.mu_sigmaThetaAZ(Material);
    sigmaTheta = MaterialLibrary.sigma_sigmaThetaAZ(Material);
    muPhi = MaterialLibrary.mu_sigmaThetaEL(Material);
    sigmaPhi = MaterialLibrary.sigma_sigmaThetaEL(Material);
    
    %%
    if  muk~=0
        sigmaS = db2pow(normalRandomGenerator(muSigmas, sigmaSigmas)); 
        kFactor = db2pow(normalRandomGenerator(muk, sigmak));           
        gamma = normalRandomGenerator(muy, sigmay);
        lambda = normalRandomGenerator(mul, sigmal);
        sigmaAodEl = abs(normalRandomGenerator(muPhi, sigmaPhi));
        sigmaAodAz = abs(normalRandomGenerator(muTheta, sigmaTheta));
        sigmaAoaEl = abs(normalRandomGenerator(muPhi, sigmaPhi));
        sigmaAoaAz = abs(normalRandomGenerator(muTheta, sigmaTheta));
        
        lambda = abs(normalRandomGenerator(mul, sigmal));
        tau_set = nan(n+1, 1);
        tau_set(1) = (distance/c) * 1e9; % convert to ns
        
        i = 1;
        
        % generates delays
        while i<=n
            
            diff = randomExponetialGenerator(lambda);
            if i1 == 1
                tau_set(i+1) = tau_set(i)-diff;
            else
                tau_set(i+1) = tau_set(i)+diff;
            end
            output(count1+i-1,1) = count-1;
            output(count1+i-1, 2:4) = dod;
            output(count1+i-1, 5:7) = doa;
            output(count1+i-1,8) = tau_set(i+1)*1e-9;
            
            % output(count1,10)=180*atan(dod(2)/dod(1))/pi;
            % output(count1,11)=180*acos(dod(3)/norm(dod))/pi;
            % output(count1,12)=180*atan(doa(2)/doa(1))/pi;
            % output(count1,13)=180*acos(doa(3)/norm(doa))/pi;
            i=i+1;
        end
        
        pgCursor = db2pow(pathGain);
        % generates path loss
        
        for i=1:n
            
            if i~=0
                s = normalRandomGenerator(0,sigmaS);
                if i1==1
                       output(count1+i-1,9) = pow2db((pgCursor/kFactor).*...
                           exp(((tau_set(i+1)-tau_set(1))/gamma)+s));
                else
                    output(count1+i-1,9) =  pow2db((pgCursor/kFactor).*...
                           exp(-((tau_set(i+1)-tau_set(1))/gamma)+s));
                    if i == 1
                        output(indexReference,9) =  20*log10(pgCursor-(pgCursor/kFactor));
                    end
                end
            end
        end
        
        mu = acosd(dod(3)/norm(dod));
        
        % generates angular spread for Aod elevation
        
        for i=1:n
            x = randomLaplaceGenerator();
            ran(i) = x;
            Aod_el(i) = mu+x;
            theta_cursor = mu;
            PG(i) = 10^(output(count1+i-1,9)/20);
            PG1(i) = output(count1+i-1,9);
            %     output(count1+i-1,11)=randomLaplaceGenerator(mu,sigma_Aod_E);
        end
        PG_cursor = 10^(output(count-1,9)/20);
        PG_cursor1 = output(count-1,9);
        
        mu_1 = (sum(PG.*Aod_el)+(PG_cursor*theta_cursor))...
            /(sum(PG)+PG_cursor);
        sigma_1 = sqrt(((sum(PG.*((Aod_el-mu_1).*...
            (Aod_el-mu_1))))+(PG_cursor*...
            ((theta_cursor-mu_1)^2)))/(sum(PG)+PG_cursor));
        s = sigmaAodEl/sigma_1;
        Aod_el1 = [theta_cursor,Aod_el]';
        x = (s^2)-((PG_cursor*((theta_cursor-mu_1)^2))/...
            ((sum(PG.*((Aod_el-mu_1).*(Aod_el-mu_1))))+...
            (PG_cursor*((theta_cursor-mu_1)^2))));
        a=((sum(PG.*((Aod_el-mu_1).*(Aod_el-mu_1))))+(PG_cursor*((theta_cursor-mu_1)^2)));
        b=PG_cursor*((theta_cursor-mu_1)^2);
        s1=abs(x*(1+(b/a)));
        Aod_el=((Aod_el-mu_1).*sqrt(s1))+(mu_1);
        
        mu=output(count1-1,10);
        
        % generates angular spread for Aod azimuth
        
        for i=1:n
            x = randomLaplaceGenerator();
            ran(i)=x;
            Aod_az(i)=mu+x;
            theta_cursor=mu;
        end
        
        mu_1=sum(PG.*Aod_az)/sum(PG);
        sigma_1=sqrt((sum(PG.*((Aod_az-mu_1).*(Aod_az-mu_1))))/sum(PG));
        s=sigmaAodAz/sigma_1;
        Aod_az1=[theta_cursor,Aod_az]';
        x=(s^2)-((PG_cursor*((theta_cursor-mu_1)^2))/((sum(PG.*((Aod_az-mu_1).*(Aod_az-mu_1))))+(PG_cursor*((theta_cursor-mu_1)^2))));
        a=((sum(PG.*((Aod_az-mu_1).*(Aod_az-mu_1))))+(PG_cursor*((theta_cursor-mu_1)^2)));
        b=PG_cursor*((theta_cursor-mu_1)^2);
        s1=abs(x*(1+(b/a)));
        Aod_az=((Aod_az-mu_1).*sqrt(s1))+(mu_1);
        
        
        mu=output(count1-1,12);
        
        % generates angular spread for Aoa azimuth
        
        for i=1:n
            x = randomLaplaceGenerator();
            ran(i)=x;
            Aoa_az(i)=mu+x;
            theta_cursor=mu;
        end
        
        mu_1=sum(PG.*Aoa_az)/sum(PG);
        sigma_1=sqrt((sum(PG.*((Aoa_az-mu_1).*(Aoa_az-mu_1))))/sum(PG));
        s=sigmaAoaAz/sigma_1;
        Aoa_az1=[theta_cursor,Aoa_az]';
        x=(s^2)-((PG_cursor*((theta_cursor-mu_1)^2))/((sum(PG.*((Aoa_az-mu_1).*(Aoa_az-mu_1))))+(PG_cursor*((theta_cursor-mu_1)^2))));
        a=((sum(PG.*((Aoa_az-mu_1).*(Aoa_az-mu_1))))+(PG_cursor*((theta_cursor-mu_1)^2)));
        b=PG_cursor*((theta_cursor-mu_1)^2);
        s1=abs(x*(1+(b/a)));
        Aoa_az=((Aoa_az-mu_1).*sqrt(s1))+(mu_1);
        
        mu=acosd(doa(3)/norm(doa));
        
        % generates angular spread for Aoa elevation
        for i=1:n
            x = randomLaplaceGenerator();
            ran(i)=x;
            Aoa_el(i)=mu+x;
            theta_cursor=mu;
        end
        
        mu_1=sum(PG.*Aoa_el)/sum(PG);
        sigma_1=sqrt((sum(PG.*((Aoa_el-mu_1).*(Aoa_el-mu_1))))/sum(PG));
        s=sigmaAoaEl/sigma_1;
        Aoa_el1=[theta_cursor,Aoa_el]';
        x=(s^2)-((PG_cursor*((theta_cursor-mu_1)^2))/((sum(PG.*((Aoa_el-mu_1).*(Aoa_el-mu_1))))+(PG_cursor*((theta_cursor-mu_1)^2))));
        a=((sum(PG.*((Aoa_el-mu_1).*(Aoa_el-mu_1))))+(PG_cursor*((theta_cursor-mu_1)^2)));
        b=PG_cursor*((theta_cursor-mu_1)^2);
        s1=abs(x*(1+(b/a)));
        Aoa_el=((Aoa_el-mu_1).*sqrt(s1))+(mu_1);
        
        % sorting all QD parameters in 'QD' parametwr
        for i=1:n
            output(count1+i-1, 11)=Aod_el1(i+1);
            output(count1+i-1, 10)=Aod_az1(i+1);
            output(count1+i-1, 12)=Aoa_az1(i+1);
            output(count1+i-1, 13)=Aoa_el1(i+1);
            output(count1+i-1, 14:18)=output(count1-1, 14:18);
            
            vAngle_DoD = Aod_el1(i+1);
            hAngle_DoD = Aod_az1(i+1);
            dod_temp=[sind(vAngle_DoD)*cosd(hAngle_DoD),sind(vAngle_DoD)*sind(hAngle_DoD),cosd(vAngle_DoD)];
            vtx_along_dod = dot(vtx, -dod_temp);
            vrx_along_dod = dot(v_temp, -dod_temp);
            c = 3e8;
            doppler_factor = freq * (vrx_along_dod - vtx_along_dod) / c;
            output(count1+i-1,20) = doppler_factor;
            output(count1+i-1,18) = rand*2*pi;
            output(count1+i-1,19) = output(count1+i-1,9)*(output(count1-1,19)/output(count1-1,9));
            switch_QD = 1;
        end
        
        count1=count1+i;
        
    end
end

end