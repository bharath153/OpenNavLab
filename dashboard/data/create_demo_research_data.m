function research = create_demo_research_data()
%CREATE_DEMO_RESEARCH_DATA Deterministic statistical datasets for v0.4 UI.
%
% These arrays are dashboard demonstration data shaped around the documented
% OpenNavLab Phase 7C / 7D result magnitudes. They are not regenerated EKF
% results and do not replace the saved production Monte Carlo outputs.

    %% Phase 7C-style paired Monte Carlo dataset
    n = 100;
    run = (1:n).';

    raw = 1.45*sin(0.19*run) + 0.82*cos(0.071*run) + 0.35*sin(0.047*run);
    raw = raw - mean(raw);
    classicalMax = 5.662 + raw;
    classicalMax = max(classicalMax, 0.65);
    classicalMax = classicalMax - mean(classicalMax) + 5.662;

    positiveMean = (0.841*n + 0.25*34)/66;
    gain = zeros(n,1);

    g1 = 0.22*sin(0.37*(1:66).') + 0.10*cos(0.11*(1:66).');
    g1 = g1 - mean(g1);
    gain(1:66) = positiveMean + g1;

    g2 = 0.07*sin(0.29*(1:34).') + 0.03*cos(0.17*(1:34).');
    g2 = g2 - mean(g2);
    gain(67:end) = -0.25 + g2;

    quantumMax = classicalMax - gain;

    % Additional metrics use deterministic paired variations.
    classicalPos = 2.55 + 0.72*sin(0.13*run) + 0.26*cos(0.043*run);
    classicalPos = max(classicalPos,0.55);
    posGain = 0.47 + 0.32*sin(0.17*run) + 0.15*cos(0.09*run);
    quantumPos = max(0.18, classicalPos - posGain);

    classicalFinal = 1.32 + 0.55*sin(0.15*run) + 0.18*cos(0.061*run);
    classicalFinal = max(classicalFinal,0.18);
    quantumFinal = max(0.08, classicalFinal - ...
        (0.21 + 0.20*sin(0.21*run) + 0.07*cos(0.08*run)));

    classicalVel = 0.406 + 0.065*sin(0.18*run) + 0.025*cos(0.063*run);
    quantumVel = max(0.08, classicalVel - ...
        (0.105 + 0.045*sin(0.16*run) + 0.018*cos(0.12*run)));

    classicalHead = 2.94 + 0.92*sin(0.11*run) + 0.35*cos(0.057*run);
    classicalHead = max(classicalHead,0.65);
    quantumHead = max(0.20, classicalHead - ...
        (0.88 + 0.48*sin(0.14*run) + 0.21*cos(0.05*run)));

    research.mc.run = run;
    research.mc.maxOutage.classical = classicalMax;
    research.mc.maxOutage.quantum = quantumMax;
    research.mc.positionRMSE.classical = classicalPos;
    research.mc.positionRMSE.quantum = quantumPos;
    research.mc.finalPosition.classical = classicalFinal;
    research.mc.finalPosition.quantum = quantumFinal;
    research.mc.velocityRMSE.classical = classicalVel;
    research.mc.velocityRMSE.quantum = quantumVel;
    research.mc.headingRMSE.classical = classicalHead;
    research.mc.headingRMSE.quantum = quantumHead;

    %% Phase 7D-style sensitivity dataset
    outage = [0 5 10 20 30 40];
    rates = [0.25 0.5 1 2];

    classicalMeanMax = [1.466 2.45 4.15 7.55 11.15 14.818];

    quantumMeanMax = [ ...
        1.55 2.31 3.75 6.30 8.65 10.200; ...
        1.52 2.25 3.60 6.05 8.20  9.734; ...
        1.49 2.14 3.36 5.62 7.35  8.710; ...
        1.47 2.03 3.12 5.05 6.72  7.929];

    reductionMean = 100*(repmat(classicalMeanMax,4,1)-quantumMeanMax) ./ ...
        repmat(classicalMeanMax,4,1);

    classicalP95 = [2.90 4.95 7.80 13.90 20.60 27.200];
    quantumP95 = [ ...
        3.00 4.60 7.10 11.80 15.90 18.604; ...
        2.95 4.45 6.85 11.20 15.10 16.855; ...
        2.91 4.28 6.52 10.65 14.20 16.087; ...
        2.88 4.08 6.18  9.80 12.60 13.725];

    p95Reduction = 100*(repmat(classicalP95,4,1)-quantumP95) ./ ...
        repmat(classicalP95,4,1);

    runsImproved = [ ...
        45 50 54 57 60 62; ...
        47 53 57 61 64 67; ...
        50 57 62 68 72 75; ...
        52 60 66 72 76 78];

    positionReduction = [ ...
         0  3.2  6.5 10.8 14.2 16.5; ...
         0  4.0  7.6 12.4 16.0 18.8; ...
         0  5.1  9.0 14.8 18.9 21.2; ...
         0  6.0 10.5 16.7 21.1 23.4];

    velocityReduction = [ ...
         0  4.0  7.2 12.0 15.5 18.0; ...
         0  5.1  8.8 14.0 18.0 21.5; ...
         0  6.4 10.9 17.0 21.8 25.1; ...
         0  7.6 12.5 19.5 24.8 28.4];

    headingReduction = [ ...
         0  5.0  9.5 15.5 20.0 24.0; ...
         0  6.3 11.5 18.8 24.0 29.0; ...
         0  8.0 14.2 22.5 29.0 34.0; ...
         0  9.5 16.5 25.5 32.4 37.9];

    quantumNIS = [ ...
        2.91 2.95 2.98 3.01 2.97 2.94; ...
        2.93 2.97 3.02 3.04 3.00 2.96; ...
        2.95 2.99 3.03 3.01 2.98 2.97; ...
        2.96 3.00 3.02 2.99 2.97 2.9666];

    research.sensitivity.outage_s = outage;
    research.sensitivity.rates_Hz = rates;
    research.sensitivity.classicalMeanMax_m = classicalMeanMax;
    research.sensitivity.quantumMeanMax_m = quantumMeanMax;
    research.sensitivity.meanReduction_pct = reductionMean;
    research.sensitivity.classicalP95_m = classicalP95;
    research.sensitivity.quantumP95_m = quantumP95;
    research.sensitivity.p95Reduction_pct = p95Reduction;
    research.sensitivity.runsImproved_pct = runsImproved;
    research.sensitivity.positionRMSEreduction_pct = positionReduction;
    research.sensitivity.velocityRMSEreduction_pct = velocityReduction;
    research.sensitivity.headingRMSEreduction_pct = headingReduction;
    research.sensitivity.quantumNIS = quantumNIS;

    research.meta.source = 'Deterministic v0.4 research-dashboard demo dataset';
    research.meta.note = [ ...
        'For UI validation only. Replace with saved Phase 6/7 result files ' ...
        'before using the dashboard as evidence of production statistics.'];
end
