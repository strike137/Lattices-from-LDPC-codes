clear all;

% Simulation Parameters
max_runs = 100;
max_decode_iterations = 20;
n_0 = 1/2;

block_length = 648;
rate = 1/2;

ebno_db_vec = -3:0.1:5;
num_word_err = zeros(length(ebno_db_vec), 1);
vnr_values_db = zeros(length(ebno_db_vec), 1);

ldpc_code = LDPCCode(0, 0);
ldpc_code.load_wifi_ldpc(block_length, rate);
info_length = ldpc_code.K;

% Main Simulation Loop
for i_run = 1:max_runs
    noise = sqrt(n_0) * randn(block_length, 1);
    info_bits = rand(info_length, 1) < 0.5;
    coded_bits = ldpc_code.encode_bits(info_bits);
    
    for i_snr = 1:length(ebno_db_vec)
        snr_db = ebno_db_vec(i_snr);
        snr = 10^(snr_db/10);
        y = coded_bits + noise/sqrt(snr);

        % Lattice Decoding
        llr = 2*y/(n_0/snr);
        decoded_bits = ldpc_code.decode_llr(llr, max_decode_iterations, 1); % LDPC Decode

        % Calculate Word Errors
        word_errors = sum(info_bits ~= decoded_bits) > 0;
        num_word_err(i_snr) = num_word_err(i_snr) + word_errors;

        % Calculate VNR
        vnr_linear = snr * (block_length/info_length);
        vnr_values_db(i_snr) = 10 * log10(vnr_linear);
    end
end

% Calculate WER
wer = num_word_err / max_runs;

% Plot WER vs. VNR
figure;
semilogy(vnr_values_db, wer, 'o-');
xlabel('VNR (dB)');
ylabel('WER');
title('WiFi LDPC with Lattice Decoding: WER vs VNR');
grid on;