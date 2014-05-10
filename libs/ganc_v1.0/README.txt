-------------
LIST OF FILES
-------------
ganc.cpp			greedy agglomerative normalized cut (the main program)
maxheap.h			implementation of max-heap
vektor.h			a pair of datastructures (red-black balanced binary tree and max-heap) whose elements are linked
Makefile			used to compile ganc	
gpl.txt				a copy of the GNU General Public License
example_networks(Dir)		includes few example networks
calc_dend_height.cpp		an auxilary file to calculate the height of a dendrogram (not part of ganc)
simple_matlab_interface.m	a simple Matlab interface script 

-----------------------------------
GREEDY AGGLOMERATIVE NORMALIZED CUT
-----------------------------------
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
 
You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

See http://www.gnu.org/licenses/gpl.txt for more details.


The source code of Clauset et al. (A. Clauset, M. Newman, C. Moore, Finding community structure in very
large networks, Phys. Rev. E 70 (6) (2004) 66111.) is reused and modified for the implementation of 
the first step of GANC (the agglomerative hierarchical clustering procedure). 
Their code can be downloaded from here: http://www.cs.unm.edu/~aaron/research/fastmodularity.htm

----------
HOW TO USE
----------
To compile: type "make" in shell. The code is compiled on Ubuntu 9.10 and 10.04 using g++ 4.4.3 with no errors. 
Compilation on Mac OS X is expected to be without errors.  

The input file can either be an unweighted (ended with .pairs) or a weighted (ended with .wpairs) graph. Every line of the input file consists of "u v i" for a weighted graph; it means w(u,v)=i, and "u v" for an unweighted graph; it means w(u,v)=1.

Description of commandline arguments
-f <filename>    	give the target .[w]pairs file to be processed
-c <int>		record the aglomerated network at step <int>
--one-based 		used when the .[w]pairs file has node ids starting from 1
--refine		perform post-processing of the clusters 
-maxiter <+int>		indicates the maximum iterations of the refinement step
--float-weight		increase weights to avoid possible underflow (mutiply by 10,000)

Important Notes:
* Make sure no node number is missing; e.g., if node 3 exists, then nodes 1 and 2 must exist. 
* DO NOT use '-c' when running the algorithm for the first time on a graph.
* After selecting k from the curvature plot or any other way, use '-c n<minus>k'
  and optionally '--refine' to obtain a [refined] flat clustering to k groups.
* For large graphs curvature(k=2) might be artificially large due to propagated
  errors from previous steps of the agglomeration and the fact that NAssoc(1) is
  always 1. We usually ignore it for large graphs. 

USAGE EXAMPLE:
  ./ganc -f network.[w]pairs [--one-based] [-c 1232997] [--float-weight] [--refine]

GENERATED FILE:
network.nassoc: <k nassoc(k)> pairs
network.curv: <k curvature(k)> pairs
network.ganc_joins: <i j> pairs, where i and j are clusters 
network.groups: unrefined groups for a specified value of k in a 0-separated format for a one-based input, and -1-separated format for a zero-based input
network.groups2: refined groups for a specified value of k; <v,c(v)> pairs 

-----------------------------
CALCULATING DENDROGRAM HEIGHT
-----------------------------
If this function is required, compile calc_dend_height.cpp manually.
file.ganc_joins is assumed to exist (run ganc without -c option to obtain it)
Usage example: ./calc_dend_height network.ganc_joins
The dendrogram height is then stored in file.ganc_joins.dendheight
