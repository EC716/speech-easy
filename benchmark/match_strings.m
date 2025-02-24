function [result_vector,ambiguity_vector] = match_strings(test_text,truth_text)
% Now, try to do some matching of

% Next, sanitize the input truth text. Ideally, this should already be a
% string. But just in case, try taking a cell array of char/strings and
% convert into a
if iscell(truth_text)
    truth_vector = [];
    for idx = 1:length(truth_text)
        truth_vector = horztcat(tmp,strsplit(string(truth_text{idx}),' '));
    end
elseif ischar(truth_text) || (isstring(truth_text) && ~isvector(truth_text))
    truth_vector = strsplit(string(truth_text),' ');
else
    truth_vector = truth_text;
end
truth_vector = lower(truth_vector);

transcript_vector = strsplit(lower(test_text)," ");

% If the inputs are exactly equal, then just return all true.
if isequal(truth_vector,transcript_vector)
    result_vector = true(size(truth_vector));
    ambiguity_vector = ones(size(truth_vector));
    return;
end

result_vector = false(size(truth_vector));
ambiguity_vector = zeros(size(truth_vector));
matched_words = zeros(size(truth_vector));
% Otherwise try to do a slightly nuanced method
% First, find all the unique words (no repetitions)
[~,ia,ic] = unique(truth_vector,'stable');

% Next, go through each unique word
for baseIdx = ia.'
    % If there are multiple, then skip this word
    if sum(ic==baseIdx)>1
        continue;
    end

    matchIdx = find(strcmp(transcript_vector,truth_vector(baseIdx)),1,'first');
    if ~isempty(matchIdx)
        matched_words(baseIdx) = matchIdx;
        result_vector(baseIdx)= true;
    end
end

% Next, go through each skipped word and look between found words
pending_matched_words = matched_words;
pending_result_vector = result_vector;
max_steps = 3;
for step = 1:max_steps
for baseIdx = 1:length(truth_vector)
    if matched_words(baseIdx)
        continue;
    end
    

    % Find the indices to search for
    if baseIdx == 1
        idx1 = 1;
        trueIdx1 = 1;
    else

        trueIdx1 = find(matched_words(1:baseIdx)~=0,1,'last');
        if isempty(trueIdx1)
            trueIdx1 = 1;
            idx1 = 1;
        else
            idx1 = matched_words(trueIdx1)+1;
        end
    end

    trueIdx2 = find(matched_words(baseIdx+1:end)~=0,1,'first');
    if isempty(trueIdx2)
        trueIdx2 = length(truth_vector);
        idx2 = length(transcript_vector);
    else
        trueIdx2 = trueIdx2+baseIdx;
        idx2 = matched_words(trueIdx2)-1;
    end

    % If we are not in final step, skip when there are duplicate words in
    % the region
    if step < max_steps
        if any(ic(trueIdx1+1:baseIdx-1)==ic(baseIdx)) || any(ic(baseIdx+1:trueIdx2-1)==ic(baseIdx))
            continue;
        end
    end

    matchIdx = find(strcmp(transcript_vector(idx1:idx2),truth_vector(baseIdx)),1,'first');
    matchIdx = matchIdx +idx1-1;
    if ~isempty(matchIdx)
        pending_matched_words(baseIdx) = matchIdx;
        pending_result_vector(baseIdx)= true;
    end
end
end

% TODO: reject matches to the same test vector word
matched_words = pending_matched_words;
result_vector = pending_result_vector;
% At this point, all results are a binary and get binary ambiguity.
ambiguity_vector(result_vector) = 1;

% Last, go through each skipped word and look between found words
for baseIdx = 1:length(truth_vector)
    if matched_words(baseIdx)
        continue;
    end
    % Find the indices to search for
    % Find the indices to search for
    if baseIdx == 1
        idx1 = 1;
        trueIdx1 = 1;
    else

        trueIdx1 = find(matched_words(1:baseIdx)~=0,1,'last');
        if isempty(trueIdx1)
            trueIdx1 = 1;
            idx1 = 1;
        else
            idx1 = matched_words(trueIdx1)+1;
        end
    end

    trueIdx2 = find(matched_words(baseIdx+1:end)~=0,1,'first');
    if isempty(trueIdx2)
        idx2 = length(transcript_vector);
    else
        idx2 = matched_words(trueIdx2+baseIdx)-1;
    end
    test_char = '';
    truth_char = char(truth_vector(baseIdx));
    for ii  = idx1:idx2
        test_char = horzcat(test_char,char(transcript_vector(ii)));
        if length(test_char) >= length(truth_char)
            break;
        end
    end
    matched_words(baseIdx) = ii;
    ncmp = min(length(test_char),length(truth_char));

    ambiguity_vector(baseIdx) = sum(truth_char(1:ncmp)==test_char(1:ncmp))./length(truth_char);
end
end
