%TESTSUITE All tests are launched from this script.
% This should allow a maintainable and reliable update process.

clear
close all
clc

%% Run test suite
testResults = runtests("exampleOutputsTest");
disp(testResults)