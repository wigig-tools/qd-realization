function x = randomExponetialGenerator(lambda)

x = -log(1-(rand(size(lambda)))) ./ lambda ;

end
