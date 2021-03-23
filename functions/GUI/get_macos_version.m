function macos_version = get_macos_version()
% return the version of MacOS as a string
if ~ismac
    macos_version = [];
    return;
end

[~,ver] = system('sw_vers');
rx = 'ProductVersion:\s*(.*)BuildVersion';
macos_version = regexp(ver,rx,'tokens');
macos_version = macos_version{1}{1}(1:2); %%% only return major version, i.e. 10.14, 10.15 etc
macos_version = str2double(macos_version);