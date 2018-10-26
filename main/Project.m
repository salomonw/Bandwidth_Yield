clear all
clc;

R = 100;
r1 = 1;

alfa = 500;
beta = 10;
gamma = 1;
eta =  0;

u_max = alfa/beta;
u_min = 0;
c_max = 0.000000001;
c_min = 0;

S = [0:floor(R/r1)];
A = [u_min : ((u_max-u_min)/50) : u_max;
     c_min : ((c_max-c_min)/50) : c_max]; 
 
v =  alfa+(gamma+eta*c_max^2)*(R/r1);

P=[];
PR=[];
cntl = [];
cnt = 0;

for a1= 1:size(A,2)
    for a2 = 1:size(A,2)
        cnt = cnt+1;
        cntl = [cntl; cnt A(1,a1),A(2,a2)];
        for s1 = 1:R
            PR(s1,cnt) = (alfa-beta*A(1,a1))*A(1,a1) +s1*A(2,a2);
            for s2 = 1:R
                if s1==min(S)
                    if s1==s2-1
                        P(s1,s2,cnt) = (alfa-beta*A(1,a1))/v;
                    elseif  s1==s2+1
                        P(s1,s2,cnt) = 0;
                    elseif  s1==s2
                        P(s1,s2,cnt) = 1 - (alfa-beta*A(1,a1))/v;
                    else
                        P(s1,s2,cnt) = 0;  
                    end
                    
                elseif s1==max(S)
                    if s1==s2-1
                        P(s1,s2,cnt) = 0;
                    elseif  s1==s2+1
                        P(s1,s2,cnt) = s1*(gamma+eta*A(2,a2)^2)/v;
                    elseif  s1==s2
                        P(s1,s2,cnt) = 1 - (s1*(gamma+eta*A(2,a2)^2)/v);
                    else
                        P(s1,s2,cnt) = 0;                      
                    end
                else
                    if s1==s2-1
                        P(s1,s2,cnt) = (alfa-beta*A(1,a1))/v;
                    elseif  s1==s2+1
                        P(s1,s2,cnt) = s1*(gamma+eta*A(2,a2)^2)/v;
                    elseif  s1==s2
                        P(s1,s2,cnt) = 1 - (alfa-beta*A(1,a1))/v - (s1*(gamma+eta*A(2,a2)^2)/v);
                    else
                        P(s1,s2,cnt) = 0;
                    end
                end
            end
        end
    end
end

PR = PR; %since maximizing

% initial policy
policy=[];
for i = 1:R
   policy(i,1)= 1;
end

discount = 1-0.00001;
epsilon = 0.0001;
max_iter = 10000;

[V, policy, iter, cpu_time] = mdp_policy_iteration(P, PR, discount);
%[policy, iter, cpu_time] = mdp_value_iteration(P, PR, discount);

opt_policy = [];
for i=1:size(policy,1)
    opt_policy = [opt_policy; cntl(cntl(:,1)==policy(i),2:3)];
end

opt_policy
figure;
plot(opt_policy)
title('Optimal policy as a function of the control')
xlabel('n')
ylabel('control price')
legend('u','c')

[Ppolicy, PRpolicy] = mdp_computePpolicyPRpolicy(P, PR, policy);
steady_dist= (Ppolicy)^1000;
figure;
bar(steady_dist(1,:));
title('Steady-State Distribution')
xlabel('i')
ylabel('P(n=i)')