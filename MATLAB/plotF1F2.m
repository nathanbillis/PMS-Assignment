% Mapping Synthserised F1 and F2 Formant Pairs compared to G. E. Peterson
% and H. L. Barney, “Control methods used in a study of the vowels,”
% Journal of the Acoustical Society of America, vol. 24, no. 2, pp.
% 175-184, March 1952.
% Written by Y3859177

dataset = "Men";

% Peterson and Barney Average Vowel Formants for Men
if dataset == "Men"
    PBi = [270 2290 3010];
    PBV = [640 1190 1390];
    PBU = [440 1020 2240];
    PBae = [660 1720 2410];
    PBa = [730 1090 2440];
    PBu = [300 870 2240];
end

% Peterson and Barney Average Vowel Formants for Women
if dataset == "Women"
    PBi = [310 2790 3310];
    PBV = [760 1400 2780];
    PBU = [470 1160 2680];
    PBae = [860 2050 2850];
    PBa = [850 1220 2820];
    PBu = [370 950 3670];
end


% Synthesied Vowels Formants
i = [232.828509   2416.477487   3449.157149];
V = [710.378629   1336.907703   2867.089307];
U = [393.328962   931.706539   2729.044706];
ae = [667.000214   1947.383714   2366.745781];
a = [796.816725   1197.740121   2945.329972];
u = [253.381504   849.261822   2554.408231];

% ----- Plot Vowels --------
fi = figure('Name','F1 F2 Plots');

hold;
scatter(PBi(2),PBi(1),'b');
scatter(PBV(2),PBV(1),'b');
scatter(PBU(2),PBU(1),'b');
scatter(PBae(2),PBae(1),'b');
scatter(PBa(2),PBa(1),'b');
scatter(PBu(2),PBu(1),'b');
text(PBi(2)-10, PBi(1)-10, "i");
text(PBV(2)-10, PBV(1)-10, "V");
text(PBU(2)-10, PBU(1)-10, "U");
text(PBae(2)-10, PBae(1)-10, "ae");
text(PBa(2)-10, PBa(1)-10, "a");
text(PBu(2)-10, PBu(1)-10, "u");

scatter(i(2),i(1),'r');
scatter(V(2),V(1),'r');
scatter(U(2),U(1),'r');
scatter(ae(2),ae(1),'r');
scatter(a(2),a(1),'r');
scatter(u(2),u(1),'r');

text(i(2)-10, i(1)-10, "i");
text(V(2)-10, V(1)-10, "V");
text(U(2)-10, U(1)-10, "U");
text(ae(2)-10, ae(1)-10, "ae");
text(a(2)-10, a(1)-10, "a");
text(u(2)-10, u(1)-10, "u");

plot([2500,2000],[200,800],'b');
plot([750,2000],[800,800],'b');
plot([750,750],[800,200]),'b';
plot([750,2500],[200,200],'b');



grid on;
ax = gca;               % get current axis and assign it the label “ax”
ax.XDir = "reverse";    % change X direction
ax.YDir = "reverse";  

xlabel('F2 (Hz)') 
ylabel('F1 (Hz)') 
