function results = freq_ratio(data, varargin)

spike_field = 'RS_V_spikes';

input_field = 'RS_iPeriodicSpikes_input';

if ~isempty(varargin)
    
    for v = 1:(length(varargin)/2)
        
        switch varargin{2*v - 1}
            
            case 'spike_field'
                
                spike_field = varargin{2*v};
            
            case 'input_field'
                
                input_field = varargin{2*v};
                
        end
        
    end
    
end

t = data.time;

i = data.(input_field);

%% Getting spike times and computing ISIs.

v_spikes = logical(data.(spike_field));
v_spike_times = t(v_spikes);
v_cycle_lengths = diff(v_spike_times);
v_freqs = 1000./v_cycle_lengths;
no_v_cycles = length(v_freqs);

[~, input_spike_indices] = findpeaks(diff(i), 'MinPeakHeight', .25*max(diff(i)));
i_spike_times = [t(input_spike_indices); t(end)];
i_cycle_lengths = diff(i_spike_times);
i_freqs = 1000./i_cycle_lengths;
no_i_cycles = length(i_freqs);

freq_ratio = nan(size(t));

for p = 1:no_i_cycles
    
    t_pd = t >= i_spike_times(p) & t <= i_spike_times(p + 1);
    
    v_spikes_pd = v_spikes & t_pd;
    
    v_spike_times_pd = t(v_spikes_pd);
    
    ISIs = [diff(v_spike_times_pd); nan]; % In milliseconds.
    
    freq_ratio(v_spikes_pd) = (1000./ISIs)/i_freqs(p); % Transform to frequencies.
    
end

results = struct('v_spike_times', v_spike_times, 'v_freqs', v_freqs, 'i_spike_times', i_spike_times, 'i_freqs', i_freqs, 'freq_ratio', freq_ratio);