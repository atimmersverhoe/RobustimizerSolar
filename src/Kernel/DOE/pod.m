% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [podbasis,Apod,lambda,Vpod] = pod(U)

% This function is used to compute the Proper Orthogonal Decomposition (POD) basis
% of a given matrix U.
%
% INPUT:
%   U       - A matrix where each column represents a snapshot or state vector.
%             The dimensions of U are typically m x n, where m is the number of
%             spatial points, and n is the number of snapshots.
%
% OUTPUT:
%   podbasis - Matrix containing the orthonormal POD basis vectors as columns.
%   Apod     - Amplitude coefficients of U in the POD basis.
%   lambda   - Vector of eigenvalues corresponding to each POD mode, sorted in
%              descending order.
%   Vpod     - Matrix of eigenvectors from the eigendecomposition.
%
% Steps:
%   - If U has more rows than columns, it uses U'*U to compute the POD basis.
%   - If U has more columns than rows, it uses U*U' for efficiency.
%   - The eigenvalues and eigenvectors are sorted in descending order.

neig = size(U,2);
podbasis = zeros(size(U,1),neig);

if size(U,1) < size(U,2)
    C = U*U';
    [Vpod,lambda] = eig(C);
    podbasis = fliplr(Vpod);
else                 % Case when U has more columns than rows       
    D = (U')*U;      % Use U*U' for efficiency in eigen decomposition
    [Vpod,lambda] = eig(D);
    for n = 1:neig   % Construct the POD basis from U and Vpod
        podbasis(:,n) = real(U*Vpod(:,end-n+1)*(lambda(end-n+1,end-n+1)^(-0.5)));
    end
end
Apod = (podbasis')*U;   % Amplitudes in POD-basis
lambda = flip(diag(lambda))'; % Sort eigenvalues in descending order and store as a vector

N = rank(podbasis);
if N < size(podbasis,2)
    podbasis = podbasis(:,1:N);
    Apod = Apod(1:N,:);
    lambda = lambda(1:N);
else
end