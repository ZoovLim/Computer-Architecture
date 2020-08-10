#include "conv.h"

void convolution(const int M, const int N, const int *input, int *output, const int filter[3][3]) 
{	
	//Write your code here
	output[0] += input[0] * filter[1][1];
	output[0] += input[1] * filter[1][2];
	output[0] += input[N] * filter[2][1];
	output[0] += input[N + 1] * filter[2][2];
	output[N - 1] += input[N - 2] * filter[1][0];
	output[N - 1] += input[N - 1] * filter[1][1];
	output[N - 1] += input[N + N - 2] * filter[2][0];
	output[N - 1] += input[N + N - 1] * filter[2][1];
	
	for(register int j = 1; j < N - 1; j++) {
		output[j] += input[j - 1] * filter[1][0];
		output[j] += input[j] * filter[1][1];
		output[j] += input[j + 1] * filter[1][2];
		output[j] += input[N + j - 1] * filter[2][0];
		output[j] += input[N + j] * filter[2][1];
		output[j] += input[N + j + 1] * filter[2][2];
		output[(M - 1) * N + j] += input[(M - 2) * N + j - 1] * filter[0][0];
		output[(M - 1) * N + j] += input[(M - 2) * N + j] * filter[0][1];
		output[(M - 1) * N + j] += input[(M - 2) * N + j + 1] * filter[0][2];
		output[(M - 1) * N + j] += input[(M - 1) * N + j - 1] * filter[1][0];
		output[(M - 1) * N + j] += input[(M - 1) * N + j] * filter[1][1];
		output[(M - 1) * N + j] += input[(M - 1) * N + j + 1] * filter[1][2];
	}
	
	output[(M - 1) * N] += input[(M - 2) * N] * filter[0][1];
	output[(M - 1) * N] += input[(M - 2) * N + 1] * filter[0][2];
	output[(M - 1) * N] += input[(M - 1) * N] * filter[1][1];
	output[(M - 1) * N] += input[(M - 1) * N + 1] * filter[1][2];
	output[(M - 1) * N + N - 1] += input[(M - 2) * N + N - 2] * filter[0][0];
	output[(M - 1) * N + N - 1] += input[(M - 2) * N + N - 1] * filter[0][1];
	output[(M - 1) * N + N - 1] += input[(M - 1) * N + N - 2] * filter[1][0];
	output[(M - 1) * N + N - 1] += input[(M - 1) * N + N - 1] * filter[1][1];
	
	for(register int i = 1; i < M - 1; i++) {
		output[i * N] += input[(i - 1) * N] * filter[0][1];
		output[i * N] += input[(i - 1) * N + 1] * filter[0][2];
		output[i * N] += input[i * N] * filter[1][1];
		output[i * N] += input[i * N + 1] * filter[1][2];
		output[i * N] += input[(i + 1) * N] * filter[2][1];
		output[i * N] += input[(i + 1) * N + 1] * filter[2][2];
		
		output[i * N + N - 1] += input[(i - 1) * N + N - 2] * filter[0][0];
		output[i * N + N - 1] += input[(i - 1) * N + N - 1] * filter[0][1];
		output[i * N + N - 1] += input[i * N + N - 2] * filter[1][0];
		output[i * N + N - 1] += input[i * N + N - 1] * filter[1][1];
		output[i * N + N - 1] += input[(i + 1) * N + N - 2] * filter[2][0];
		output[i * N + N - 1] += input[(i + 1) * N + N - 1] * filter[2][1];
	}
	
	for(register int i = 1; i < M - 1; i++) {
		for(register int j = 1; j < N - 1; j++) {	
			output[i * N + j] += input[(i - 1) * N + (j - 1)] * filter[0][0] + input[(i - 1) * N + (j - 1)] * filter[0][0] + input[(i - 1) * N + j] * filter[0][1] + input[(i - 1) * N + (j + 1)] * filter[0][2] + input[i * N + (j - 1)] * filter[1][0] + input[i * N + j] * filter[1][1] + input[i * N + (j + 1)] * filter[1][2] + input[(i + 1) * N + (j - 1)] * filter[2][0] + input[(i + 1) * N + j] * filter[2][1] + input[(i + 1) * N + (j + 1)] * filter[2][2];
		}
	}
}
