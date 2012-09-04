function newfun(filename,description)

if nargin < 1
    filename = '';
end

if nargin <2 
    description = '';
end

str = MSB_mfiletemplate('full',filename,description);

if nargout == 0
    % put the code into a new Editor buffer
    com.mathworks.mlservices.MLEditorServices.newDocument(str)
end







