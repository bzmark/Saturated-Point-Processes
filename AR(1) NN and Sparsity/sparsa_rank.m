function [A_hat, loss, loss_true, MSE, grad,kk]=sparsa_rank(X,X0,A,L,lambda,epsilon,iters,K)
%inner loop of sparsa_main: optimize low rank A for fixed L

% Extract dimension parameters and initialize estimates
[n, T]=size(X);
[~,D,~]=svd(A);
loss_true=calc_loss(A,L,D,X,X0,lambda,T,K);
A_hat=A; %Initialize at true A for hopefully faster convergence
sigma=1e-8; % Amount of increase in objective allowed each iteration. 
            %0 means monotonically decreasing.

% Pre-compute portion of gradient which is independent of current estimate
grad_constant=zeros(n);

for t=1:T
    if t==1
        grad_constant=X(:,t)*min(K,X0');
    else
        grad_constant=grad_constant+X(:,t)*min(K,X(:,t-1)');
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
    grad = grad + exp((A_hat+L)*min(K,X(:,1:T-1)))*min(K,X(:,1:T-1)') + exp((A_hat+L)*X0)*X0';
    grad=grad/T;
    
    % Find diagonal approximation to the Hessian
    if kk>1
        r_t=grad-grad_prev;
        alpha=(s_t(:)'*r_t(:))/(s_t(:)'*s_t(:));
        if isnan(alpha)
            alpha=1;
        end
        if alpha==0
            alpha=.1;
        end
    else
        alpha=1;
       
        
    end
    
    accept=false;
    % Take step with parameter alpha using backtracking method of SpaRSA
    while ~accept;
        A2=(A_hat-1/alpha*grad);
        non_nu=A2(2:n,2:n);
        [U,D,V]=svd(non_nu);
        D=sign(D).*(abs(D)-lambda/alpha).*(abs(D)>lambda/alpha);
        non_nu=U*D*V';
        A2(2:n,2:n)=non_nu;
        %A2 = (A2+lambda/alpha).*(A2<=-lambda/alpha);
        loss_temp=calc_loss(A2,L,D,X,X0,lambda,T,K);
        if kk>1
            accept=(loss_temp<=loss(kk-1)*(1+sigma));
        else
            accept=(loss_temp<=loss_true*(1+sigma));
        end
        
        %if ~accept && alpha<2
         %   alpha=alpha*1.1;
        
       if ~accept && alpha<2250
            alpha=alpha*2;
        
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
            diff=.1;
        end
        
    end
    
    kk=kk+1;
end

loss=loss(1:kk-1);
MSE=MSE(1:kk-1);



end

