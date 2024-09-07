% load data
load('k=540.mat');

% Plot WER vs. VNR
figure;
semilogy(vnr_db_vec, wer, 'o-');  % Plot WER using a semi-logarithmic scale
xlabel('VNR (dB)');
ylabel('WER');
title('Result graph of K = 540');
grid on;  % Enable grid
