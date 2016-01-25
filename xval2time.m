function [ time ] = xval2time( xval )
%   Video Plot Sync Time Calculator
%   @Knowblesse 2015-10-27
%   @Last modified 2015-10-27
%% Fixed Variables
start_time_hour = 6;
start_time_minute = 2;
start_time_second = 37;
%%
hour = floor(xval/(5*60*60));
min = floor((xval - (5*60*60)*hour)/(5*60));
second = (xval - (5*60*60)*hour - (5*60)*min)/5;

hour = start_time_hour + hour;
min = start_time_minute + min;
second = start_time_second + second;
if second >= 60
    min = min + 1;
    second = second - 60;
end
if min >= 60
    hour = hour + 1;
    min = min - 60;
end
if hour >= 12
    hour = hour -12;
end
time = [int2str(hour),' ½Ã : ', int2str(min), ' ºĞ : ', int2str(second), ' ÃÊ'];
end