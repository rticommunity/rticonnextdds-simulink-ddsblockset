%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  (c) 2021 Copyright, Real-Time Innovations, Inc. (RTI) All rights reserved. %
%                                                                             %
%  RTI grants Licensee a license to use, modify, compile, and create          %
%  derivative works of the software solely for use with RTI Connext DDS.      %
%  Licensee may redistribute copies of the software provided that all such    %
%  copies are subject to this license.                                        %
%  The software is provided "as is", with no warranty of any type, including  %
%  any warranty for fitness for any purpose. RTI is under no obligation to    %
%  maintain or support the software.  RTI shall not be liable for any         %
%  incidental or consequential damages arising out of the use or inability to %
%  use the software.                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function run_rti_launcher()
    % RUN_RTI_LAUNCHER run RTI Launcher. NDDSHOME environment variable should
    % be set. This is done at the startup script.
    %   run_rti_launcher() run RTI Launcher executable

    nddshomePath = string(getenv("NDDSHOME"));
    if nddshomePath == ""
        error("Error running RTI Launcher, NDDSHOME is not set.")
    end

    if ismac
        launcherPath = append(nddshomePath, "/RTI Launcher.app");
        if isfolder(launcherPath) % .app are represented as folders
            launcherPath = strrep(launcherPath, ' ', '\ ');
            system(append("open ", launcherPath));
        else
            error("Error running RTI Launcher, it doesn't exist.");
        end
    elseif isunix
        launcherPath = append(nddshomePath, "/bin/rtilauncher");
        if isfile(launcherPath)
            launcherPath = strrep(launcherPath, ' ', '\ ');
            system(append(launcherPath, " &"));
        else
            error("Error running RTI Launcher, it doesn't exist.");
        end
    elseif ispc
        launcherPath = append(nddshomePath, "/RTILauncher.exe");
        if isfile(launcherPath)
            system(launcherPath);
        else
            error("Error running RTI Launcher, it doesn't exist.");
        end
    else
        error('Unsupported OS');
    end
end