function [A_hat, loss, loss_true, MSE, grad,kk]=arma_sparsity(X,X0,init,lambda,epsilon,iters,K,beta)
%estimate sparse A generated by

%X_t ~ Poisson(u_t)
%log(u_t)=nu+min(X_t,K)+beta*log(u_{t-1})

%using MLE with an l_1 regularization penalty

%lambda=regularization parameter

%stopping criteria: stop if succesive losses are within epsilon or
%number of iterations exceeds iters

%init=initialization



% Extract dimension parameters and initialize estimates
[n, T]=size(X);
gx=zeros(n,T);
loss_true=arma_calc_loss(init,X,X0,lambda,T,K,beta);
A_hat=init; %Initialize at true A for hopefully faster convergence
sigma=1e-8; % Amount of increase in objective allowed each iteration. 
            %0 means monotonically decreasing.

% Pre-compute portion of gradient which is independent of current estimate
grad_constant=zeros(n);

for t=1:T
    if t==1
        grad_constant=X(:,t)*min(X0,K)';
        gx(:,1)=beta*min(X0,K)+min(X(:,1),K);
    else
        grad_constant=grad_constant+X(:,t)*gx(:,t-1)';
        gx(:,t)=beta*gx(:,t-1)+min(K,X(:,t));
    end
end

% SpaRSA loop
loss=zeros(1,iters+1);
MSE=zeros(1,iters+1);
diff=inf;
kk=1;
while diff>epsilon && kk<iters

    %Calculate gradient at current estimate
    grad=-grad_constant;

    grad = grad + exp(A_hat*gx(:,1:T-1))*gx(:,1:T-1)' + exp(A_hat*X0)*X0';
    grad=grad/T;
    
    % Find diagonal approximation to the Hessian
    if kk>1
        r_t=grad-grad_prev;
        alpha=(s_t(:)'*r_t(:))/(s_t(:)'*s_t(:));
        if isnan(alpha)
            alpha=1;
        end
        if alpha==0;
            alpha=.1;
        end
    else
        alpha=1;
    end
    
    accept=false;
    % Take step with parameter alpha using backtracking method of SpaRSA
    while ~accept;
       % A2=(A_hat-1/alpha*grad).*(abs(A_hat)>=lambda/alpha);
        A2=A_hat-1/alpha*grad;
        A2=sign(A2).*(abs(A2)-lambda/alpha).*(abs(A2)>=lambda/alpha);
   
        loss_temp=arma_calc_loss(A2,X,X0,lambda,T,K,beta);
        if kk>1
            accept=(loss_temp<=loss(kk-1)*(1+sigma));
        else
            accept=(loss_temp<=loss_true*(1+sigma));
            
           
        end
        
       %backtracking step 
       if ~accept && alpha<500
            alpha=alpha*1.2;
        
        
       else
                        
            accept=true;
            s_t=A2-A_hat;
            grad_prev=grad;
            A_hat=A2;
        end
    end
    loss(kk)=loss_temp;
    MSE(kk) = norm(A_hat-A,'fro')^2;
    if kk>1
        diff=abs(loss(kk)-loss(kk-1));
        if diff==0
            diff=1;
        end
        
    end
    
    kk=kk+1;
end

loss=loss(1:kk-1);
MSE=MSE(1:kk-1);

end
