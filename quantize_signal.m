function y = quantize_signal(x, bits)
    % Quantizes input signal x to the specified number of bits.
    
    % Inputs:
    %   x - Input signal (vector)
    %   bits - Number of quantization bits
    
    % Output:
    %   y - Quantized signal

    % Define quantization levels
    numLevels = 2^bits;
    
    % Find the min and max of x
    x_min = min(x);
    x_max = max(x);

    % Normalize x to [0,1] range
    x_norm = (x - x_min) / (x_max - x_min);
    
    % Apply uniform quantization
    x_quant = round(x_norm * (numLevels - 1)) / (numLevels - 1);
    
    % Scale back to original range
    y = x_quant * (x_max - x_min) + x_min;
end