%% ����PETCT��������
PETCT = Scanner.PETCT_Scanner([],[],[],[]);
Sino = PETCT.MakeScan();

%����˲���ά�ȡ�
[n,~] = size(Sino.X);
m = 0;
p = 0;
[q,~] = size(Sino.Y_Poisson);

SDKF = Filter.Filter_SDKF(n,m,p,q);

%�����˲���ֵ
X = ones(SDKF.n_,1);
P_k_k = diag(ones(SDKF.n_,1));
SDKF.Initialization(X,P_k_k);

Times = 8;
for i = 1:1:Times
    Sino = PETCT.MakeScan();
    SDKF.Set_Parameter(Sino);
    [x,P] = SDKF.Step(Sino);
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






