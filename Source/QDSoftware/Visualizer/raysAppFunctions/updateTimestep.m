function updateTimestep(src,event)
app = event.AffectedObject;
t = app.currentTimestep;

app.TimestepSpinner.Value = t;
app.TimestepSlider.Value = t;

disp(t)
end