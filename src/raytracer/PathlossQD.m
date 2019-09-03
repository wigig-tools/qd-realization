function [PathlossFinal]=PathlossQD(MaterialLibrary,arrayOfMaterials,order)
size1=size(arrayOfMaterials);

Material=arrayOfMaterials(1,order);
mu = MaterialLibrary.mu_RL(Material);
sigma = MaterialLibrary.sigma_RL(Material);
PathlossFinal = normalRandomGenerator(mu,sigma);
if PathlossFinal<=0
   PathlossFinal=abs(PathlossFinal); 
end

if PathlossFinal<mu-(mu/2)
    PathlossFinal=PathlossFinal+(mu/2);
end
if size1(2)~=order
    [PathlossTemporary]=PathlossQD(MaterialLibrary,arrayOfMaterials,order+1);
    PathlossFinal=PathlossFinal+PathlossTemporary;
end

end