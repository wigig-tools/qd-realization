function [color, width] = getRayAspect(reflOrder)
%GETRAYASPECT Returns color and width corresponding to the given relfOrder
%
%SEE ALSO: PLOTFRAME


% Copyright (c) 2020, University of Padova, Department of Information
% Engineering, SIGNET lab.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%    http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

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