clear; clc; close all;

walking = readtable('inverse_dynamics_w.sto', 'FileType','text');
crouch = readtable('inverse_dynamics_c.sto', 'FileType','text');
vicon_w = readtable('Upload files/ViconMoments/Walking_moment_vicon.csv'); %Vicon reference (Nm/kg)
vicon_c = readtable('Upload files/ViconMoments/Crouch_moment_vicon.csv');
gait_cycle_vw = (vicon_w.Time - 1.23) / (2.11 - 1.23) * 100;
gait_cycle_vc = (vicon_c.Time - 1.89) / (2.87 - 1.89) * 100;

%Gait cycle (normal walking)
time_nw = walking.time >= 1.23 & walking.time <= 2.11;
time_w = walking.time(time_nw);
gait_cycle_w = (time_w - 1.23) / (2.11 - 1.23) * 100; %convert time to gait cycle (%)
toe_off_w = (177-124) / (212-124) * 100;

%Gait cycle (crouch walking)
time_cw = crouch.time >= 1.89 & crouch.time <= 2.87;
time_c = crouch.time(time_cw);
gait_cycle_c = (time_c - 1.89) / (2.87 - 1.89) * 100;
toe_off_c = (250-190) / (288-190) * 100;

%Subject mass
mass = 61.9; %kg

%Plot
figure;
tiledlayout(3,2);

%Hip moment flexion/extension
nexttile;
plot(gait_cycle_w, -walking.hip_flexion_r_moment(time_nw)/mass, LineWidth=1.5);
xline(toe_off_w, '--', HandleVisibility='off');
hold on;
plot(gait_cycle_c, -crouch.hip_flexion_r_moment(time_cw)/mass, LineWidth=1.5);
xline(toe_off_c, '--', HandleVisibility='off');
plot(gait_cycle_vw, vicon_w.RHipMoment, ':', Color=[0 0.447 0.741], LineWidth=1.5);
plot(gait_cycle_vc, vicon_c.RHipMoment, ':', Color=[0.85 0.325 0.098], LineWidth=1.5);
xlabel('Gait cycle (%)');
ylabel('Extension > 0 (Nm/kg)');
title('Hip moment - Sagittal plane');
legend('Normal walking', 'Crouch walking', 'Normal walking (Vicon)', 'Crouch walking (Vicon)');
grid on;

%Ankle moment plantarflexion/dorsiflexion
nexttile;
plot(gait_cycle_w, -walking.ankle_angle_r_moment(time_nw)/mass, LineWidth=1.5);
xline(toe_off_w, '--');
hold on;
plot(gait_cycle_c, -crouch.ankle_angle_r_moment(time_cw)/mass, LineWidth=1.5);
xline(toe_off_c, '--');
plot(gait_cycle_vw, vicon_w.RAnkleMoment, ':', Color=[0 0.447 0.741], LineWidth=1.5);
plot(gait_cycle_vc, vicon_c.RAnkleMoment, ':', Color=[0.85 0.325 0.098], LineWidth=1.5);
xlabel('Gait cycle (%)');
ylabel('Plantarflexion > 0 (Nm/kg)');
title('Ankle moment - Sagittal plane');
grid on;

%Hip moment rotation
nexttile;
plot(gait_cycle_w, walking.hip_rotation_r_moment(time_nw)/mass, LineWidth=1.5);
xline(toe_off_w, '--');
hold on;
plot(gait_cycle_c, crouch.hip_rotation_r_moment(time_cw)/mass, LineWidth=1.5);
xline(toe_off_c, '--');
xlabel('Gait cycle (%)');
ylabel('Internal rotation > 0 (Nm/kg)');
title('Hip moment - Transverse plane');
grid on;

%Knee moment flexion/extension
nexttile;
plot(gait_cycle_w, walking.knee_angle_r_moment(time_nw)/mass, LineWidth=1.5);
xline(toe_off_w, '--');
hold on;
plot(gait_cycle_c, crouch.knee_angle_r_moment(time_cw)/mass, LineWidth=1.5);
xline(toe_off_c, '--');
plot(gait_cycle_vw, vicon_w.RKneeMoment, ':', Color=[0 0.447 0.741], LineWidth=1.5);
plot(gait_cycle_vc, vicon_c.RKneeMoment, ':', Color=[0.85 0.325 0.098], LineWidth=1.5);
xlabel('Gait cycle (%)');
ylabel('Extension > 0 (Nm/kg)');
title('Knee moment - Sagittal plane');
grid on;


%Hip moment adduction/abduction
nexttile;
plot(gait_cycle_w, -walking.hip_adduction_r_moment(time_nw)/mass, LineWidth=1.5); %OpenSim: adduction > 0 -> multiply by -1
xline(toe_off_w, '--');
hold on;
plot(gait_cycle_c, -crouch.hip_adduction_r_moment(time_cw)/mass, LineWidth=1.5);
xline(toe_off_c, '--');
xlabel('Gait cycle (%)');
ylabel('Abduction > 0 (Nm/kg)');
title('Hip moment - Frontal plane');
grid on;
