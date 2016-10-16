function [ train_list, val_list ] = compute_train_val_split( full_dataset, train_percentage, plot_clusters)
%COMPUTE_TRAIN_VAL_SPLIT Computes the train and validation splits 
% Given a full dataset (in a nonscalar struct, as returned by
% read_train_dataset.m) and the percentage of elements in the train split
% (train_percentage), it returns a list of the elements that belong to the
% train split (approximately train_percentage % of the elements in the full
% dataset) and a list of the elements that belong to the validation split 
% (approximately (100 - train_percentage) % of the
% elements in the full dataset).

if nargin < 3
    plot_clusters = 0;
end

% Pre-allocate features matrix
dataset_length = length(full_dataset);
num_features = 5; % area, height, width, filling ratio and form factor
X = zeros(dataset_length, num_features + 1); % The added one stands for the type of signal

% Initialize train and val lists
train_list = [];
val_list = [];

% Train and val probabilities
train_prob = double(train_percentage) / 100;

% Compute features matrix for each signal category 
for i=1:dataset_length
    
    % Get the information from the ground truth
    [bound_box, type, num_elems] = parse_annotations(full_dataset(i).annotations);
    mask = imread(full_dataset(i).mask);
    
    % If an image has more than one signal, get one of them at random
    rand_int = round(rand(1)*(num_elems - 1)) + 1;
    bound_box = bound_box(rand_int, :);
    type = type{rand_int};
    
    % Compute features
    [area, height, width] = bbParam(bound_box);
    f_ratio = filling_ratio(bound_box, mask);
    f_factor = form_factor(bound_box);
   
    X(i,:) = [type, area, height, width, f_ratio, f_factor];
    
end

% Iterate over all categories of signals to cluster them by features,
% and then select a partition for each cluster for each type of signal
num_categories = 6;
categories_names = {'Type A', 'Type B', 'Type C', 'Type D', 'Type E', 'Type F'};
k_clustering = [2 2 2 2 2 2];   % k clustering value for each category
for cat=1:num_categories
   % Get features matrix for that category 
   matrix_indices = X(:, 1) == cat;
   X_cat = X(matrix_indices, 2:end);
   
   % k-means clustering algorithm
   k_cat = k_clustering(cat);
   cluster_indices = kmeans(X_cat, k_cat);
   original_matrix_ind = find(matrix_indices);
   
   % PCA to plot the clusters
   if plot_clusters
       [coeff, score, dummy] = pca(X_cat);
       vbls = {'area', 'height', 'width', 'filling ratio', 'form factor'};
   end
   
   % For each cluster, shuffle all the indices and split them in train and
   % validation depending on the train_percentage value.
   colors = [0.9 0.1 0.1; 0.1 0.1 0.9];
   for c_ind=1:k_cat
       
       % Random permutation
       selection_ind = cluster_indices == c_ind;
       m_ind = original_matrix_ind(selection_ind);
       num_elems_cluster = length(m_ind);
       rand_permutation = randperm(num_elems_cluster);
       m_ind_shuffled = m_ind(rand_permutation);
       
       % Scatter plot of clusters
       if plot_clusters
           f = scatter(score(selection_ind, 1), score(selection_ind, 2), 25, colors(c_ind, :), 'filled');
           hold on;
       end
       
       % Append the indices to the train and validation set
       train_list = [train_list; m_ind_shuffled(1:round(train_prob*num_elems_cluster))];
       val_list = [val_list; m_ind_shuffled((round(train_prob*num_elems_cluster) + 1):end)];
       
   end
   if plot_clusters
       xlabel('PC 1');
       ylabel('PC 2');
       title(categories_names{cat});
       waitfor(f);
   end
end

end

