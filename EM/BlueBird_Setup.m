%% 初始化
clear;
clc;
disp('本工具是在参与浙江工业大学王宏霞老师的研究项目“PET图像重构”时设计。');
disp('感谢王宏霞老师发起此项目，并为此项目提供智力支持。');
disp('  ');
disp('本工具依赖Michigan Image Reconstruction Toolbox(MIRT)');
disp('感谢Fessler等人的艰苦工作。');
disp('  ');
disp('本工具依赖Machine Vision Toolbox');
disp('感谢Peter Corke等人的艰苦工作。');
disp('  ');
disp('We wish you good luck!');
disp('Blue Bird');
disp('  ');
%测试安装文件的位置。
%setupDIR = which('BlueBird_Setup.m');

setupDIR = mfilename('fullpath');
[BlueBird_PETCT, ~] = fileparts(setupDIR);
addpath(BlueBird_PETCT);
cd('../');
cd('irt');
run('setup.m');
%如果需要重新编译 IRT 工具箱内部的MEX文件，请执行下面的语句。
%run('ir_mex_build.m');
cd('../');
addpath('irt');
cd(BlueBird_PETCT);
clear;

