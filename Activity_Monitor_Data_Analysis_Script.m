%   Activity Monitor Data Analysis Script
%   @Knowblesse 2015-06-04
%   @Last modified 2017-04-27
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Ver 1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Init.
clear;
clc;
close all;
hold on;

%% Variables
Screensize = get(groot, 'Screensize');
THRESHOLD = 6;

%% Load Group Data
[filename, pathname] = uigetfile('.txt', 'MultiSelect', 'on');
Paths = strcat(pathname,filename);
if (ischar(Paths))
    Paths = {Paths};
    filename = {filename};
end

numDay = size(Paths,2);
data = cell(1,numDay);
calculated_data_size = cell(1,numDay);
windowed_data_std = cell(1,numDay);
windowed_data_std_mean = cell(1,numDay);


for day = 1 : numDay
    data{day} = load(Paths{day});
    data{day} = data{day}(:,3:6); %의대 분석용으로 임시로 바꿈.
end

numChannel = size(data{1},2); % 첫날의 data를 기준으로 channel 수를 파악.
stat_activityLevel = zeros(numDay,numChannel);
stat_sleepRate = zeros(numDay,numChannel);

%duration = datestr((data(end,1) - data(1,1))/86400,'HH:MM:SS.FFF');
%msgbox({'Data successfully loaded.';['Channel Number : ', num2str(channel)];['Duration : ', num2str(duration)]});

%% 데이터 분석 시작.
for day = 1 : numDay
    %% SD 값 계산.
    %data window = 300 point = 1 minute
    window = 300;
    calculated_data_size{day} = size(data{day},1) - rem(size(data{day},1),window);
    windowed_data_std{day} = zeros(calculated_data_size{day} / window,numChannel);
    for i = window:window:calculated_data_size{day}
        windowed_data_std{day}(i/window,:) = std(data{day}(i-window+1:i,:),1);
    end
    clear i;
    windowed_data_std_mean{day} = mean(windowed_data_std{day} , 2);

%     %% Draw Raw Data + STD Data Graph
%     gui1 = figure('name','Raw Data');
%     set(gui1, 'Position', [1,1,Screensize(3)/2,Screensize(4)]);
%     movegui(gui1,'west');
%     subplot(2,1,1);
%     plot(windowed_data_std{day});
%     subplot(2,1,2);
%     plot(windowed_data_std_mean{day});
%     gui2 = figure('name','Sleep Wake Data');
%     set(gui2, 'Position', [1,1,Screensize(3)/2,Screensize(4)]);
%     movegui(gui2,'east');
%     for chn = 1 : numChannel
%         subplot(numChannel,1,chn);
%         title(['Day ', num2str(day), ' Channel ', num2str(chn)]);
%         bar(double(windowed_data_std{day}(:,chn) > THRESHOLD));
%     end
    %% Draw STD Data + Sleep Wake Graph
    [stddata_size,~] = size(windowed_data_std{day});
    gui2 = figure('name','Activity Level');
    set(gui2, 'Position', [1,1,Screensize(3),Screensize(4)]);
    for chn = 1:numChannel
        subplot(numChannel,1,chn);
        bar(4.*(windowed_data_std{day}(:,chn)<THRESHOLD));
        hold on;
        plot(windowed_data_std{day}(:,chn));
        title(['Day ', num2str(day), ' Sample ', num2str(chn)]);
        axis([0,stddata_size, 0, 40]);
    end
    saveas(gui2,['Day ', num2str(day),'.png'],'png');
    for chn = 1 : numChannel
        %% Gaussian Mixture Distribution
        fig_temp = figure('name',['GMM Model']);
        clf(fig_temp);
        % Set Initial Condition
        Sigma(:,:,1) = 100;
        Sigma(:,:,2) = 5;
        initialOption = struct('mu',[30;80],'Sigma',Sigma,'ComponentProportion',[0.3,0.7]);
        % Tabulate it
        drawdata = windowed_data_std{day}(:,chn)*10; %To increased tabulation resolution, multiply by 10
        tabulated = tabulate(round(drawdata)); 
        bar(tabulated(:,1),tabulated(:,3)/100,'FaceColor','k');
        hold on;
        GMModel = fitgmdist(drawdata(:,1),2,'Options',statset('MaxIter',1000));
        plot(tabulated(:,1),pdf(GMModel,tabulated(:,1)),'Color','r','LineWidth',1);
        axis([0,300,0,0.025]);
        title(['Day ' num2str(day), ' Sample ', num2str(chn)]);
        saveas(fig_temp,['Day ', num2str(day), ' Sample ',num2str(chn),'.png'],'png');
    end
    
    %% 통계 데이터 추출용
    stat_activityLevel(day,:) = mean(windowed_data_std{day},1);
    stat_sleepRate(day,:) = sum(windowed_data_std{day}<6,1);
end