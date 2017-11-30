function ls=calc_loss_rank(A,X,X0,lambda,T,K)

%calculate negative log-likelihood
ls=0;
for m=1:length(A)
    ls=ls+exp(A(m,:)*min(K,X0))-X(m,1)*(A(m,:)*min(K,X0));
end


for t=1:(T-1)
    for m=1:length(A)
        ls=ls+exp(A(m,:)*min(K,X(:,t)))-X(m,t+1)*(A(m,:)*min(K,X(:,t)));
    end
end

%add nuclear norm penalty 
nuclear_norm=0;
[~,D,~]=svd(A);
for i=1:length(A)
        nuclear_norm=nuclear_norm+abs(D(i,i));
end

ls=ls+lambda*nuclear_norm;

end
