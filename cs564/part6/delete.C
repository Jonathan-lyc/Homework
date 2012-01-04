/*
User1: Josh Day
username1: day
studentid1: 9040529886
User2: Josh Gachnang
username: gachnang
studentid2: 9040440803

Delete.c provides a function to remove relations through a query.
*/

#include "catalog.h"
#include "query.h"
#include <stdlib.h>
#include <stdio.h>

/*
 * Deletes records from a specified relation.
 *
 * Returns:
 * 	OK on success
 * 	an error code otherwise
 */
const Status QU_Delete(const string & relation,
                       const string & attrName,
                       const Operator op,
                       const Datatype type,
                       const char *attrValue) {
              
	Status status = OK;
	RID rid;
	Record rec;
	AttrDesc attrInfo;

	const char *filter;
	// Convert the attrValue to a string.
	if (type == INTEGER)
	{
		int val = atoi(attrValue);
		filter = (char *)&val;
	}
	else if (type == FLOAT)
	{
		int val = atof(attrValue);
		filter = (char *)&val;
	}
	else
	{
		filter = attrValue;
	}
	// Get a heap file scanner, then the info for the relation we're deleting.
	HeapFileScan hfs(relation, status);
	
	status = attrCat->getInfo(relation, attrName, attrInfo);
	if (status != OK) 
	{
		return status;
	}
	
	status = hfs.startScan(attrInfo.attrOffset, attrInfo.attrLen, type, filter, op);
	if (status != OK)
	{
		return status;
	}
	// Find the record, and delete it.
	while ((hfs.scanNext(rid)) == OK) 
	{
		status = hfs.getRecord(rec);
		if (status != OK)
		{
			return status;
		}
		
		status = hfs.deleteRecord();
		if (status != OK) 
		{
			return status;
		}
	}   
   
	return status;
}