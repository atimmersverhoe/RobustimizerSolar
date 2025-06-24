# RobustimizerSolar

## Description

### Model

The file QuarterPanelLandscape.SLDASM is a CAD model of the Biosphere model V1.3. The file QuarterPanelLandscape-glassdomain.SLDASM is the same model but used for stress analysis in specific regions. The file QuarterPanelPortrait.SLDASM is the same CAD model but in portrait mounting configuration. 

***Open Solidworks model and Comsol simultaneously and click 'Synchronize' in order for the livelink to work.***

### Optimization

The file RobustimizerBiosphereSolar.opt can be opened in Robustimizer to run the optimization for the Biopshere solar module V1.3. Create a DOE and perform a simulation in Comsol to generate an output file. Upload this output file in Robustimizer.

The file fileConverter.xlsx can be used for converting the normalized values to the Original values and back, and for converting Robustimizer format to Comsol format. 
OutCalc.m can be used for calculation the Objective Function values. 