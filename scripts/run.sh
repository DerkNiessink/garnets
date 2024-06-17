#!/bin/bash
#SBATCH -J garnets
#SBATCH -t 20:00:00
#SBATCH -N 10
#SBATCH --mem=60G
#SBATCH --ntasks=1

module load 2022
module load 2023
module load foss/2023a


NUM_RUNS=10
BASE_DIR=$PWD/sim


# Function to modify the temperature in the CONTROL file
modify_control_file() {
    local run_number=$1
    local control_file=$2
    local temp_increase=$((run_number * 50))

    awk -v temp_increase="$temp_increase" '
    /temperature/ {
        $2 = $2 + temp_increase
    }
    { print }
    ' "$control_file" > "$control_file.modified"

    mv "$control_file.modified" "$control_file"
}


run_dlpoly_instance() {
    local instance_dir=$1

    cd "$instance_dir"

    echo "Running DLPOLY in $instance_dir..."
    srun --exclusive -n 1 --mem=6G DLPOLY.Z & 
    cd "$BASE_DIR"
}

for i in $(seq 1 $NUM_RUNS); do
    # Create a unique directory for this instance
    INSTANCE_DIR="$BASE_DIR/run_$i"
    mkdir -p "$INSTANCE_DIR"

    cp $BASE_DIR/FIELD "$INSTANCE_DIR"
    cp $BASE_DIR/CONFIG "$INSTANCE_DIR" 
    cp $BASE_DIR/DLPOLY.Z "$INSTANCE_DIR"

    # Copy and modify the CONTROL file for this instance
    cp $BASE_DIR/CONTROL "$INSTANCE_DIR/CONTROL"
    modify_control_file $i "$INSTANCE_DIR/CONTROL"

    # Run the DL_POLY instance in the background
    run_dlpoly_instance "$INSTANCE_DIR"
done

wait


echo "All DL_POLY runs finished"
