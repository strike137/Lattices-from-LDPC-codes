% Load data from each file and plot
data_files = {'k=324.mat', 'k=432.mat', 'k=486.mat', 'k=540.mat'};
labels = {'k = 324', 'k = 432', 'k = 486', 'k = 540'};

% Initialize figure with a specific size
figure;
set(gcf, 'Position', [100, 100, 800, 600]);  % Set figure size

hold on;

for i = 1:length(data_files)
    load(data_files{i}, 'vnr_db_vec', 'wer');
    
    % Set any zero WER values to a small number to avoid issues with log scale
    wer(wer == 0) = 1e-10;  % Replace 0 values with a small number
    
    % For k=432, exclude data points where VNR > 4.5
    if strcmp(data_files{i}, 'k=432.mat')
        mask = vnr_db_vec <= 4.2;  % Create mask for VNR values <= 4.5
        vnr_db_vec = vnr_db_vec(mask);  % Apply mask to VNR values
        wer = wer(mask);  % Apply mask to WER values
    end

    if strcmp(data_files{i}, 'k=540.mat')
        mask = vnr_db_vec <= 3.4;  % Create mask for VNR values <= 4.5
        vnr_db_vec = vnr_db_vec(mask);  % Apply mask to VNR values
        wer = wer(mask);  % Apply mask to WER values
    end
    % For k=432, exclude data points where VNR > 4.5
    if strcmp(data_files{i}, 'k=486.mat')
        mask = vnr_db_vec <= 3.6;  % Create mask for VNR values <= 4.5
        vnr_db_vec = vnr_db_vec(mask);  % Apply mask to VNR values
        wer = wer(mask);  % Apply mask to WER values
    end
    % For k=432, exclude data points where VNR > 4.5
    if strcmp(data_files{i}, 'k=324.mat')
        mask = vnr_db_vec <= 4.6;  % Create mask for VNR values <= 4.5
        vnr_db_vec = vnr_db_vec(mask);  % Apply mask to VNR values
        wer = wer(mask);  % Apply mask to WER values
    end
    
    % Plot with logarithmic scale for WER
    semilogy(vnr_db_vec, wer, 'o-', 'DisplayName', labels{i});
end

xlabel('VNR (dB)');
ylabel('WER');
title('WER vs. VNR for WiFi LDPC with Construction A');
grid on;
legend show;

% Set appropriate y-limits for the logarithmic scale
ylim([1e-5 1]);  % Adjust the limits based on the data range

% Set the Y-axis ticks manually to display powers of 10
yticks([1e-5 1e-4 1e-3 1e-2 1e-1 1]);

% Ensure that each tick has the same visual length on the log scale
set(gca, 'YScale', 'log', 'PlotBoxAspectRatio', [1 1 1]);

hold off;

% Adjust paper size and position for PDF export
set(gcf, 'PaperPositionMode', 'auto');  % Automatically adjust the paper size
print(gcf, 'output_graph', '-dpdf', '-r0');  % Export as PDF



