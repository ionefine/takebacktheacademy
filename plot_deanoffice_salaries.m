cd('C:\Users\Ione Fine\OneDrive - UW\Documents\code\TBA\Universities');

yrList = 2020:2025;

%% calculate inflation year over year

% https://www.in2013dollars.com/Seattle-Washington/price-inflation/2025-to-2025?amount=1
infl = [4.49 8.89 5.99 3.68 2.07];
infl = zeros(size(infl));

%% faculty salaries

figure(1); clf

%% calculate faculty salary increases
F = [189100	190400	195000	201900	209300 217752;
    162400	163500	167400	173300	179700 186948];

for y = 2:6
    F_per_inc(y-1) = 100*mean((F(:, y)-F(:, y-1))./F(:, y-1))-infl(y-1);
end

%% get rid of NaNs in dean list
for y = 2:6
    eval(['tmp  = D.YR', num2str(yrList(y)), '(:);'])
    tmp(tmp==0) = NaN;
    eval(['D.YR', num2str(yrList(y)), '=tmp']);
end

D_per_inc = NaN(size(D, 1),5)
for y = 3:6
    for p = 1:size(D, 1)
      eval(['t1 = D.YR', num2str(yrList(y)), '(p);']);
        eval(['t2 = D.YR', num2str(yrList(y-1)), '(p);'])
        if ~isnan(t1) && ~isnan(t2)
            tmp = 100*((t1-t2)./t2)-infl(y-1);
            if tmp<0
                D_per_inc(p, y-1) = NaN;
            end
            if tmp>30

                num1 = eval(['D.YR', num2str(yrList(y-1)), '(p);']);
                num2 = eval(['D.YR', num2str(yrList(y)), '(p);']);

                disp([D.Name{p}, ' ', num2str(yrList(y-1)) , '-', num2str(num1), ' ', num2str(yrList(y)), '-', num2str(num2)]);
            end
            D_per_inc(p, y-1) = tmp;
            end
        end
    end


D_per_inc_med = nanmedian(D_per_inc);
D_per_inc_mean = nanmean(D_per_inc);

f(1) = plot(yrList(2:end), F_per_inc, 'k-'); hold on
f(2) = plot(yrList(2:end), D_per_inc_mean, 'r-');

fcum = 1;
acum = 1;
icum = 1;
infl = [4.49 8.89 5.99 3.68 2.07];
for y = 2:5
    fcum(y) = fcum(y-1)*(1+F_per_inc(y)/100);
    acum(y) = acum(y-1)*(1+D_per_inc_mean(y)/100);
    icum(y)  = icum(y-1)*(1+infl(y)/100);
end

D_per_inc_med = nanmedian(D_per_inc);
D_per_inc_mean = nanmean(D_per_inc);
close all

plot(2021:2025, fcum-icum, 'k'); hold on
plot(2021:2025, acum-icum, 'r');
%plot(2021:2025, icum, 'g');

xlabel('year'); 
ylabel('year on year %age increase in salary');
legend({'faculty', 'deans office'});

f_final = fcum(end)-icum(end);
a_final = acum(end)-icum(end);

a_cost = sum(D.YR2025.*1.323);
a_cost*.225

%     D_per_inc(p, :) = D(p, 6:11)
% UA_per_inc = D(:, 6:11)./D(:, 6);
%
%     per_median_UA(y) = nanmedian(tmp).*infl(y); hold on
%     per_mean_UA(y) = nanmean(tmp)*infl(y); hold on
% plot(yrList,per_median_UA); hold on
% plot(yrList,per_mean_UA); hold on
% return

% %% Faculty salaries
%
% FAC = readtable(['University of Washington', filesep, 'NCES_collated_by_year_UW.csv']);
%
% for y = 1:length(yrList)
%     yr = yrList(y);
%     ind1 = find(INF.year==yr-1);
%     ind2 = find(INF.year==yr);
%     inflation1 = INF.inf_2024_SEA(ind1);
%     inflation2 = INF.inf_2024_SEA(ind2);
%
%     ind1 = find(FAC.year ==yr-1);
%     ind2 = find(FAC.year ==yr);
%     sal1 = (FAC.dF(ind1)/FAC.nF(ind1))*inflation1;
%     sal2 = (FAC.dF(ind2)/FAC.nF(ind2))*inflation2;
%     per_mean_FAC(y) = (100*(sal2-sal1)./sal1);
%
%     % calculate the effective cummulative effect of these salary increases
%     if y == 1
%         eff_inc_FAC(y) = 1 + per_mean_FAC(y)/100;
%         eff_inc_UA_mean(y) = 1 + per_mean_UA(y)/100;
%          eff_inc_UA_median(y) = 1 + per_median_UA(y)/100;
%     else
%         eff_inc_FAC(y) = eff_inc_FAC(y-1) *(1 + per_mean_FAC(y)/100);
%         eff_inc_UA_mean(y) = eff_inc_UA_mean(y-1) * (1 + per_mean_UA(y)/100);
%         eff_inc_UA_median(y) = eff_inc_UA_median(y-1) * (1 + per_median_UA(y)/100);
%     end
%
% end
% figure(2); clf
% plot(yrList, per_median_UA, '--','Color', [.5 0 .5], 'LineWidth',2); hold on
% plot(yrList, per_mean_UA, '-','Color', [.5 0 .5], 'LineWidth',2); hold on
% plot(yrList, per_mean_FAC, '-','Color', [0 0 1], 'LineWidth',2);
% set(gca, 'XTick', [2021:2024]);
% set(gca, 'XLim', [2020.5 2024.5]);
% l  = line([2020.5 2024.5], [0 0 ]); set(l, 'Color', [.5 .5 .5], 'LineStyle', '--', 'LineWidth', .5)
% xlabel('year');
% ylabel('percent raise that year');
% legend({'Upper Admin median', 'Upper Admin mean', 'Faculty mean'});
%
% figure(3); clf
% plot([2020 yrList], [1 eff_inc_UA_median], '--','Color', [.5 0 .5], 'LineWidth',2); hold on
% plot([2020 yrList], [1 eff_inc_UA_mean], '-','Color', [.5 0 .5], 'LineWidth',2); hold on
% plot([2020 yrList], [1 eff_inc_FAC], '-','Color', [0 0 1], 'LineWidth',2);
% set(gca, 'XTick', [2020:2024]);
% set(gca, 'XLim', [2019.5 2024.5]);
% l  = line([2019.5 2024.5], [1 1]); set(l, 'Color', [.5 .5 .5], 'LineStyle', '--', 'LineWidth', .5)
% xlabel('year');
% ylabel('cummulative increases in salary');
% legend({'Upper Admin median', 'Upper Admin mean', 'Faculty mean'});
%
% data =