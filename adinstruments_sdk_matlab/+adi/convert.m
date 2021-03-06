function save_path = convert(file_path_or_paths,varargin)
%
%   adi.convert(*file_path,varargin)
%
%   This function will save a .adicht file's contents into a .mat file 
%   (v7.3) or a hdf5 file
%
%   The format is a bit awkward since it was originally written using a
%   32bit SDK which meant that partial reads and writes needed to be
%   supported.
%
%   Once converted, the converted file can be read by this program as well.
%
%   Current Status:
%   ---------------
%   Things are working however the HDF5 format will likely change soon as I
%   develop my HDF5 Matlab library:
%       https://github.com/JimHokanson/hdf5_matlab
%
%   Optional Inputs:
%   ----------------
%   file_path_or_paths : str or cellstr (default: prompts user)
%       Path to the file or files. If omitted a prompt will ask the user 
%       to select the file to convert.
%   format : {'h5','mat'} (default 'mat')
%       The format to convert the file to. H5 (HDF5) requires additional
%       code, located at:
%           https://github.com/JimHokanson/hdf5_matlab
%   conversion_options: {.h5_conversion_options,.mat_conversion_options}
%       These classes provide access to the conversion options. The main 
%       point of these options (at least initially) was to have control
%       over options that impact how fast the data is written (and then
%       subsequently written)
%
%   See Also:
%   adi.h5_conversion_options
%   adi.h5_mat_conversion_options

persistent base_path

in.conversion_options = [];
in.format = 'mat'; %or 'h5'
in.save_path = '';
in = adi.sl.in.processVarargin(in,varargin);

if in.format(1) == '.'
    in.format(1) = [];
end
   
if nargin == 0 || isempty(file_path_or_paths)
    
    [file_path_or_paths,file_root] = adi.uiGetChartFile('prompt','Pick a file to convert','start_path',base_path,'multi_select',true);
    
    if isnumeric(file_path_or_paths)
        return
    end
    
    base_path = file_root;
    
else
    if ischar(file_path_or_paths)
        base_path = fileparts(file_path_or_paths);
    else
        base_path = fileparts(file_path_or_paths{1});
    end
end

for iFile = 1:length(file_path_or_paths)

    cur_file_path = file_path_or_paths{iFile};
    
    file_obj = adi.readFile(cur_file_path);

    switch in.format
        case 'h5'
            %adi.file.exportToMatFile
            save_path = file_obj.exportToHDF5File(in.save_path,in.conversion_options);
        case 'mat'
            %adi.file.exportToMatFile
            save_path = file_obj.exportToMatFile(in.save_path,in.conversion_options);
        otherwise
            error('Unrecognized format option: %s',in.format);
    end

end