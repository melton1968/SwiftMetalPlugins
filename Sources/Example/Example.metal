// Empty

kernel void add(device float *r,
		device float *a,
		device float *b,
		uint tid [[thread_position_in_grid]]) {
    r[tid] = a[tid] + b[tid];
}
