function plot_freq_ratio_by_variable(name, variable, varargin)

if nargin < 2, variable = []; end

if isempty(variable), variable = 'LTS_gSpike'; end

data = struct();
if nargin > 2
    for arg = 1:(length(varargin)/2)
        switch varargin{2*arg - 1}
            case 'data'
                data = varargin{2*arg};
        end
        
    end
end


if isempty(data)
    data = dsImport(name);
end
variable_vec = [data.(variable)];
variable_values = unique(variable_vec);

for i = 1:length(variable_values)
    
    figure_name = sprintf('%s_%s_%0.2g', name, variable, variable_values(i));
    
    plot_freq_ratio(data(variable_vec == variable_values(i)), [], figure_name)
    
    dsPlot(data(variable_vec == variable_values(i)), 'suppress_textstring', 1)
    
    saveas(gcf, [figure_name, '.fig'])

    save_as_pdf(gcf, figure_name)
    
end