function POSITION=xycoordination(Position)
% find the x-y coordinate (extracted by ImageJ/Fiji) of AuNR in each frame.
% input: x-y coordination extracted by ImageJ/Fiji
% output: pixel position in images

POSITION=round(Position);
POSITION=POSITION+1;%coordinate unification
end