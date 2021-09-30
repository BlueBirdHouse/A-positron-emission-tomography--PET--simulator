%利用从****得来的数据做扫描
PETCT = Scanner.ZJU_Scanner();
Sino = PETCT.MakeScan();

%生成滤波器对象
KF = Filter.Filter_Kalman(PETCT.n,0,0,PETCT.q);
R = eye(PETCT.q)*PETCT.Variances;
KF.Set_Parameter(eye(PETCT.n),[],[],Sino.C,[],[],R);

%设置滤波初值
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
    Str = strcat('第',num2str(i),'次滤波完成！');
    disp(Str);
    Analyse.StatisticalData(X,Sino.True_Figure);
    disp('  ');
    pause(5);
end