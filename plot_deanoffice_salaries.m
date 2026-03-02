% Compare year-over-year salary growth for faculty vs dean's office.
% NOTE: This script expects a table named `D` in the workspace with columns:
%   - Name
%   - YR2020, YR2021, ..., YR2025

clear
cd('C:\Users\Ione Fine\OneDrive - UW\Documents\code\takebacktheacademy')
DO = readtable('Salariesuw_cleanest.xlsx'); 
yrList = 2020:2025;
yrListVal = [2019.5:2023.5 2026];


%% Inflation year-over-year (%) for Seattle
% Source: https://www.in2013dollars.com/Seattle-Washington/price-inflation/2025-to-2025?amount=1
infl = [4.49 8.89 5.99 3.68 2.07];

%% Faculty salaries (rows are faculty groups, columns are years in yrList)
% merit increases only
Fmerit = [175750      176950      181200      187600      194500      202350];

% including promotions, taken from the NCES data. Probably not valid to
% use because a shift towards junior faculty would show up as a decrease in
% salaries.
% Fpro = [138756.1559 130860.056 132719.9478 135744.7137 142647.645  147996.6988];

% Compute mean year-over-year faculty percent increase adjusted for inflation.
%F_per_inc_pro = NaN(1, numel(yrList) - 1);
F_per_inc_merit = NaN(1, numel(yrList) - 1);
for y = 2:numel(yrList)
 %   nominal_inc_pro = (Fpro(y) - Fpro(y - 1)) ./ Fpro(y - 1);
 %   F_per_inc_pro(y - 1) = 100 * nominal_inc_pro;
     nominal_inc_merit = 0.0 + ((Fmerit(y) - Fmerit(y - 1)) ./ Fmerit(y - 1));
    F_per_inc_merit(y - 1) = 100 * nominal_inc_merit;
end

%% Clean dean salary table and compute year-over-year changes
% Replace 0 entries with NaN so they are treated as missing values.
for y = 1:numel(yrList)
    fieldName = sprintf('YR%d', yrList(y));
    tmp = DO.(fieldName);
    tmp(tmp == 0) = NaN;
    DO.(fieldName) = tmp;
end

% D_per_inc(p, k) = inflation-adjusted percent increase for person p and year k,
% where k corresponds to transitions 2020->2021, ..., 2024->2025.
DO_per_inc_allstaff = NaN(size(DO, 1), numel(yrList) - 1);
DO_sal_allstaff = NaN(size(DO, 1), numel(yrList) - 1);

for y = 2:numel(yrList)
    prevField = sprintf('YR%d', yrList(y - 1));
    currField = sprintf('YR%d', yrList(y));

    for p = 1:size(DO, 1) % for each individual
        t1 = DO.(currField)(p);
        t2 = DO.(prevField)(p);

        if ~isnan(t1) && ~isnan(t2)
            tmp = 100 * ((t1 - t2) ./ t2);
            

            % Treat negative adjusted increases as missing.
            if tmp < 0
                DO_per_inc_allstaff(p, y - 1) = NaN;
                continue;
            end

            % if tmp > 30
            %     disp([DO.Name{p}, ' ', num2str(yrList(y - 1)), '-', num2str(t2), ...
            %           ' ', num2str(yrList(y)), '-', num2str(t1)]);
            % end

            DO_per_inc_allstaff(p, y - 1) = tmp;
            DO_sal_allstaff(p, y - 1) = t1;
        end
    end
end

DO_per_inc_med = nanmedian(DO_per_inc_allstaff);
DO_per_inc_mean = nanmean(DO_per_inc_allstaff);


figure(1); clf
subplot(2, 2,1); 
mksz = 10;lwdth = 2;
%plot(yrListVal(3:end), F_per_inc_pro(2:end), 'bo--', 'MarkerSize',mksz, 'MarkerFaceColor','b', 'MarkerEdgeColor','none','LineWidth', lwdth); hold on
plot(yrListVal(3:end), F_per_inc_merit(2:end), 'bo-', 'MarkerSize',mksz, 'MarkerFaceColor','b', 'MarkerEdgeColor','none','LineWidth', lwdth); hold on
plot(yrListVal(3:end), DO_per_inc_mean(2:end), 'ro-', 'MarkerSize', mksz, 'MarkerFaceColor','r', 'MarkerEdgeColor','none','LineWidth', lwdth);
plot(yrListVal(3:end), DO_per_inc_med(2:end), 'ro--', 'MarkerSize', mksz, 'MarkerFaceColor','r', 'MarkerEdgeColor','none','LineWidth', lwdth);
plot(yrListVal(3:end), infl(2:end), 'ko-', 'MarkerSize',mksz, 'MarkerFaceColor','k', 'MarkerEdgeColor','none','LineWidth', lwdth);
set(gca, 'XTickLabels', 2021:2026); set(gca, 'XLim', [2020.5 2026.5])
title('Salary increases & Inflation');
set(gca, "YLim", [0 14])

subplot(2, 2,2); 
%plot(yrListVal(3:end), F_per_inc_pro(2:end)-infl(2:end), 'bo--', 'MarkerSize',mksz, 'MarkerFaceColor','b', 'MarkerEdgeColor','none','LineWidth', lwdth);hold on
plot(yrListVal(3:end), F_per_inc_merit(2:end)-infl(2:end), 'bo-', 'MarkerSize',mksz, 'MarkerFaceColor','b', 'MarkerEdgeColor','none','LineWidth', lwdth);hold on
plot(yrListVal(3:end), DO_per_inc_mean(2:end)-infl(2:end), 'ro-', 'MarkerSize',mksz, 'MarkerFaceColor','r', 'MarkerEdgeColor','none','LineWidth', lwdth);
plot(yrListVal(3:end), DO_per_inc_med(2:end)-infl(2:end), 'ro--', 'MarkerSize',mksz, 'MarkerFaceColor','r', 'MarkerEdgeColor','none','LineWidth', lwdth);
set(gca, 'XTickLabels', 2021:2026);set(gca, 'XLim', [2020.5 2026.5])
plot(yrListVal, zeros(size(yrList)), 'k--')
title('Salary increases, Inflation Adjusted');


% Build cumulative raise multipliers and compare against cumulative inflation.
%Fcum_pro = NaN(1, numel(yrList) - 1);
Fcum_merit = NaN(1, numel(yrList) - 1);
DOcum_med = NaN(1, numel(yrList) - 1);
DOcum_mean = NaN(1, numel(yrList) - 1);
Icum = NaN(1, numel(yrList) - 1);

%Fcum_pro(1) = 1 ;
Fcum_merit(1) = 1 ;
DOcum_med(1) = 1 ;
DOcum_mean(1) = 1 ;
Icum(1) = 1 ;

for y = 2:numel(yrList) - 1
    %   F_inc_inf_pro = F_per_inc_pro(y)-infl(y);
    F_inc_inf_merit = F_per_inc_merit(y)-infl(y);
    DO_inc_inf_med = DO_per_inc_med(y)-infl(y);
    DO_inc_inf_mean = DO_per_inc_mean(y)-infl(y);
    %  Fcum_pro(y) = Fcum_pro(y - 1) * (1 + F_inc_inf_pro / 100);
    Fcum_merit(y) = Fcum_merit(y - 1) * (1 + F_inc_inf_merit / 100);
    DOcum_med(y) = DOcum_med(y - 1) * (1 + DO_inc_inf_med / 100);
    DOcum_mean(y) = DOcum_mean(y - 1) * (1 + DO_inc_inf_mean / 100);
end

subplot(2,2,3)
%h(1) = plot(yrListVal(3:end), Fcum_pro(2:end), 'bo--', 'MarkerSize',mksz, 'MarkerFaceColor','b', 'MarkerEdgeColor','none','LineWidth', lwdth);hold on
h(1) = plot(yrListVal(3:end), Fcum_merit(2:end), 'bo-', 'MarkerSize',mksz, 'MarkerFaceColor','b', 'MarkerEdgeColor','none','LineWidth', lwdth);hold on
h(2) = plot(yrListVal(3:end), DOcum_med(2:end), 'ro--', 'MarkerSize',mksz, 'MarkerFaceColor','r', 'MarkerEdgeColor','none','LineWidth', lwdth);
h(3) = plot(yrListVal(3:end), DOcum_mean(2:end), 'ro-', 'MarkerSize',mksz, 'MarkerFaceColor','r', 'MarkerEdgeColor','none','LineWidth', lwdth);
set(gca, 'XTickLabels', 2021:2026);set(gca, 'XLim', [2020.5 2026.5])
xlabel('year');
ylabel('Year on year %age Increase in Salary, Inflation Adjusted');

legend(h, {'Faculty M only', 'Deans office median', 'Deans office mean'}, 'Location', "eastoutside");

%% sum salary increases
disp('%===============================================%')
disp(['Average DO salary increase ', num2str(100*(DOcum_mean(end)-1))]); % compensation for the time samples for salary 
%disp(['Average Faculty salary increase P&M ', num2str(100*(Fcum_pro(end)-1))]); % compensation for the time samples for salary
disp(['Faculty salary increase M only ', num2str(100*(Fcum_merit(end)-1))]); % compensation for the time samples for salary

%% mean salary increases

disp(['Average DO annual salary increase ', num2str(100*(DOcum_mean(end)-1)/4.5)]); % compensation for the time samples for salary 
%disp(['Average Faculty annual salary increase P&M ', num2str(100*(Fcum_pro(end)-1)/4.5)]); % compensation for the time samples for salary
disp(['Average Faculty annual salary increase M only ', num2str(100*(Fcum_merit(end)-1)/4.5)]); % compensation for the time samples for salary

%% what does this cost us
DOcost = sum(DO.YR2025 .* 1.271); % cost of admin salary plus benefits, very conservative since most benefit rates higher
%DOcost = sum(DO.YR2025 .* 1.377); % cost of admin salary plus benefits, very conservative since most benefit rates higher

rebalance = Fcum_merit(end)/DOcum_mean(end); % if DO were multiplied by this, they would similarly sufffer a ~9% cut since 2021
DOcost_rebalanced = DOcost * rebalance;
DOsavings = DOcost - DOcost_rebalanced;
disp(['Average Savings rebalanced M only ', num2str(DOsavings/10^6)]);


% %% most recent increase in salaries
% subplot(2,2, 4);
% sal = DO_sal_allstaff(: , end); inc = DO_per_inc_allstaff(:, end);
% ind = ~isnan(sal.*inc);
% corr(sal(ind), inc(ind))
% plot(sal(ind)/1000, inc(ind), 'k*')
% 
