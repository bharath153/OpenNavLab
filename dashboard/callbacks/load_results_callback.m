function load_results_callback(fig)
%LOAD_RESULTS_CALLBACK Load an OpenNavLab MAT result into the dashboard.

    if isempty(fig) || ~isvalid(fig), return; end

    [file,path] = uigetfile('*.mat','Select OpenNavLab result MAT-file');
    if isequal(file,0), return; end

    fullName = fullfile(path,file);

    try
        data = adapt_opennavlab_results(fullName);
        apply_loaded_case(fig,data,sprintf('Loaded %s',file));
    catch ME
        uialert(fig,ME.message,'Could not load results','Icon','error');
    end
end
