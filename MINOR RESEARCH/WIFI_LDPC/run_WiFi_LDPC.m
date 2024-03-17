% run WiFi LDPC with BER Calculation
clear all;
% close all;
max_runs = 100;  % Number of simulation runs
max_decode_iterations = 20;  % Maximum number of decoding iterations
ldpc_code = LDPCCode(0, 0);  % LDPC code object
min_sum = 1;  % Min-sum algorithm flag
n_0 = 1/2;  % Noise power

block_length = 648;  % Block length, should be one of 648, 1296, or 1944
rate = 1/2;  % Code rate, should be one of 1/2, 2/3, 3/4, or 5/6

constellation_name = 'bpsk';  % Constellation name, should be 'bpsk', 'ask4', or 'ask8'
modulation = Constellation(constellation_name);  % Modulation object

ebno_db_vec = 1:0.1:4;  % Eb/N0 range in dB

% Initialize variables for storing bit error counts
num_bit_err = zeros(length(ebno_db_vec), 1);

tic  % Start timer

ldpc_code.load_wifi_ldpc(block_length, rate);  % Load WiFi LDPC code parameters
info_length = ldpc_code.K;  % Information length
disp(['Running LDPC with N = ', num2str(block_length), ' and rate = ' , num2str(rate), ' with constellation = ', constellation_name]);

% Calculate SNR vector based on Eb/N0 and modulation parameters
snr_db_vec = ebno_db_vec + 10*log10(info_length/block_length) + 10*log10(modulation.n_bits);

for i_run = 1 : max_runs
    if (mod(i_run, max_runs/10) == 1)
        disp(['Current run = ', num2str(i_run), ' percentage complete = ', num2str((i_run-1)/max_runs * 100), '%', ' time elapsed = ', num2str(toc), ' seconds']);
    end
    
    noise = sqrt(n_0) * randn(block_length/modulation.n_bits, 1);  % Generate noise
    info_bits = rand(info_length, 1) < 0.5;  % Generate random information bits
    coded_bits = ldpc_code.encode_bits(info_bits);  % Encode bits using LDPC
    scrambling_bits = (rand(block_length, 1) < 0.5);  % Generate scrambling bits
    scrambled_bits = mod(coded_bits + scrambling_bits, 2);  % Scramble encoded bits
    x = modulation.modulate(scrambled_bits);  % Modulate scrambled bits
    
    for i_snr = 1 : length(snr_db_vec)
        snr_db = snr_db_vec(i_snr);  % Current SNR in dB
        snr = 10^(snr_db/10);  % Convert SNR from dB to linear scale
        y = x + noise/sqrt(snr);  % Add noise to the signal
        
        [llr, ~] = modulation.compute_llr(y, n_0/snr);  % Compute log-likelihood ratios
        llr = llr .* (1 - 2 * scrambling_bits);  % De-scramble LLR
        
        [decoded_codeword, ~] = ldpc_code.decode_llr(llr, max_decode_iterations, min_sum);  % Decode LLR using LDPC
        
        % Calculate bit errors
        bit_errs = sum(decoded_codeword ~= coded_bits);
        num_bit_err(i_snr) = num_bit_err(i_snr) + bit_errs;  % Update bit error count for the current SNR
    end
end

% Calculate BER
ber = num_bit_err / (max_runs * block_length);

% Plot BER vs. Eb/N0
figure;
semilogy(ebno_db_vec, ber, 'o-');  % Plot BER using a semi-logarithmic scale
xlabel('Eb/N0 (dB)');
ylabel('BER');
title('BER vs. Eb/N0 for WiFi LDPC');
legend(constellation_name);
grid on;  % Enable grid





