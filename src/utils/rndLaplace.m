function x = rndLaplace(mu, sigma, m, n)
%RNDLAPLACE Generate a matrix of size [m, n] with independent laplacian
%random variables. The generated variables have mean(x) = 0,
%std(x) = sigma.


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

u = rand(m,n) - 0.5;
b = sigma / sqrt(2);
x = mu - b * sign(u) .* log(1 - 2*abs(u)) ;
end