% Get mm coordinates from voxels coordinates 

function [output] = Coord_vox_to_mmSPM(Xvox,Yvox,Zvox)
X=80-2*Xvox;
Y=2*Yvox-114;
Z=2*Zvox-52;

output=[X;Y;Z];