#!/bin/bash
#SBATCH -J garnets
#SBATCH -t 1:30:00
#SBATCH -N 1
#SBATCH --tasks-per-node 15
#SBATCH --mem=60G


interrupted=0

# Define a function to run when the INT signal is received
handle_interrupt() {
    echo -e "\nDLPOLY was interrupted"
    kill -KILL "$pid"
    interrupted=1
}

cd sim

# Set up the trap
trap handle_interrupt INT
echo "Running DLPOLY..."
./DLPOLY.Z &

pid=$!

# Start the timer
start=$(date +%s)
while kill -0 $pid 2>/dev/null; do

    if [ $interrupted -eq 1 ]; then
        break
    fi

    now=$(date +%s)
    elapsed=$((now - start))
    echo -ne "Elapsed time: $elapsed seconds\033[0K\r"
    sleep 1
done

# Reset the trap to the default behavior
trap - INT

echo -e "\nSaving output files..."

current_date_time=$(date '+%Y-%m-%d_%H-%M-%S')
new_dir="../results/output_${current_date_time}"
mkdir "${new_dir}"

mv REVCON "${new_dir}" 2>/dev/null
mv OUTPUT "${new_dir}" 2>/dev/null
mv STATIS "${new_dir}" 2>/dev/null
mv HISTORY "${new_dir}" 2>/dev/null
mv RDFDAT "${new_dir}" 2>/dev/null
mv RDFOUT "${new_dir}" 2>/dev/null
mv REVIVE "${new_dir}" 2>/dev/null

cp CONTROL "${new_dir}" 2>/dev/null
cp CONFIG "${new_dir}" 2>/dev/null
cp FIELD "${new_dir}" 2>/dev/null

rm ../temp.cif 2>/dev/null

echo "Finished"