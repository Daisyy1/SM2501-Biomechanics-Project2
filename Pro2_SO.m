clear; clc; close all;
%Part 2: SO muscle activations (+ EMG), RRA residuals, SO reserve actuators
%Run from the Project2 folder (same as Pro2_fig.m)

set(groot, 'DefaultAxesFontSize', 12, 'DefaultLineLineWidth', 1.5);
save_figs = true;                 %export PNGs to Figures_Part2/
out_dir = 'Figures_Part2';
if save_figs && ~exist(out_dir, 'dir'), mkdir(out_dir); end

%Motions: name, time interval, toe-off (%), result files
d = 'Upload files/';
mot(1).name = 'Normal walking';
mot(1).t = [1.23 2.11];
mot(1).toe_off = (177-124) / (212-124) * 100;
mot(1).act = [d 'SO/Walking/subject_walking_SO_StaticOptimization_activation.sto'];
mot(1).frc = [d 'SO/Walking/subject_walking_SO_StaticOptimization_force.sto'];
mot(1).rra = [d 'RRA/Walking/iter2/subject_scaled_walking_RRA2_Actuation_force.sto'];
mot(1).emg = [d 'ExperimentalData/EMG/Walking_EMG.csv'];
mot(1).res_leg = {'FX (+ right)', 'FY (+ upward)', 'FZ (+ backward)'}; %walks towards -Z

mot(2).name = 'Crouch walking';
mot(2).t = [1.89 2.87];
mot(2).toe_off = (250-190) / (288-190) * 100;
mot(2).act = [d 'SO/Crouch/subject_crouch_SO_StaticOptimization_activation.sto'];
mot(2).frc = [d 'SO/Crouch/subject_crouch_SO_StaticOptimization_force.sto'];
mot(2).rra = [d 'RRA/Crouch/iter2/subject_scaled_crouch_RRA2_Actuation_force.sto'];
mot(2).emg = [d 'ExperimentalData/EMG/Crouch_EMG.csv'];
mot(2).res_leg = {'FX (+ left)', 'FY (+ upward)', 'FZ (+ forward)'};    %walks towards +Z

%Read data, keep only the specified time interval, convert to gait cycle (%)
for k = 1:2
    mot(k).A = cut(readSto(mot(k).act), mot(k).t);   %SO activations (0-1)
    mot(k).F = cut(readSto(mot(k).frc), mot(k).t);   %SO forces (reserves in Nm)
    mot(k).R = cut(readSto(mot(k).rra), mot(k).t);   %RRA residuals (N, Nm)
    mot(k).E = cut(readtable(mot(k).emg), mot(k).t); %EMG (0-1)
end

%% 1) SO activations: one figure per muscle group, Walking | Crouch
%EMG muscle matched to the SO muscle (dashed line, same colour)
emg_map = {'rect_fem_r','Rect_Fem'; 'vas_lat_r','Vast_Lat'; 'bifemlh_r','Bice_Fem'; ...
           'tib_ant_r','Tibi_Ant'; 'med_gas_r','Gast_Med'; 'soleus_r','Sol'};

groups = {
  'Hip extensors',          {'glut_max1_r','glut_max2_r','glut_max3_r','semimem_r','semiten_r','bifemlh_r'};
  'Hip flexors',            {'iliacus_r','psoas_r','rect_fem_r'};
  'Hip abductors',          {'glut_med1_r','glut_med2_r','glut_med3_r','glut_min1_r','glut_min2_r','glut_min3_r','tfl_r'};
  'Knee extensors',         {'rect_fem_r','vas_med_r','vas_int_r','vas_lat_r'};
  'Ankle plantarflexors',   {'med_gas_r','lat_gas_r','soleus_r'};
  'Ankle dorsiflexors',     {'tib_ant_r','ext_dig_r','ext_hal_r'}};

for g = 1:size(groups,1)
    muscles = groups{g,2};
    col = lines(numel(muscles));
    figure('Position', [100 100 1200 450]);
    tiledlayout(1,2);
    ymax = 0;                          %largest value in both panels
    for k = 1:2
        ax(k) = nexttile; hold on;
        leg = {};
        for m = 1:numel(muscles)
            plot(mot(k).A.gc, mot(k).A.(muscles{m}), Color=col(m,:));
            ymax = max(ymax, max(mot(k).A.(muscles{m})));
            leg{end+1} = [strrep(muscles{m}, '_', '\_') ' (SO)'];
        end
        for m = 1:numel(muscles)
            i = find(strcmp(emg_map(:,1), muscles{m}));
            if ~isempty(i)
                plot(mot(k).E.gc, mot(k).E.(emg_map{i,2}), '--', Color=col(m,:));
                ymax = max(ymax, max(mot(k).E.(emg_map{i,2})));
                leg{end+1} = [strrep(emg_map{i,2}, '_', '\_') ' (EMG)'];
            end
        end
        xline(mot(k).toe_off, ':k');
        leg{end+1} = 'Toe-off';
        xlim([0 100]);
        xlabel('Gait cycle (%)');
        ylabel('Activation (0 = none, 1 = full)');
        title([groups{g,1} ' - ' mot(k).name]);
        legend(leg, Location='northeastoutside');
        grid on;
    end
    %same y-axis for Walking and Crouch: max rounded up to 0.1 (small margin)
    set(ax, 'YLim', [0 min(1, ceil((ymax + 0.02)*10)/10)]);
    saveFig(save_figs, out_dir, sprintf('SO_%d_%s', g, strrep(groups{g,1}, ' ', '_')));
end

%% 2) RRA residual forces and moments: one figure per motion
%Ground frame: Y up, Z = walking direction (Walking -Z, Crouch +Z), X = mediolateral
for k = 1:2
    R = mot(k).R;
    figure('Position', [100 100 1500 450]);
    tiledlayout(1,2);
    nexttile; hold on;
    plot(R.gc, R.FX); plot(R.gc, R.FY); plot(R.gc, R.FZ);
    xline(mot(k).toe_off, ':k');
    xlim([0 100]);
    xlabel('Gait cycle (%)'); ylabel('Residual force (N)');
    title(['RRA residual forces - ' mot(k).name]);
    legend([mot(k).res_leg, {'Toe-off'}], Location='eastoutside');
    grid on;
    nexttile; hold on;
    plot(R.gc, R.MX); plot(R.gc, R.MY); plot(R.gc, R.MZ);
    xline(mot(k).toe_off, ':k');
    xlim([0 100]);
    xlabel('Gait cycle (%)'); ylabel('Residual moment (Nm), + right-hand rule');
    title(['RRA residual moments - ' mot(k).name]);
    legend('MX (about ground X)', 'MY (about ground Y)', 'MZ (about ground Z)', 'Toe-off', ...
           Location='eastoutside');
    grid on;
    saveFig(save_figs, out_dir, sprintf('Residuals_%d_%s', k, strrep(mot(k).name, ' ', '_')));
end

%% 3) SO reserve actuators: all reserves in one figure per motion
for k = 1:2
    F = mot(k).F;
    names = F.Properties.VariableNames(endsWith(F.Properties.VariableNames, '_reserve'));
    figure('Position', [100 100 1100 500]);
    hold on;
    col = lines(7);
    for n = 1:numel(names)
        %right leg solid, left leg dashed, lumbar dotted
        if contains(names{n}, '_r_'), ls = '-'; elseif contains(names{n}, '_l_'), ls = '--'; else, ls = ':'; end
        plot(F.gc, F.(names{n}), ls, Color=col(mod(n-1,7)+1,:));
    end
    xline(mot(k).toe_off, ':k');
    xlim([0 100]);
    xlabel('Gait cycle (%)'); ylabel({'Reserve actuator moment (Nm)', '+ = positive coordinate direction (OpenSim)'});
    title(['SO reserve actuators - ' mot(k).name]);
    legend([strrep(strrep(names, '_reserve', ''), '_', '\_'), {'Toe-off'}], Location='eastoutside', NumColumns=1);
    grid on;
    saveFig(save_figs, out_dir, sprintf('Reserves_%d_%s', k, strrep(mot(k).name, ' ', '_')));
end

%% Helper functions
function T = readSto(file)
%Read an OpenSim .sto file (header ends with 'endheader')
    txt = fileread(file);
    n = numel(strfind(txt(1:strfind(txt, 'endheader')), newline)) + 1; %line of 'endheader'
    opts = detectImportOptions(file, 'FileType', 'text', 'Delimiter', '\t');
    opts.VariableNamesLine = n + 1;
    opts.DataLines = [n + 2 Inf];
    opts.VariableNamingRule = 'preserve';
    T = readtable(file, opts);
    [~, i] = unique(T.time);  %sort by time, drop duplicate time stamps
    T = T(i, :);
end

function T = cut(T, t)
%Keep the specified time interval and add gait cycle (%) column
    T = T(T.time >= t(1) - 1e-3 & T.time <= t(2) + 1e-3, :);
    T.gc = (T.time - t(1)) / (t(2) - t(1)) * 100;
end

function saveFig(do_save, out_dir, name)
    if do_save
        exportgraphics(gcf, fullfile(out_dir, [name '.png']), Resolution=200);
    end
end
