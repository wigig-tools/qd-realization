function PathlossFinal = PathlossQD(MaterialLibrary, arrayOfMaterials, order)
size1=size(arrayOfMaterials);

Material=arrayOfMaterials(1,order);
mu = MaterialLibrary.mu_RL(Material);
sigma = MaterialLibrary.sigma_RL(Material);
PathlossFinal = abs(randn(1)*sigma + mu);

if PathlossFinal<mu-(mu/2)
    PathlossFinal=PathlossFinal+(mu/2);
end

if size1(2)~=order
    [PathlossTemporary]=PathlossQD(MaterialLibrary,arrayOfMaterials,order+1);
    PathlossFinal=PathlossFinal+PathlossTemporary;
end

end