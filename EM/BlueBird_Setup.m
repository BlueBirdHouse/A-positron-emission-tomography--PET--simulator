%% ��ʼ��
clear;
clc;
disp('���������ڲ����㽭��ҵ��ѧ����ϼ��ʦ���о���Ŀ��PETͼ���ع���ʱ��ơ�');
disp('��л����ϼ��ʦ�������Ŀ����Ϊ����Ŀ�ṩ����֧�֡�');
disp('  ');
disp('����������Michigan Image Reconstruction Toolbox(MIRT)');
disp('��лFessler���˵ļ�๤����');
disp('  ');
disp('����������Machine Vision Toolbox');
disp('��лPeter Corke���˵ļ�๤����');
disp('  ');
disp('We wish you good luck!');
disp('Blue Bird');
disp('  ');
%���԰�װ�ļ���λ�á�
%setupDIR = which('BlueBird_Setup.m');

setupDIR = mfilename('fullpath');
[BlueBird_PETCT, ~] = fileparts(setupDIR);
addpath(BlueBird_PETCT);
cd('../');
cd('irt');
run('setup.m');
%�����Ҫ���±��� IRT �������ڲ���MEX�ļ�����ִ���������䡣
%run('ir_mex_build.m');
cd('../');
addpath('irt');
cd(BlueBird_PETCT);
clear;

