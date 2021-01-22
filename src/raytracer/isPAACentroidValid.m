function check = isPAACentroidValid(roomCoordinates, centroidCoordinate)
%ISPAACENTROIDVALID returns check if the centroid inside the defined area (box).
%
%   ISPAACENTROIDVALID(roomCoordinates, centroidCoordinate)
%   Generate a warning is the centroid coordinates centroidCoordinate are
%   outside the area defined in roomCoordinates
%
%   check = ISPAACENTROIDVALID(roomCoordinates, centroidCoordinate)
%   Return false if the centroid coordinates centroidCoordinate are
%   outside the area defined in roomCoordinates
%
%   Copyright 2019-2020 NIST/CTL (steve.blandino@nist.gov)

%#codegen

roomCoordinates = reshape(permute(reshape(roomCoordinates,size(roomCoordinates,1),3,[]),[1,3,2]),[],3);
minCoord = min(roomCoordinates);
maxCoord = max(roomCoordinates);


if ~all(reshape(centroidCoordinate>= minCoord & centroidCoordinate<= maxCoord, [],1))
    warning OFF BACKTRACE
    warning('PAA outside defined area')
    warning ON BACKTRACE
    check = false;
else
    check = true;
end

end