%% Init.
Screensize = get(groot, 'Screensize');
hold on;
%% Load Group Data
[filename, pathname] = uigetfile('*.txt','Load Labmil Data','MultiSelect', 'on');
Paths = strcat(pathname,filename); % Single Select : char, Multi Select : Cells of char
if (ischar(Paths)) % If Single Select => Change to Cell 
    Paths = {Paths};
    filename = {filename};
end
sizeOfDataSet = size(Paths,2);
data = cell(1,7); % cell by days
channel = cell(1,7); % probably all the same
for day = 1 : 7
    data{day} = load(Paths{day}); % data for one day
    data{day} = data{day}(:,2:end);
    channel{day} = size(data{day},2);
end
%% std_interval
%data window = 300 point = 1 minute
window = 300;
calculated_data_size = cell(1,7);
windowed_data_std = cell(1,7);
for day = 1 : 7
    calculated_data_size{day} = size(data{day},1) - rem(size(data{day},1),window);
    windowed_data_std{day} = zeros(calculated_data_size{day} / window,channel{day});
    for i = window:window:calculated_data_size{day}
        windowed_data_std{day}(i/window,:) = std(data{day}(i-window+1:i,:),1);
    end
end
%% Gaussian Mixture Distribution
subplot(4,7,1);
drawdata = cell(1,4);
numericData = zeros(4,7);
figure(1);
clf(1);
criterion = zeros(4,7);
Sigma(:,:,1) = 100;
Sigma(:,:,2) = 5;
initialOption = struct('mu',[20;100],'Sigma',Sigma,'ComponentProportion',[0.3,0.7]);
drawdata = windowed_data_std{day}(:,chan)*10;
tabulated = tabulate(round(drawdata));
bar(tabulated(:,1),tabulated(:,3)/100);
hold on;
% %% Multi Data Analysis
% for day = 1 : 7
%     for chan = 1 : 4
%         subplot(4,7,day+7*(chan-1));
%         drawdata = windowed_data_std{day}(:,chan)*10;
%         tabulated = tabulate(round(drawdata));
%         bar(tabulated(:,1),tabulated(:,3)/100);
%         hold on;
%         % GMModel = fitgmdist(drawdata,2,'Options',statset('MaxIter',1000),'Start',initialOption);            
%         GMModel = fitgmdist(drawdata,2,'Options',statset('MaxIter',1000),'Replicates',5000);
%         plot(tabulated(:,1),pdf(GMModel,tabulated(:,1)),'Color','r','LineWidth',1);
%         axis([0,300,0,0.025]);
%         firstPeakReached = false;
%         point = 0;
%         temp = pdf(GMModel,tabulated(:,1));
%         for x = 1 : size(tabulated,1)
%             if firstPeakReached ==false
%                 if point > temp(x,1) % Now Going Down
%                     firstPeakReached = true;
%                 end
%             else
%                 if point < temp(x,1) % Now Going Up Again
%                     criterion(chan,day) = x;
%                     break;
%                 end
%             end
%             point = temp(x,1);
%         end
%     end
%     fprintf('%d %% complete...... \n',round(4*day+chan/28*100));
% end
% figure(2);
% clf(2);
% for day = 1 : 7 
%     subplot(1,7,day);
%     drawdata_all = reshape(windowed_data_std{day}.*10,numel(windowed_data_std{day}),1);
%     tabulated = tabulate(round(drawdata_all));
%     bar(tabulated(:,1),tabulated(:,3)/100);
%     hold on;
%     GMModel = fitgmdist(drawdata_all,2,'Options',statset('MaxIter',1000));            
%     plot(tabulated(:,1),pdf(GMModel,tabulated(:,1)),'Color','r','LineWidth',1);
%     axis([0,300,0,0.025]);
% end
    
    