% Simulation settings
max_runs = 10000;  % Number of simulation runs
max_decode_iterations = 20;  % Maximum number of decoding iterations

block_length = 648;  % Block length
rate = 3/4;  % Code rate
p = 2;  % Example prime number for Construction A
ldpc_code = LDPCCode(block_length, rate, p);  % Create LDPC object
min_sum = 1;  % Min-sum algorithm flag

% setting VNR range
vnr_db_vec = 0:0.25:5;  % VNR range in dB

% save data
data_file = 'simulation_data.mat';

% Initialize variables for storing word error counts
num_word_err = zeros(length(vnr_db_vec), 1);

tic  % Start timer

ldpc_code.load_wifi_ldpc(block_length, rate);  % Load WiFi LDPC code parameters
ldpc_code.generate_construction_A(p);  % Apply Construction A

info_length = ldpc_code.K;  % Information length

% Simulation loop
for i_vnr = 1:length(vnr_db_vec)
    vnr_lin = 10^(vnr_db_vec(i_vnr) / 10);  % Convert VNR from dB to linear scale
    VL = 2^((1 - rate) * block_length);
    n_0 = (VL^(2/block_length)) / (2 * pi * exp(1) * vnr_lin);  % Calculate n_0 based on VNR

    for i_run = 1:max_runs
        if (mod(i_run, max_runs/10) == 1)
            disp(['Current run = ', num2str(i_run), ' percentage complete = ', num2str((i_run-1)/max_runs * 100), '%', ' time elapsed = ', num2str(toc), ' seconds']);
        end

        % Generate noise and random information bits
        noise = sqrt(n_0) * randn(block_length, 1);  % Generate Gaussian noise
        info_bits = rand(info_length, 1) < 0.5;  % Generate random information bits
        
        % LDPC encoding using Construction A
        c = ldpc_code.encode_construction_A(info_bits);  % LDPC encoding
        z = randi([-20 20], length(c), 1);  % Generate random integer vector z
        x = c + 2 * z;  % Calculate transmitted signal x (no modulation)

        % Transmit over the channel (add noise)
        y = x + noise;  % Add noise to the transmitted signal
        
        % Apply mod-star function to received signal
        y_prime = abs(mod(y + 1, 2) - 1);  % Apply mod-star function
        
        % Calculate LLRs based on y_prime
        LLR = (1 - 2 * y_prime) / (2 * n_0);  % Compute LLRs using n_0
        
        % LDPC decoding using the LLR values and construction A decoding
        [chat, zhat, xhat] = ldpc_code.decode_constructionA(LLR, y, max_decode_iterations, min_sum);  % Decode the LLR values
        
        % Compare xhat with x to detect errors
        if any(xhat ~= x)  % Compare the decoded xhat with the transmitted x
            num_word_err(i_vnr) = num_word_err(i_vnr) + 1;  % Increment word error count if errors are found
        end
    end
end

% Calculate WER (Word Error Rate)
wer = num_word_err / max_runs;

% Save the simulation data to a file
save(data_file, 'vnr_db_vec', 'wer');  % Save VNR and WER data

% Separate plotting program can load the data and plot the graph


