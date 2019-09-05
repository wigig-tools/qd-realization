function updateScenario(app)

scenarioName = app.ScenarioDropDown.Value;
app.scenarioName = scenarioName;
app.visualizerPath = sprintf('../%s/Output/Visualizer', scenarioName);
app.UIAxes.Title.String = scenarioName;

end