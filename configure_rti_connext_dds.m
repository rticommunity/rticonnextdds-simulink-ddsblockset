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

function configure_rti_connext_dds()
    % CONFIGURE_RTI_CONNEXT_DDS configures all necessary stuff to use
    % RTI Connext DDS with MATLAB/Simulink.
    %   configure_rti_connext_dds() configures RTI Connext DDS

    add_configure_nddshome_startup();
    configure_nddshome();

    version = "6.0.1";
    % NDDSHOME is set in configure_nddshome() to a supported version
    connextPath = string(getenv("NDDSHOME"));
    shortcutName = append("RTI Launcher ", version);
    create_rti_launcher_shortcut(shortcutName, connextPath, version);

    move_license_file(connextPath)
end

function move_license_file(connextPath)
    % MOVE_LICENSE_FILE move the license file from its corresponding
    % dependency to RTI Connext DDS dependency
    %   move_license_file() move the corresponding RTI Connext DDS license

    licensePath = rticonnextdds_simulink_ddsblockset.getInstallationLocation(...
                "RTI Connext DDS - License");
    outputLicenseFilePath = append(connextPath, "/rti_license.dat");

    if isfile(outputLicenseFilePath)
        warning(['The license file <%s> already exists. Therefore, ',...
                'a new license file won''t be copied.\n'],...
            outputLicenseFilePath);
    else
        % There is not license, so it gets copied
        licenseFilePath = append(licensePath, "/rti_license.dat");
        if isfile(licenseFilePath)
            movefile(licenseFilePath,connextPath);
        else
            warning('No license file under <%s>.\n', licenseFilePath);
        end
    end
end

function add_configure_nddshome_startup()
    % ADD_CONFIGURE_NDDSHOME_STARTUP add if needed the configuration of
    % NDDSHME environment variable to the user's startup file.
    %   add_configure_nddshome_startup() add if needed the configuration of
    %   NDDSHOME to the startup file

    startupFile = fullfile(userpath, 'startup.m');

    % Check whether NDDSHOME is already configured
    startupText = "";
    if isfile(startupFile)
        f = fopen(startupFile, 'rt');
        if f == -1
            error("Error opening <%s> file.", startupFile);
        end

        startupText = convertCharsToStrings(fread(f, '*char'));
        fclose(f);
    end

    % If NDDSHOME is not configured in the startup script, add it
    if ~contains(startupText, "configure_nddshome")
         textToAdd = sprintf([
                '\n%% Configure NDDSHOME to use RTI Connext for DDS Blockset \n',...
                'if exist("configure_nddshome", "file") == 2\n',...
                '    configure_nddshome();\n',...
                'end\n']);

        f = fopen(startupFile, 'at');
        if f == -1
            error("Error opening <%s> file.\n", startupFile);
        end

        fprintf(f, '%s', textToAdd);
        fclose(f);
    end
end

function create_rti_launcher_shortcut(shortcutName, connextPath, version)
    % CREATE_RTI_LAUNCHER_SHORTCUT Creates a desktop shortcut to
    % RTI Launcher independently of the OS.
    %   create_rti_launcher_shortcut(shortcutName, connextPath, "6.0.1")
    %       Creates a shortcut called shortcutName, pointing to connextPath
    %       for the RTI Connext DDS version 6.0.1

    if ~exist(connextPath, "dir")
        error(['Error creating RTI Launcher shortcut, ',...
             'the folder <%s> doesn''t exist.\n'], connextPath);
    end

    if ismac
        create_rti_launcher_shortcut_mac(shortcutName, connextPath);
    elseif isunix
        create_rti_launcher_shortcut_linux(shortcutName, connextPath, version);
    elseif ispc
        create_rti_launcher_shortcut_win(shortcutName, connextPath);
    else
        error("Unsupported OS.");
    end
end

function create_rti_launcher_shortcut_win(shortcutName, connextPath)
    % CREATE_RTI_LAUNCHER_SHORTCUT_WIN Creates a desktop shortcut to
    % RTI Launcher for Windows.
    %   create_rti_launcher_shortcut(shortcutName, connextPath)
    %       Creates a shortcut called shortcutName, pointing to connextPath


    % Run create_connext_shortcut script to create a desktop shortcut
    toolboxPath = regexprep(...
            mfilename('fullpath'),...
            '(.+)\\configure_rti_connext_dds',...
            '$1\\');
    system(append(...
            '"', toolboxPath, 'bin\create_rti_launcher_shortcut.bat" ',...
            '"', shortcutName, '" ',...
            '"', connextPath, '"'));
end

function create_rti_launcher_shortcut_linux(shortcutName, connextPath, version)
    % CREATE_RTI_LAUNCHER_SHORTCUT_LINUX Creates a desktop shortcut to
    % RTI Launcher for Linux.
    %   create_rti_launcher_shortcut(shortcutName, connextPath, "6.0.1")
    %       Creates a shortcut called shortcutName, pointing to connextPath
    %       for the RTI Connext DDS version 6.0.1

    % Create the .desktop file
    unixShortcut = sprintf([ ...
            '[Desktop Entry]\n',...
            'Version=%s\n',...
            'Name=RTI Launcher\n',...
            'GenericName=RTI Launcher\n',...
            'Exec="%s/bin/rtilauncher" %%f\n',...
            'Terminal=false\n',...
            'Hidden=false\n',...
            'Icon=%s/resource/app/app_support/launcher/icons/RTI_Launcher_Dock-Icon_256x256.png\n',...
            'Type=Application\n',...
            'Categories=Development\n',...
            'MimeType=application/rti-package\n\n',...
            'Name[en_US]=%s'],...
    version,... %version
    connextPath,... %exec
    connextPath,...
    shortcutName); %Name[en_US]

    launcherPath = append(connextPath, "/rtilauncher.desktop");

    f = fopen(launcherPath , 'wt');
    if f == -1
        error("Error opening <%s> file.\n", launcherPath);
    end

    fprintf(f, '%s', unixShortcut);
    fclose(f);

    launcherPath = strrep(launcherPath, ' ', '\ ');
    shortcutDesktopName = strrep(append(shortcutName, ".desktop"), ' ', '\ ');
    system(append("cp ", launcherPath, " ~/Desktop/", shortcutDesktopName));

    % make the shortcut a trusted application
    system(append('gio set ~/Desktop/', shortcutDesktopName, ' "metadata::trusted" yes'));
end

function create_rti_launcher_shortcut_mac(shortcutName, connextPath)
    % CREATE_RTI_LAUNCHER_SHORTCUT_MAC Creates a desktop shortcut to
    % RTI Launcher for MacOS.
    %   create_rti_launcher_shortcut(shortcutName, connextPath)
    %       Creates a shortcut called shortcutName

    % escape spaces
    connextPath = strrep(connextPath, ' ', '\ ');
    shortcutName = strrep(shortcutName, ' ', '\ ');

    system(append("ln -s ", connextPath, "/RTI\ Launcher.app ~/Desktop/", shortcutName));
end
