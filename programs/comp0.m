%% Comparison 0

n = 40;
m = 2;
density = 0.5;

P = struct('pos', [1], 'neg', [], 'lbound', -inf , 'ubound', inf);

Results = table;
cvx_clear;



for i = 1:m, %1:m 

    B = round(rand(n)/(2-2*density)).*round(rand(n)*25);
    B = B - diag(diag(B))  ;
    B = triu(B)' + triu(B);
    L = diag(B*ones(n,1)) -  B;
    W = L/4;

    result = struct();
    result.Size = n;
    
    
    
        bound.sdp(W,P); 
        sprintf('warmup %d done',i)

    [result.sdp_lb, result.sdp_ub, xf, result.sdp_utime, result.sdp_ltime] = bound.sdp(W,P); 
    sprintf('sdp %d done',i)
    [result.sdp_rlt_lb, result.sdp_rlt_ub, xf, result.sdp_rlt_utime, result.sdp_rlt_ltime] = bound.sdp_rlt(W,P);
    sprintf('sdp_rlt %d done',i)
    [result.sdp_tri_lb, result.sdp_tri_ub, xf, result.sdp_tri_utime, result.sdp_tri_ltime] = bound.sdp_triangle(W,P);
    sprintf('sdp_tri %d done',i)
    [result.socp1_lb, result.socp1_ub, xf, result.socp1_utime, result.socp1_ltime] = bound.socp1(W,P);
    sprintf('socp1 %d done',i)
    [result.socp2_lb, result.socp2_ub, xf, result.socp2_utime, result.socp2_ltime] = bound.socp2(W,P);
    sprintf('socp2 %d done',i)
    [result.socp3_lb, result.socp3_ub, xf, result.socp3_utime, result.socp3_ltime] = bound.socp3(W,P);
    sprintf('socp3 %d done',i)
    [result.mix1_lb, result.mix1_ub, xf, result.mix1_utime, result.mix1_ltime] = bound.mixedSocpSdp(W,P);
    sprintf('mix1 %d.%d done',[n,i])
    [result.mix2_lb, result.mix2_ub, xf, result.mix2_utime, result.mix2_ltime] = bound.mixedSocpSdp2(W,P);
    sprintf('mix2 %d.%d done',[n,i])
    [result.mixr20_lb, result.mixr20_ub, xf, result.mixr20_utime, result.mixr20_ltime] = bound.mixedSocpSdpr(W,P,20);
    sprintf('mixr20 %d done',i)
    [result.mixr3_lb, result.mixr3_ub, xf, result.mixr3_utime, result.mixr3_ltime] = bound.mixedSocpSdpr(W,P,3);
    sprintf('mixr3 %d done',i)
    [result.lp1_lb, result.lp1_ub, xf, result.lp1_utime, result.lp1_ltime] = bound.lp1(W,P);
    sprintf('lp1 %d done',i)
    [result.lp2_lb, result.lp2_ub, xf, result.lp2_utime, result.lp2_ltime] = bound.lp2(W,P);
    sprintf('lp2 %d done',i)
    [result.lp3_lb, result.lp3_ub, xf, result.lp3_utime, result.lp3_ltime] = bound.lp3(W,P);
    sprintf('lp3 %d done',i)
    [result.lp4_lb, result.lp4_ub, xf, result.lp4_utime, result.lp4_ltime] = bound.lp4(W,P);
    sprintf('lp4 %d done',i)
    [result.dnn1_lb, result.dnn1_ub, xf, result.dnn1_utime, result.dnn1_ltime] = bound.dnn1(W,P);
    sprintf('dnn1 %d done',i)
    [result.dnn2_lb, result.dnn2_ub, xf, result.dnn2_utime, result.dnn2_ltime] = bound.dnn2(W,P);
    sprintf('dnn2 %d done',i)
    [result.dnn3p_lb, result.dnn3p_ub, xf, result.dnn3p_utime, result.dnn3p_ltime] = bound.dnn3p(W,P,10000);
    sprintf('dnn3p %d done',i)
    [result.dnn3d_lb, result.dnn3d_ub, xf, result.dnn3d_utime, result.dnn3d_ltime] = bound.dnn3d(W,P,10000);
    sprintf('dnn3d %d done',i)


    result.optVal = bnb_max(W);

Results = [Results; struct2table(result)];
save('results0.mat', 'Results');
    

end

Results(:,[1, end,3:4:end])

%%

% upper bounds
optVals = Results.optVal;
utabl = Results(:,[1,2, end,3:4:end]);
rel_err = @(col)((col - optVals)./optVals);
rel_errors = varfun(rel_err,utabl(:,4:end));

ub_names = cellstr(rel_errors.Properties.VariableNames);
figure; hold on;
for i = 1:width(rel_errors)
    plot(i,rel_errors.(cell2mat(ub_names(i))), 'ro')
end
ax = gca;
ax.YScale = 'log';




% times 
uttabl = Results(:,[4:4:end]);
ut_names = cellstr(uttabl.Properties.VariableNames);
hold on;
for i = 1:width(uttabl)
    plot(i,uttabl.(cell2mat(ut_names(i))), 'b*')
end
ax = gca;
ax.YScale = 'log';


names = ub_names;
nm = length(names);
for i = 1:nm
    namei = cell2mat(names(i));
    names(i) = cellstr(regexprep(namei(5:(end-3)),'_',' '));
end

set(gca,'xtick',1:nm);
set(gca,'XTickLabel',names);
ax.XTickLabelRotation=90;


grid on;
%grid minor; 

ro = plot(-1,-1,'ro');
    bs = plot(-1,-1,'b*');
    legend([ro,bs],'relative lower bound', 'runing time', 'Location','north')
title(sprintf('%d random max cut instances, density = %2.2f, n = %d', [m, density,n]));

% probably should also do 100 case and run those slow DNNs

