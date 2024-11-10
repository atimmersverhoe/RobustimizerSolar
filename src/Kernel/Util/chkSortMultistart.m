% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [locGlob,valGlob] = chkSortMultistart(exitflag,xOpt,fOpt,varRng,nVar)

% Limit to converged optimization results
if max(exitflag) > 0
    Loc = exitflag >= 1;
    xOpt = xOpt(Loc,:);
    fOpt = fOpt(Loc,:);
else
    errordlg('The problem has no optimum with the selected method. Check your input and output and try again.')
    locGlob=zeros(1,nVar);
    valGlob=0;
    return;
end

% Remove redundant minima
counter = 1;
des = xOpt;
fVal = fOpt;
clear xOpt fOpt

while isempty(des) == 0
    xOpt(counter,:) = des(1,:);
    fOpt(counter,:) = fVal(1,:);
    desLoc = ones(length(des(:,1)),1);
    [optLoc,~] = find(abs(des - repmat(des(1,:),length(des(:,1)),1)) < repmat(1e-2*(varRng(:,2)-varRng(:,1))',length(des(:,1)),1));
    while isempty(optLoc) == 0
        [matchIndex,~] = find(optLoc == optLoc(1)*ones(size(optLoc)));
        if length(matchIndex) == nVar % Optima match
            desLoc(optLoc(1),1) = 0;
        end
        optLoc(matchIndex,:) = [];
    end
    % find and remove equal minima
    if ~islogical(desLoc)
        desLoc = desLoc ~= 0; % Convert W to logical if it's not already
    end
    [des, fVal] = deal(des(desLoc, :), fVal(desLoc, :));
    counter = counter + 1;
end

% sort in ascending order
[fOpt,optLoc] = sort(fOpt);
xOpt = xOpt(optLoc,:);

% global minimum
[locGlob, valGlob] = deal(xOpt(1, :), fOpt(1, :));