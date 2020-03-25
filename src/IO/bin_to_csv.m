function bin_to_csv(fnames, V, vmax, n_col, ns)

%% pars
names = fieldnames(V)';
write_output(['n_pars', names(vmax>1)], {''}, fnames.pars_file, n_col.pars, ns)
% write_output(['n_pars', {V(vmax>1).Name}], {''}, fnames.pars_file, n_col.pars, ns)

%% veg
veg_names = {'simulation_number', 'year', 'DoY', 'aPAR', 'aPARbyCab', 'aPARbyCab(energyunits)', 'Photosynthesis', 'Electron_transport', 'NPQ_energy', 'LST'};
veg_units = {'', '', '', 'umol m-2 s-1', 'umol m-2 s-1', 'W m-2', 'umol m-2 s-1', 'umol m-2 s-1', 'W m-2', 'K'};
write_output(veg_names, veg_units, fnames.veg_file, n_col.veg, ns)

%% fluor
if isfield(fnames, 'fluor_file')
    fluor_names = {'F_1stpeak', 'wl_1stpeak', 'F_2ndpeak', 'wl_2ndpeak', 'F687', 'F760', 'LFtot', 'EFtot', 'EFtot_RC'};
    fluor_units = {'W m-2 um-1 sr-1','nm','W m-2 um-1 sr-1','nm','W m-2 um-1 sr-1','W m-2 um-1 sr-1','W m-2 sr-1','W m-2','W m-2'};
    write_output(fluor_names, fluor_units, fnames.fluor_file, n_col.fluor, ns)
        
    write_output({'fluorescence_spectrum 640:1:850 nm'}, {'W m-2 um-1 sr-1'}, ...
        fnames.fluor_spectrum_file, n_col.fluor_spectrum, ns, true)

    write_output({'escape probability 640:1:850 nm'}, {'sr-1'}, ...
        fnames.sigmaF_file, n_col.sigmaF, ns, true)
    
    write_output({'fluorescence_spectrum 640:1:850 nm hemispherically integrated'}, {'W m-2 um-1'}, ...
        fnames.fhemis_file, n_col.fhemis, ns, true)  
    
    write_output({'upwelling radiance including fluorescence'}, {'W m-2 um-1 sr-1'}, ...
        fnames.Lo2_file, n_col.Lo2, ns, true) 
end

%% reflectance
write_output({'reflectance'}, {'pi*upwelling radiance/irradiance'}, ...
    fnames.r_file, n_col.r, ns, true) 

write_output({'rsd'}, {'directional-hemispherical reflectance factor'}, ...
    fnames.rsd_file, n_col.rsd, ns, true) 

write_output({'rdd'}, {'bi-hemispherical reflectance factor'}, ...
    fnames.rdd_file, n_col.rdd, ns, true) 

write_output({'rso'}, {'bi-directional reflectance factor'}, ...
    fnames.rso_file, n_col.rso, ns, true) 

%% radiance
write_output({'hemispherically integrated upwelling radiance'}, {'W m-2 um-1'}, ...
    fnames.Eout_file, n_col.Eout, ns, true) 

write_output({'upwelling radiance excluding fluorescence'}, {'W m-2 um-1 sr-1'}, ...
    fnames.Lo_file, n_col.Lo, ns, true) 

write_output({'direct solar irradiance'}, {'W m-2 um-1 sr-1'}, ...
    fnames.Esun_file, n_col.Esun, ns, true) 

write_output({'diffuse solar irradiance'}, {'W m-2 um-1 sr-1'}, ...
    fnames.Esky_file, n_col.Esky, ns, true) 

fclose('all');

%% deleting .bin
structfun(@delete, fnames)
end

function write_output(header, units, bin_path, f_n_col, ns, not_header)
    if nargin == 5
        not_header = false;
    end
    n_csv = strrep(bin_path, '.bin', '.csv');
    
    f_csv = fopen(n_csv, 'w');
    header_str = [strjoin(header, ','), '\n'];
    if not_header
        header_str = ['#' header_str];
    else
        % it is a header => each column must have one
        assert(length(header) == f_n_col, 'Less headers than lines `%s`', bin_path)
    end
    fprintf(f_csv, header_str);
    fprintf(f_csv, ['#' strjoin(units, ','), '\n']);
    
    f_bin = fopen(bin_path, 'r');
    out = fread(f_bin, 'double');
%     fclose(f_bin);  % + some useconds to execution
    
    out_2d = reshape(out, f_n_col, ns)';
%     dlmwrite(n_csv, out_2d, '-append', 'precision', '%d'); % SLOW!
    for k=1:ns
        fprintf(f_csv, '%d,', out_2d(k, 1:end-1));
        fprintf(f_csv, '%d\n', out_2d(k, end));  % saves from extra comma
    end
%     fclose(f_csv);
end
