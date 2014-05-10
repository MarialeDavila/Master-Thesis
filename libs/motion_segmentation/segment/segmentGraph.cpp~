/*
 * Written by Juan Carlos Niebles
 *
 */

#include "mex.h"
#include "segment-graph.h"

/* Input Arguments */
#define edge_links_IN	prhs[0]
#define edge_weights_IN	prhs[1]

/* Output Arguments */
#define memberships_OUT plhs[0]

void mexFunction(int nlhs,mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
        //double *XpDen;

        /* Check for proper number of arguments */
        if (nrhs !=2)
            mexErrMsgTxt("usage: memberships = segmentGraph(edge_links, edge_weights)");
        if (nlhs !=1)
            mexErrMsgTxt("usage: memberships = segmentGraph(edge_links, edge_weights)");

        if (!mxIsInt32(edge_links_IN)) {
            mexErrMsgTxt("edge_links must be of type int32.");
        }
        if (!mxIsSingle(edge_weights_IN)) {
            mexErrMsgTxt("edge_weights must be of type single.");
        }
        
        mwSize edge_links_ndims = mxGetNumberOfDimensions(edge_links_IN);
        const mwSize *edge_links_dimensions = mxGetDimensions(edge_links_IN);
        
        mwSize edge_weights_ndims = mxGetNumberOfDimensions(edge_weights_IN);        
        const mwSize *edge_weights_dimensions = mxGetDimensions(edge_weights_IN);
        
        if (edge_links_ndims != 2 || edge_weights_ndims != 2) {
            mexErrMsgTxt("inputs must be 2 dimensional matrices.");
        }
        if (edge_weights_dimensions[1] != 1)
            mexErrMsgTxt("edge_weights must be of size Nx1.");
        if (edge_links_dimensions[1] != 2)
            mexErrMsgTxt("edge_links must be of size Nx2.");
        
        if (edge_weights_dimensions[0] != edge_links_dimensions[0]) {
            mexErrMsgTxt("inputs must have the same number of rows.");
        }
        
        // Get number of edges and pointers to links and weights.
        mwSize number_edges = edge_weights_dimensions[0];
        int *edge_links = (int *) mxGetData(edge_links_IN);
        float *edge_weights = (float *) mxGetData(edge_weights_IN);
        
        // Create data structure and populate it.
        edge *edges = new edge[number_edges];
        mwSize number_nodes = -1;
        for (mwSize i = 0; i < number_edges; i++) {
            // Store edge link. We assume one-based indices
            edges[i].a = edge_links[i] - 1;
            edges[i].b = edge_links[i + number_edges] - 1;
            // Store edge weight.
            edges[i].w = edge_weights[i];
            // Count nodes. We assume one-based indices.
            if (edge_links[i] > number_nodes)
                number_nodes = edge_links[i];
            if (edge_links[i + number_edges] > number_nodes)
                number_nodes = edge_links[i + number_edges];
        }
        // Segment graph.
        // TODO: Get parameter as input argument.
        universe *u = segment_graph(number_nodes, number_edges, edges, 0.5);
        // Output result.
        memberships_OUT = mxCreateDoubleMatrix(number_nodes, 1, mxREAL);
        double *membership = mxGetPr(memberships_OUT);
        for (mwSize i = 0; i < number_nodes; i++) {
            membership[i] = u->find(i) + 1;
        }
}

