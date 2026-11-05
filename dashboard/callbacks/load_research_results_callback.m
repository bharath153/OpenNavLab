function load_research_results_callback(fig)
%LOAD_RESEARCH_RESULTS_CALLBACK Load Monte Carlo and/or sensitivity results.
    if isempty(fig) || ~isvalid(fig), return; end
    [file,path]=uigetfile({'*.mat;*.csv','Research results (*.mat, *.csv)'},'Select OpenNavLab research results');
    if isequal(file,0), return; end
    try
        incoming=adapt_research_results(fullfile(path,file));
        app=fig.UserData;
        if isfield(incoming,'mc'), app.Research.mc=incoming.mc; end
        if isfield(incoming,'sensitivity'), app.Research.sensitivity=incoming.sensitivity; end
        fig.UserData=app;
        refresh_research_pages(fig);
        app=fig.UserData;
        app.Footer.Message.Text=['Research results loaded: ' file];
        fig.UserData=app;
    catch ME
        uialert(fig,ME.message,'Could not load research results','Icon','error');
    end
end
