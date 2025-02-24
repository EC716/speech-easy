% Startup script for initializing expected subfolders
% This will run when MATLAB is started from this folder.
% Alternatively, run startup.m to add the project folders to the path.
if exist("asr-wav2vec2-librispeech.mat",'file')
    printf("Found speech model on path. Using:\n%s\n",which("asr-wav2vec2-librispeech.mat"))
elseif isfile(fullfile("asr-wav2vec2-librispeech","asr-wav2vec2-librispeech.mat"))
    addpath("asr-wav2vec2-librispeech\")
else
    warning("Expected speech model under %s.\nNo Speech model is available for benchmarking. Please see the README on download instructions.",fullfile(pwd,"asr-wav2vec2-librispeech"))
end

addpath("benchmark\");