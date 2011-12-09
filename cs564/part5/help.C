#include <sys/types.h>
#include <functional>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
using namespace std;

#include "error.h"
#include "utility.h"
#include "catalog.h"

// define if debug output wanted


//
// Retrieves and prints information from the catalogs about the for
// the user. If no relation is given (relation.empty() is true), then
// it lists all the relations in the database, along with the width in
// bytes of the relation, the number of attributes in the relation,
// and the number of attributes that are indexed.  If a relation is
// given, then it lists all of the attributes of the relation, as well
// as its type, length, and offset, whether it's indexed or not, and
// its index number.
//
// Returns:
// 	OK on success
// 	error code otherwise
//

const Status RelCatalog::help(const string & relation)
{
	Status status = OK;
	RelDesc rd;
	AttrDesc *attrs;
	int attrCnt;
	
	if (relation.empty()) return UT_Print(RELCATNAME);
	
	while (status == OK)
	{
		status = getInfo(relation, rd);
		status = attrCat->getRelInfo(relation, attrCnt, attrs);
		break;
	}
	if (status != OK) 
	{
		cout<<"PROBLEM!"<<endl;
		cout<<status<<endl;
		return status;
	}
	// Print all the available attributes
	cout << "Relation name: " << rd.relName << " (" << rd.attrCnt << " attributes)" << endl;
	cout << "  Attribute name   Off   T   Len   I" << endl << endl;
	for (int i = 0; i < rd.attrCnt; i++)
	{
		cout << attrs[i].attrName;
		cout << attrs[i].attrOffset;
		if (attrs[i].attrType == FLOAT)
		{
			cout << " f ";
		}
		else if (attrs[i].attrType == INTEGER)
		{
			cout << " i ";
		}
		else if (attrs[i].attrType == STRING)
		{ 
			cout << " s ";
		}
		cout << attrs[i].attrLen <<endl;
	}

	return status;
}
