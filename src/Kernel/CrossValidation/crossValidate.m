% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.

function [result] = crossValidate(DOE, outputVal, srgModel, opt)

% crossValidate - Perform cross-validation on a Design of Experiments (DOE) dataset.
%
% Syntax:
%   [result] = crossValidate(DOE, outputVal, srgModel, opt)
%
% Inputs:
%   - DOE: The Design of Experiments dataset.
%   - outputVal: The output values corresponding to the DOE dataset.
%   - srgModel: The surrogate model used for cross-validation.
%
% Options:
%   - progress_dlg: A ProgressDialog object to show the progress of the cross-validation process.
%                   If the user cancels the ProgressDialog, the cross-validation process is 
%                   stopped and no value is returned. The Value property of the ProgressDialog is
%                   updated with the percentage of the cross-validation process completed.
%
% Output:
%   - result: A struct containing the results of the cross-validation process. 
%             The following fields are included:
%               - RMSE: The Root Mean Square Error of the cross-validation process.
%               - residuals: The residuals of the cross-validation process.
%               - R2pred: The R^2 prediction value of the cross-validation process.
%               - R2predadj: The adjusted R^2 prediction value of the cross-validation process.
%               - Ypred: The predicted output values of the cross-validation process.
%
% Description:
%   This function performs cross-validation on a given Design of Experiments (DOE) dataset. 
%   It uses a surrogate model to predict the output values for each sample in the DOE dataset
%   and compares them with the actual output values.
%   The result of the cross-validation process is returned as an output.

    arguments
        DOE (:,:) double
        outputVal (:,:) double
        srgModel (:,:) struct
        opt.progress_dlg matlab.ui.dialog.ProgressDialog {mustBeScalarOrEmpty} = matlab.ui.dialog.ProgressDialog.empty
    end

    % Cross-validation of surrogate model
    n = height(DOE);
    out = outputVal;
    nOutput = width(out);
    nInp = width(DOE); 
    regr = @regpoly0; 
    corr = @corrgauss; 
    t0 = zeros(1,nInp); 
    tcon = [1e-5 1000];  % lower and upperbound constraints on theta
    lowerB = repmat (1e-5, [1,nInp]);
    upperB = repmat (1000, [1,nInp]);

    % Preallocate variables
    [YpredMSE,resid,sqYpred,SSEcv] = deal(zeros(n,1),zeros(n,1),zeros(n,1),zeros(n,1));
    RMSE = zeros(nOutput,1);
    residuals = zeros(n, nOutput);
    R2predicted = zeros(nOutput,1);
    R2predictedadj = zeros(nOutput,1);
    Ypredicted = zeros(n,nOutput);

    total_loops = nOutput * n;
    for counter1 = 1:nOutput % for all outputs
        for counter2 = 1 : n % for all DOE points
            if ~isempty(opt.progress_dlg) && opt.progress_dlg.CancelRequested
                result = struct.empty;
                return
            end
            if ~isempty(opt.progress_dlg)
                percentage = ((counter1-1)*n + counter2) / total_loops;
                opt.progress_dlg.Value = percentage;
            end
            DOEExcl = DOE([1:counter2-1, counter2+1:end], :);  % Copy all rows except the row counter2
            outputCross = out([1:counter2-1, counter2+1:end], :);  % Copy all rows except the row counter2
            [surrogateModel] = dacefit(DOEExcl, outputCross, regr, corr, t0, lowerB, upperB);
            [Ypredicted(counter2,counter1), ~, YpredMSE(counter2,counter1)] = predictor(DOE(counter2,:),surrogateModel);
            res = out(counter2,counter1) - Ypredicted(counter2,counter1);
            [resid(counter2,1),SSEcv(counter2,1)]=deal(res,res.^2);
            sqYpred(counter2,1) = sqrt(YpredMSE(counter2,counter1));
        end

        PRESS = sum(SSEcv); % Calculate predicted residual error sum of squares (PRESS)
        RMSE(counter1) = sqrt(PRESS / n); % Calculate the Root Mean Square Error (RMSE)
        residuals(:,counter1) = resid./sqYpred; % Standardise the residuals
        
        % Calculate R^2_pred and R^2_pred,adj
        SST = sum((out(:,counter1) - mean(out(:,counter1))).^2); % total sum of squared errors
        R2predicted(counter1) = 1 - PRESS/SST; 
        R2predictedadj(counter1) = 1 - ((n-1)/(n-(nInp+3)))*(1-R2predicted(counter1));
    end

    result.RMSE = RMSE;
    result.residuals = residuals;
    result.R2pred = R2predicted;
    result.R2predadj = R2predictedadj;
    result.Ypred = Ypredicted;
end
    