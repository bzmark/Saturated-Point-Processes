function ls=calc_loss_arma(A,X,X0,lambda,T,K,alpha)


%compute negative log-likelihood
ls=0;
for m=1:length(A)
    ls=ls+exp(A(m,:)*min(K,X0))-X(m,1)*(A(m,:)*min(K,X0));
end
gx=min(K,X(:,1));

for t=1:(T-1)
    for m=1:length(A)
        ls=ls+exp(A(m,:)*gx)-X(m,t+1)*(A(m,:)*gx);
    end
    gx=gx*alpha+min(K,X(:,t+1));
end

%add l_1 penalty
one_norm=0;
for i=1:length(A)
    for j=1:length(A)
        one_norm=one_norm+abs(A(i,j));
    end
end

ls=ls+lambda*one_norm;

end
