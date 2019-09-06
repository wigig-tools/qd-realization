function playScenario(app, event)
if ~app.playFlag
    % Pause has been pressed
    return
end
if app.currentTimestep == length(app.timestepInfo)
    % reached the end
    return
end

% Advance time and update plot
app.currentTimestep = app.currentTimestep + 1;

% Next frame
T = timer('StartDelay', 1/app.framerate,...
    'TimerFcn', @(timer,evt) playScenario(app,evt));
start(T)
end