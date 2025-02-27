#!/bin/bash
echo "Running ViT (test)"

if ls lsf.* 1> /dev/null 2>&1
then
    echo "lsf files do exist"
    echo "removing older lsf files"
    rm lsf.*
fi

module load gcc/8.2.0 python_gpu/3.8.5 cuda/11.3.1 eth_proxy
source ../venv/bin/activate

args=(
    -G s_stud_infk
    -n 1
    -W 1:00
    -R "rusage[mem=12000]"
)

if [ -z "$1" ]; then echo "CPU mode selected"; fi
while [ ! -z "$1" ]; do
    case "$1" in
        gpu)
            echo "GPU mode selected"
            args+=(-R "rusage[ngpus_excl_p=8]")
        args+=(-R "select[gpu_mtotal0>=10240]")
            ;;
        intr)
            echo "Interactive mode selected"
            args+=(-Is)
            ;;
    esac
    shift
done

bsub "${args[@]}" "python classify.py combined" 
bsub "${args[@]}" "python classify.py background" 
