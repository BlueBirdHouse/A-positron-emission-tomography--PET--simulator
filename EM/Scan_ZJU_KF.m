%���ô�****������������ɨ��
PETCT = Scanner.ZJU_Scanner();
Sino = PETCT.MakeScan();

%�����˲�������
KF = Filter.Filter_Kalman(PETCT.n,0,0,PETCT.q);
R = eye(PETCT.q)*PETCT.Variances;
KF.Set_Parameter(eye(PETCT.n),[],[],Sino.C,[],[],R);

%�����˲���ֵ
X = ones(PETCT.n,1);
P_k_k = diag(ones(PETCT.n,1));
KF.Initialization(X,P_k_k);

Times = 8;
for i = 1:1:Times
    Sino = PETCT.MakeScan();
    [X,P] = KF.Step(Sino.Y_Poisson,[]);
    X = reshape(X,[PETCT.nx,PETCT.ny]);
    idisp(X);
    drawnow;
    Str = strcat('��',num2str(i),'���˲���ɣ�');
    disp(Str);
    Analyse.StatisticalData(X,Sino.True_Figure);
    disp('  ');
    pause(5);
end