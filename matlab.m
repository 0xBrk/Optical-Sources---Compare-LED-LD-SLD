%--------------------------------------------------------------------------
% ENGINEERING REPORT: OPTICAL SOURCES & LINK BUDGET ANALYSIS
% Group 3: Device Design & Application Engineering
%--------------------------------------------------------------------------
clc; clear; close all;

% --- 1. SETUP PARAMETERS ---
% General
lambda = linspace(1500, 1600, 1000); 
center_lambda = 1550;

% --- FIGURE 1: SPECTRAL CHARACTERISTICS (LED vs LD vs SLD) ---
% LED: Wide spectrum (Gaussian)
width_LED = 40; % nm
Spec_LED = exp(-((lambda - center_lambda).^2) / (2 * width_LED^2));

% SLD: Medium spectrum
width_SLD = 15; % nm
Spec_SLD = 0.8 * exp(-((lambda - center_lambda).^2) / (2 * width_SLD^2));

% LD: Narrow spectrum
width_LD = 1; % nm
Spec_LD = 1.2 * exp(-((lambda - center_lambda).^2) / (2 * width_LD^2));

figure('Name', 'Optical Source Analysis & Design', 'Color', 'w', 'Position', [100, 100, 1000, 800]);

% Plot 1: Spectrum
subplot(2,2,1);
plot(lambda, Spec_LED, 'b', 'LineWidth', 2); hold on;
plot(lambda, Spec_LD, 'r', 'LineWidth', 2);
plot(lambda, Spec_SLD, 'g--', 'LineWidth', 2);
title('1. Spectral Characteristics');
xlabel('Wavelength (nm)'); ylabel('Normalized Intensity');
legend('LED (Wide)', 'Laser Diode (Narrow)', 'SLD');
grid on; xlim([1480 1620]);

% --- FIGURE 2: L-I CURVE (Power vs Current) ---
Current = 0:0.5:100; % mA
I_th = 20; % Threshold for Laser (mA)

% LED Power (Linear)
P_LED = 0.02 * Current; 

% Laser Power (Threshold behavior)
P_LD = zeros(size(Current));
mask = Current > I_th;
P_LD(mask) = 0.15 * (Current(mask) - I_th); 

% Plot 2: L-I Curve
subplot(2,2,2);
plot(Current, P_LED, 'b--', 'LineWidth', 2); hold on;
plot(Current, P_LD, 'r', 'LineWidth', 2);
xline(I_th, 'k:', 'Label', 'I_{th}', 'LabelVerticalAlignment', 'bottom');
title('2. L-I Curve (Output Power)');
xlabel('Drive Current (mA)'); ylabel('Optical Power (mW)');
legend('LED', 'Laser Diode');
grid on;

% --- FIGURE 3: LINK BUDGET VISUALIZATION (Updated) ---
Distance = 0:1:50; % km
Alpha = 0.2; % dB/km (Fiber Loss @1550nm)
P_tx_dBm = 0; % 0 dBm Launch Power
Conn_Loss = 0.5; % dB (Start & End)
Splice_Loss = 0.1; % dB per 10km
System_Margin = 3; % dB (Safety Margin)

% Calculate Nominal Signal Power
Signal_Power = P_tx_dBm - Conn_Loss - (Alpha * Distance);

% Add Splice Losses (Step drops every 10km)
Splice_Locs = 10:10:40;
for i = 1:length(Distance)
    num_splices = sum(Splice_Locs < Distance(i));
    Signal_Power(i) = Signal_Power(i) - (num_splices * Splice_Loss);
end
% Final connector at end
Signal_Power(end) = Signal_Power(end) - Conn_Loss;

% Calculate Worst Case Signal (Margin applied)
Worst_Case_Signal = Signal_Power - System_Margin;

Sensitivity = -28; % dBm

% Plot 3: Link Budget
subplot(2,1,2);
% Plot Nominal Signal
plot(Distance, Signal_Power, 'b-', 'LineWidth', 2); hold on;
% Plot Worst Case Signal
plot(Distance, Worst_Case_Signal, 'k:', 'LineWidth', 1.5); 

% Reference Lines
yline(Sensitivity, 'r--', 'Label', 'Rx Sensitivity (-28 dBm)', 'LabelHorizontalAlignment', 'left', 'FontSize', 9);
yline(P_tx_dBm, 'g--', 'Label', 'Tx Power (0 dBm)', 'FontSize', 9);

% Danger Zone (Red Shading)
fill([0 50 50 0], [Sensitivity Sensitivity -40 -40], 'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none');

% Annotations
text(2, -18, '\downarrow System Margin (3 dB)', 'FontSize', 8, 'Color', 'k');
text(42, Worst_Case_Signal(end)+2, 'Safe Margin', 'FontSize', 8, 'FontWeight', 'bold');

title('3. Link Budget Analysis (50km SMF Link)');
xlabel('Distance (km)'); ylabel('Optical Power (dBm)');
legend('Nominal Signal', 'Worst Case (w/ 3dB Margin)', 'Sensitivity Limit', 'Location', 'SouthWest');
grid on; ylim([-35 5]);

sgtitle('Assignment 3: Optical Sources & System Design Analysis');