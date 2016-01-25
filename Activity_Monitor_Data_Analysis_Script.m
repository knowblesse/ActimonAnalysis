%   Activity Monitor Data Analysis Script
%   @Knowblesse 2015-06-04
%   @Last modified 2015-08-17

%% Init.
% Screensize = get(groot, 'Screensize');
% hold on;
% %% Load Group Data
% [filename, pathname] = uigetfile;
% Path=strcat(pathname,filename);
% load(Path);
% data = Untitled;
%% std_interval
%   data window = 300 point = 1 minute
windowed_data_std = std_Interval(data,6,300);%User defined function <std_Interval(data,window)>
windowed_data_std_mean = mean(windowed_data_std , 2);
%% Draw Graph Version 1
gui1 = figure(1);
set(gui1, 'Position', [1,1,Screensize(3)/2,Screensize(4)]);
movegui(gui1,'west');
subplot(2,1,1);
plot(windowed_data_std);
subplot(2,1,2);
plot(windowed_data_std_mean);
gui2 = figure(2);
set(gui2, 'Position', [1,1,Screensize(3)/2,Screensize(4)]);
movegui(gui2,'east');
subplot(3,1,1);
bar(windowed_data_std_mean>12);
subplot(3,1,2);
bar(windowed_data_std_mean>10);
subplot(3,1,3);
bar(windowed_data_std_mean>8);
%% Draw Graph Version 2 for 6 Samples 
% [stddata_size,~] = size(windowed_data_std);
% THRESHOLD = 5;
% figure(1);
% for i = 1:6
% subplot(3,2,i);
% bar(windowed_data_std(:,i)>THRESHOLD);
% hold on;
% plot(windowed_data_std(:,i));
% title(['Sample ', num2str(i)]);
% axis([0,stddata_size, 0, 40]);
% end
