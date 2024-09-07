% Load data from each file and plot
data_files = {'k=324.mat', 'k=432.mat', 'k=486.mat', 'k=540.mat'};
labels = {'k = 324', 'k = 432', 'k = 486', 'k = 540'};

% Initialize figure
figure;
hold on;

for i = 1:length(data_files)
    load(data_files{i}, 'vnr_db_vec', 'wer');
    
    % Set any zero WER values to a small number to avoid issues with log scale
    wer(wer == 0) = 1e-10;  % Replace 0 values with a small number
    
    semilogy(vnr_db_vec, wer, 'o-', 'DisplayName', labels{i});
end

xlabel('VNR (dB)');
ylabel('WER');
title('WER vs. VNR for WiFi LDPC with Construction A');
grid on;
legend show;
ylim([1e-20 1]);  

hold off;
