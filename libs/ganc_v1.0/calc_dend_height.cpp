// Author: Salim
// Date: Aug 22, 2010
// Given .ganc_joins or .joins, returns the height of the dendrogram
#include<iostream>
#include<map>
#include<fstream>
#include<string>
using namespace std;
int main(int argc, char* argv[])
{
	if (argc!=2){
		cout << "Usage: ./calc_dend_height filename.[ganc_]joins"<<endl;
		return 1;
	}
	map<int,int> mmap;
	map<int,int>::iterator it1;
	map<int,int>::iterator it2;
	
	ifstream infile(argv[1],ios::in);
	string outfname = string(argv[1]) + ".dendheight";
	ofstream outfile(outfname.c_str(),ios::out);
	cout<<"Saving to "<<outfname<<endl;
	int tmp1,tmp2,tmp4;
	double tmp3;
	
	infile >> tmp1 >> tmp2 >> tmp3 >> tmp4; //ignore first line
	while(infile >> tmp1 >> tmp2 >> tmp3 >> tmp4){
		it1 = mmap.find(tmp1);
		it2 = mmap.find(tmp2);
		
		// j exists
		if (it2!=mmap.end()) {//j exists
			if (it1==mmap.end()) //if i doesn't exist
				it2->second ++; //increment height
			if (it1!=mmap.end()){ //if i exists
				if(it1->second>it2->second) //i is higher
					it2->second = it1->second+1; 
				else it2->second ++;
				mmap.erase(it1);
			}
			continue;
		}
		
		// j doesn't exist
		if(it1 == mmap.end()){ // i doesn't exist as well
			mmap.insert(pair<int,int>(tmp2,1));
			continue;
		}
		
		// j doesn't exist, but i exists
		mmap.insert(pair<int,int>(tmp2,(it1->second)+1));
		mmap.erase(it1);
	}

	cout<<"mmap contents: "<<endl;
	for (map<int,int>::iterator it = mmap.begin();it!=mmap.end();it++) cout<<it->first<<"\t"<<it->second<<endl;
	cout<<endl;
	
	map<int,int>::iterator it = mmap.begin();
	int max = it->second;
	for (++it;it!=mmap.end();it++) {
		if(it->second>max)
			max = it->second;
		max++;
	}
	cout<<"Height of the dendrogram: "<<max<<endl;
	outfile<<max;
	outfile.close();
	infile.close();
	return 0;
	
}
