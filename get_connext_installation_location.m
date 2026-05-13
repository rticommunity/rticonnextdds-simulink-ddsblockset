%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  (c) 2026 Copyright, Real-Time Innovations, Inc. (RTI) All rights reserved. %
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
function installedLocation = get_connext_installation_location(version)
    % GET_CONNEXT_INSTALLATION_LOCATION returns the RTI Connext DDS installation
    % path for a given version, computed dynamically from the location of
    % this script.
    %
    %   installedLocation = get_connext_installation_location('6.1.2')
    %
    % The current OS is detected internally to build the correct path.
    %
    % The Add-On layout expected on disk is:
    %   <Toolboxes>/
    %     <This toolbox>/           <- folder containing this script
    %     Additional Software/
    %       <3rdPartyFolder>/       <- e.g. RTIConnextDDS6_1_2_Windows
    %         <ConnextFolder>/      <- e.g. rti_connext_dds-6.1.2
    %
    % 3rdPartyFolder derivation:
    %   version '6.1.2'  +  OS 'Windows'  =>  'RTIConnextDDS6_1_2_Windows'
    %   Replace '.' with '_' in version, prepend 'RTIConnextDDS', append '_<OS>'
    %
    % ConnextFolder derivation:
    %   'rti_connext_dds-' + version  =>  'rti_connext_dds-6.1.2'

    % Detect OS
    if ismac
        osLabel = 'MacOS';
    elseif isunix
        osLabel = 'Linux';
    elseif ispc
        osLabel = 'Windows';
    else
        error('get_connext_installation_location: unsupported operating system.');
    end

    % Locate the 'Additional Software' folder relative to this script
    scriptDir             = fileparts(mfilename('fullpath'));
    additionalSoftwareDir = fullfile(scriptDir, '..', 'Additional Software');

    % 3rdPartyFolder: e.g. 'RTIConnextDDS6_1_2_Windows'
    thirdPartyFolder     = 'RTIConnextDDS' + strrep(version, '.', '_') + '_' + osLabel;
    thirdPartyFolderPath = fullfile(additionalSoftwareDir, thirdPartyFolder);

    if ~isfolder(thirdPartyFolderPath)
        error('get_connext_installation_location: Add-On folder not found: %s', ...
              thirdPartyFolderPath);
    end

    % ConnextFolder: e.g. 'rti_connext_dds-6.1.2'
    connextFolder = 'rti_connext_dds-' + version;

    installedLocation = char(java.io.File(fullfile(thirdPartyFolderPath, connextFolder)).getCanonicalPath());

    if ~isfolder(installedLocation)
        error('get_connext_installation_location: Connext installation not found: %s', ...
              installedLocation);
    end
end
