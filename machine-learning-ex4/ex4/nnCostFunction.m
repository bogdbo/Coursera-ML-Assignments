function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%


% Inference (Forward propagation)

% Convert y to binary vectors
xY = zeros(size(y,1), num_labels);
for i = [1:size(xY, 1)] 
  resultValue = y(i); % eg, 2 for picture with 2, 5 for picture with 5
  xY(i, resultValue) = 1; % [0 1 0 0 0 0 ...] for 2
end

X = [ones(m, 1), X]; % Add byas
A1 = X;

Z2 = A1 * Theta1';
A2 = sigmoid(Z2); % use nn activation function
SigmoidZ2 = A2; % save this for backpropagation
A2 = [ones(size(A2, 1), 1) A2]; % Add bias

Z3 = A2* Theta2';
A3 = sigmoid(Z3); % this is output, need to map to values between 0 and 1

[a4mVal, a4mInd] = max(A3, [], 2); 
A4 = a4mInd; % contains the labels, eg 5 for picture with 5


% Compute COST
firstSum = xY' * log(A3);
secondSum = (1 - xY)' * (log(1 - A3));
J = -1/m * trace(firstSum + secondSum); % use trace to exclude unnecessary 
                                        % terms from sum
                                        % take only main diagonal

regularizedTheta1 = Theta1;
regularizedTheta2 = Theta2;

regularizedTheta1(:,1) = 0;
regularizedTheta2(:,1) = 0;
regularizationTerm = sum(sum(regularizedTheta1.^2)) + sum(sum(regularizedTheta2.^2));

J = J + lambda/(2*m) * regularizationTerm;

% Compute gradients
d3 = A3 - xY; % diference between extended labels [0 0 0 1 ...] - [1 0 0 0...]
              % size is 5000x10
d2 = d3 * Theta2(:,2:end) .* SigmoidZ2 .* (1 - SigmoidZ2);

delta1 = d2' * A1;
delta2 = d3' * A2;

Theta1_grad = 1/m .* delta1;
Theta2_grad = 1/m .* delta2;


% regularize theta
Theta1(:, 1) = 0;
Theta2(:, 1) = 0;

Theta1 = (lambda/m) .* Theta1; 
Theta2 = (lambda/m) .* Theta2;

Theta1_grad = Theta1_grad + Theta1;
Theta2_grad = Theta2_grad + Theta2;

% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
