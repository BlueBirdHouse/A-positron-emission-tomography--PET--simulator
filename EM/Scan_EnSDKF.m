%% ����PETCT��������
PETCT = Scanner.PETCT_Scanner([],[],[],[]);
Sino = PETCT.MakeScan();

%����˲���ά�ȡ�
[n,~] = size(Sino.X);
m = 0;
p = 0;
[q,~] = size(Sino.Y_Poisson);

SDEnKF = Filter.Filter_SDEnKF(n,100,q);

%% �����˲���ֵ
Init = Filter.Filter_SDKF(n,m,p,q);
X_Init = ones(Init.n_,1);
P_k_k_Init = diag(ones(Init.n_,1));
Init.Initialization(X_Init,P_k_k_Init);
Sino = PETCT.MakeScan();
Init.Set_Parameter(Sino);
[X_Init,P_k_k_Init] = Init.Step(Sino);
P_k_k_Init = triu(P_k_k_Init,0) + triu(P_k_k_Init,1)';
SDEnKF.Initialization(X_Init,P_k_k_Init);


%% �˲�����
Times = 8;
for i = 1:1:Times
    Sino = PETCT.MakeScan();
    SDEnKF.Set_Parameter(Sino);
    [x] = SDEnKF.Step(Sino);
    X_Figure = Sino.RemoveMask(x,PETCT.Image_Info);
    idisp(X_Figure');
    Str = strcat('��',num2str(i),'���˲���ɣ�');
    disp(Str);
    Analyse.StatisticalData(X_Figure,Sino.True_Figure);
    disp('  ');
    pause(5);
end

idisp(X_Figure');
Analyse.StatisticalData(X_Figure,Sino.True_Figure);






