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

cd dl-poly-5.1.0/execute

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
./store "${current_date_time}" 2>/dev/null
./cleanup 2>/dev/null

echo "Finished"