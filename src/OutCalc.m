%script to calculate out.txt 

% Load the COMSOL output file (assumed to be .csv or tab-delimited)
comsolOut = readtable('ComsolOutFinal.txt', 'Delimiter', '\t');

% Constants
salary = 3.25;                     % €/hour
M0 = 32.76;                      % kg (144-cell panel) or 27.42 kg (120-cell panel)
m0Glass1 = 13.400;               % kg
m0Glass2 = 13.400;               % kg 
m0Dots = 11.178/1000;            % kg
m0Frame = 2.218;                 % kg               
m0Clamp =  25.53/1000;           % kg
C0mat = 57.88;                   % €/panel
C0ship = 38.77;                  % €/panel
H0frame = 30;                    % mm
mSeal = 0.0766;                  % kg 
s = C0ship / H0frame;           % €/mm
N0dots = 348;                   % dots (144-cell panel) or 290 dots (120-cell panel)
C0prod = 6.58 * salary;         % €/panel
c3 = 88.72;                     % €/kg for dots
Wpanel = 564;
Lpanel = 1188;

% Initialize result vector
numDOE = height(comsolOut);
Fobj = zeros(numDOE, 1);
rM = zeros(numDOE, 1);
rAntiRepairability = zeros(numDOE, 1);
rC = zeros(numDOE, 1);

% Extract relevant columns
Hframe = comsolOut{:,1};
Hglass1 = comsolOut{:,4};
Hglass2 = comsolOut{:,7};

DdotsX = comsolOut{:,5};
DdotsY = comsolOut{:,6};
D0dotsX = comsolOut{:,5};
D0dotsY = comsolOut{:,6};

mGlass1 = comsolOut{:,12} * 4; %multiply by 4 because of quarter model
mGlass2 = comsolOut{:,13} * 4;
mDots = comsolOut{:,14} * 4 - mSeal; %mass is given including mseal
mFrame = comsolOut{:,15} * 4;
mClamp = comsolOut{:,16} * 4;

deformations = comsolOut{:,10} /100; %make it a number between 0 and 1
stressGlass = comsolOut{:,9} /1000; %make it a number between 0 and 1
stressCells = comsolOut{:,11}/1000; %make it a number between 0 and 1

% Loop through each DOE row
for i = 1:numDOE
    % ----- Mass ratio -----
    deltaM = mGlass1(i) + mGlass2(i) + mDots(i) + mFrame(i) + mClamp(i) - m0Glass1 - m0Glass2 - m0Dots - m0Frame - m0Clamp;
    rM(i) = deltaM / M0;

    % ----- Amount of Dots -----
    Ndots = floor((Wpanel - D0dotsY(i) - DdotsY(i)/2) / DdotsY(i)) * 12 + ...
            floor((Lpanel - D0dotsX(i) - DdotsX(i)/2) / DdotsX(i)) * 3;

    % ----- Repairability -----
    rAntiRepairability(i) = (-5/26)*(Hglass1(i) - 2)/2 + ...
                         (-5/26)*(Hglass2(i) - 2)/2 + ...
                         (8/26)*(Ndots - N0dots)/N0dots;

    % ----- Cost ratio -----
    deltaCmat = c3 * (mDots(i)-m0Dots);

    Cship = s * Hframe(i);
    deltaCship = Cship - C0ship;

    deltaCprod = ((50 / N0dots * Ndots - 50) / 60) * salary;

    C0tot = C0mat + C0ship + C0prod;

    rC(i) = (deltaCmat + deltaCship + deltaCprod) / C0tot;

    % ----- Final objective -----
    Fobj(i) = rM(i) + rAntiRepairability(i) + rC(i);           
end

% Create output table
outputTable = table(Fobj, deformations, stressGlass, stressCells);

% Write to .txt file with tab-separated columns
writetable(outputTable, 'OutFinal.txt', 'Delimiter', '\t', 'FileType', 'text', 'WriteVariableNames', false);
