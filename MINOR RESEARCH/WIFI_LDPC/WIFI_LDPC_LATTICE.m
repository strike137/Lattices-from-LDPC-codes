% run_WiFi_LDPC with Lattice Decoding and WER vs. VNR
clear all;

% Simulation Parameters
max_runs = 100;
max_decode_iterations = 20;
n_0 = 1/2;

block_length = ;
rate = 1/2;

constellation_name = 'bpsk';
modulation = Constellation(constellation_name);

ebno_db_vec = -3:0.1:3;
num_word_err = zeros(length(ebno_db_vec), 1);
vnr_values_db = zeros(length(ebno_db_vec), 1);

ldpc_code = LDPCCode(0, 0);
ldpc_code.load_wifi_ldpc(block_length, rate);
info_length = ldpc_code.K;

% Main Simulation Loop
for i_run = 1:max_runs
    noise = sqrt(n_0) * randn(block_length/modulation.n_bits, 1);
    info_bits = rand(info_length, 1) < 0.5;
    coded_bits = ldpc_code.encode_bits(info_bits);
    
    for i_snr = 1:length(ebno_db_vec)
        snr_db = ebno_db_vec(i_snr);
        snr = 10^(snr_db/10);
        y = coded_bits + noise/sqrt(snr);

        % Lattice Decoding
        y_prime = mod(y + 1, 2) - 1;
        llr = modulation.compute_llr(y_prime, n_0/snr); % Compute LLR
        decoded_bits = ldpc_code.decode_llr(llr, max_decode_iterations, 1); % LDPC Decode
        y_double_prime = (y - decoded_bits) / 2;
        z = round(y_double_prime);
        lattice_point = decoded_bits + 2*z;

        % Calculate Word Errors
        word_errors = sum(info_bits ~= lattice_point(1:info_length)) > 0;
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