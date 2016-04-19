%% Fixed Variables
NUM_DAY = 7;
NUM_CHANNEL = 8;
GMM_Replicates = 10000;
%% Load Group Data
[filename, pathname] = uigetfile('.mat');
Path=strcat(pathname,filename);
load(Path);
%% Create Secondary Data
calculated_data_size = zeros(1,NUM_DAY);
windowed_data_std = cell(1,NUM_DAY);
for day = 1 : NUM_DAY
    calculated_data_size(day) = size(data{day},1) - rem(size(data{day},1),300);
    data{day} = data{day}(:,2:end);
    windowed_data_std{day} = zeros(calculated_data_size(day) / 300,NUM_CHANNEL);
    for i = 300:300:calculated_data_size(day)
        windowed_data_std{day}(i/300,:) = std(data{day}(i-300+1:i,:),1);
    end
end
clear day mouse i;
%% Draw Raw Data
figure('Name','Raw Data','NumberTitle','off');
for day = 1 : NUM_DAY
    for mouse = 1 : NUM_CHANNEL
        subplot(8,7,7*(mouse-1) + day);
        plot(data{day}(:,mouse));
        axis([0,432000,0,600]);
    end
end
%% Draw Secondary Data
figure('Name','SD Data','NumberTitle','off');
for day = 1 : NUM_DAY
    for mouse = 1 : NUM_CHANNEL
        subplot(8,7,7*(mouse-1) + day);
        plot(windowed_data_std{day}(:,mouse));
        axis([0,1440,0,40]);
    end
end
%% Draw Tertiary Data Tabulated Data
figure('Name','Histogram','NumberTitle','off');
% GMM_data = struct(...
%     'NumIteration', [],...
%     'mu', cell(8,7),...
%     'ComponentProportion', cell(8,7)...
%     );
GMM_data.NumIteration = zeros(8,7);
GMM_data.mu = cell(8,7);
GMM_data.ComponentProportion = cell(8,7);
for day = 1 : NUM_DAY
    for mouse = 1 : NUM_CHANNEL
        drawdata = windowed_data_std{day}(:,mouse)*10; %To increased tabulation resolution, multiply by 10
        tabulated = tabulate(round(drawdata));
        subplot(8,7,7*(mouse-1) + day);
        bar(tabulated(:,1),tabulated(:,3)/100,'FaceColor','k');
        hold on;
       %% Generate GMM & Plot
        GMModel = fitgmdist(drawdata(:,1),2,'Replicates',GMM_Replicates,'Options',statset('MaxIter',1000));
        GMM_data.NumIteration(mouse,day) = GMModel.NumIterations;
        if GMModel.mu(1) <= GMModel.mu(2)
            GMM_data.mu1(mouse,day) = GMModel.mu(1);
            GMM_data.mu2(mouse,day) = GMModel.mu(2);
            GMM_data.ComponentProportion1(mouse,day) = GMModel.ComponentProportion(1);
            GMM_data.ComponentProportion2(mouse,day) = GMModel.ComponentProportion(2);
        else
            GMM_data.mu1(mouse,day) = GMModel.mu(2);
            GMM_data.mu2(mouse,day) = GMModel.mu(1);
            GMM_data.ComponentProportion1(mouse,day) = GMModel.ComponentProportion(2);
            GMM_data.ComponentProportion2(mouse,day) = GMModel.ComponentProportion(1);
        end 
        plot(tabulated(:,1),pdf(GMModel,tabulated(:,1)),'Color','r','LineWidth',1.5);
        axis([0,300,0,0.05]);
        fprintf('%d %% complete...... \n',round((8*(day-1) + mouse)/(NUM_CHANNEL*NUM_DAY)*100));
    end
end
%% Draw Tertiary Data (Gaussian Mixture Model)


%% GCA  configuration
