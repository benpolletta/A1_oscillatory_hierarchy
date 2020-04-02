function simple_theta_gamma(theta_cycles, NMDA_tauD)

theta_freqs = 1./theta_cycles;

colors = flipud(cool(length(theta_cycles)));

time = 0:.001:3;
    
psp_time = -.5:.001:.5;

PV_tauD = .00015;
PV_psp = exp(-psp_time/PV_tauD);
PV_psp(psp_time <= 0) = 0;
    
% NMDA_tauD = .15;
NMDA_psp = exp(-psp_time/NMDA_tauD);
NMDA_psp(psp_time <= 0) = 0;

gPV = 5;
gNMDA = 5;

NMDA_edges = 0:.05:2;

gamma_freq_edges = 0:5:100;

freq_ratio_edges = 7:.25:13;

freq_scatter = figure;

figure

plot(0:.1:5, 60*real(sqrt((0:.1:5)/2)), 'LineWidth', 2)

set(gca, 'FontSize', 20)

xlabel('Input')

ylabel('Gamma Freq. (Hz)')

box off

for i = 1:length(theta_cycles)
    
    theta_spikes = mod(time,theta_cycles(i)) == 0;
    
    PV = conv(theta_spikes, PV_psp, 'same');
    
    NMDA = conv(theta_spikes, NMDA_psp, 'same');
    
    input = gNMDA*NMDA - gPV*PV;
    
    gamma_freq = 60*real(sqrt(input/2));
%     gamma_freq(input < .75) = nan;
    gamma_freq(mod(time, theta_cycles(i))/theta_cycles(i) <=.75) = nan;

    figure(freq_scatter)
    
    plot(theta_freqs(i)*ones(size(gamma_freq)), gamma_freq, '.', 'Color', colors(i, :))
    
    hold on
    
    % figure
    % plot(psp_time, [PV_psp; NMDA_psp])
    % figure
    % plot(time, [PV; NMDA])
    if i == round(length(theta_cycles)/2)
        figure
        [ax, h1, h2] = plotyy(time, input, time, gamma_freq);
        set(h1, 'LineWidth', 2)
        set(h2, 'LineWidth', 2)
        set(ax, 'FontSize', 20)
        %set(ax(1), 'YLabel', 'Input')
        %set(ax(2), 'YLabel', 'Gamma Freq. (Hz)')
        xlabel('Time (s)')
        box off
    end
        
    nmda_hist(:, i) = histc(NMDA, NMDA_edges);
    
    gamma_freq_hist(:, i) = histc(gamma_freq(~isnan(gamma_freq)), gamma_freq_edges);
    
    freq_ratio_hist(:, i) = histc(gamma_freq(~isnan(gamma_freq))/theta_freqs(i), freq_ratio_edges);
    
end

figure(freq_scatter)

set(gca, 'FontSize', 20)

box off

my_legend = cellfun(@(x) [num2str(x, '%.3g'), ' Hz \theta'], mat2cell(theta_freqs, 1, ones(1,9)), 'unif', 0);

legend(my_legend)

xlabel('Theta Freq.'), ylabel('Gamma Freq.')

saveas(gcf, 'theta_by_gamma.fig')

figure

set(gca, 'FontSize', 20, 'NextPlot', 'add', 'ColorOrder', colors)

plot(NMDA_edges(2:end) - diff(NMDA_edges)/2, nmda_hist(2:end, :)*diag(1./sum(nmda_hist)), 'LineWidth', 2)

legend(my_legend)

xlabel('Input Value'), ylabel('Proportion of Time')

box off

saveas(gcf, 'NMDA_input.fig')

figure

set(gca, 'FontSize', 20, 'NextPlot', 'add', 'ColorOrder', colors)

plot(gamma_freq_edges(2:end) - diff(gamma_freq_edges)/2, gamma_freq_hist(2:end, :)*diag(1./sum(gamma_freq_hist)), 'LineWidth', 2)

xlabel('Gamma Freq.'), ylabel('Proportion of Time')

legend(my_legend)

box off

saveas(gcf, 'gamma_freq_hist.fig')

figure

set(gca, 'FontSize', 20, 'NextPlot', 'add', 'ColorOrder', colors)

plot(freq_ratio_edges(2:end) - diff(freq_ratio_edges)/2, freq_ratio_hist(2:end, :)*diag(1./sum(freq_ratio_hist)), 'LineWidth', 2)

xlabel('Gamma Freq./Theta Freq.'), ylabel('Proportion of Time')

legend(my_legend)

box off

saveas(gcf, 'gamma_theta_ratio.fig')

