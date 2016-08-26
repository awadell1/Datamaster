function reportGitInfo()
    %Report Current Version info
    gitInfo = getGitInfo;
    fprintf('Current Version: %s\n',gitInfo.hash);
    fprintf('Host: %s\n',gitInfo.url);
end