function plot_freq_ratio(data, results, name, varargin)

[subplot_dims, v_field, data, results, name, time] = checkArgs(data, results, name, varargin{:});

colors = flipud(cool(length(data)));

gamma_freq_edges = 0:5:100;

freq_ratio_edges = 0:1:25;

figure

ha = tight_subplot(subplot_dims(1), subplot_dims(2));

for sp = 1:length(data)
   
    axes(ha(sp))
    
    [ax, h1, h2] = plotyy(time, data(sp).(v_field), time, results(sp).freq_ratio);
    
    %axis(ax, 'tight')
    
    set(ax, 'box', 'off')
    
    set(h1, 'LineWidth', 2)

    set(h2, 'Marker', '*')
    
    gamma_freq_hist(:, sp) = histc(results(sp).v_freqs, gamma_freq_edges);
    
    freq_ratio_hist(:, sp) = histc(results(sp).freq_ratio(time >= 500), freq_ratio_edges);
    
end

saveas(gcf, [name, '_V_freq_ratio.fig'])

figure

set(gca, 'FontSize', 20, 'NextPlot', 'add', 'ColorOrder', colors)

plot(gamma_freq_edges(2:end) - diff(gamma_freq_edges)/2, gamma_freq_hist(2:end, :)*diag(1./sum(gamma_freq_hist)), 'LineWidth', 2)

xlabel('Gamma Freq.'), ylabel('Proportion of Time')

% legend(my_legend)

box off

saveas(gcf, [name, '_gamma_freq_hist.fig'])

figure

set(gca, 'FontSize', 20, 'NextPlot', 'add', 'ColorOrder', colors)

plot(freq_ratio_edges(2:end) - diff(freq_ratio_edges)/2, freq_ratio_hist(2:end, :)*diag(1./sum(freq_ratio_hist)), 'LineWidth', 2)

xlabel('Gamma Freq./Theta Freq.'), ylabel('Proportion of Time')

% legend(my_legend)

box off

saveas(gcf, [name, '_freq_ratio.fig'])

end

function [subplot_dims, v_field, data, results, name, time] = checkArgs(data, results, name, varargin)

subplot_dims = [length(data), 1];

v_field = 'RS_V';

spike_field = 'RS_V_spikes';

input_field = 'RS_iPeriodicSpikes_input';

figure_flag = 0;

if ~isempty(varargin)
    
    for v = 1:(length(varargin)/2)
        
        switch varargin{2*v - 1}
            
            case 'subplot_dims'
                
                subplot_dims = varargin{2*v};
            
            case 'v_field'
                
                v_field = varargin{2*v};
            
            case 'spike_field'
                
                spike_field = varargin{2*v};
            
            case 'input_field'
                
                input_field = varargin{2*v};
                
            case 'figure_flag'
                
                figure_flag = varargin{2*v};
                
        end
        
    end
    
end

if isempty(results) && isempty(data)
    
    try
        
        results = dsImportResults(name);
        
        data = results;
        
    catch error
        
    end
    
    if isempty(results)
        
        data = dsImport(name);
        
        results = dsAnalyze(data, @freq_ratio, 'spike_field', spike_field,...
            'input_field', input_field);

        save([name, '_freq_ratio.mat'], 'results', 'name')
        
    end
    
elseif isempty(data) && ~isempty(results)
    
    data = results;
    
elseif isempty(results) && ~isempty(data)
    
    results = dsAnalyze(data, @freq_ratio, 'spike_field', spike_field,...
        'input_field', input_field);
    
    save([name, '_freq_ratio.mat'], 'results', 'name')
    
end

if isempty(data)
    
    data = dsImport(name);
    
end

if isfield(data(1), 'time')

    time = data(1).time;
    
%     tspan = time(end);
    
else
    
    sim_struct = load([name, '_sim_spec.mat'], 'sim_struct');
    
    sim_struct = sim_struct.sim_struct;
    
    tspan = sim_struct.tspan;
    
    tspan = tspan(end);
    
    time = 0:.01:tspan;
    
end

end