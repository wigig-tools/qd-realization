function out = readQdFile(path)
fid = fopen(path,'r');

assert(fid ~= -1,...
    'File path ''%s'' not valid', path)

i = 1;
while ~feof(fid)
    % From documentation:
    % (a) number of rays occupies the first row
    line = fgetl(fid);
    numRays = sscanf(line,'%d');
    
    if numRays == 0
        % skip
        continue
    end
    
    out(i).numRays = numRays;
    
    % (b) Delay of each ray is stored in the second row
    line = fgetl(fid);
    out(i).delay = sscanf(line,'%f,',[1,numRays]);
    
    % (c) pathGain of each ray is stored in third row
    line = fgetl(fid);
    out(i).pathGain = sscanf(line,'%f,',[1,numRays]);
    
    % (d) phase offset of each ray is stored in fourth row
    line = fgetl(fid);
    out(i).phaseOffset = sscanf(line,'%f,',[1,numRays]);
    
    % (e) Angle of Departure, Elevation of each ray is stored in fifth row
    line = fgetl(fid);
    out(i).aodEl = sscanf(line,'%f,',[1,numRays]);
    
    % (f) Angle of Departure, Azimuth of each ray is stored in sixth row
    line = fgetl(fid);
    out(i).aodAz = sscanf(line,'%f,',[1,numRays]);
    
    % (g) Angle of Arrival, Elevation of each ray is stored in seventh row
    line = fgetl(fid);
    out(i).aoaEl = sscanf(line,'%f,',[1,numRays]);
    
    % (h) Angle of Arrival, Azimuth of each ray is stored in eighth row
    line = fgetl(fid);
    out(i).aoaAz = sscanf(line,'%f,',[1,numRays]);
    
    i = i+1;
end

fclose(fid);

end