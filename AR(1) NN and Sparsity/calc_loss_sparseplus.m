function ls=calc_loss_sparseplus(A,L,X,X0,lambda,T,K)

A=A+L;
ls=0;
for m=1:length(A)
    ls=ls+exp(A(m,:)*min(K,X0))-X(m,1)*(A(m,:)*min(K,X0));
end


for t=1:(T-1)
    for m=1:length(A)
        ls=ls+exp(A(m,:)*min(K,X(:,t)))-X(m,t+1)*(A(m,:)*min(K,X(:,t)));
    end
end

one_norm=0;
for i=1:length(L)
    for j=1:length(L)
        one_norm=one_norm+abs(L(i,j));
    end
end

ls=ls+lambda*one_norm;




end
