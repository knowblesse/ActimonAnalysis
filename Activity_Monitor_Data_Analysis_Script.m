%   Activity Monitor Data Analysis Script
%   @Knowblesse 2015-06-04
%   @Last modified 2016-02-22
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Ver 1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Init.
Screensize = get(groot, 'Screensize');
hold on;
%% Load Group Data
[filename, pathname] = uigetfile('.txt');
Path=strcat(pathname,filename);
data = load(Path);
data = data(:,2:end);
channel = size(data,2);
duration = datestr((data(end,1) - data(1,1))/86400,'HH:MM:SS.FFF');
msgbox({'Data successfully loaded.';['Channel Number : ', num2str(channel)];['Duration : ', num2str(duration)]});
%% std_interval
%data window = 300 point = 1 minute
window = 300;
calculated_data_size = size(data,1) - rem(size(data,1),window);
windowed_data_std = zeros(calculated_data_size / window,channel);
for i = window:window:calculated_data_size
    windowed_data_std(i/window,:) = std(data(i-window+1:i,:),1);
end
windowed_data_std_mean = mean(windowed_data_std , 2);
% %% Draw Graph Version 1
% gui1 = figure(1);
% set(gui1, 'Position', [1,1,Screensize(3)/2,Screensize(4)]);
% movegui(gui1,'west');
% subplot(2,1,1);
% plot(windowed_data_std);
% subplot(2,1,2);
% plot(windowed_data_std_mean);
% gui2 = figure(2);
% set(gui2, 'Position', [1,1,Screensize(3)/2,Screensize(4)]);
% movegui(gui2,'east');
% subplot(3,1,1);
% bar(double(windowed_data_std_mean>12));
% subplot(3,1,2);
% bar(double(windowed_data_std_mean>10));
% subplot(3,1,3);
% bar(double(windowed_data_std_mean>8));
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
for chn = 1 : channel
    %% Gaussian Mixture Distribution
    fignum = chn;
    figure(fignum);
    clf(chn);
    % Set Initial Condition
    Sigma(:,:,1) = 100;
    Sigma(:,:,2) = 5;
    initialOption = struct('mu',[20;100],'Sigma',Sigma,'ComponentProportion',[0.3,0.7]);
    % Tabulate it
    drawdata = windowed_data_std(:,chn)*10; %To increased tabulation resolution, multiply by 10
    tabulated = tabulate(round(drawdata)); 
    bar(tabulated(:,1),tabulated(:,3)/100,'FaceColor','k');
    hold on;
    GMModel = fitgmdist(drawdata(:,1),2);
    plot(tabulated(:,1),pdf(GMModel,tabulated(:,1)),'Color','r','LineWidth',1);
    axis([0,300,0,0.025]);
end
