% Compare year-over-year salary growth for faculty vs dean's office.
% NOTE: This script expects a table named `D` in the workspace with columns:
%   - Name
%   - YR2020, YR2021, ..., YR2025

cd('C:\Users\Ione Fine\OneDrive - UW\Documents\code\TBA\Universities');

yrList = 2020:2025;

%% Inflation year-over-year (%) for Seattle
% Source: https://www.in2013dollars.com/Seattle-Washington/price-inflation/2025-to-2025?amount=1
infl = [4.49 8.89 5.99 3.68 2.07];

%% Faculty salaries (rows are faculty groups, columns are years in yrList)
F = [189100 190400 195000 201900 209300 217752;
     162400 163500 167400 173300 179700 186948];

% Compute mean year-over-year faculty percent increase adjusted for inflation.
F_per_inc = NaN(1, numel(yrList) - 1);
for y = 2:numel(yrList)
    nominal_inc = (F(:, y) - F(:, y - 1)) ./ F(:, y - 1);
    F_per_inc(y - 1) = 100 * mean(nominal_inc) - infl(y - 1);
end

%% Clean dean salary table and compute year-over-year changes
% Replace 0 entries with NaN so they are treated as missing values.
for y = 1:numel(yrList)
    fieldName = sprintf('YR%d', yrList(y));
    tmp = D.(fieldName);
    tmp(tmp == 0) = NaN;
    D.(fieldName) = tmp;
end

% D_per_inc(p, k) = inflation-adjusted percent increase for person p and year k,
% where k corresponds to transitions 2020->2021, ..., 2024->2025.
D_per_inc = NaN(size(D, 1), numel(yrList) - 1);

for y = 2:numel(yrList)
    prevField = sprintf('YR%d', yrList(y - 1));
    currField = sprintf('YR%d', yrList(y));

    for p = 1:size(D, 1)
        t1 = D.(currField)(p);
        t2 = D.(prevField)(p);

        if ~isnan(t1) && ~isnan(t2)
            tmp = 100 * ((t1 - t2) ./ t2) - infl(y - 1);

            % Treat negative adjusted increases as missing.
            if tmp < 0
                D_per_inc(p, y - 1) = NaN;
                continue;
            end

            if tmp > 30
                disp([D.Name{p}, ' ', num2str(yrList(y - 1)), '-', num2str(t2), ...
                      ' ', num2str(yrList(y)), '-', num2str(t1)]);
            end

            D_per_inc(p, y - 1) = tmp;
        end
    end
end

D_per_inc_med = nanmedian(D_per_inc);
D_per_inc_mean = nanmean(D_per_inc);

figure(1); clf
plot(yrList(2:end), F_per_inc, 'k-'); hold on
plot(yrList(2:end), D_per_inc_mean, 'r-');

% Build cumulative raise multipliers and compare against cumulative inflation.
fcum = NaN(1, numel(yrList) - 1);
acum = NaN(1, numel(yrList) - 1);
icum = NaN(1, numel(yrList) - 1);

fcum(1) = 1 + F_per_inc(1) / 100;
acum(1) = 1 + D_per_inc_mean(1) / 100;
icum(1) = 1 + infl(1) / 100;
for y = 2:numel(yrList) - 1
    fcum(y) = fcum(y - 1) * (1 + F_per_inc(y) / 100);
    acum(y) = acum(y - 1) * (1 + D_per_inc_mean(y) / 100);
    icum(y) = icum(y - 1) * (1 + infl(y) / 100);
end

close all
plot(2021:2025, fcum - icum, 'k'); hold on
plot(2021:2025, acum - icum, 'r');
xlabel('year');
ylabel('year on year %age increase in salary');
legend({'faculty', 'deans office'});

f_final = fcum(end) - icum(end); %#ok<NASGU>
a_final = acum(end) - icum(end); %#ok<NASGU>

a_cost = sum(D.YR2025 .* 1.323);
a_cost * .225
