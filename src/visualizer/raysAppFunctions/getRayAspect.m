function [color, width] = getRayAspect(reflOrder)

switch(reflOrder)
    case 0
        color = [0, 0, 0];
        width = 2;
    case 1
        color = [1, 0, 0];
        width = 1.2;
    case 2
        color = [0, 1, 0];
        width = 0.8;
    case 3
        color = [0, 0, 1];
        width = 0.5;
    case 4
        color = [1, 1, 0];
        width = 0.5;
    case 5
        color = [1, 0, 1];
        width = 0.5;
    case 6
        color = [0, 1, 1];
        width = 0.5;
    otherwise
        color = [1, 1, 1] * 0.5;
        width = 0.5;
end

end