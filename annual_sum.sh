#!/bin/bash
set -euxo pipefail

export in_dir="${HOME}/out/collated"
export out_dir="${HOME}/out/sums"

vars="AET Deficit"
models="bcc-csm1-1-m bcc-csm1-1 BNU-ESM CanESM2 CNRM-CM5 CSIRO-Mk3-6-0 GFDL-ESM2G GFDL-ESM2M HadGEM2-CC365 HadGEM2-ES365 inmcm4 IPSL-CM5A-LR IPSL-CM5A-MR IPSL-CM5B-LR MIROC5 MIROC-ESM-CHEM MIROC-ESM MRI-CGCM3 NorESM1-M"
scenarios="rcp45 rcp85"

#models="historical"
#scenario="gridmet"

calc_annual_sum () {
    model=$1
    scenario=$2
    var=$3

    echo $model $scenario $var
    
    for file in ${in_dir}/${model}_${scenario}_${var}_*_burroughs.nc; do
	cdo yearsum $file "${file}_sum.nc"
    done

    cdo mergetime ${in_dir}/${model}_${scenario}_${var}*_sum.nc "${out_dir}/${model}_${scenario}_${var}_annual_sum_burroughs.nc"
}

export -f calc_annual_sum

parallel -j 96 calc_annual_sum {} ::: $models ::: $scenarios ::: $vars
