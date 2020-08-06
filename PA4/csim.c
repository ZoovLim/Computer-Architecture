#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include "cachelab.h"

//Results and Parameters
int hits = 0, misses = 0, evictions = 0, E = 0, S = 0, B = 0, s = 0, b = 0;

//Renew used_order Function
void renew(int set, int index, int valid[S][E], int used_order[S][E]) {
	for (int i = 0; i < E; i++) {
		if(valid[set][i] == 0) {
			continue;
		}
		if(used_order[set][i] <= used_order[set][index]) {
			continue;
		}
		used_order[set][i]--;
	}
	used_order[set][index] = E - 1;
}

//Simulate Function
void access(unsigned long long addr, int valid[S][E], int tag[S][E], int used_order[S][E]) {
	unsigned long long set_tmp = (addr << (64 - b - s) >> (64 - s)) & (0xffffffffffffffff >> b);
	unsigned long long tag_tmp = (addr >> (b + s)) & 0xffffffffffffffff;
	int set_index = (int) set_tmp;
	int tag_index = (int) tag_tmp;

	//Hit
	for (int i = 0; i < E; i++) {
		if (valid[set_index][i] == 0) {
			continue;
		}
		if (tag[set_index][i] != tag_index) {
			continue;
		}

		hits++;
		renew(set_index, i, valid, used_order);
		return;
	}

	//Miss
	misses++;

	for (int i = 0; i < E; i++) {
		if (valid[set_index][i] == 1) {
			continue;
		}
		valid[set_index][i] = 1;
		tag[set_index][i] = tag_index;
		renew(set_index, i, valid, used_order);
		return;
	}

	//Eviction	
	evictions++;

	for (int i = 0; i < E; i++) {
		if(used_order[set_index][i] != 0) {
			continue;
		}
		valid[set_index][i] = 1;
		tag[set_index][i] = tag_index;
		renew(set_index, i, valid, used_order);
		return;
	}
}

int main(int argc, char** argv)
{
	FILE* file = 0;
	char c;
	
	while ((c = getopt(argc, argv, "s:E:b:t:")) != -1) {
		switch (c) {
			case 's':
				s = atoi(optarg);
				S = 1 << s;
				break;
			case 'E':
				E = atoi(optarg);
				break;
			case 'b':
				b = atoi(optarg);
				B = 1 << b;
				break;
			case 't':
				if (!(file = fopen(optarg, "r"))) {
					return 1;
				}
				break;
			default:
				return 1;
		}
	}

	if (!s || !E || !b || !file) {
		return 1;
	}	
	
	int valid[S][E];
	int tag[S][E];
	int used_order[S][E];
	
	char command[100];
	char op;
	unsigned long long addr;
	int size;
  	
	for (int i = 0; i < S; i++) {
		for (int j = 0; j < E; j++) {
			valid[i][j] = 0;
			tag[i][j] = 0;
			used_order[i][j] = 0;
		}
	}

	while (fgets(command, sizeof(command), file)) {
		sscanf(command, " %c %llx,%d", &op, &addr, &size);

		if(command[0] == 'I') {
			continue;
		}
		
		switch (op) {
			case 'L':
				access(addr, valid, tag, used_order);
				break;
			case 'S':
				access(addr, valid, tag, used_order);
				break;
			case 'M':
				access(addr, valid, tag, used_order);
				access(addr, valid, tag, used_order);
			default:
				break;
		}
	}
    
	printSummary(hits, misses, evictions);
    fclose(file);
	return 0;
}
