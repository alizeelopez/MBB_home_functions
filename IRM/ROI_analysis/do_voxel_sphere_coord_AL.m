function voxels=do_voxel_sphere_coord_AL(radius, center_vox)

% This function reports vector of triplets of coordinates of all voxels in a sphere
% radius    = sphere radius, in VOXELS
% center_vox = sphere center, in VOXELS coordinates
% voxels    = vector of coordinates in VOXELS ,for all voxels in sphere

% compute sphere coordinates in VOXELS
temp=[];

if radius==0
    voxels=center_vox;
elseif radius>0
    for X=(center_vox(1)-radius):1:...
            (center_vox(1)+radius)
        for Y=center_vox(2)-radius:1:...
                (center_vox(2)+radius)
            for Z=(center_vox(3)-radius):1:...
                    (center_vox(3)+radius)
                
                if sqrt((X-center_vox(1))^2+(Y-center_vox(2))^2+(Z-center_vox(3))^2) <=radius
                    
                    temp=[temp [X;Y;Z]];
                end
            end
        end
    end
    voxels=temp;
end

end