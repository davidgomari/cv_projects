function DTMF_function()

myfile = 'data.mat';
S = load(myfile);
data = S.Signal1;

Fs = 44e3;
N = length(data);

low_freq_list = [697, 770, 852, 941];
high_freq_list = [1209, 1336, 1477];

keys_list = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#'];

% Used for slicing the sound
start_num = 1;
end_num = 1;

i = 0;

string_number = "";
while i < N-1

    % Skipping Silent times & Find the next beep
    for i = end_num+1:1:N-1
        if data(1,i) == 0 && data(1,i+1) ~= 0 && i>100
            end_num = i;
            break;
        end
        if i == N-1
            end_num = N;
            break;            
        end
    end
    
    % Time-Space to Frequency-Space
    Num_Data = end_num - start_num + 1;
    sub_data = data(1,start_num:end_num);
    y = fftshift(fft(sub_data,Num_Data));
    f = -Fs/2 : Fs/Num_Data : Fs/2-Fs/Num_Data;
    y = abs(y);
    
    % Find the Low-Frequency
    low_freq = 1;
    low_freq_index = 1;
    len_y = length(y);
    end_y = round((22000 + 1000)*len_y/44000)-1;
    low_freq_y = y(1, round(len_y/2):1:end_y);
    lf_f = f(1, round(len_y/2):1:end_y);
    [~,I] = max(low_freq_y);

    for j = 1:1:4 
        if abs(lf_f(1,I)-low_freq_list(1,j)) < 20
            low_freq = low_freq_list(1, j);
            low_freq_index = j;
            break;
        end
    end
    
    % Find the High-Frequency
    high_freq = 1;
    high_freq_index = 1;
    start_y = end_y;
    end_y = round((22000 + 1500)*len_y/44000)-1;
    high_freq_y = y(1, start_y:1:end_y);
    hf_f = f(1, start_y:1:end_y);
    [~,I] = max(high_freq_y);
    for j = 1:1:3 
        if abs(hf_f(1,I)-high_freq_list(1,j)) < 20
            high_freq = high_freq_list(1, j);
            high_freq_index = j;
            break;
        end
    end
    
    % Detecting the number
    index = 3 * (low_freq_index - 1) + high_freq_index;
    string_number = strcat(string_number, num2str(keys_list(1, index)));

    % Updating start position
    start_num = end_num+1;
end

disp(string_number);

end

