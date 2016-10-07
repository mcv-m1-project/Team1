function [ form_factor_list, ...
           form_factor_A, form_factor_B, form_factor_C, ...
           form_factor_D, form_factor_E, form_factor_F ] = form_factor( train_dataset )
%FORM_FACTOR Form factor (width / height) for all signals

form_factor_list = [];
form_factor_A = [];
form_factor_B = [];
form_factor_C = [];
form_factor_D = [];
form_factor_E = [];
form_factor_F = [];

% Iterate over all the dataset
for i=1:length(train_dataset)
    [bound_box, type, num_elems] = parse_annotations(train_dataset(i).annotations);
    for m=1:num_elems
        c1=bound_box(m, 1);
        c2=bound_box(m, 2);
        c3=bound_box(m, 3);
        c4=bound_box(m, 4);
        types=type{m};
        form_factor_value = (c3 - c1) / (c4 - c2);
        form_factor_list = [form_factor_list, form_factor_value];
        switch types
            case 'A'
                form_factor_A = [form_factor_A, form_factor_value];
            case 'B'
                form_factor_B = [form_factor_B, form_factor_value];
            case 'C'
                form_factor_C = [form_factor_C, form_factor_value];
            case 'D'
                form_factor_D = [form_factor_D, form_factor_value];
            case 'E'
                form_factor_E = [form_factor_E, form_factor_value];
            case 'F'
                form_factor_F = [form_factor_F, form_factor_value];
            otherwise
                % Do nothing
        end
    end
end

