% Model: Kramer 2008, PLoS Comp Bio
%%
tic
% Simulation mode
sim_mode = 1;   % 1 - normal sim
                % 2 - sim study IB disconnected; iM and iCaH
                % 3 - sim study IBs inject
                
                
% Cells to include in model
include_IB = 1;
include_FS = 0;
include_NG = 0;

% simulation controls
tspan=[0 1000]; dt=.01; solver='euler'; % euler, rk2, rk4
dsfact=1; % downsample factor, applied after simulation

% No noise simulation
no_noise = 0;


% number of cells per population
N=2;   % Number of excitatory cells
Nng=N;  % Number of FSNG cells
Nfs=N;  % Number of FS cells

% % % % % % % % % % % % %  Injected currents % % % % % % % % % % % % %  
% tonic input currents
Jd1=5; % apical: 23.5(25.5), basal: 23.5(42.5)
Jd2=-.5; % apical: 23.5(25.5), basal: 23.5(42.5)
Jng1=2;     % NG current injection; step1   % Do this to remove the first NG pulse
Jng2=1;     % NG current injection; step2
Jfs=1;     % FS current injection; step1

IB_offset1=245;
IB_onset2=245;

% Poisson IPSPs to IBdb (basal dendrite)
gRAN=.015;
ERAN=0;
tauRAN=2;
lambda = 1000;

% Periodic pulse stimulation
PPfreq = 40; % in Hz
PPwidth = 2; % in ms
PPonset = 250;    % ms, onset time
PPoffset = Inf;   % ms, offset time
ap_pulse_num = 17;        % The pulse number that should be delayed. 0 for no aperiodicity.
ap_pulse_delay = 11;  % ms, the amount the spike should be delayed. 0 for no aperiodicity.
ap_pulse_delay = 0;  % ms, the amount the spike should be delayed. 0 for no aperiodicity.
IBPPstim = 0;
NGPPstim = 0;
FSPPstim = 0;
% IBPPstim = -15;
% NGPPstim = -1.2;
% FSPPstim = -5;



% % % % % % % % % % % % %  Synaptic connections % % % % % % % % % % % % %  
% compartmental connection strengths
gsd=.2;     % IBs -> IBda,IBdb
gds=.4;     % IBda,IBdb -> IBs
gas=.3;     % IBa -> IBs
gsa=.3;     % IBs -> IBa

% Gap junction connection
ggja=0;
ggja=.2/N;  % IBa -> IBa

% Synapse heterogenity
gsyn_hetero = 0;

% Synaptic connection strengths zeros
gAMPAee=0;
gNMDAee=0;

gAMPAei=0;
gNMDAei=0;

gGABAaii=0;
gGABAbii=0;

gGABAaie=0;
gGABAbie=0;

gGABAaff=0;

gGABAafe=0;


% % Synaptic connection strengths
gAMPAee=0.1/N;      % IBa -> IBdb, 0(.04)
gNMDAee=10/N;
% 
gAMPAei=0.1/Nng;      % IBa -> IBdb, 0(.04)
gNMDAei=10/Nng;
% 
gGABAaii=0.1/Nng;
gGABAbii=.3/Nng;
% % 
gGABAaie=0.1/N;
gGABAbie=.35/N;

gGABAaff=0.4/Nfs;

gGABAafe=.5/N;


% % % % % % % % % % % % % % % % % % % % % % 



% Synaptic time constants & reversals
tauAMPAr=.25;  % ms, AMPA rise time; Jung et al
tauAMPAd=1;   % ms, AMPA decay time; Jung et al
tauNMDAr=5; % ms, NMDA rise time; Jung et al
tauNMDAd=100; % ms, NMDA decay time; Jung et al
tauGABAar=.5;  % ms, GABAa rise time; Jung et al
tauGABAad=8;   % ms, GABAa decay time; Jung et al
tauGABAbr=38;  % ms, GABAa rise time; From NEURON Delta simulation
tauGABAbd=150;   % ms, GABAa decay time; From NEURON Delta simulation
EAMPA=0;
EGABA=-95;
TmaxGABAB=0.5;



% Current injection noise levels
IBda_Vnoise = .3;
IBs_Vnoise = .1;
IBdb_Vnoise = .3;
IBa_Vnoise = .1;
NG_Vnoise = 3;
FS_Vnoise = 3;

% constant biophysical parameters
Cm=.9;        % membrane capacitance
gl=.1;
ENa=50;      % sodium reversal potential
E_EKDR=-95;  % potassium reversal potential for excitatory cells
IB_Eh=-25;   % h-current reversal potential for deep layer IB cells
ECa=125;     % calcium reversal potential
IC_noise=.25;% fractional noise in initial conditions
if no_noise
    IC_noise= 0;
    IBda_Vnoise = 0;
    IBs_Vnoise = 0;
    IBdb_Vnoise = 0;
    IBa_Vnoise = 0;
    gRAN=0;
    FSgRAN=0;
end

IC_V = -65;


% % % % % % % % % % % % % % % % Override some defaults
switch sim_mode
    case 2
        include_IB = 1; include_FS = 0; include_NG = 0;
        gAMPAee=0; gNMDAee=0;
end


% % % % % % % % % % % % %  Populations  % % % % % % % % % % % % %  

spec=[];
i=0;

if include_IB
    i=i+1;
    spec.populations(i).name = 'IB';
    spec.populations(i).size = N;
    spec.populations(i).equations = {['V''=(current)/Cm; V(0)=' num2str(IC_V) ]};
    spec.populations(i).mechanism_list = {'iPeriodicPulses','IBdbiPoissonExpJason','itonicPaired','IBnoise','IBiNaF','IBiKDR','IBiMMich','IBiCaH','IBleak'};
    spec.populations(i).parameters = {...
      'V_IC',-65,'IC_noise',IC_noise,'Cm',Cm,'E_l',-67,'g_l',gl,...
      'PPstim',IBPPstim,'PPfreq',PPfreq,'PPwidth',PPwidth,'PPonset',PPonset,'PPoffset',PPoffset,'ap_pulse_num',ap_pulse_num,'ap_pulse_delay',ap_pulse_delay,...
      'gRAN',gRAN,'ERAN',ERAN,'tauRAN',tauRAN,'lambda',lambda,...
      'stim',Jd1,'onset',0,'offset',IB_offset1,'stim2',Jd2,'onset2',IB_onset2,'offset2',Inf,...
      'V_noise',IBda_Vnoise,...
      'gNaF',100,'E_NaF',ENa,...
      'gKDR',80,'E_KDR',E_EKDR,...
      'gM',2,'E_M',E_EKDR,...
      'gCaH',2,'E_CaH',ECa,...
      };
end

if include_NG
    i=i+1;
    spec.populations(i).name = 'NG';
    spec.populations(i).size = Nng;
    spec.populations(i).equations = {['V''=(current)/Cm; V(0)=' num2str(IC_V) ]};
    spec.populations(i).mechanism_list = {'iPeriodicPulses','itonicPaired','IBnoise','FSiNaF','FSiKDR','IBleak','iAhuguenard'};
    spec.populations(i).parameters = {...
      'V_IC',-65,'IC_noise',IC_noise,'Cm',Cm,'E_l',-67,'g_l',0.1,...
      'PPstim',NGPPstim,'PPfreq',PPfreq,'PPwidth',PPwidth,'PPonset',PPonset,'PPoffset',PPoffset,'ap_pulse_num',ap_pulse_num,'ap_pulse_delay',ap_pulse_delay,...
      'stim',Jng1,'onset',0,'offset',50,'stim2',Jng2,'onset2',50,'offset2',Inf,...
      'V_noise',NG_Vnoise,...
      'gNaF',100,'E_NaF',ENa,...
      'gKDR',80,'E_KDR',E_EKDR,...
      'gA',60,'E_A',E_EKDR, ...
      };
end

if include_FS
    i=i+1;
    spec.populations(i).name = 'FS';
    spec.populations(i).size = Nfs;
    spec.populations(i).equations = {['V''=(current)/Cm; V(0)=' num2str(IC_V) ]};
    spec.populations(i).mechanism_list = {'iPeriodicPulses','IBitonic','IBnoise','FSiNaF','FSiKDR','IBleak'};
    spec.populations(i).parameters = {...
      'V_IC',-65,'IC_noise',IC_noise,'Cm',Cm,'E_l',-67,'g_l',0.1,...
      'PPstim',FSPPstim,'PPfreq',PPfreq,'PPwidth',PPwidth,'PPonset',PPonset,'PPoffset',PPoffset,'ap_pulse_num',ap_pulse_num,'ap_pulse_delay',ap_pulse_delay,...
      'stim',Jfs,'onset',0,'offset',Inf,...
      'V_noise',FS_Vnoise,...
      'gNaF',100,'E_NaF',ENa,...
      'gKDR',80,'E_KDR',E_EKDR,...
      };
end



% % % % % % % % % % % %  Connections  % % % % % % % % % % % % %  
i=0;

% % IB->IB intracompartmental connections
if include_IB
end


% % IB->IB recurrent synaptic and gap connections
if include_IB
    i=i+1;
    spec.connections(i).direction = 'IB->IB';
    spec.connections(i).mechanism_list = {'IBaIBdbiSYNseed','iNMDA','IBaIBaiGAP'};
    spec.connections(i).parameters = {'g_SYN',gAMPAee,'E_SYN',EAMPA,'tauDx',tauAMPAd,'tauRx',tauAMPAr,'fanout',inf,'IC_noise',0,'g_SYN_hetero',gsyn_hetero, ...
        'gNMDA',gNMDAee,'ENMDA',EAMPA,'tauNMDAr',tauNMDAr,'tauNMDAd',tauNMDAd ...
        'g_GAP',ggja,...
        };
end

% % IB->NG
if include_IB && include_NG
    i=i+1;
    spec.connections(i).direction = 'IB->NG';
    spec.connections(i).mechanism_list = {'IBaIBdbiSYNseed','iNMDA'};
    spec.connections(i).parameters = {'g_SYN',gAMPAei,'E_SYN',EAMPA,'tauDx',tauAMPAd,'tauRx',tauAMPAr,'fanout',inf,'IC_noise',0,'g_SYN_hetero',gsyn_hetero, ...
        'gNMDA',gNMDAei,'ENMDA',EAMPA,'tauNMDAr',tauNMDAr,'tauNMDAd',tauNMDAd ...
        };
end

% % NG->NG Synaptic connections
if include_NG
    i=i+1;
    spec.connections(i).direction = 'NG->NG';                   % GABA_A
    spec.connections(i).mechanism_list = {'IBaIBdbiSYNseed','iGABABAustin'};
    spec.connections(i).parameters = {'g_SYN',gGABAaii,'E_SYN',EGABA,'tauDx',tauGABAad,'tauRx',tauGABAar,'fanout',inf,'IC_noise',0,'g_SYN_hetero',gsyn_hetero,...
        'gGABAB',gGABAbii,'EGABAB',EGABA,'tauGABABd',tauGABAbd,'tauGABABr',tauGABAbr,'gGABAB_hetero',gsyn_hetero,  ...
        'TmaxGABAB',TmaxGABAB ...
        };
end

% % NG->IB Synaptic connections
if include_NG && include_IB
    i=i+1;
    spec.connections(i).direction = 'NG->IB';                   % GABA_A
    spec.connections(i).mechanism_list = {'IBaIBdbiSYNseed','iGABABAustin'};
    spec.connections(i).parameters = {'g_SYN',gGABAaie,'E_SYN',EGABA,'tauDx',tauGABAad,'tauRx',tauGABAar,'fanout',inf,'IC_noise',0,'g_SYN_hetero',gsyn_hetero,...
        'gGABAB',gGABAbie,'EGABAB',EGABA,'tauGABABd',tauGABAbd,'tauGABABr',tauGABAbr,'gGABAB_hetero',gsyn_hetero, ...
        'TmaxGABAB',TmaxGABAB ...
        };
end

% % FS->FS Synaptic connections
if include_FS
    i=i+1;
    spec.connections(i).direction = 'FS->FS';                   % GABA_A
    spec.connections(i).mechanism_list = {'IBaIBdbiSYNseed'};
    spec.connections(i).parameters = {'g_SYN',gGABAaff,'E_SYN',EGABA,'tauDx',tauGABAad,'tauRx',tauGABAar,'fanout',inf,'IC_noise',0,'g_SYN_hetero',gsyn_hetero,...
        };
end


% % FS->IB Synaptic connections
if include_FS && include_IB
    i=i+1;
    spec.connections(i).direction = 'FS->IB';                   % GABA_A
    spec.connections(i).mechanism_list = {'IBaIBdbiSYNseed'};
    spec.connections(i).parameters = {'g_SYN',gGABAafe,'E_SYN',EGABA,'tauDx',tauGABAad,'tauRx',tauGABAar,'fanout',inf,'IC_noise',0,'g_SYN_hetero',gsyn_hetero,...
        };
end




switch sim_mode

    case 1
        % DynaSim code
        % data=SimulateModel(spec);
        %tic
        data=SimulateModel(spec,'tspan',tspan,'dt',dt,'dsfact',dsfact,'solver',solver,'coder',0,'random_seed',1,'compile_flag',1);
        %toc
        PlotData(data,'plot_type','waveform');
        
        
    case 2
        
        servermode=0;
        
        vary = {
            'IB','gCaH',[2 3];
            'IB','gM',[1 2];
            };
        if servermode==0
            data=SimulateModel(spec,'tspan',tspan,'dt',dt,'dsfact',dsfact,'solver',solver,'coder',0,'random_seed',1,'compile_flag',1,'vary',vary,'parallel_flag',1);
            PlotData(data,'plot_type','waveform');
            PlotData(data,'variable','IBiMMich_mM','plot_type','waveform');
            PlotData(data,'variable','IBaIBdbiSYNseed_s','plot_type','waveform');
        else
            data=SimulateModel(spec,'tspan',tspan,'dt',dt,'dsfact',dsfact,'solver',solver,'coder',0, ...
                'save_data_flag',1,'study_dir','demo_cluster_2', ...
                'random_seed',1,'compile_flag',1,'vary',vary, ...
                'cluster_flag',0,'verbose_flag',1,...
                'plot_functions',@PlotData);
        end

end

%PlotData(data,'plot_type','rastergram');
%PlotData(data,'variable','IBaIBdbiSYNseed_s','plot_type','waveform');
%PlotData(data,'variable','ISYN','plot_type','waveform');
%PlotData(data,'variable','iNMDA_s','plot_type','waveform');
%PlotData(data,'variable','INMDA','plot_type','waveform');
%PlotData(data,'variable','IGABAB','plot_type','waveform');
%PlotData(data,'variable','iGABABAustin_g','plot_type','waveform');
%PlotData(data,'variable','IBiMMich_mM','plot_type','waveform');

toc





