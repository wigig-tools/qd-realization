clear
close all
clc

%% Run test suite
testResults = runtests("exampleOutputsTest");
disp(testResults)