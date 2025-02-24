%
%
%
function [result_vector,transcript] = wav2vec2_benchmark(input_audio,fs,truth_text)

% First, check that the input is only a 1-D vector. The deep learning model
% only takes in a single channel / mono input.
if ~isvector(input_audio)
    error("Only mono-channel audio supported. Please run one channel at a time");
end


transcript = speech2text(input_audio,fs);

result_vector = match_strings(transcript,truth_text);
end

