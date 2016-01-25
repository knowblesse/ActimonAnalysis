function [ output ] = std_Interval( data, channel_number, window )
%   get std array for specific data window
%   divide data array into an array that has the size of "window". 
%   data over multiples of "window" is discarded.
%   
[data_size,~] = size(data);
calculated_data_size = data_size - rem(data_size,window);
result_array = zeros(calculated_data_size / window,channel_number);
for i = window:window:calculated_data_size
    result_array(i/window,:) = std(data(i-window+1:i,:),1);
end
output = result_array;

