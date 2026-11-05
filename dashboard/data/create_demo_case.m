function data = create_demo_case(config)
%CREATE_DEMO_CASE Deterministic demonstration case for UI smoke testing.
%
% config fields (optional):
%   outageStart_s
%   outageDuration_s
%   quantumRate_Hz

    if nargin < 1 || isempty(config)
        config = struct();
    end

    if ~isfield(config,'outageStart_s'),    config.outageStart_s = 50; end
    if ~isfield(config,'outageDuration_s'), config.outageDuration_s = 40; end
    if ~isfield(config,'quantumRate_Hz'),   config.quantumRate_Hz = 2; end

    dt = 0.01;
    tEnd = 120;
    t = (0:dt:tEnd).';
    n = numel(t);

    outageStart = max(0,min(tEnd,config.outageStart_s));
    outageEnd = max(outageStart,min(tEnd,outageStart + config.outageDuration_s));
    quantumRate = config.quantumRate_Hz;

    speed = 8.0 + 1.5*sin(2*pi*t/55);
    yawRate = deg2rad(1.8)*sin(2*pi*t/38) + deg2rad(0.7)*sin(2*pi*t/17);
    heading = cumtrapz(t,yawRate);

    vx = speed.*cos(heading);
    vy = speed.*sin(heading);
    x = cumtrapz(t,vx);
    y = cumtrapz(t,vy);

    truthPosition = [x y];
    truthVelocity = [vx vy];

    outageMask = t >= outageStart & t <= outageEnd;

    tau = max(t-outageStart,0);
    outageGrowth = outageMask.*(0.10*tau + 0.0045*tau.^2);
    recovery = (t > outageEnd).*exp(-(t-outageEnd)/5.5);

    classicalBiasX = 0.35*sin(t/8) + outageGrowth;
    classicalBiasY = 0.25*cos(t/11) + 0.55*outageGrowth;
    classicalBiasX(t > outageEnd) = classicalBiasX(t > outageEnd).*recovery(t > outageEnd);
    classicalBiasY(t > outageEnd) = classicalBiasY(t > outageEnd).*recovery(t > outageEnd);

    qScale = max(0.28, min(0.85, 0.68 - 0.13*log2(max(quantumRate,0.25))));
    quantumBiasX = 0.28*sin(t/8) + qScale*outageGrowth;
    quantumBiasY = 0.20*cos(t/11) + 0.72*qScale*outageGrowth;
    quantumBiasX(t > outageEnd) = quantumBiasX(t > outageEnd).*recovery(t > outageEnd);
    quantumBiasY(t > outageEnd) = quantumBiasY(t > outageEnd).*recovery(t > outageEnd);

    classicalPosition = truthPosition + [classicalBiasX classicalBiasY];
    quantumPosition = truthPosition + [quantumBiasX quantumBiasY];

    classicalVelocity = truthVelocity + ...
        [gradient(classicalBiasX,dt) gradient(classicalBiasY,dt)];
    quantumVelocity = truthVelocity + ...
        [gradient(quantumBiasX,dt) gradient(quantumBiasY,dt)];

    classicalHeading = heading + deg2rad(0.9)*sin(t/13) + deg2rad(0.07)*outageGrowth;
    quantumHeading = heading + deg2rad(0.6)*sin(t/13) + deg2rad(0.035*qScale/0.54)*outageGrowth;

    posErrClassical = vecnorm(classicalPosition-truthPosition,2,2);
    posErrQuantum = vecnorm(quantumPosition-truthPosition,2,2);
    velErrClassical = vecnorm(classicalVelocity-truthVelocity,2,2);
    velErrQuantum = vecnorm(quantumVelocity-truthVelocity,2,2);
    headingErrClassical = abs(rad2deg(wrapToPiLocal(classicalHeading-heading)));
    headingErrQuantum = abs(rad2deg(wrapToPiLocal(quantumHeading-heading)));

    gpsRate = 1;
    gpsPeriodSamples = round(1/(gpsRate*dt));
    gpsScheduled = false(n,1);
    gpsScheduled(1:gpsPeriodSamples:end) = true;
    gpsAvailable = gpsScheduled & ~outageMask;

    qPeriodSamples = max(1,round(1/(quantumRate*dt)));
    quantumUpdates = false(n,1);
    quantumUpdates(1:qPeriodSamples:end) = true;

    data.time = t;
    data.truth.position = truthPosition;
    data.truth.velocity = truthVelocity;
    data.truth.heading_rad = heading;

    data.classical.position = classicalPosition;
    data.classical.velocity = classicalVelocity;
    data.classical.heading_rad = classicalHeading;

    data.quantum.position = quantumPosition;
    data.quantum.velocity = quantumVelocity;
    data.quantum.heading_rad = quantumHeading;

    data.gps.outageMask = outageMask;
    data.gps.scheduledMask = gpsScheduled;
    data.gps.availableMask = gpsAvailable;

    data.quantum.updateMask = quantumUpdates;

    data.errors.classical.position_m = posErrClassical;
    data.errors.quantum.position_m = posErrQuantum;
    data.errors.classical.velocity_mps = velErrClassical;
    data.errors.quantum.velocity_mps = velErrQuantum;
    data.errors.classical.heading_deg = headingErrClassical;
    data.errors.quantum.heading_deg = headingErrQuantum;

    % Bias truth / estimates for the Quantum Analysis page.
    trueBax = 0.030 + 0.004*sin(t/28);
    trueBay = -0.022 + 0.003*cos(t/31);
    trueBg  = deg2rad(0.045) + deg2rad(0.006)*sin(t/35);

    classicalBax = trueBax + 0.010*sin(t/17) + 0.0007*outageGrowth;
    classicalBay = trueBay + 0.008*cos(t/19) + 0.0005*outageGrowth;
    classicalBg  = trueBg  + deg2rad(0.030)*sin(t/21) + deg2rad(0.0018)*outageGrowth;

    quantumBax = trueBax + 0.005*sin(t/17) + 0.00030*qScale*outageGrowth;
    quantumBay = trueBay + 0.004*cos(t/19) + 0.00022*qScale*outageGrowth;
    quantumBg  = trueBg  + deg2rad(0.014)*sin(t/21) + deg2rad(0.0008*qScale)*outageGrowth;

    data.bias.true.accel_x_mps2 = trueBax;
    data.bias.true.accel_y_mps2 = trueBay;
    data.bias.true.gyro_z_rps = trueBg;

    data.bias.classical.accel_x_mps2 = classicalBax;
    data.bias.classical.accel_y_mps2 = classicalBay;
    data.bias.classical.gyro_z_rps = classicalBg;

    data.bias.quantum.accel_x_mps2 = quantumBax;
    data.bias.quantum.accel_y_mps2 = quantumBay;
    data.bias.quantum.gyro_z_rps = quantumBg;

    % NIS channels. Values are deterministic and centered near their
    % theoretical expectations (GPS: 2 DOF, quantum: 3 DOF).
    gpsNIS = nan(n,1);
    gpsIdx = find(gpsAvailable);
    gpsNIS(gpsIdx) = 1.92 + 0.55*sin(0.37*(1:numel(gpsIdx))).' ...
        + 0.22*cos(0.13*(1:numel(gpsIdx))).';
    gpsNIS(gpsIdx) = max(gpsNIS(gpsIdx),0.02);

    qNIS = nan(n,1);
    qIdx = find(quantumUpdates);
    qNIS(qIdx) = 2.97 + 0.72*sin(0.29*(1:numel(qIdx))).' ...
        + 0.31*cos(0.11*(1:numel(qIdx))).';
    qNIS(qIdx) = max(qNIS(qIdx),0.02);

    data.nis.gps = gpsNIS;
    data.nis.quantum = qNIS;
    data.nis.gpsExpected = 2;
    data.nis.quantumExpected = 3;

    data.meta.source = 'OpenNavLab dashboard demo case';
    data.meta.dt_s = dt;
    data.meta.imuRate_Hz = 1/dt;
    data.meta.gpsRate_Hz = gpsRate;
    data.meta.quantumRate_Hz = quantumRate;
    data.meta.outageStart_s = outageStart;
    data.meta.outageEnd_s = outageEnd;
end

function a = wrapToPiLocal(a)
    a = mod(a+pi,2*pi)-pi;
end
