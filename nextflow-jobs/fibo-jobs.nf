#!/usr/bin/env nextflow
nextflow.enable.dsl=2

workflow {
    channel.of(1, 2, 3) | emitFibonacci
}

process emitFibonacci {
    tag "fib-${val}"
    
    input:
    val val
    
    script:
    """
    echo "Starting Fibonacci generator for Task ${val}..."

    python3 - <<'PYCODE'
import time
from datetime import datetime

a, b = 0, 1
for i in range(20):
    current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f"[{current_time}] Task ${val} - Fibonacci #{i}: {a}", flush=True)
    a, b = b, a + b
    time.sleep(3)

print(f"Task ${val} completed!", flush=True)
PYCODE
    """
}
