% calculate psth for specified voxels, sessions and contrasts

clear all;

subjects=[1:3,5:18,20:22,24:27];

model='102';
length_FIR=16;
radius = 0 ;

done=0;
to_save=0;

working_dir='/mnt/data/IRM_INVPREF';
data_dir=strcat(working_dir,'/data');
cd(data_dir)
subj_data_dir=dir('*INVPREF*');

find_behavior_dir=strcat(working_dir,'/Behavior');
cd(find_behavior_dir);
behavior_dir=dir('*INVPREF*');


% COMPUTE COORDINATES
% ============================

names{1}='VMPFC';
XYZmm{1}=[-8 44 -10];

if done==1
    cd('/mnt/data/IRM_INVPREF/data');
    load(strcat('errpsth',num2str(model),'_radius',num2str(radius)))
else
    
    % Compute sphere coordinates (input in MM, output in voxel)
    for n_roi=1:length(names)
        fprintf('Computing sphere coordinates %d\n',n_roi);
        XYZvox{n_roi} = do_voxel_sphere_coord(radius, XYZmm{n_roi});
    end
    
    % re-convert to MM
    cd(strcat(data_dir,'/',subj_data_dir(1).name,'/stats/model',model));
    M = spm_get_space('spmT_0001.img'); % matrix to convert mm to voxel
    for n_roi=1:length(names)
        for vox=1:size(XYZvox{n_roi},2)
            Sphere_mm{n_roi}(:,vox) = M(1:3,:)*[XYZvox{n_roi}(:,vox); ones(size(XYZvox{n_roi}(:,vox),2),1)];
        end
    end
    
    
    % GET PSTH
    % =============================
    
    for region=1:size(names)
        pos_m{region}=zeros(length_FIR,length(subjects));
        neg_m{region}=zeros(length_FIR,length(subjects));
        pos_nm{region}=zeros(length_FIR,length(subjects));
        neg_nm{region}=zeros(length_FIR,length(subjects));
    end
    
    for n_roi=1:length(names)
        
        sub=0;
        
        for nsub=subjects
            sub=sub+1;
            fprintf('Sub %d\n',subjects(sub));
            cd(strcat(data_dir,'/',subj_data_dir(nsub).name))
            cd(['stats/model' model])
            
            for nsession=1:6
                fprintf('\t Session %d\n',nsession);
                
                for i=1:size(Sphere_mm{n_roi},2)
                    fprintf('\t \t Voxel %d\n',i);
                    if mod(nsession,2)==mod(nsub,2) % music sessions only
                        pos_m{n_roi}(:,sub)=pos_m{n_roi}(:,sub)+spm_myPSTH('SPM',Sphere_mm{n_roi}(:,i),nsession,'pos')/(6*size(Sphere_mm{n_roi},2));
                        neg_m{n_roi}(:,sub)=neg_m{n_roi}(:,sub)+spm_myPSTH('SPM',Sphere_mm{n_roi}(:,i),nsession,'neg')/(6*size(Sphere_mm{n_roi},2));
                    else
                        pos_nm{n_roi}(:,sub)=pos_nm{n_roi}(:,sub)+spm_myPSTH('SPM',Sphere_mm{n_roi}(:,i),nsession,'pos')/(6*size(Sphere_mm{n_roi},2));
                        neg_nm{n_roi}(:,sub)=neg_nm{n_roi}(:,sub)+spm_myPSTH('SPM',Sphere_mm{n_roi}(:,i),nsession,'neg')/(6*size(Sphere_mm{n_roi},2));
                    end
                end
            end
            
            cd(['/mnt/data/IRM_INVPREF/data'])
            
        end
        
    end
    
    if to_save==1
        save(strcat('errpsth',model,'_radius',num2str(radius),'_(no23_w26)'));
    end
end


set(0,'DefaultFigureColor','w')
scrsz = get(0,'ScreenSize');
col1 = {'b', 'r'};
col2 = {'g', 'm'};
my_x_axis = -10:2:20;

fig=figure('Position',[1 scrsz(4)/4 scrsz(3)/8 scrsz(4)]);
set(fig, 'Name', strcat(['Model' model 'all conditions, radius' num2str(radius)]))
hold on
for n_roi=1:length(names)
    clear subplot
    subplot(2,length(names),n_roi)
    xlim([0 17])
    do_joliplot2(pos_m{n_roi}, neg_m{n_roi}, col1, my_x_axis)
    plot([0 0],[-0.2 0.3],'k')
    title('pos vs neg Music');
    ax1 = gca;
    legend(ax1,'boxoff');
    axis([-11 21 -0.3 0.2])
    set(gca,'XTick',-10:2:20);
    
    subplot(2,length(names),n_roi+length(names))
    xlim([0 17])
    do_joliplot2(pos_nm{n_roi}, neg_nm{n_roi}, col2,my_x_axis)
    plot([0 0],[-0.2 0.3],'k')
    title('pos vs neg No Music');
    ax1 = gca;
    %     legend('Positive','Negative', 'Location','Best');
    legend(ax1,'boxoff');
    axis([-11 21 -0.3 0.2])
    set(gca,'XTick',-10:2:20);
end

fig=figure('Position',[1 scrsz(4)/2 scrsz(3)/8 scrsz(4)/2]);
set(fig, 'Name', strcat(['Modele 102 all conditions, radius' num2str(radius)]))
hold on
for n_roi=1:length(names)
    pos{n_roi} = [pos_m{n_roi}, pos_nm{n_roi}];
    neg{n_roi} = [neg_m{n_roi}, neg_nm{n_roi}];
    clear subplot
    subplot(1,length(names),n_roi)
    xlim([0 17])
    do_joliplot2(pos{n_roi}, neg{n_roi}, col1,my_x_axis)
    plot([0 0],[-0.21 0.2],'k')
    title(strcat(names{n_roi},' pos vs neg All Conditions'));
    ax1 = gca;
    %     legend('Positive','Negative', 'Location','Best');
    legend(ax1,'boxoff');
    axis([-11 21 -0.21 0.2])
    set(gca,'XTick',-10:2:20);
end

% COMPARE AREA UNDER CURVE
% ========================

% figure
% hold on
for ii=1:6
%     subplot(6,1,ii)
%     hold on
ii;
    [h p]=ttest(trapz(pos_m{n_roi}(ii:6,:)-neg_m{n_roi}(ii:6,:)));
%     bar([mean(trapz(pos{n_roi}(ii:6,:)));mean(trapz(neg{n_roi}(ii:6,:)))])
%     errorbar([mean(trapz(pos{n_roi}(ii:6,:)));mean(trapz(neg{n_roi}(ii:6,:)))],[std(trapz(pos{n_roi}(ii:6,:)));std(trapz(neg{n_roi}(ii:6,:)))])
    [h p]=ttest(trapz(pos_nm{n_roi}(ii:6,:)-neg_nm{n_roi}(ii:6,:)));
end
cd(['/mnt/data/IRM_INVPREF/data'])

