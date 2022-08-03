classdef EuphonicSfTestBase < matlab.mock.TestCase

    methods (Static)
        function [expected_wmat, expected_sfmat] = get_expected_w_sf(material_name, model_kwargs)
            fname = get_expected_output_filename(material_name, ...
                                                 model_kwargs);
            load(fname, 'expected_w', 'expected_sf');
            expected_wmat = cell2mat(expected_w);
            expected_sfmat = cell2mat(expected_sf);
        end
        function summed_sf = sum_degenerate_modes(w, sf)
            % Need to sum over degenerate modes to compare structure factors
            tol = 0.1;
            [rows, cols] = size(w);
            diff = zeros(cols-1, 1);
            summed_sf = zeros(size(sf));
            for i=1:rows
                for j=1:cols-1
                    diff(j) = w(i, j+1) - w(i, j);
                end
                sum_at = find(diff > tol);
                x = zeros(cols, 1);
                x(sum_at + 1) = 1;
                degenerate_modes = cumsum(x);
                summed = accumarray(degenerate_modes + 1, sf(i,:));
                summed_sf(i,1:length(summed)) = summed;
            end
        end
        function zeroed_sf_mat = zero_acoustic_sf(sf_mat, model_kwargs)
            % Ignore acoustic structure factors by setting to zero - their
            % values can be unstable at small frequencies
            sf_mat(:, 1:3) = 0;
            idx = find(strcmp('negative_e', model_kwargs));
            if length(idx) == 1 && model_kwargs{idx + 1} == true
                n = size(sf_mat, 2)/2;
                sf_mat(:, n+1:n+3) = 0;
            end
            zeroed_sf_mat = sf_mat;
        end
    end
end