% Digital Waveguide Vocal Tract Model, based on the example by
% Mathur and Story in their paper:
%
% Mathur S., Story B. "Vocal tract modeling: Implementation of continuous
% length variations in a half-sample delay Kelly-Lochbaum model", ISSPIT 2003
%
% Vocal tract section data from:
%
% Story, B., Titze, I.R., Parameterization of vocal tract area functions
% by empirical orthogonal modes, Journal of Phonetics,26(3),1998, pp.
% 223-260, https://doi.org/10.1006/jpho.1998.0076.
%
% Adapted by DTM for LF excitation, Sound Output, Dynamics, Oct 2020
% Adapted by Y3859177
% for fufliment of Physical Modelling Synthesis, Dec 2020
% -----------------------------------------------------------------------

% --------------------------- Initial Setup -----------------------------

% Load crossectional area function, there are 44 sections in the profile.
AreaFile = load('areaFunctions.mat');
a = AreaFile.AreaFile.a;           % bart/father
ae = AreaFile.AreaFile.ae;         % bat/lad
bird = AreaFile.AreaFile.bird;     % (3) bird
I = AreaFile.AreaFile.i;           % beet/see
O = AreaFile.AreaFile.O;           % ball/law
Q = AreaFile.AreaFile.Q;           % bod/not
u = AreaFile.AreaFile.u;           % food/soon
U2 = AreaFile.AreaFile.U;           % foot/put
V = AreaFile.AreaFile.V;           % but

% ---------- USER INPUT VARIABLES -------------

% enable saving output to disk | true or false
saveFile = true;

% enable displaying graphs | true or false
graphs = true;

% Add a plositve "b" sound | true or false
plosive = false;

% Position to start plosive 0.0 = start | 0.5 = middle | 1 = end
PlosivePosition = 0.0;

% Excitation Type | "LF" "LFVib" "Noise"
Excitation = "LF";

% Select which vowel/dipthong to use:
%
% a     | bart/father
% ae    | bat/lad
% bird  | (3) bird
% I     | (i) beet/see
% O     | ball/law
% Q     | bod/not
% u     | food/soon
% U2    | foot/put
% V     | but

firstVowelString =  "a";

% if using two vowels for a dipthong set to true and select the second
% vowel
% EXAMPLES
% ===========================
% 1Vowel|2Vowel | Description
% a     | U2    | now
% bird  | I     | day
% a     | I     | high
% O     | I     | boy
% ===========================

dipthong = false; % true or false
secondVowelString = "I";

%------------------- MAIN PROGRAM ------------

%Define the waveguide parameters
Fs = 44100;                 % Sample Rate
rho = 1.2041;               % Density of Air at 20degC (kg/m^3)
c = 343.26;                 % Speed of sound at 20degC (m/s)
duration = 1.0;             % Sound output Duration (s)
nSegments = 44;             % Number of segments in the waveguide
nSamples = Fs*duration;     % No of speech samples (Pout) required
PlosiveStartPosition = nSamples*PlosivePosition;
firstVowel =  eval(firstVowelString);
secondVowel = eval(secondVowelString);


% ----- Excitation -----
% The unit impulse/glottal volume velocity input
if Excitation == "unitImpulse"
    uin = zeros(nSamples, 1);
    uin(1)= 200;
end

% With Vibrato
if Excitation == "LFVib"
    uin = audioread('LFVib1000ms44100.wav');
end

% Without Vibrato
if Excitation == "LF"
    uin = audioread('LFInput1000ms44100.wav');
end

% 1s of Noise
if Excitation == "WhiteNoise"
    cn = dsp.ColoredNoise('Color','White','SamplesPerFrame',44100);
    noise = cn();
    uin = noise;
end

% 1s of Pink Noise
if Excitation == "PinkNoise" || Excitation == "Noise"
    cn = dsp.ColoredNoise('Color','Pink','SamplesPerFrame',44100);
    noise = cn();
    uin = noise;
end

% 1s of Brown Noise
if Excitation == "BrownNoise"
    cn = dsp.ColoredNoise('Color','Brown','SamplesPerFrame',44100);
    noise = cn();
    uin = noise;
end

% ------------------------------
% Intialisation of Delay lines, outputs, boundary conditions
% and dithongs transitions
% ------------------------------

% Delay Lines
% Upper and lower delay lines
u_delay = zeros(nSegments, 1); % Upper Right-going Delay Line
l_delay = zeros(nSegments, 1); % Lower Left-going Delay Line
Pout = zeros(nSamples, 1);     % Output

% Boundary Conditions
r_g = 0.99; % Reflection (with loss) at glottis end
r_l = -0.99; % Reflection (with loss) at lip end

% Dipthong transitions
transition = linspace(0,1,nSamples);
transition2 = 1 - transition;

% Plosive
plosiveDuration = round(nSamples/8);
plosiveEnv = linspace(0,1,plosiveDuration);
plosiveBefore = ones(1,(PlosiveStartPosition));
plosiveAfter = ones(1,(nSamples-PlosiveStartPosition-plosiveDuration));
plosiveLine = [plosiveBefore plosiveEnv plosiveAfter];

%------ System Update Equations --------
for n=1:nSamples
    
    if dipthong
        % for when we're using dipthongs we need to move from one vowel to
        % the next over time
        for j=1:nSegments
            A(j) = transition2(n)*firstVowel(j) + transition(n)*secondVowel(j);
        end
    else
        % Select a vowel for synthesis
        for j=1:nSegments
            A(j) = firstVowel(j);
        end
    end
    
    if plosive
        plo = plosiveLine(n);
        A(44) = plo*A(44);
    end
    
    % Reflection coefficients derived from the cross-sectional areas
    % The array of k-values are the reflection coefficients from tube section
    % to tube section as defined by the Kelly-Lochbaum scattering junction
    
    k = (A(1:(nSegments-1))-A(2:nSegments))./(A(1:nSegments-1)+A(2:nSegments));
    
    % Boundary Condition 1 - glottis end
    % Reflection from lower delay line to upper line at closed glottal end
    % + contribution from input u(n).
    u_delay(1) = r_g*l_delay(1) + uin(n)*(rho*c)/A(1);
    
    % Scattering equations
    for i=1:nSegments-1
        temp  = k(i)*( u_delay(i)-l_delay(i+1) );
        u_delay(i+1) = u_delay(i) + temp;
        l_delay(i) = l_delay(i+1) + temp;
    end
    
    % Boundary Condition 2 - lip end
    % reflection from upper line to lower line at open lip
    l_delay(44) = r_l*u_delay(44);
    
    % Sum the upper and lower delay lines at the
    % last section to get the output
    Pout(n) = u_delay(44) + l_delay(44);
end


Pout = Pout/(max(abs(Pout)));     % Normalise output

% ---- Plot Graphs -----
if graphs
    figure(1);
    clf;
    plot(Pout);
    xlabel('time (samples)');
    ylabel('Amplitude');
    
    fftSize = 2^16;
    f = (0:fftSize-1)*(Fs/fftSize);
    
    figure(2);
    clf;
    plot(f,20*log10(abs(fft(Pout,fftSize))/max(abs(fft(Pout,fftSize)))));
    axis([0 5000 -100 0]);
%     xline(270,'r'); %F1
%     xline(2290,'r'); %F2

    grid on;
    xlabel('Frequency (Hz)');
    ylabel('Magnitude Response (dB)');
end

% --- Play and Write Audio ---
soundsc(Pout, Fs);

if saveFile
    if dipthong && plosive
        fileName = sprintf('VocalTractOutput_%s_%s_%s_plosive.wav',Excitation,firstVowelString,secondVowelString);
    elseif dipthong
        fileName = sprintf('VocalTractOutput_%s_%s_%s.wav',Excitation,firstVowelString,secondVowelString);
    elseif plosive
        fileName = sprintf('VocalTractOutput_%s_%s_plosive-%d.wav',Excitation,firstVowelString,PlosivePosition);
    else
        fileName = sprintf('VocalTractOutput_%s_%s.wav',Excitation,firstVowelString);
    end
    % Write File and output to prompt
    audiowrite(fileName, Pout, Fs);
    fprintf('----------\nwritten %s to disk\n----------\n',fileName);
end