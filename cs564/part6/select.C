/*
User1: Josh Day
username1: day
studentid1: 9040529886
User2: Josh Gachnang
username: gachnang
studentid2: 9040440803

Select.c provides a function to scan the DB for all relations matching a 
filter.
*/
#include "catalog.h"
#include "query.h"
#include <stdlib.h>
#include <stdio.h>

//forward declaration
const Status ScanSelect(const string & result, 
			const int projCnt, 
			const AttrDesc projNames[],
			const AttrDesc *attrDesc, 
			const Operator op, 
			const char *filter,
			const int reclen);

const Status QU_Select(const string & result, 
                       const int projCnt, 
                       const attrInfo projNames[],
                       const attrInfo *attr, 
                       const Operator op, 
                       const char *attrValue)
{
    cout << "Doing QU_Select " << endl;

	Status status;
	AttrDesc attrDesc;
	const char *filter;


	AttrDesc* projs = new AttrDesc[projCnt];
	// Get info for all given projections
	for (int i = 0; i < projCnt; i++)
	{
		status = attrCat->getInfo(projNames[i].relName, projNames[i].attrName, projs[i]);
		if (status != OK)
		{
			return status;
		}
	}

    if (attr != NULL) 
	{
		status = attrCat-> getInfo(attr->relName, attr->attrName, attrDesc);
		if (status != OK)
		{
			return status;
		}
	}

    int reclen = 0;
    for (int i = 0; i < projCnt; i++)
	{
            reclen += projs[i].attrLen;
    }

	// Get attrType as a string
	int type = attrDesc.attrType;
	if (type == INTEGER)
	{
		int val = atoi(attrValue);
		filter = (char *)&val;
	}
	else if (type == FLOAT)
	{
		float val = atof(attrValue);
		filter = (char *)&val;
	}
	else
	{
		filter = attrValue;
	}
	return ScanSelect(result, projCnt, projs, &attrDesc, op, filter, reclen);


}


const Status ScanSelect(const string & result, 
                        const int projCnt, 
                        const AttrDesc projNames[],
                        const AttrDesc *attrDesc, 
                        const Operator op, 
                        const char *filter,
                        const int reclen)
{
    cout << "Doing HeapFileScan Selection using ScanSelect()" << endl;

	Status status;
	RID rid;
	Record outputRec;
	Record rec;
	
	// See if the relation is already in the DB
    InsertFileScan resultRel(result, status);
    if (status != OK) 
	{
		return status;
	}
	
	outputRec.data = (char*) malloc(reclen);
	outputRec.length = reclen;

	// Prepare to scan the heap!
	HeapFileScan hfs(projNames->relName, status);

	status = hfs.startScan(attrDesc->attrOffset, attrDesc->attrLen, (Datatype)attrDesc->attrType, filter, op);
	if (status != OK)
	{
		return status;
	}

	// Scan for all the records we need.
	while (hfs.scanNext(rid) == OK)
	{
		status = hfs.getRecord(rec);
		if (status != OK)
		{
			return status;
		}
		
		int off = 0;
		for (int i = 0; i < projCnt; i++)
		{
			memcpy((char *)outputRec.data + off, (char *)rec.data + projNames[i].attrOffset, projNames[i].attrLen);
			off = off + projNames[i].attrLen;
		}
		RID output;
		status = resultRel.insertRecord(outputRec,output);
	}
	return status;
}