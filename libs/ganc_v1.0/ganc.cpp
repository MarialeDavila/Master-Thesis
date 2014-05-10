/*
 * GANC: Greedy Agglomerative Normalized Cut
 * Copyright (C) 2010 Seyed Salim Tabatabaei
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 * See http://www.gnu.org/licenses/gpl.txt for more details.
*/


/****************************************************************************** 
 * Author: Seyed Salim Tabatabaei (seyed.s.tabatabaei@mail.mcgill.ca)
 * Date: August 2010
 * Collaborators: 	Dr. Mark Coates (mark.coates@mcgill.ca)
 * 					Dr. Michael Rabbat (michael.rabbat@mcgill.ca)
*******************************************************************************/

////////////////////////////////////////////////////////////////////////
// Description of commandline arguments
// -f <filename>    give the target .[w]pairs file to be processed
// -c <int>		record the aglomerated network at step <int>
// --one-based 	used when the .[w]pairs file has node ids starting from 1
// --refine		perform post-processing of the clusters 
// -maxiter <+int>	indicates the maximum iterations of the refinement step
// --float-weight	increase weights to avoid possible underflow
////////////////////////////////////////////////////////////////////////

#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <ctime>
#include <cmath>
#include <cstdlib>
#include <map>
#include "maxheap.h"
#include "vektor.h"

using namespace std;

// ------------------------------------------------------------------------------------
// Edge object - defined by a pair of vertex indices and *edge pointer to next in linked-LIST
class edge {
public:
	int     so;					// originating node
	int     si;					// terminating node
	double     we;					// edge weight
	edge    *next;					// pointer for linked LIST of edges
	
	edge();						// default constructor
	~edge();						// default destructor
};
edge::edge()  { so = 0; si = 0; next = NULL; }
edge::~edge() {}

// ------------------------------------------------------------------------------------
// Nodenub object - defined by a *node pointer and *node pointer 
struct nodenub {
	tuple	*heap_ptr;			// pointer to node(max,i,j) in max-heap of row maxes
	vektor    *v;					// pointer stored vector for (i,j)
};

// ------------------------------------------------------------------------------------
// Boundary node object
struct boundary_node
{
	int c;	// cluster it connects to
	double x;	// sumweight of connection
};
// ------------------------------------------------------------------------------------
// tuple object - defined by an real value and (row,col) indices
#if !defined(TUPLE_INCLUDED)
#define TUPLE_INCLUDED
struct tuple {
	double	m;					// stored value
	
	double m2;					// second stored value (adjacency)
	
	int		i;					// row index
	int		j;					// column index
	int		k;					// heap index
};
#endif

// ordered pair structures (handy in the program)
struct apair { int x; int y; };
#if !defined(DPAIR_INCLUDED)
#define DPAIR_INCLUDED
class dpair {
public:
	int x; double y; double zz; dpair *next;
	dpair(); ~dpair();
};
dpair::dpair()  { x = 0; y = 0.0; zz = 0.0; next = NULL; }
dpair::~dpair() {}
#endif

// ------------------------------------------------------------------------------------
// List object - simple linked LIST of integers
class LIST {
public:
	int		index;				// node index
	LIST		*next;				// pointer to next element in linked LIST
	LIST();   ~LIST();
};
LIST::LIST()  { index= 0; next = NULL; }
LIST::~LIST() {}

// ------------------------------------------------------------------------------------
// Community stub object - stub for a community LIST
class stub {
public:
	bool		valid;				// is this community valid?
	int		size;				// size of community
	LIST		*members;				// pointer to LIST of community members
	LIST		*last;				// pointer to end of LIST
	stub();   ~stub();
};
stub::stub()  { valid = false; size = 0; members = NULL; last = NULL; }
stub::~stub() {
	LIST *current;
	if (members != NULL) {
		current = members;
		while (current != NULL) { members = current->next; delete current; current = members; }
	}
}

// ------------------------------------------------------------------------------------
// Neighborhood node object -----------------------------------------------------------
class nbnode {
public: double we;		// weight of connection
	unsigned int j;	// connected to
	nbnode *next;	// pointer to next entry
	nbnode() {we = 0; j=0; next = NULL;}
	~nbnode() {}
};

// ------------------------------------------------------------------------------------
// FUNCTION DECLARATIONS --------------------------------------------------------------

void buildXMatrix();
void buildFilenames();
void groupListsSetup();
void groupListsUpdate(const int x, const int y);
void mergeCommunities(int i, int j);
bool parseCommandLine(int argc,char * argv[]);
void readInputFile();
void recordGroupLists();
void recordNAssoc(); //record normalized association as a functon of algorithm step
void recordCurv(); //record curvature as a functon of algorithm step
void createPartVector();	//creates a vector of partition numbers (N by 1) and set numGroups
void doRefine();	//do the refinement step
void joinsAlone();	// given the joins file, create goupLists


// ------------------------------------------------------------------------------------
// PROGRAM PARAMETERS -----------------------------------------------------------------

struct netparameters {
	int			n;				// number of nodes in network
	int			m;				// number of edges in network
	double			w;				// total weight of edges in network
	int			maxid;			// maximum node id
	int			minid;			// minimum node id
}; netparameters    gparm;

struct outparameters {
	short int		textFlag;			// 0: no console output
								// 1: writes file outputs
	short int		fileFlag;			// 
	string		filename;			// name of input file
	string		d_in;			// (dir ) directory for input file
	string		d_out;			// (dir ) director for output file
	string		f_parm;			// (file) parameters output
	string		f_input;			// (file) input data file
	string		f_joins;			// (file) community hierarchy
	string		f_net;			// (file) .wpairs file for .cutstep network
	string		f_group;			// (file) .LIST of indices in communities at .cutstep
	
	string		f_group2;		// used to store output of refinement
	string		f_nassoc;		// (file) normalized association as a function of step
	string 		f_curv;			// (file) curvature as a function of step
	string		f_time;			// (file) time (init/s
	
	string		s_scratch;		// (temp) text for building filenames
	int			timer;			// timer for displaying progress reports 
	bool			timerFlag;		// flag for setting timer
	int			cutstep;			// step at which to record aglomerated network
	
	
	int		max_refinement_steps;	// maximum number of iterations of refinement
	bool		floatWeight;		// are the weights floating point
	int		oneBased;		// are the pairs one based
	int		refineFlag;	// one if refinement is to be done
}; outparameters	ioparm;

// ------------------------------------------------------------------------------------
// ----------------------------------- GLOBAL VARIABLES -------------------------------

char		pauseme;
edge		*e;				// initial adjacency matrix (sparse)
edge		*elist;			// LIST of edges for building adjacency matrix

double 		*deg;			// vector of node degrees
double 		*dSup;			// vector of node degrees of supernodes
double 		*aSupDiag;			// vector of internal weights of supernodes

bool		only_joins;	// if true, no need to do the clustering, just merge from joins

int			refinement_steps;	// number of refinement iterations 

nodenub   *X;				// X matrix
maxheap   *h;				// heap of values from max_i{delta_ij}; each row
double    *NASSOC;			// NASSOC(t); NAssoc as function of algorithm step
double    *a;				// A_i //it means d(i) where i is a cluster
double    *aSup;				// aSup(i) means w(i,i) where i is a cluster





apair	*joins;			// LIST of joins
stub		*c;				// link-lists for communities

int		*part;			//vector to store partition ID of every node
double	*Internal;		// number of edges (weight sum) connected to own community
int numGroups;			// number of groups (set when createPartVector is called)
//nbnode	*nbhd;			// linked LIST of neighborhoods of each node (adjacency matrix)

// B Matrix (used in refinement; refer to the paper)
map<int,double> *mB;

//normalize association and curvature
double *NAssoc;
double *Curv;

enum {NONE};


// ------------------------------------------------------------------------------------
// ----------------------------------- MAIN PROGRAM -----------------------------------
int main(int argc,char * argv[]) {

	time_t t1_main,t2_main,t1_init,t2_init,t1_merge,t2_merge,t1_ref,t2_ref,t1_file,t2_file; //to record times;

	time_t t1_tmp,t2_tmp;
	double no_file_time=0; //store the time without the WRITE operation
		
	only_joins = false;			// by default, do the whole clustering
	
	
	numGroups = 0;
		
	// default values for parameters which may be modified from the commandline
	ioparm.timer     = 20;
	ioparm.fileFlag  = NONE;
	ioparm.textFlag  = 0;
	ioparm.filename  = "community.pairs";
	time_t t1;	t1 = time(&t1);
	time_t t2;	t2 = time(&t2);
	
	ioparm.floatWeight = false;
	ioparm.oneBased = 0;
	
	ioparm.refineFlag = 0;
	ioparm.max_refinement_steps = 100; // default maximum number of iterations
	// ----------------------------------------------------------------------
	// Parse the command line, build filenames and then import the .pairs file
	// cout << "\nGreedy Agglomerative Normalized Cut (GANC).\n";
	// cout << "Copyright (c) 2010 by Seyed Salim Tabatabaei (seyed.s.tabatabaei@mail.mcgill.ca)\n";
	if (parseCommandLine(argc, argv)) {} else { return 0; }
	//cout << "\nImporting: " << ioparm.filename << endl;    // note the input filename
	buildFilenames();								// builds filename strings
	
	// start recording the time excluding the 
	t1_tmp = time(&t1_tmp);
	
	readInputFile();								// gets adjacency matrix data
	
	// ----------------------------------------------------------------------
	// Allocate data structures for main loop
	a     = new double [gparm.maxid]; 	// weighted degrees
	aSup     = new double [gparm.maxid];	// diagonal entries of adjacency matrix
	deg	= new double [gparm.maxid];
	Internal = new double [gparm.maxid];
	
	mB = new map<int,double> [gparm.maxid]; //to relace B and boundaries
	
	NASSOC     = new double [gparm.n+1];
	joins = new apair  [gparm.n+1];
	
	
	NAssoc = new double [gparm.maxid];
	Curv = new double [gparm.maxid];
	
	for (int i=0; i<gparm.maxid; i++) { a[i] = 0.0; aSup[i] = 0; NAssoc[i]=0; Curv[i]=0; deg[i]=0; Internal[i]=0;}
	for (int i=0; i<gparm.n+1;   i++) { NASSOC[i] = 0.0; joins[i].x = 0; joins[i].y = 0; }
	int t = 1;
	if (ioparm.cutstep > 0) { groupListsSetup(); }		// will need to track agglomerations
	
	if(only_joins){
		// cout<<"\n***************\nNot running agglomerative clustering, working on joins file... "<<endl;
		joinsAlone();			// create group lists from joins file
		recordGroupLists();		// record the created group lists
		createPartVector();		// initiate requirements for refinement
		if (ioparm.refineFlag){
			t1 = time(&t1);
			doRefine();			// refine and write the new groups
			t2 = time(&t2);
			// cout<<"Total refinement time: "<<difftime(t2,t1)<<endl;
		}		
		t2_tmp = time(&t2_tmp);
		no_file_time += difftime(t2_tmp,t1_tmp);
		// cout<<"Total flat partitioning time: "<<no_file_time<<endl;
		return 1;
	}
	
	// cout << "\n\nBuilding initial X matrix ..." << endl;
	buildXMatrix();							// builds X[] and h
	// cout << "Initial X matrix built." << endl;
	
	if(!only_joins)
	{
		ofstream fjoins(ioparm.f_joins.c_str(), ios::trunc);
		fjoins << -1 << "\t" << -1 << "\t" << NASSOC[0] << "\t0\n";
		fjoins.close();
	}
	
	// ----------------------------------------------------------------------
	// Start FastCommunity algorithm
	// cout << "\n\nStarting GANC ..." << endl;
	tuple  deltaMax;
	int isupport, jsupport;
	
	
	while (h->heapSize() > 1) {
				
		// ---------------------------------
		// Find largest delta
		if (ioparm.textFlag > 0) { h->printHeapTop10(); cout << endl; }
		deltaMax = h->popMaximum();					// select maximum delta_ij // convention: insert i into j
		
		
		if (deltaMax.m < -4000000000.0) { break; }		// no more joins possible
		
		// ---------------------------------
		// Merge the chosen communities
		if (X[deltaMax.i].v == NULL || X[deltaMax.j].v == NULL) {
			cerr << "WARNING: invalid join (" << deltaMax.i << " " << deltaMax.j << ") found at top of heap\n"; cin >> pauseme;
		}
		isupport = X[deltaMax.i].v->returnNodecount();
		jsupport = X[deltaMax.j].v->returnNodecount();
		if (isupport < jsupport) {
			mergeCommunities(deltaMax.i, deltaMax.j);	// merge community i into community j
			joins[t].x = deltaMax.i;				// record merge of i(x) into j(y)
			joins[t].y = deltaMax.j;				// 
		} else {								// 
			X[deltaMax.i].heap_ptr = X[deltaMax.j].heap_ptr; // take community j's heap pointer
			X[deltaMax.i].heap_ptr->i = deltaMax.i;			//   mark it as i's
			X[deltaMax.i].heap_ptr->j = deltaMax.j;			//   mark it as i's
			mergeCommunities(deltaMax.j, deltaMax.i);	// merge community j into community i
			joins[t].x = deltaMax.j;				// record merge of j(x) into i(y)
			joins[t].y = deltaMax.i;				// 
		}									// 
		NASSOC[t] = deltaMax.m + NASSOC[t-1];					// record NASSOC(t)
		
		// ---------------------------------
		// Record join to file
		//

		t2_tmp = time(&t2_tmp);
		no_file_time += difftime(t2_tmp,t1_tmp);
		
		ofstream fjoins(ioparm.f_joins.c_str(), ios::app);   // open file for writing the next join
		fjoins << joins[t].x-1+ioparm.oneBased << "\t" << joins[t].y-1+ioparm.oneBased << "\t";	// convert to external format
		if ((NASSOC[t] > 0.0 && NASSOC[t] < 0.0000000000001) || (NASSOC[t] < 0.0 && NASSOC[t] > -0.0000000000001))
			{ fjoins << 0.0; } else { fjoins << NASSOC[t]; }
		fjoins << "\t" << t << "\n";
		fjoins.close();

		t1_tmp = time(&t1_tmp);
				
		// ---------------------------------
		// If cutstep valid, then do some work
		if (t <= ioparm.cutstep) { groupListsUpdate(joins[t].x, joins[t].y);}
		if (t == ioparm.cutstep) {
			cerr<<"This should not happen!"<<endl;
			cin.get();
			recordGroupLists();
			createPartVector();
			if (ioparm.refineFlag){
				doRefine();
			}
		}


		
		t++;									// increment time
	} // ------------- end community merging loop

	//cout << "NASSOC["<<t-1<<"] = "<<NASSOC[t-1] << endl;
	// cout << "exited safely" << endl;
	
	t2_tmp = time(&t2_tmp);
	no_file_time += difftime(t2_tmp,t1_tmp);
	
	// cout<<"Total partitioning time: "<<no_file_time<<endl;
	
	recordNAssoc();
	recordCurv(); 
	
	return 1;
}


// ------------------------------------------------------------------------------------ //
// ------------------------------------------------------------------------------------ //
// ------------------------------------------------------------------------------------ //
// FUNCTION DEFINITIONS --------------------------------------------------------------- //

void buildXMatrix() {

	edge   *current;
	
	double aSup_ii,aSup_jj,aSup_ij ;
	

	//initializing the adjacency matrix and neighborhood
		
	for (int i=1; i<gparm.maxid; i++) {				// for each row
		a[i]   = 0.0;								// 
				
		if (e[i].so != 0) {							//    ensure it exists
			current = &e[i];						//    grab first edge
			deg[i]  = 0;							// 
			while (current != NULL) {
				a[i] += double(current->we);				// diagonal entries of adjacency matrix
				deg[i]++;							//	 increment degree count
				current = current->next;				//
			}
		} else { deg[i] = 0; }						// 
	}
	
	// initiating normalized association and self loops
	for (int i=1; i<gparm.maxid; i++) {				// for each row
		aSup[i] = 0.0;
		if (e[i].so != 0) {							//    ensure it exists
			current = &e[i];						//    grab first edge
			while (current != NULL) {
				if (e[i].so == e[i].si){ //self loop
					NASSOC[0] += double(current->we) / a[i];	
					aSup[i] += double(current->we); //self loop
				}
				current = current->next;				//
			}
		} else { NASSOC[0] = -1000; }						// 
	}


	// now we create an empty (ordered) sparse matrix X[]
	X = new nodenub [gparm.maxid];						// initialize X matrix
	for (int i=0; i<gparm.maxid; i++) {					// 
		X[i].heap_ptr = NULL;							// no pointer in the heap at first
		if (e[i].so != 0) { X[i].v = new vektor(2+deg[i]); }
		else {			X[i].v = NULL; }
	}
	h = new maxheap(gparm.n);							// allocate max-heap of size = number of nodes
	
	
	double    deltaTmp;
	tuple	deltaMax;										// for heaping the row maxes
	tuple*    itemaddress;									// stores address of item in maxheap

	for (int i=1; i<gparm.maxid; i++) {
		if (e[i].so != 0) {
			current = &e[i];								// grab first edge
			
			deltaMax.m2 = (double)current->we;
			aSup_ii = aSup[current->so];
			aSup_jj = aSup[current->si];
			aSup_ij = deltaMax.m2;
			
			deltaTmp = (aSup_ii+aSup_jj+2*aSup_ij) / (a[current->so]+a[current->si]) - aSup_ii/a[current->so] - aSup_jj/a[current->si];  /// A_ij = current->we		
						
			deltaMax.m = deltaTmp;									// assume it is maximum so far
			deltaMax.i = current->so;							// store its (row,col)
			deltaMax.j = current->si;							// 
			X[i].v->insertItem(current->si, deltaTmp, deltaMax.m2);				// insert its deltaTmp 
			
			while (current->next != NULL) {					// 
				current = current->next;						// step to next edge
				
				aSup_ii = aSup[current->so];
				aSup_jj = aSup[current->si];
				aSup_ij =	(double)current->we;
				
				deltaTmp = (aSup_ii+aSup_jj+2*aSup_ij) / (a[current->so]+a[current->si]) - aSup_ii/a[current->so] - aSup_jj/a[current->si];  /// A_ij = current->we	
				if (deltaTmp > deltaMax.m) {							// if deltaTmp larger than current max
					deltaMax.m = deltaTmp;							//    replace it as maximum so far
					deltaMax.m2 = current->we;					// entries of adjacency matrix
					deltaMax.i = current->so;
					deltaMax.j = current->si;					//    and store its (col)
				}
				X[i].v->insertItem(current->si, deltaTmp,current->we);			// insert it into vektor[i], also adjacency
			}
			X[i].heap_ptr = h->insertItem(deltaMax);				// store the pointer to its location in heap, for row i, store the maximum in h
		}
	}
	return;
}

// ------------------------------------------------------------------------------------ //
// ------------------------------------------------------------------------------------ //
// ------------------------------------------------------------------------------------ //
// ------------------------------------------------------------------------------------ //
// ------------------------------------------------------------------------------------ //

void buildFilenames() {
	ioparm.f_input   = ioparm.d_in  + ioparm.filename;
	ioparm.f_joins   = ioparm.d_out + ioparm.s_scratch + ".ganc_joins";
	ioparm.f_net     = ioparm.d_out + ioparm.s_scratch + ".wpairs";
	ioparm.f_group   = ioparm.d_out + ioparm.s_scratch + ".groups";
	ioparm.f_group2   = ioparm.d_out + ioparm.s_scratch + ".groups2"; // (refinement output)
	ioparm.f_nassoc	 = ioparm.d_out + ioparm.s_scratch + ".nassoc";
	ioparm.f_curv	 = ioparm.d_out + ioparm.s_scratch + ".curv";
	ioparm.f_time	 = ioparm.d_out + ioparm.s_scratch + ".time";

	
	return;
}


// ------------------------------------------------------------------------------------

void groupListsSetup() {
	
	LIST *newList;
	c = new stub [gparm.maxid];
	for (int i=0; i<gparm.maxid; i++) {
		if (e[i].so != 0) {								// note: internal indexing
			newList = new LIST;							// create new community member
			newList->index = i;							//    with index i
			c[i].members   = newList;					// point ith community at newList
			c[i].size		= 1;							// point ith community at newList
			c[i].last		= newList;					// point last[] at that element too
			c[i].valid	= true;						// mark as valid community
		}
	}
	
	return;
}
// ------------------------------------------------------------------------------------

void groupListsUpdate(const int x, const int y) {
	
	c[y].last->next = c[x].members;				// attach c[y] to end of c[x]
	c[y].last		 = c[x].last;					// update last[] for community y
	c[y].size		 += c[x].size;					// add size of x to size of y
	
	c[x].members   = NULL;						// delete community[x]
	c[x].valid	= false;						// 
	c[x].size		= 0;							// 
	c[x].last		= NULL;						// delete last[] for community x
	
	return;
}

// ------------------------------------------------------------------------------------

void mergeCommunities(int i, int j) {
	
	dpair *LIST, *current, *temp;
	tuple newMax;
	int t = 1;
	
	double nassoc_temp;
 

	LIST    = X[i].v->returnTreeAsList();			// get a LIST of items in X[i].v
	current = LIST;							// store ptr to head of LIST
	
	//first, update the adjacency and degree, then find new delta values
	//update diagonal element of (j,j)
	aSup[j] += aSup[i];
	aSup[i] = 0;
	//update degree of community j
	a[j] += a[i];
	a[i] = 0; //??? make sure not to divide by zero
	//update adjacency matrix
	while (current!=NULL) {	
		//double aSup_jk = X[j].v->findItem(current->x)
		if (current->x != j){ //do a regular update of the adjacency matrix
			X[current->x].v->insertItem(j,0,current->zz); //A_xj
			X[j].v->insertItem(current->x,0,current->zz); //A_jx
		}
		else // if (current->x == j) -- A_jj += A_ii + 2A_ij (first term already added)
			aSup[j] += 2*current->zz;	
		temp    = current;
		current = current->next;						// move to next element in ith row
		delete temp;
		temp = NULL;
	}
	
	
	LIST    = X[j].v->returnTreeAsList();			// get a LIST of items in X[i].v, with new adjacencies
	current = LIST;							// point to the head of the ith row again	
	//update deltas (non-zeros of j)
	while (current!=NULL) {	
			//double aSup_jk = X[j].v->findItem(current->x)
			if (current->x != j && current->x != i){ //j is agglomeration of i&j, so delta_jj is meaningless
				
				nassoc_temp = (aSup[j]+aSup[current->x] + 2*current->zz)/(a[j]+a[current->x]) - aSup[j]/a[j] - aSup[current->x]/a[current->x];
				
				// IT HAS TO BE DONE FOR BOTH OF FOLLOWING 
				X[current->x].v->insertItem(j,nassoc_temp,0); //update jth entry of xth heap. 
				X[j].v->insertItem(current->x,nassoc_temp,0); //update xth entry of jth heap. 
				
				X[current->x].v->deleteItem(i); //remove i from xth heap
				
				newMax = X[current->x].v->returnMaxStored(); //after updating one entry at xth row, update corresponding max
				
				h->updateItem(X[current->x].heap_ptr, newMax); //update heap of rowmax's at x
				
				X[j].v->insertItem(current->x,nassoc_temp,0); //update xth column in jth row as well

			}
			temp    = current;
			current = current->next;						// move to next element in ith row
			delete temp;
			temp = NULL;
	}	
	
	X[j].v->deleteItem(i);	//remove ith entry of jth row
	
	newMax = X[j].v->returnMaxStored(); //find the max at jth row (now that i doesn't exist)
	
	h->updateItem(X[j].heap_ptr, newMax); //update heap of rowmax's at j
	

	
	
	if (ioparm.textFlag>1) { cout << "--> finished merging community "<<i<<" into community "<<j<<" and housekeeping.\n\n"; }
	
	// remove ith community 
	delete X[i].v;							// (step 8)
	X[i].v        = NULL;						// (step 8)
	X[i].heap_ptr = NULL;						//
	
	return;
 
}

// ------------------------------------------------------------------------------------

bool parseCommandLine(int argc,char * argv[]) {
	int argct = 1;
	string temp, ext;
	string::size_type pos;
	char **endptr;
	long along;
	int count; 
	
	if (argc <= 1) { // if no arguments, return statement about program usage.
		cout << "\nThis program is the implementation of Greedy Agglomerative Normalized Cut (GANC)\n"
			 << "by Seyed Salim Tabatabaei, Mark Coates, and Michael Rabbat. The source code of \n"
			 << "Clauset, Newman, and Moore is reused and modified for the implementation of \n"
			 << "the first step of GANC (the agglomerative hierarchical clustering procedure). \n"
			 << "\nThe input file can either be an unweighted or a weighted graph. Every line of\n"
			 << "the input file consists of \"u v i\" for a weighted graph; it means w(u,v)=i\n"
			 << "and \"u v\" for an unweighted graph; it means w(u,v)=1.\n"
			 << "\nIf the node numbers of the input file start from 1, use \'--one-based\'.\n"
			 << "\nIf the edge weights are small and non-integer, use \'--float-weight\'.\n"
			 << "\nDO NOT use \'-c\' when running the algorithm for the first time on a graph;\n"
			 << "after selecting k from the curvature plot or any other way, use \'-c n<minus>k\'\n"
			 << "and optionally \'--refine\' to obtain a refined flat clustering to k groups.\n\n";
		cout << "USAGE EXAMPLE:"<<endl;
		cout << "  ./ganc -f network.[w]pairs [--one-based] [-c 1232997] [--float-weight] [--refine]\n";
		cout << "\n";
		return false;
	}

	while (argct < argc) {
		temp = argv[argct];
		if (temp == "-f") {			// input file name
			argct++;
			temp = argv[argct];
			ext = ".pairs";
			pos = temp.find(ext,0);
			if (pos == string::npos){
				ext = ".wpairs";
				pos = temp.find(ext,0);
				if (pos == string::npos) { cout << " Error: Input file must have terminating .pairs or .wpairs extension.\n"; return false; }
			}
			
			ext = "/";
			count = 0; pos = string::npos;
			for (int i=0; i < temp.size(); i++) { if (temp[i] == '/') { pos = i; } }
			if (pos == string::npos) {
				ioparm.d_in = "";
				ioparm.filename = temp;
			} else {
				ioparm.d_in = temp.substr(0, pos+1);
				ioparm.filename = temp.substr(pos+1,temp.size()-pos-1);
			}
			ioparm.d_out = ioparm.d_in;
			// now grab the filename sans extension for building outputs files
			for (int i=0; i < ioparm.filename.size(); i++) { if (ioparm.filename[i] == '.') { pos = i; } }
			ioparm.s_scratch = ioparm.filename.substr(0,pos);
		} else if (temp == "-t") {	// timer value
			argct++;
			if (argct < argc) {
				along = strtol(argv[argct],endptr,10);
				ioparm.timer = atoi(argv[argct]);
				// cout << ioparm.timer << endl;
				if (ioparm.timer == 0 || strlen(argv[argct]) > temp.length()) {
					// cout << " Warning: malformed modifier for -t; using default.\n"; argct--;
					ioparm.timer = 20;
				} 
			} else {
				// cout << " Warning: missing modifier for -t argument; using default.\n"; argct--;
			}
		} else if (temp == "-c") {	// cut value
			argct++;
			if (argct < argc) {
//				along = strtol(argv[argct],endptr,10);
				ioparm.cutstep = atoi(argv[argct]);
				only_joins = true;
				if (ioparm.cutstep == 0) {
					// cout << " Warning: malformed modifier for -c; disabling output.\n"; argct--;
				} 
			} else {
				// cout << " Warning: missing modifier for -c argument; using default.\n"; argct--;
			}
		}
		
		else if (temp == "-maxiter") {	// maximum number of iterations for the refinement
					argct++;
					if (argct < argc) {
		//				along = strtol(argv[argct],endptr,10);
						if (atoi(argv[argct]) <= 0) {
							// cout << " Warning: malformed modifier for -maxiter; using default.\n"; argct--;
						} 
						else ioparm.max_refinement_steps = atoi(argv[argct]);
					} else {
						// cout << " Warning: missing modifier for -maxiter argument; using default.\n"; argct--;
					}
				}
		
		else if (temp == "--float-weight")	{ioparm.floatWeight = true; }
		else if (temp == "--one-based"){ioparm.oneBased = 1; }		

		else if (temp == "--refine" ){ioparm.refineFlag = 1; }
		
		else if (temp == "-v")		{    ioparm.textFlag = 1;		}
		else if (temp == "--v")		{    ioparm.textFlag = 2;		}
		else if (temp == "---v")		{    ioparm.textFlag = 3;		}
		else {  cout << "Unknown commandline argument: " << argv[argct] << endl; }
		argct++;
	}
		
	return true;
}

// ------------------------------------------------------------------------------------

void readInputFile() {
	
	// temporary variables for this function
	int numnodes = 0;
	int numlinks = 0;
	int s,f,t,w;
	edge **last;
	edge *newedge;
	edge *current;								// pointer for checking edge existence
	bool existsFlag;							// flag for edge existence
	time_t t1; t1 = time(&t1);
	time_t t2; t2 = time(&t2);
	
	// First scan through the input file to discover the largest node id. We need to
	// do this so that we can allocate a properly sized array for the sparse matrix
	// representation.
	// cout << " scanning input file for basic information." << endl;
	// cout << "  edgecount: [0]"<<endl;
	ifstream fscan(ioparm.f_input.c_str(), ios::in);

	char slmtemp[1024];
		
	while (fscan.getline(slmtemp,60,'\n')) {				// read friendship pair (s,f)
		char* pch = strtok (slmtemp," ,\t");
		s = atoi(pch) - ioparm.oneBased;
		pch = strtok (NULL," ,\t");
		f = atoi(pch) - ioparm.oneBased;

		numlinks++;							// count number of edges
		if (f == s) continue;
		if (f < s) { t = s; s = f; f = t; }		// guarantee s < f
		if (f > numnodes) { numnodes = f; }		// track largest node index

		if (t2-t1>ioparm.timer) {				// check timer; if necessarsy, display
			// cout << "  edgecount: ["<<numlinks<<"]"<<endl;
			t1 = t2;							// 
			ioparm.timerFlag = true;				// 
		}									// 
		t2=time(&t2);							// 
		
	}

	fscan.close();
	// cout << "  edgecount: ["<<numlinks<<"] total (first pass)"<<endl;
	
	
	gparm.maxid = numnodes+2;					// store maximum index
	elist = new edge [2*numlinks];				// create requisite number of edges
	int ecounter = 0;							// index of next edge of elist to be used

	// Now that we know numnodes, we can allocate the space for the sparse matrix, and
	// then reparse the file, adding edges as necessary.
	// cout << " allocating space for network." << endl;
	e        = new  edge [gparm.maxid];			// (unordered) sparse adjacency matrix
	last     = new edge* [gparm.maxid];			// LIST of pointers to the last edge in each row
	numnodes = 0;								// numnodes now counts number of actual used node ids
	numlinks = 0;								// numlinks now counts number of bi-directional edges created
	int totweight = 0;							// counts total weight of undirected network
	ioparm.timerFlag = false;					// reset timer
	
	// cout << " reparsing the input file to build network data structure." << endl;
	// cout << "  edgecount: [0]"<<endl;
	ifstream fin(ioparm.f_input.c_str(), ios::in);


	while(fin.getline(slmtemp,60,'\n')) {
		char* pch = strtok (slmtemp," ,\t");
		s = atoi(pch);// - ioparm.oneBased;
		pch = strtok (NULL," ,\t");
		f = atoi(pch);// - ioparm.oneBased;
		pch = strtok (NULL," ,\t");
		if(pch != NULL)
			if(!ioparm.floatWeight)
				w = atof(pch);
			else
				w = 10000*atof(pch);
		else w = 1;

		if (!ioparm.oneBased)
			{s++; f++;}								// increment s,f to prevent using e[0]
		if (f == s) continue;
		if (f < s) { t = s; s = f; f = t; }		// guarantee s < f
		numlinks++;							// increment link count (preemptive)
		if (e[s].so == 0) {						// if first edge with s, add s and (s,f)
			e[s].so = s;						// 
			e[s].si = f;						// 
			e[s].we = w;						// 
			last[s] = &e[s];					//    point last[s] at self
			numnodes++;						//    increment node count
			totweight += w;					//	 increment weight total
		} else {								//    try to add (s,f) to s-edgelist
			current = &e[s];					// 
			existsFlag = false;					// 
			while (current != NULL) {			// check if (s,f) already in edgelist
				if (current->si==f) {			// 
					existsFlag = true;			//    link already exists
					numlinks--;				//    adjust link-count downward
					break;					// 
				}							// 
				current = current->next;			//    look at next edge
			}								// 
			if (!existsFlag) {					// if not already exists, append it
				newedge = &elist[ecounter++];		//    grab next-free-edge
				newedge -> so = s;				// 
				newedge -> si = f;				// 
				newedge -> we = w;
				totweight += w;				//	 increment weight total
				last[s] -> next = newedge;		//    append newedge to [s]'s LIST
				last[s]         = newedge;		//    point last[s] to newedge
			}								// 
		}									// 
		
		if (e[f].so == 0) {						// if first edge with f, add f and (f,s)
			e[f].so = f;						// 
			e[f].si = s;						// 
			e[f].we = w;						// 
			last[f] = &e[f];					//    point last[s] at self
			numnodes++;						//    increment node count
			totweight += w;					//	 increment weight total
		} else {								// try to add (f,s) to f-edgelist
			if (!existsFlag) {					//    if (s,f) wasn't in s-edgelist, then
				newedge = &elist[ecounter++];		//       (f,s) not in f-edgelist
				newedge -> so = f;				// 
				newedge -> si = s;				//
				newedge -> we = w;				// 
				totweight += w;				//	 increment weight total
				last[f] -> next = newedge;		//    append newedge to [f]'s LIST
				last[f]		 = newedge;		//    point last[f] to newedge
			}								// 
		}									
		existsFlag = false;						// reset existsFlag
		if (t2-t1>ioparm.timer) {				// check timer; if necessarsy, display
			// cout << "  edgecount: ["<<numlinks<<"]"<<endl;
			t1 = t2;							// 
			ioparm.timerFlag = true;				// 
		}									// 
		t2=time(&t2);							// 
		
	}
	totweight = totweight / 2;					// fix double counting from bi-directed edges
											// (tip to Kimberly Glass for pointing this out)
	// cout << "  edgecount: ["<<numlinks<<"] total (second pass)"<<endl;
	// cout << "  totweight: ["<<totweight<<"]"<<endl;
	fin.close();
	

	gparm.m = numlinks;							// store actual number of edges created
	gparm.n = numnodes;							// store actual number of nodes used
	gparm.w = totweight;						// store actual total weight of edges
	return;
}

// ------------------------------------------------------------------------------------
// create partition vector and return the number of groups
void createPartVector() 
{
	numGroups = gparm.maxid - ioparm.cutstep - 1;
	// cout<<"NumGroups "<<numGroups<<endl;
	
	part = new int [gparm.maxid];
	dSup = new double [numGroups+1];
	aSupDiag = new double [numGroups+1];

	for (int i=0; i<numGroups+1; i++){
		dSup[i]=0;
		aSupDiag[i]=0;
	}	
	
		
	LIST *current;

	int gid = 1;
	
	
	part[0] = 0;
	aSupDiag[0] = 0;
	for (int i=0; i<gparm.maxid; i++) {
		if (c[i].valid) {
			current = c[i].members;
			while (current != NULL) {
				part[current->index] = gid;				
				current = current->next;				
			}
			gid ++;
		}
	}

	
	edge* currentEdge;
	for (int i=1; i<gparm.maxid; i++){
		a[i] = 0;
		if (e[i].so != 0) {							//    ensure it exists
			currentEdge = &e[i];					//    grab first edge
			deg[i]  = 0;		
			while (currentEdge != NULL) {
				deg[i]++;
				if (part[currentEdge->si] == part[i]){
					aSupDiag[part[i]] += currentEdge->we;
				}
				a[i] += (double)currentEdge->we;
				currentEdge = currentEdge->next;
			}
		}
		else {deg[i]=0;}
	}
	
	for (int i=0; i<gparm.maxid; i++) {
		dSup[part[i]] += a[i];
	}
	return ;
}

// ------------------------------------------------------------------------------------
// records the agglomerated LIST of indices for each valid community 

void recordGroupLists() {

	LIST *current;
	
	ofstream fgroup(ioparm.f_group.c_str(), ios::trunc);
	for (int i=0; i<gparm.maxid; i++) {
		if (c[i].valid) {
			fgroup<<-1+ioparm.oneBased<<endl;
			current = c[i].members;
			while (current != NULL) {
				fgroup << current->index-1+ioparm.oneBased<< "\n";
				current = current->next;				
			}
		}
	}
	fgroup.close();
	
	
	
	return;
}


// ------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------

void recordNAssoc() 
{
	// cout<<"Recording NAssoc to "<<ioparm.f_nassoc.c_str()<<endl;
	ofstream outfile(ioparm.f_nassoc.c_str(),ios::trunc);
	for (int i=0; i<gparm.maxid-1; i++) {
		NAssoc[i] = NASSOC[gparm.maxid-i-2];
		outfile<<i+1<<'\t'<<NASSOC[gparm.maxid-i-2]<<endl;
	}
}

void recordCurv()
{
	Curv[0]=0;
	ofstream outfile(ioparm.f_curv.c_str(),ios::trunc);
	for (int i=1; i<gparm.maxid-2; i++) {
		Curv[i]=-NAssoc[i-1] + 2*NAssoc[i] - NAssoc[i+1];
	}
	
	for (int i=0; i<gparm.maxid-1; i++) {
		outfile<<i+1<<'\t'<<Curv[i]<<endl;
	}
}



void doRefine()
{	
	
	/*********************** NOTE *****************************/
		// instead of comparing mB's to 0, one might need to compare to 
		// a very small value instead for round-off errors of doubles
		
	
	
	// cout<<"Refining the results ..."<<endl;
	edge *current;
	refinement_steps = 0;
	
	double NAssoc = NASSOC[ioparm.cutstep]; // old value of normalized association 
	double pass_improvement; // improvement in one pass
	double total_improvement; //total improvement of refinement
		
	
	total_improvement = 0; 	// Nassoc improvement

	map<int,double>::iterator tmpit;
	
	for (int i=1; i<gparm.maxid; i++){
		if (e[i].so != 0) {							//    ensure it exists
			current = &e[i];						//    grab first edge
			while (current != NULL) {
				if (part[current->si] == part[i]){
					Internal[i] += (double)current->we;
				}
				else{ 
					tmpit = mB[i].find(part[current->si]); // k log(k) at worst (sum_1^k log sum_1^k)
					if(tmpit == mB[i].end()) // this element does not exist
					{
						tmpit = mB[i].insert(tmpit,pair<int,double>(part[current->si],(double)current->we)); //insert to the end of map; in general log(k), amortized constant if inserted right after tmpit
					}
					else
					{
						(*tmpit).second += (double)current->we; //update
					}

				}
				current = current->next;
			}
		} 
		else
		{
			// cout<<"This should not happen";
			cin.get();
		}

	}	

	while(true)	{
		if (refinement_steps >= ioparm.max_refinement_steps){ //stop if the maximum iterations reached
			// cout<<"The maximum refinement iterations reached."<<endl;
			break;
		}

	 	// NOW START NODE BY NODE

		double max_delta;
		map<int,double>::iterator max_iter;
		double temp_delta;
		
		pass_improvement = 0;
						
		int i;
		for (i=1;i<gparm.maxid; i++)
		{
			if(mB[i].empty()) continue;
			
							
			map<int,double>::iterator iter=mB[i].begin();
			max_iter = iter;
			
			if(dSup[part[i]]-a[i] == 0){
				// cout<<"WARNING: skipped moving node #"<<i<<" which empties cluster #"<<part[i]<<"."<<endl;
				continue;
			}
				
			
			max_delta = (aSupDiag[part[i]] - 2*Internal[i]) / (dSup[part[i]]-a[i]) + (aSupDiag[(*iter).first] + 2*(*iter).second) / (dSup[(*iter).first]+a[i]) - (aSupDiag[part[i]]/dSup[part[i]] + aSupDiag[(*iter).first]/dSup[(*iter).first]);


			for(++iter; iter != mB[i].end(); ++iter) { //find maximum possible improvement for node i
				temp_delta = (aSupDiag[part[i]] - 2*Internal[i]) / (dSup[part[i]]-a[i]) + (aSupDiag[(*iter).first] + 2*(*iter).second) / (dSup[(*iter).first]+a[i]) - (aSupDiag[part[i]]/dSup[part[i]] + aSupDiag[(*iter).first]/dSup[(*iter).first]);
								
				if(temp_delta>max_delta){
					max_delta = temp_delta;
					max_iter = iter;
				}
			}
			
			if (max_delta<=0) continue; //no improvement or negative improvement
			dSup[part[i]] -= a[i];
			dSup[(*max_iter).first] += a[i];
			aSupDiag[part[i]] -= (2*Internal[i]);
			aSupDiag[(*max_iter).first] += (2*(*max_iter).second);		
			
			map<int,double>::iterator tmpiter;
			
			current = &e[i];						//    grab first edge
			//	Update neighbors 
			while (current != NULL) {
				if (part[current->si] == (*max_iter).first){ 			// this neighbor is in the new community
					Internal[current->si] += current->we; 	// the old boundary edges for this neighbor to i, are now part of the internal edges
					tmpiter = mB[current->si].find(part[i]);	//log(size)
					(*tmpiter).second -= current->we;	// the boundary edges from i to this neighbor are reduced now
					if ((*tmpiter).second == 0) 		// this neighbor is no more in boundary of old cluster of i
						mB[current->si].erase(tmpiter);	// log(|boundaries[current->si]|)
				}
				else if (part[current->si] == part[i]){ 	// this neighbor is in the old community
					Internal[current->si] -= current->we; 	// the old internal edges for this neighbor to i, are now part of the boundary edges
					tmpiter = mB[current->si].find((*max_iter).first);
					if(tmpiter == mB[current->si].end()) 		// this neighbor was not in boundary to the current 
						tmpiter = mB[current->si].insert(tmpiter,pair<int,double>((*max_iter).first,0)); // allocate an entry for old community
					(*tmpiter).second += current->we;	// the boundary edges from i to this neighbor is added to the total weight of edges connecting this neighbor to new cluster of i
				}
				else{ // this neighbor is in neither communities
					tmpiter = mB[current->si].find(part[i]);
					(*tmpiter).second -= current->we;		// weight of boundary edges from this neighbor to old community of i, via i, is reduced
					if ((*tmpiter).second == 0) // no more connection to old community of i to this neighbor
						mB[current->si].erase(tmpiter);
					tmpiter = mB[current->si].find((*max_iter).first);
					if(tmpiter == mB[current->si].end()) 		// this neighbor was not in boundary to the current 
						tmpiter = mB[current->si].insert(tmpiter,pair<int,double>((*max_iter).first,0)); // allocate an entry for old community
					(*tmpiter).second += current->we;	// weight of boundary edges from this neighbor to new community of i, via i, is increased
				}
				current = current->next;					
			}
			
			mB[i].insert(pair<int,double>(part[i],Internal[i]));	// sumweight of edges connecting i to its old cluster 
			Internal[i] = (*max_iter).second;				// sumweight of edges connecting i to nodes in its new cluster
	
			(*max_iter).second = 0; //not necessary!
			
			part[i] = (*max_iter).first;
			mB[i].erase(max_iter);
			
			pass_improvement += max_delta;
		} // for all nodes
		refinement_steps++;
		// cout << "Improvement of pass "<<refinement_steps<< ": "<<pass_improvement<<endl;
		if (pass_improvement <= 1e-10) break;
		total_improvement += pass_improvement;			
	} // do

	// cout << "Accumulated improvement: "<<total_improvement<<" (from "<<NAssoc<<" to "<<NAssoc + total_improvement<<")"<<endl;
	

	NAssoc += total_improvement;
	
	// cout<<"Recording groups after refinement to "<<ioparm.f_group2.c_str()<<endl;
	ofstream outfile(ioparm.f_group2.c_str(),ios::trunc);
	for (int i=1; i<gparm.maxid; i++){
		outfile<<i<<'\t'<<part[i]<<endl;
	}
	// cout<<"====================="<<endl;
}

void joinsAlone()
{
	// cout<<"Reading the joins file (assuming it exists!) "<<ioparm.f_joins<<endl;
	//read the joins file
	ifstream infile(ioparm.f_joins.c_str(),ios::in);
	int tmp1,tmp2,tmp4;
	double tmp3;
	infile >> tmp1 >> tmp2 >> tmp3 >> tmp4; //ignore first line
	int current_cut = 0;
	while(infile >> tmp1 >> tmp2 >> tmp3 >> tmp4){
		groupListsUpdate(tmp1,tmp2); //update groups
		NASSOC[tmp4]=tmp3;
		if (++current_cut >= ioparm.cutstep) break;
	}
	// cout<<"Joins file read successfully."<<endl;
	infile.close();
	
}
