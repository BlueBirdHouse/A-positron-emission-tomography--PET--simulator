%���ô�****��ѧ������������ɨ��
PETCT = Scanner.ZJU_Scanner();
Sino = PETCT.MakeScan();

%�����˲�������
HF = Filter.Filter_Hinf(PETCT.n,0,PETCT.q,PETCT.n);
HF.Set_Parameter(eye(PETCT.n),[],Sino.C,eye(PETCT.n));

%�����˲���ֵ
X = ones(PETCT.n,1);
P_k_k = diag(ones(PETCT.n,1));

%�˲�������Ԥ���ʼ��(����һ����Ҫ)
HF.Off_lineComputation(X,P_k_k,8);
%�˲�����׼��ʼ��
HF.Initialization(X);

Times = 8;
for i = 1:1:Times
    Sino = PETCT.MakeScan();
    [X,P] = HF.Step(Sino.Y_Poisson);
    X = reshape(X,[PETCT.nx,PETCT.ny]);
    idisp(X);
    drawnow;
    Str = strcat('��',num2str(i),'���˲���ɣ�');
    disp(Str);
    Analyse.StatisticalData(X,Sino.True_Figure);
    disp('  ');
    pause(5);
end