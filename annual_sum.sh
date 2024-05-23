in_dir="/home/steve/out/collated/"
out_dir="/home/steve/out/"

deficit_files=$(find $in_dir -type f -name "Deficit*" -print)

parallel -j 12 cdo yearsum {} {}_sum.nc ::: $deficit_files

out_files=$(find $in_dir -type f -name "Deficit*_sum.nc" -print)

cdo mergetime $out_files $out_dir/Deficit_annual_sum_burroughs.nc

aet_files=$(find $in_dir -type f -name "AET*" -print)

parallel -j 12 cdo yearsum {} {}_sum.nc ::: $aet_files

out_files=$(find $in_dir -type f -name "AET*_sum.nc" -print)

cdo mergetime $out_files $out_dir/AET_annual_sum_burroughs.nc


### accumswe is generated for each pixel at the DEM scale, but is
### calculated from variables only derived from larger grids
### such as 4km climate and t50.
### Therefore, it's not very interesting to look at at the meter scale
# accumswe_files=$(find $in_dir -type f -name "accumswe*" -print)

# parallel -j 12 cdo -O yearmax {} {}_sum.nc ::: $accumswe_files

# out_files=$(find $in_dir -type f -name "accumswe*_sum.nc" -print)

# cdo -O mergetime $out_files $out_dir/accumswe_annual_max_burroughs.nc
