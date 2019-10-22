#include<stdio.h>
#define MEMSIZE 8
int writeCount = 0; //Shift every phi steps
int phi = 1;
int memory[MEMSIZE];
//Here MEMSIZE includes gapline also
int start = 0;
int gap = MEMSIZE - 1;


int translate(int logicalAddress)
{
	int physicalAddress = (logicalAddress + start) % (MEMSIZE-1);
	if(physicalAddress >= gap) return physicalAddress +1;
	else return physicalAddress;
}

//It is advisable to make this function a macro - A user defined instruction that is not part of the ISA
//That is - we make our own instruction called "sgmv" (Example), in contrast to the usual mv instruction in the ISA
void memAccess(int logicalAddress,int inp)
{
	writeCount ++;
	if(writeCount % phi != 0)
	{
		memory [translate(logicalAddress)] = inp;
		return;
	}
	

	if(gap != 0)
	{
		memory[gap] = memory[gap-1];
		gap--;
		memory [translate(logicalAddress)] = inp;
		return;
	}

	start = (start+1)%MEMSIZE;
	memory[gap] = memory[MEMSIZE-1];
	memory [translate(logicalAddress)] = inp;
	gap = MEMSIZE-1;
}


void printTable()
{
	int physical;

	printf("Physical Logical Data\n");
	for(int i =0;i<MEMSIZE-1;i++)
	{
		physical = translate(i);
		printf("%d\t%d\t%d\n",physical,i,memory[physical]);
	}
	printf("\nStart is at %d\nGap is at %d\n\n",start,gap);
}

int main()
{
	
	//Initialization
	for(int i=0;i<MEMSIZE -1;i++)
		memory[i] = i;
	printTable();

	for(int i = 0;i<30;i++)
	{
		memAccess(i%MEMSIZE,i%MEMSIZE);
		printTable();
	}

}
