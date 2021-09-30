%利用从****大学得来的数据做扫描
PETCT = Scanner.ZJU_Scanner();
Sino = PETCT.MakeScan();

%生成滤波器对象
HF = Filter.Filter_Hinf(PETCT.n,0,PETCT.q,PETCT.n);
HF.Set_Parameter(eye(PETCT.n),[],Sino.C,eye(PETCT.n));

%设置滤波初值
X = ones(PETCT.n,1);
P_k_k = diag(ones(PETCT.n,1));

%滤波器离线预算初始化(仅第一次需要)
HF.Off_lineComputation(X,P_k_k,8);
%滤波器标准初始化
HF.Initialization(X);

Times = 8;
for i = 1:1:Times
    Sino = PETCT.MakeScan();
    [X,P] = HF.Step(Sino.Y_Poisson);
    X = reshape(X,[PETCT.nx,PETCT.ny]);
    idisp(X);
    drawnow;
    Str = strcat('第',num2str(i),'次滤波完成！');
    disp(Str);
    Analyse.StatisticalData(X,Sino.True_Figure);
    disp('  ');
    pause(5);
end