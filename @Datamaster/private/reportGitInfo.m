function reportGitInfo()
    %Report Current Version info
    gitInfo = getGitInfo(Datamaster.getPath);
    if ~isempty(gitInfo)
    	fprintf('Version: %s - %s\n',gitInfo.branch, gitInfo.hash);
    	fprintf('Host: %s\n',gitInfo.url);
    else
    	warning('You are not using git and will miss out on the latest updates');
    end
end