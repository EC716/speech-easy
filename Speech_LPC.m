clear, close all, clc;

load('speech16k.mat'); %Replace with your audio data
fs = 16e3; % 16k samples/sec
x = getaudiodata(Speech16k,'double');
x = x / max(abs(x)); %normalize audio
%% optional - plot original signal (can help identify specific sections of speech)
figure;
plot(1/16 * (0:length(x)-1), x);
ms_tks = (0:8000:length(x)-1) / 16;
xticks(ms_tks)
%% Frame length of 30ms, hamm window w/ 50% overlap

frame_length = 30e-3 * fs;
overlap = frame_length/2;
win = hamming(frame_length);
start = 1;
numBlocks = ceil(length(x) / frame_length * 2);
%% ENCODE STEP - Calculation of a_k's and G's for each window
STS = cell(1,numBlocks-1); %Store short time sections for reference and later processing
STS_win = STS; %Also store windowed versions??

A = cell(2,numBlocks-1); %First row stores the 11 LPC coefficients; 2nd row stores G
A_win = A; %Windowed version of above
Residuals = cell(2,numBlocks-1);
P = 50;
for i = 1:numBlocks
    x_short = x(start : start+frame_length-1); %short time section of x (320-point signal)
    %x_short = x_short / max(abs(x_short));  % Normalize the signal to have max value 1
    STS{i} = x_short;
    STS_win{i} = x_short .* win;
    r = conv(x_short,flip(x_short));
    r = r(frame_length:frame_length + P);
    start = start + overlap - 1;
    [a, ~] = lpc(x_short, P);
    A{1,i} = a;
    G2 = sum(a'.* r);
    g = sqrt(G2); %gain factor
    A{2,i} = g;
    e = filter(a, 1, x_short);
    Residuals{1,i} = e;
    [a, ~] = lpc(x_short.*win,P);
    r = conv(x_short.*win, flip(x_short.*win));
    r = r(frame_length:frame_length + P);
    A_win{1,i} = a;
    G2 = sum(a' .* r);
    g = sqrt(G2); %gain factor for windowed version
    A_win{2,i} = g;
    e = filter(a, 1, x_short.*win);
    Residuals{2,i} = e;
end

%% DECODE STEP
x_hat = zeros(length(x),1);
x_hat_quant = x_hat;
segIdx = 1:frame_length;
quant = 3;
for i = 1:numBlocks-1
    excitation = Residuals{2,i};
    y = quantize_signal(excitation,quant);
    h = quantize_signal(A_win{1,i},16);
    x_hat(segIdx) = x_hat(segIdx) + filter(A_win{2,i},A_win{1,i},Residuals{2,i}).*win;
    x_hat_quant(segIdx) = x_hat_quant(segIdx) + filter(A_win{2,i},h,y).*win;
    segIdx = segIdx + overlap;
end
x_hat = x_hat / max(abs(x_hat));
x_hat_quant = x_hat_quant / max(abs(x_hat_quant)); % NORMALIZE

%% Compute TDFT of reconstructed signal for analysis
[s1, f1, t1] = spectrogram(x_hat, win, overlap, 512, fs); 
[s2, f2, t2] = spectrogram(x_hat_quant, win, overlap, 512, fs);
s1_dB = 10 *log10(abs(s1) + eps); % Convert magnitude to dB scale
s2_dB = 10 *log10(abs(s2) + eps);



figure;
subplot(2,2,1)
plot(0:length(x)-1,x_hat)
title(sprintf('reconstruct | P = %d',P))

subplot(2,2,3)
plot(0:length(x)-1,x_hat_quant)
title(sprintf('residual quantized to %d bits',quant))

subplot(2,2,2)
imagesc(t1, f1, s1_dB);
axis xy; % Correct orientation
colormap jet;
colorbar;
xlabel('Time (s)');
ylabel('Frequency (Hz)');

subplot(2,2,4)
imagesc(t2, f2, s2_dB);
axis xy; % Correct orientation
colormap jet;
colorbar;
xlabel('Time (s)');
ylabel('Frequency (Hz)');

comp_index = 61000:81500;

figure;
subplot(3,2,1)
plot(comp_index,x(comp_index))
title('Sample of Original Speech')

subplot(3,2,3)
plot(comp_index,x_hat(comp_index))
title('Reconstruction w/o Quantization')

subplot(3,2,5)
plot(comp_index,x_hat_quant(comp_index))
title('2-bit e[n] | 16-bit coefficients')

win = hamming(300);
overlap = 150;
[s0, f0, t0] = spectrogram(x(comp_index), win, overlap, 512, fs);
[s1, f1, t1] = spectrogram(x_hat(comp_index), win, overlap, 512, fs); 
[s2, f2, t2] = spectrogram(x_hat_quant(comp_index), win, overlap, 512, fs);
s0_dB = 10 *log10(abs(s0 + eps));
s1_dB = 10 *log10(abs(s1) + eps); % Convert magnitude to dB scale
s2_dB = 10 *log10(abs(s2) + eps);

subplot(3,2,2)
imagesc(t0, f0, s0_dB);
axis xy; % Correct orientation
colormap jet;
colorbar;
xlabel('Time (s)');
ylabel('Frequency (Hz)');

subplot(3,2,4)
imagesc(t1, f1, s1_dB);
axis xy; % Correct orientation
colormap jet;
colorbar;
xlabel('Time (s)');
ylabel('Frequency (Hz)');

subplot(3,2,6)
imagesc(t2, f2, s2_dB);
axis xy; % Correct orientation
colormap jet;
colorbar;
xlabel('Time (s)');
ylabel('Frequency (Hz)');

transmitSize = (numBlocks * quant * frame_length) + (P * numBlocks * 16);
compressionRate = transmitSize / (length(x)*16)