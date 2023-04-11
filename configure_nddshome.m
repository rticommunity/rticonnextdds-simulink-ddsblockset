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
function configure_nddshome()
    % CONFIGURE_NDDSHOME set NDDSHOME to the corresponding version if
    % it is not already set.
    %   configure_nddshome() configure NDDSHOME to the corresponding
    %   installation path RTI Connext DDS
    connextVersion = "6.1.2";

    if isMATLABReleaseOlderThan('R2023a')
        supportedVersions = ["6.0.1"];
    else
        supportedVersions = ["6.1.0", "6.1.1", "6.1.2"];
    end

    configure_nddshome_w_version(connextVersion, supportedVersions);
end

function configure_nddshome_w_version(version, supportedVersions)
    % CONFIGURE_NDDSHOME_W_VERSION set NDDSHOME to the specific version if
    % it is not already set.
    %   configure_nddshome("6.0.1") configure NDDSHOME to RTI Connext 6.0.1

    connextPath = get_rti_connext_dds_path(version);

    nddshomePath = string(getenv("NDDSHOME"));
    % If NDDSHOME is already set, check it points to a supported version
    if nddshomePath ~= ""
        if is_rti_connext_dds_version_supported(nddshomePath,...
                supportedVersions) == false
            % NDDSHOME is not set to a supported version. In case it is set
            % to a supported version, do not set it again to the RTI
            % Connext for DDS Blockset toolbox
            productSupportedVersions = "";
            for i = 1:length(supportedVersions)
                productSupportedVersions = productSupportedVersions +...
                        " - RTI Connext DDS " + supportedVersions{i};
                if i ~= length(supportedVersions)
                    productSupportedVersions =...
                            productSupportedVersions + newline;
                end
            end

            warning(['NDDSHOME environment variable is not set ',...
                    'to a supported version for MATLAB/DDS Blockset. ',...
                    'Supported Connext versions for MATLAB %s:\n',...
                    '%s'],...
                matlabRelease.Release,...
                productSupportedVersions);
        end
    else
        % Set NDDSHOME to the latest installed RTI Connext for DDS Blockset
        % toolbox
        if exist(connextPath, "dir")
            setenv("NDDSHOME", connextPath);
        else
            error("Error setting NDDSHOME, the path <%s> doesn't exist",...
                connextPath);
        end
    end
end

function ok = is_rti_connext_dds_version_supported(nddshome, supported_versions)
    % IS_RTI_CONNEXT_DDS_VERSION_SUPPORTED check whether the current
    % nddshome is pointing to a supported version
    %   is_rti_connext_dds_version_supported() return true if that nddshome
    %   is supported

    ok = false;
    for i = 1:length(supported_versions)
        if contains(nddshome, strcat('rti_connext_dds-',supported_versions{i}))
            ok = true;
        end
    end
end

function connextPath = get_rti_connext_dds_path(version)
    % GET_RTI_CONNEXT_DDS_PATH return the path to the corresponding
    % RTI Connext DDS installation.
    %   connextPath = get_rti_connext_dds_path("6.0.1") returns the
    % RTI Connext DDS installation folder of the specific version (6.0.1).
    packageName = append("RTI Connext DDS ", version);

    if ismac
        connextPath = rticonnextdds_simulink_ddsblockset.getInstallationLocation(...
                packageName + " - MacOS");
    elseif isunix
        connextPath = rticonnextdds_simulink_ddsblockset.getInstallationLocation(...
                packageName + " - Linux");
    elseif ispc
        connextPath = rticonnextdds_simulink_ddsblockset.getInstallationLocation(...
                packageName + " - Windows");
    else
        error('Unsupported OS');
    end
end