in_dir="/home/steve/out/collated/"
out_dir="/home/steve/out/"

deficit_files=$(find $in_dir -type f -name "Deficit*" -print)

parallel -j 12 cdo yearsum {} {}_sum.nc ::: $deficit_files

out_files=$(find $out_dir -type f -name "Deficit*_sum.nc" -print)

cdo mergetime $out_files $out_dir/Deficit_annual_sum_burroughs.nc

aet_files=$(find $in_dir -type f -name "AET*" -print)

parallel -j 12 cdo yearsum {} {}_sum.nc ::: $aet_files

out_files=$(find $out_dir -type f -name "AET*_sum.nc" -print)

cdo mergetime $out_files $out_dir/AET_annual_sum_burroughs.nc
