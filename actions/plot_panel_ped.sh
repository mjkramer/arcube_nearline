#!/usr/bin/env bash

set -o errexit

inbase=/global/cfs/cdirs/dune/www/data/2x2/nearline/packet
json_outbase=/global/cfs/cdirs/dune/www/data/2x2/nearline/panel_ped/jsons
plot_outbase=/global/cfs/cdirs/dune/www/data/2x2/nearline/panel_ped/plots
log_outbase=/pscratch/sd/d/dunepr/logs/nearline/panel_ped

inpath=$1; shift

get_outpath() {
    outbase=$1
    ext=$2

    indir=$(dirname "$inpath")
    reldir=$(echo "$indir" | sed "s|^$inbase/||")
    outname=$(basename "$inpath").panel_ped.$ext
    echo "$outbase/$reldir/$outname"
}

jsonpath=$(get_outpath "$json_outbase" json)
plotpath=$(get_outpath "$plot_outbase" png)
logpath=$(get_outpath "$log_outbase" log)

cd "$(dirname "${BASH_SOURCE[0]}")/plot_panel_ped"

if [[ "$(stat -c %s "$inpath")" -gt 10000000000 ]]; then
    echo "File is larger than 10 GB; bailing"
    exit 1
fi

mkdir -p "$(dirname "$jsonpath")" "$(dirname "$plotpath")" "$(dirname "$logpath")"

./make-mean-std-json.py --input_file "$inpath" --output_file "$jsonpath" 2>&1 | tee "$logpath"
./make_8iog_panel_ped.py --input_file "$jsonpath" --output_file "$plotpath" 2>&1 | tee "$logpath"