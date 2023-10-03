%% Beans_Data_Sixten
clear all;
clc; 
close all; 

% Define path
cdir = fileparts(mfilename('fullpath'));
% Load data
[NUMERIC, TXT, RAW] = xlsread(fullfile(cdir,'Dry_Bean_Dataset.xlsx'));

X = NUMERIC(1:end,1:16); 

% Extract attribute names from the first row
attributeNames = RAW(1,1:16)';

% Extract unique class names from the last column
classLabels = RAW(2:end,end);
classNames = unique(classLabels);

[~,y] = ismember(classLabels, classNames); y = y-1;

[N, M] = size(X);
C = length(classNames);

% We start with a box plot of each attribute
mfig('Beans: Boxplot');
boxplot(X, attributeNames, 'LabelOrientation', 'inline');

% box plot of standardized data (using the zscore function).
mfig('Beans: Boxplot (standardized)');
boxplot(zscore(X), attributeNames, 'LabelOrientation', 'inline');


% Next, we plot histograms of all attributes.

mfig('Beans: Histogram'); clf;
for m = 1:M
    u = floor(sqrt(M)); v = ceil(M/u);
    subplot(u,v,m);
	hist(X(:,m));
	xlabel(attributeNames{m});      
	axis square;
end
linkax('y'); % Makes the y-axes equal for improved readability


%% PCA 

% Plot data

% Data attributes to be plotted
i = 8;
j = 12;

% Make a simple plot of the i'th attribute against the j'th attribute
mfig('Beans: Data'); clf;
plot(X(:,i), X(:,j),'o');
axis tight

% Make another more fancy plot that includes legend, class labels, 
% attribute names, and a title
mfig('Beans: Classes'); clf; hold all; 
C = length(classNames);
% Use a specific color for each class (easy to reuse across plots!):
colors = get(gca, 'colororder'); 
% Here we the standard colours from MATLAB, but you could define you own.
for c = 0:C-1
    h = scatter(X(y==c,i), X(y==c,j), 50, 'o', ...
                'MarkerFaceColor', colors(c+1,:), ...
                'MarkerEdgeAlpha', 0, ...
                'MarkerFaceAlpha', .5);
end
% You can also avoid the loop by using e.g.: (but in this case, do not call legend(classNames) as it will overwrite the legend with wrong entries) 
% gscatter(X(:,i), X(:,j), classLabels)
legend(classNames);
axis tight
xlabel(attributeNames{i});
ylabel(attributeNames{j});
title('Correlation of "Area" and "Convex Area"');

% Varience explained 

mx=mean(X);
% Subtract the mean from the data
Y = bsxfun(@minus, X, mean(X));

% Obtain the PCA solution by calculate the SVD of Y
[U, S, V] = svd(Y);

% Compute variance explained
rho = diag(S).^2./sum(diag(S).^2);
threshold = 0.9;

% Plot variance explained
mfig('Beans: Var. explained'); clf;
hold on
plot(rho, 'x-');
plot(cumsum(rho), 'o-');
plot([0,length(rho)], [threshold, threshold], 'k--');
legend({'Individual','Cumulative','Threshold'}, ...
        'Location','best');
ylim([0, 1]);
xlim([1, length(rho)]);
grid minor
xlabel('Principal component');
ylabel('Variance');
title('Variance explained by principal components');


% Index of the principal components
i = 1;
j = 2;

% Compute the projection onto the principal components
Z = U*S;

% Plot PCA of data
mfig('Beans: PCA Projection'); clf; hold all; 
C = length(classNames);
colors = get(gca,'colororder');
for c = 0:C-1
    scatter(Z(y==c,i), Z(y==c,j), 50, 'o', ...
                'MarkerFaceColor', colors(c+1,:), ...
                'MarkerEdgeAlpha', 0, ...
                'MarkerFaceAlpha', .5);
end
legend(classNames);
%axis tight
axis equal
xlabel(sprintf('PC %d', i));
ylabel(sprintf('PC %d', j));
title('PCA Projection of beans data');


pcs = 1:2; % change this to look at more/fewer, or compare e.g. [2,5]
mfig('Beans: PCA Component Coefficients');
h = bar(V(:,pcs));
legendCell = cellstr(num2str(pcs', 'PC%-d'));
legend(legendCell, 'location','best');
xticks([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]);
xtickangle(45)
xticklabels(attributeNames);
grid
xlabel('Attributes');
ylabel('Component coefficients');
title('PCA Component Coefficients');

% Inspecting the plot, we see that the 2nd principal component has large
% (in magnitude) coefficients for attributes A, E and H. We can confirm
% this by looking at it's numerical values directly, too:
disp('PC1:')
disp(V(:,1)') % notice the transpose for display in console 





