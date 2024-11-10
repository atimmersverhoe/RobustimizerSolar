% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [DOE]=makeDOE(np,nDOE,cp,mmi)

% This function generates the DOE based on the given input

% Input: 
% np        number of parameters
% nDOE      number of DOE points
% cp        parameter to consider factorial design
% mmi       parameter to include maxmizing the minimum distance

% OutPut: 
% DOE       Design of experiment with nDOE*np size

if cp==0
    if mmi==1
        DOE=lhsdesign(nDOE,np,'criterion','maximin','iterations',1000); 
    else
        DOE=lhsdesign(nDOE,np);
    end
else
    % Generate factorial design by defining the cell array of `np` value
    fracfactStrings = {
        'a b', ...                             
        'a b ab', ...                        
        'a b c abc', ...                         
        'a b c ab ac', ...                       
        'a b c ab ac bc', ...                    
        'a b c ab ac bc abc', ...              
        'a b c d bcd acd abc abd', ...         
        'a b c d abc bcd acd abd abcd', ...     
        'a b c d abc bcd acd abd abcd ab'   
    };
    
    % Ensure `np` is within the valid range before proceeding
    if np >= 2 && np <= 10
        DOEcp = fracfact(fracfactStrings{np - 1});
    else
        error('Value of np must be between 2 and 10.');
    end

    if mmi==1
        DOE_LHS=lhsdesign(nDOE-size(DOEcp,1),np,'criterion','maximin','iterations',1000);
    else
        DOE_LHS=lhsdesign(nDOE-size(DOEcp,1),np);
    end  
    % Combine factorial design with LHS
    DOE=[DOEcp./2+0.5;DOE_LHS];
end
 