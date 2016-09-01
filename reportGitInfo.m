function reportGitInfo()
    %Report Current Version info
    gitInfo = getGitInfo;
    fprintf('Version: %s - %s\n',gitInfo.branch, gitInfo.hash);
    fprintf('Host: %s\n',gitInfo.url);
end