function yz = problem_seven( yz,t )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

y = yz(1);
z = yz(2);
yz = [-2.*y + 5.*exp(-1.*t), -1*(y.*z.^2)./2];

end

