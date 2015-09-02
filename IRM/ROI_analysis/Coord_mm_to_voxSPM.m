% January 2011 - Mael Lebreton

% This function take coordinates inputs in mm, as can be seen in SPM maps,
% and convert into voxels, to extract correct betas when using spm_get_data

function [output] = Coord_mm_to_voxSPM(Xmm,Ymm,Zmm)

X=40-Xmm/2;
Y=57+Ymm/2;
Z=26+Zmm/2;

output=[X;Y;Z];